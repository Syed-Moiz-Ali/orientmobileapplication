import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// Registering or updating one vehicle.
///
/// Only what the workshop genuinely needs is required — the make and the plate.
/// Everything else is optional enrichment, and nothing is invented: a blank
/// year stays blank, a blank mileage stays unknown, and the workshop's own
/// health and service fields are preserved exactly as stored rather than being
/// overwritten with client defaults.
class AddVehicleView extends ConsumerStatefulWidget {
  /// Empty registers a new vehicle; an id edits that vehicle.
  final String vehicleId;

  const AddVehicleView({super.key, this.vehicleId = ''});

  @override
  ConsumerState<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends ConsumerState<AddVehicleView> {
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();

  String _makeError = '';
  String _plateError = '';
  String _yearError = '';
  String _saveError = '';
  bool _saving = false;
  bool _loadedExisting = false;

  bool get _isEditing => widget.vehicleId.trim().isNotEmpty;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _vinCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    _mileageCtrl.dispose();
    super.dispose();
  }

  /// The stored vehicle being edited, resolved from live state.
  CustomerVehicleEntity? get _original {
    if (!_isEditing) return null;
    for (final vehicle in ref.read(customerDashboardProvider).vehicles) {
      if (vehicle.id == widget.vehicleId) return vehicle;
    }
    return null;
  }

  void _fillFrom(CustomerVehicleEntity vehicle) {
    _makeCtrl.text = vehicle.brand.trim();
    _modelCtrl.text = vehicle.model.trim();
    _plateCtrl.text = CustomerVehiclePresentation.plateLabel(
      vehicle.plateNumber,
    );
    _vinCtrl.text = vehicle.vin.trim().toUpperCase();
    // Unknown values stay unknown: no fabricated current year, no 0 km.
    _yearCtrl.text = vehicle.year > 0 ? '${vehicle.year}' : '';
    _colorCtrl.text = vehicle.color.trim();
    _mileageCtrl.text = CustomerVehiclePresentation.mileageInput(
      vehicle.mileage,
    );
  }

  bool _validate() {
    final make = _makeCtrl.text.trim();
    final plate = CustomerVehiclePresentation.plateLabel(_plateCtrl.text);
    final year = _yearCtrl.text.trim();
    final yearValue = year.isEmpty ? 0 : int.tryParse(year) ?? -1;
    final now = DateTime.now().year;

    setState(() {
      _makeError = make.isEmpty ? 'Enter the make of your vehicle' : '';
      _plateError = plate.isEmpty ? 'Enter the registration plate' : '';
      _yearError =
          yearValue == -1 ||
              (yearValue != 0 && yearValue < 1950) ||
              yearValue > now + 1
          ? 'Enter a year between 1950 and ${now + 1}'
          : '';
    });
    return _makeError.isEmpty && _plateError.isEmpty && _yearError.isEmpty;
  }

