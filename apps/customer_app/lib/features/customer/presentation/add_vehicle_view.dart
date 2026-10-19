import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart' as models;

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// Registering or updating one vehicle, as three short steps: Plate →
/// Vehicle → Details.
///
/// Only what the workshop genuinely needs is required — the plate, then the
/// make — everything else is optional enrichment, and nothing is invented: a
/// blank year stays blank, a blank mileage stays unknown, and the workshop's
/// own health and service fields are preserved exactly as stored rather than
/// being overwritten with client defaults. There is no photo step: the
/// client has no photo storage contract, so upload UI would be a fake
/// affordance.
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
  int _step = 0;

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
    _vinCtrl.text = models.Vin(vehicle.vin).format();
    // Unknown values stay unknown: no fabricated current year, no 0 km.
    _yearCtrl.text = vehicle.year > 0 ? '${vehicle.year}' : '';
    _colorCtrl.text = vehicle.color.trim();
    _mileageCtrl.text = CustomerVehiclePresentation.mileageInput(
      vehicle.mileage,
    );
  }

  int _yearValue(String year) {
    final raw = year.trim();
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? -1;
  }

  bool _validatePlate() {
    final t = context.cx;
    final plate = CustomerVehiclePresentation.plateLabel(_plateCtrl.text);
    setState(() {
      _plateError = plate.isEmpty ? t.avPlateError : '';
    });
    return _plateError.isEmpty;
  }

  bool _validateVehicle() {
    final t = context.cx;
    final make = _makeCtrl.text.trim();
    final yearValue = _yearValue(_yearCtrl.text);
    final now = DateTime.now().year;
    setState(() {
      _makeError = make.isEmpty ? t.avMakeError : '';
      _yearError =
          yearValue == -1 ||
              (yearValue != 0 && yearValue < 1950) ||
              yearValue > now + 1
          ? t.avYearError(now + 1)
          : '';
    });
    return _makeError.isEmpty && _yearError.isEmpty;
  }

  bool _validate() => _validatePlate() & _validateVehicle();

  int get _yearSaveValue {
    final raw = _yearCtrl.text.trim();
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  void _next() {
    if (_saving) return;
    if (_step == 0) {
      if (!_validatePlate()) return;
      HapticFeedback.selectionClick();
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      if (!_validateVehicle()) return;
      HapticFeedback.selectionClick();
      setState(() => _step = 2);
      return;
    }
    _save();
  }

  Future<void> _save() async {
    if (_saving || !_validate()) {
      // A last-step failure returns to the step that owns the error.
      if (_plateError.isNotEmpty) {
        setState(() => _step = 0);
      } else if (_makeError.isNotEmpty || _yearError.isNotEmpty) {
        setState(() => _step = 1);
      }
      return;
    }
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
      // Phase 07.1: canonical VIN normalization (byte-identical output).
      vin: models.Vin(_vinCtrl.text).format(),
      color: _colorCtrl.text.trim(),
      year: _yearSaveValue,
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
            ? context.cx.avSaveFailFallback
            : result.error,
      );
      return;
    }
    Navigator.of(context).pop(result.vehicle);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);

    // Prepopulate once, from the real stored record.
    if (_isEditing && !_loadedExisting) {
      final vehicle = _original;
      if (vehicle != null) {
        _loadedExisting = true;
        _fillFrom(vehicle);
      }
    }

    final steps = <String>[t.avStepPlate, t.avStepVehicle, t.avStepDetails];
    final eyebrows = <String>[t.avEyebrowReg, t.avEyebrowVeh, t.avEyebrowDet];
    final titles = <String>[t.avPlateTitle, t.avVehicleTitle, t.avDetailsTitle];
    final bodies = <String>[t.avPlateBody, t.avVehicleBody, t.avDetailsBody];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Phase 07.1: bespoke AppTopBar migrated to the shared workspace bar.
      appBar: WorkspaceAppBar(
        title: _isEditing ? t.avTitleEdit : t.avTitleAdd,
        showBack: true,
      ),
      bottomNavigationBar: _StepDock(
        step: _step,
        isEditing: _isEditing,
        saving: _saving,
        onBack: _step == 0
            ? null
            : () {
                HapticFeedback.selectionClick();
                setState(() => _step -= 1);
              },
        onNext: _next,
      ),
      body: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppDimensions.s16),
            if (_saveError.isNotEmpty) ...[
              CustomerNoticePanel(
                message: _saveError,
                actionLabel: t.avRetryCta,
                onAction: _save,
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            AppStepper(
              steps: steps,
              currentIndex: _step,
              onStepTap: (index) {
                // Backward travel is always safe; forward travel validates
                // each gate in turn so no invalid step is ever skipped.
                if (index < _step) {
                  HapticFeedback.selectionClick();
                  setState(() => _step = index);
                } else if (index == _step + 1) {
                  _next();
                }
              },
            ),
            const SizedBox(height: AppDimensions.s20),
            _StepHeader(
              eyebrow: eyebrows[_step],
              title: titles[_step],
              body: bodies[_step],
            ),
            const SizedBox(height: AppDimensions.s16),
            AnimatedSwitcher(
              duration: AppMotion.resolve(context, AppMotion.fast),
              switchInCurve: AppMotion.enter,
              switchOutCurve: AppMotion.exit,
              child: KeyedSubtree(
                key: ValueKey<int>(_step),
                child: switch (_step) {
                  0 => _PlateStep(
                      plateCtrl: _plateCtrl,
                      plateError: _plateError,
                    ),
                  1 => _VehicleStep(
                      makeCtrl: _makeCtrl,
                      modelCtrl: _modelCtrl,
                      yearCtrl: _yearCtrl,
                      makeError: _makeError,
                      yearError: _yearError,
                    ),
                  _ => _DetailsStep(
                      vinCtrl: _vinCtrl,
                      colorCtrl: _colorCtrl,
                      mileageCtrl: _mileageCtrl,
                      note: _Note(
                        editing: _isEditing,
                        hasWorkshopData:
                            (_original?.healthScore ?? 0) > 0 ||
                                (_original?.lastService.trim().isNotEmpty ??
                                    false) ||
                                (_original?.nextDue.trim().isNotEmpty ??
                                    false),
                      ),
                    ),
                },
              ),
            ),
            const SizedBox(height: AppDimensions.s32),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;

  const _StepHeader({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          body,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PlateStep extends StatelessWidget {
  final TextEditingController plateCtrl;
  final String plateError;

  const _PlateStep({required this.plateCtrl, required this.plateError});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: plateCtrl,
          label: t.avPlateLabel,
          hint: t.avPlateHint,
          prefixIcon: Icons.pin_outlined,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          errorText: plateError.isEmpty ? null : plateError,
          onChanged: (_) {},
        ),
        if (CustomerVehiclePresentation.plateLabel(plateCtrl.text).isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s10),
          Align(
            alignment: Alignment.centerLeft,
            child: CustomerPlateChip(
              plate: CustomerVehiclePresentation.plateLabel(plateCtrl.text),
            ),
          ),
        ],
      ],
    );
  }
}

