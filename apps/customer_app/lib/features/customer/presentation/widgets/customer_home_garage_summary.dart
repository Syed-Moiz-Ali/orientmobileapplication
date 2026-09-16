import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_plate_chip.dart';

/// Compact real-data garage summary.
///
/// Vehicles are rendered as informational rows inside one grouped surface
/// (never a carousel of tall promotional cards, and never a stock photo of a
/// car the customer does not own). Only fields the backend actually supplies
/// are shown — health is omitted when the vehicle has not been assessed.
class CustomerHomeGarageSummary extends StatelessWidget {
  final List<CustomerVehicleEntity> vehicles;
  final VoidCallback onManageVehicles;
  final int maxVisible;

  const CustomerHomeGarageSummary({
    super.key,
    required this.vehicles,
    required this.onManageVehicles,
    this.maxVisible = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final visible = vehicles.take(maxVisible).toList();
    final hidden = vehicles.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: vehicles.length == 1 ? 'Your vehicle' : 'Your garage',
          action: 'Manage',
          onAction: onManageVehicles,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < visible.length; index++) ...[
                _VehicleRow(vehicle: visible[index]),
                if (index < visible.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
              if (hidden > 0) ...[
                Divider(height: 1, color: colors.outlineVariant),
                _MoreVehiclesRow(hidden: hidden, onTap: onManageVehicles),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final CustomerVehicleEntity vehicle;

  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final name = vehicle.displayName.trim();
    final facts = <String>[
      if (vehicle.year > 0) '${vehicle.year}',
      if (vehicle.mileage.trim().isNotEmpty) vehicle.mileage.trim(),
      if (vehicle.color.trim().isNotEmpty) vehicle.color.trim(),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.s14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 20,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'Vehicle' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (vehicle.healthScore > 0) ...[
                      const SizedBox(width: AppDimensions.s8),
                      _HealthPill(score: vehicle.healthScore),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.s6),
                Wrap(
                  spacing: AppDimensions.s8,
                  runSpacing: AppDimensions.s6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (vehicle.plateNumber.trim().isNotEmpty)
                      CustomerPlateChip(plate: vehicle.plateNumber.trim()),
                    if (facts.isNotEmpty)
                      Text(
                        facts.join(' \u00b7 '),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                if (vehicle.nextDue.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s6),
                  Row(
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: AppDimensions.iconSm,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppDimensions.s6),
                      Expanded(
                        child: Text(
                          'Next service due ${vehicle.nextDue.trim()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthPill extends StatelessWidget {
  final int score;

  const _HealthPill({required this.score});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = score.clamp(0, 100);
    final tint = value >= 80
        ? colors.tertiary
        : value >= 60
        ? colors.onSurfaceVariant
        : colors.error;

    return StatusPill(
      label: 'Health $value%',
      showDot: true,
      bg: tint.withValues(alpha: 0.12),
      fg: tint,
    );
  }
}

class _MoreVehiclesRow extends StatelessWidget {
  final int hidden;
  final VoidCallback onTap;

  const _MoreVehiclesRow({required this.hidden, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hidden == 1
                    ? '1 more vehicle in your garage'
                    : '$hidden more vehicles in your garage',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: AppDimensions.iconMd,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
