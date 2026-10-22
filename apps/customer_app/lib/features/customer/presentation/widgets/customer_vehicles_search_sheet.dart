import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';

/// Opens the vehicles search sheet: a list-scoped search over the already
/// loaded vehicle records (no new routes, no logic changes). Result taps reuse
/// the record contract — tapping a result closes the sheet and reveals the
/// record; record actions stay on the record itself.
Future<void> showCustomerVehiclesSearchSheet(
  BuildContext context, {
  required List<CustomerVehicleEntity> vehicles,
  required ValueChanged<CustomerVehicleEntity> onSelect,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.vhSearchTitle,
    builder: (_) => _VehiclesSearchSheet(
      vehicles: vehicles,
      onSelect: onSelect,
    ),
  );
}

/// Presentation-only vehicle search: filters the loaded records by display
/// name, plate label or specs substring (case-insensitive; plates compared
/// without punctuation). Mirrors the record content so the sheet can never
/// promise a vehicle the list does not show.
class _VehiclesSearchSheet extends StatefulWidget {
  final List<CustomerVehicleEntity> vehicles;
  final ValueChanged<CustomerVehicleEntity> onSelect;

  const _VehiclesSearchSheet({required this.vehicles, required this.onSelect});

  @override
  State<_VehiclesSearchSheet> createState() => _VehiclesSearchSheetState();
}

class _VehiclesSearchSheetState extends State<_VehiclesSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static String _normalizedPlate(String value) =>
      value.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();

  List<CustomerVehicleEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.vehicles;
    final normalizedQuery = _normalizedPlate(q);
    return widget.vehicles.where((vehicle) {
      final name = vehicle.displayName.toLowerCase();
      final plate = CustomerVehiclePresentation.plateLabel(
        vehicle.plateNumber,
      ).toLowerCase();
      final specs = CustomerVehiclePresentation.specs(
        vehicle,
      ).join(' ').toLowerCase();
      // Grouped display form mirrors the record line, so `45,000` matches
      // what the card shows (same data, presentation only).
      final grouped = CustomerVehiclePresentation.displayMileage(
        vehicle.mileage,
      ).toLowerCase();
      return name.contains(q) ||
          plate.contains(q) ||
          specs.contains(q) ||
          (grouped.isNotEmpty && grouped.contains(q)) ||
          (normalizedQuery.isNotEmpty &&
              _normalizedPlate(vehicle.plateNumber).contains(normalizedQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.vhSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.vhSearchNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                        child: Text(t.vhFilterClear),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (rowContext, index) {
                    final vehicle = results[index];
                    final name = vehicle.displayName.trim();
                    final plate = CustomerVehiclePresentation.plateLabel(
                      vehicle.plateNumber,
                    );
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(rowContext).pop();
                        widget.onSelect(vehicle);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty ? t.vhFallbackName : name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (plate.isNotEmpty) ...[
                              const SizedBox(width: AppDimensions.s10),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  plate,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mono(
                                    color: colors.onSurfaceVariant,
                                  ).copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