class _VehicleStep extends StatelessWidget {
  final TextEditingController makeCtrl;
  final TextEditingController modelCtrl;
  final TextEditingController yearCtrl;
  final String makeError;
  final String yearError;

  const _VehicleStep({
    required this.makeCtrl,
    required this.modelCtrl,
    required this.yearCtrl,
    required this.makeError,
    required this.yearError,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: makeCtrl,
          label: t.avMakeLabel,
          hint: t.avMakeHint,
          prefixIcon: Icons.directions_car_outlined,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          errorText: makeError.isEmpty ? null : makeError,
        ),
        const SizedBox(height: AppDimensions.s14),
        AppTextField(
          controller: modelCtrl,
          label: t.avModelLabel,
          hint: t.avModelHint,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AppDimensions.s14),
        AppTextField(
          controller: yearCtrl,
          label: t.avYearLabel,
          hint: t.avYearHint,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          textInputAction: TextInputAction.next,
          errorText: yearError.isEmpty ? null : yearError,
        ),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final TextEditingController vinCtrl;
  final TextEditingController colorCtrl;
  final TextEditingController mileageCtrl;
  final Widget note;

  const _DetailsStep({
    required this.vinCtrl,
    required this.colorCtrl,
    required this.mileageCtrl,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: vinCtrl,
          label: t.avVinLabel,
          hint: t.avVinHint,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          helperText: t.avVinHelp,
        ),
        const SizedBox(height: AppDimensions.s14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: colorCtrl,
                label: t.avColorLabel,
                hint: t.avColorHint,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: AppTextField(
                controller: mileageCtrl,
                label: t.avMileageLabel,
                hint: t.avMileageHint,
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: AppDimensions.s14),
                  child: Center(
                    widthFactor: 1,
                    child: Text('km'),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s16),
        note,
      ],
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
    final t = context.cx;
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
              hasWorkshopData ? t.avNoteKept : t.avNoteFresh,
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

class _StepDock extends StatelessWidget {
  final int step;
  final bool isEditing;
  final bool saving;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _StepDock({
    required this.step,
    required this.isEditing,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final colors = Theme.of(context).colorScheme;
    final last = step == 2;
    final back = onBack;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              if (back != null) ...[
                Expanded(
                  child: SecondaryButton(
                    label: t.avBack,
                    onPressed: saving ? null : back,
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
              ],
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: last
                      ? (isEditing ? t.avSaveEdit : t.avSaveAdd)
                      : t.avNext,
                  icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  isLoading: saving,
                  onPressed: saving ? null : onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