  int get _yearValue {
    final raw = _yearCtrl.text.trim();
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _save() async {
    if (_saving || !_validate()) return;
    setState(() {
      _saving = true;
      _saveError = '';
    });

    final original = _original;
    final draft = CustomerVehicleEntity(
      id: original?.id ?? '',
      brand: _makeCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      plateNumber: CustomerVehiclePresentation.plateLabel(_plateCtrl.text),
      vin: _vinCtrl.text.trim().toUpperCase(),
      color: _colorCtrl.text.trim(),
      year: _yearValue,
      mileage: CustomerVehiclePresentation.mileageLabel(_mileageCtrl.text),
      // Never invented, never erased: a new vehicle is unassessed, an existing
      // one keeps whatever the workshop recorded.
      lastService: original?.lastService ?? '',
      nextDue: original?.nextDue ?? '',
      healthScore: original?.healthScore ?? 0,
    );

    final result = await customerSaveVehicle(
      ref,
      vehicle: draft,
      isEdit: _isEditing,
      localId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (!result.accepted) {
      setState(
        () => _saveError = result.error.isEmpty
            ? "We couldn't save this vehicle. Please try again."
            : result.error,
      );
      return;
    }
    Navigator.of(context).pop(result.vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Prepopulate once, from the real stored record.
    if (_isEditing && !_loadedExisting) {
      final vehicle = _original;
      if (vehicle != null) {
        _loadedExisting = true;
        _fillFrom(vehicle);
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _SaveBar(
        label: _isEditing ? 'Save changes' : 'Add vehicle',
        icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
        saving: _saving,
        onSave: _save,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(title: _isEditing ? 'Edit vehicle' : 'Add vehicle'),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                maxContentWidth: 760,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.s16),
                    if (_saveError.isNotEmpty) ...[
                      CustomerNoticePanel(
                        message: _saveError,
                        actionLabel: 'Try again',
                        onAction: _save,
                      ),
                      const SizedBox(height: AppDimensions.s16),
                    ],
                    AppSplitView(
                      primaryFlex: 1,
                      secondaryFlex: 1,
                      spacing: AppDimensions.s20,
                      primary: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Section(
                            title: 'Vehicle',
                            subtitle: 'The make is required to register it.',
                            children: [
                              AppTextField(
                                controller: _makeCtrl,
                                label: 'Make',
                                hint: 'Toyota',
                                prefixIcon: Icons.directions_car_outlined,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                errorText: _makeError.isEmpty
                                    ? null
                                    : _makeError,
                              ),
                              const SizedBox(height: AppDimensions.s14),
                              AppTextField(
                                controller: _modelCtrl,
                                label: 'Model (optional)',
                                hint: 'Land Cruiser',
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          _Section(
                            title: 'Registration',
                            subtitle:
                                'Required — the plate is how the workshop '
                                'identifies your car.',
                            children: [
                              AppTextField(
                                controller: _plateCtrl,
                                label: 'Plate',
                                hint: 'A 12345',
                                prefixIcon: Icons.pin_outlined,
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.characters,
                                errorText: _plateError.isEmpty
                                    ? null
                                    : _plateError,
                              ),
                              if (CustomerVehiclePresentation.plateLabel(
                                _plateCtrl.text,
                              ).isNotEmpty) ...[
                                const SizedBox(height: AppDimensions.s10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: CustomerPlateChip(
                                    plate:
                                        CustomerVehiclePresentation.plateLabel(
                                          _plateCtrl.text,
                                        ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppDimensions.s14),
                              AppTextField(
                                controller: _vinCtrl,
                                label: 'VIN (optional)',
                                hint: 'Chassis number',
                                textInputAction: TextInputAction.next,
                                textCapitalization:
                                    TextCapitalization.characters,
                                helperText:
                                    'The workshop can read this from the car.',
                              ),
                            ],
                          ),
                        ],
                      ),
                      secondary: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Section(
                            title: 'Details',
                            subtitle: 'Optional — helps identify your car.',
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _yearCtrl,
                                      label: 'Year',
                                      hint: '2021',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      textInputAction: TextInputAction.next,
                                      errorText: _yearError.isEmpty
                                          ? null
                                          : _yearError,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.s12),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _colorCtrl,
                                      label: 'Colour',
                                      hint: 'White',
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.s14),
                              AppTextField(
                                controller: _mileageCtrl,
                                label: 'Mileage (optional)',
                                hint: '48,200',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppDimensions.s14,
                                  ),
                                  child: Center(
                                    widthFactor: 1,
                                    child: Text(
                                      'km',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: false,
                                    ),
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          _Note(
                            editing: _isEditing,
                            hasWorkshopData:
                                (_original?.healthScore ?? 0) > 0 ||
                                (_original?.lastService.trim().isNotEmpty ??
                                    false) ||
                                (_original?.nextDue.trim().isNotEmpty ?? false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimensions.s14),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Explains, truthfully, what the workshop data means.
class _Note extends StatelessWidget {
  final bool editing;
  final bool hasWorkshopData;

  const _Note({required this.editing, required this.hasWorkshopData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppDimensions.iconSm,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s6),
          Expanded(
            child: Text(
              hasWorkshopData
                  ? 'Health and service dates come from the workshop and are '
                        'kept as they are.'
                  : 'Health and service dates are recorded by the workshop '
                        'during a service — nothing is assumed here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool saving;
  final VoidCallback onSave;

  const _SaveBar({
    required this.label,
    required this.icon,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.onPrimary,
                      ),
                    ),
                  )
                : Icon(icon, size: 18),
            label: Text(saving ? 'Saving…' : label),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
            ),
          ),
        ),
      ),
    );
  }
}
