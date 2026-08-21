import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/core/router/app_router.dart';

class CustomerVehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final bool compact;

  const CustomerVehicleCard({
    super.key,
    required this.vehicle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      width: 200,
      padding: const EdgeInsets.all(AppDimensions.s14),
      borderRadius: AppDimensions.r18,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
              const Spacer(),
              StatusPill(
                label: 'REGISTERED',
                bg: colorScheme.primary.withValues(alpha: 0.1),
                fg: colorScheme.primary,
              ),
            ],
          ),
          const Spacer(),
          Text(
            vehicle.displayName,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.s6),
          // UAE License Plate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFACC15),
              borderRadius: BorderRadius.circular(AppDimensions.r6),
              border: Border.all(color: Colors.black87, width: 1),
            ),
            child: Text(
              vehicle.plateNumber.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black,
                fontFamily: AppFontFamilies.mono,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s18),
      borderRadius: AppDimensions.r22,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r14),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(AppDimensions.r6),
                            border: Border.all(color: Colors.black87, width: 1),
                          ),
                          child: Text(
                            vehicle.plateNumber.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              fontFamily: AppFontFamilies.mono,
                            ),
                          ),
                        ),
                        if (vehicle.year > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Model ${vehicle.year}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    context.push(AppRoutes.customerEditVehicle(vehicle.id)),
                icon: Icon(
                  Icons.edit_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Edit Vehicle',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              if (vehicle.color.isNotEmpty) ...[
                Icon(
                  Icons.palette_outlined,
                  size: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.color,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 14),
              ],
              if (vehicle.mileage.isNotEmpty) ...[
                Icon(
                  Icons.speed_outlined,
                  size: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.mileage,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.customerBookService),
                icon: const Icon(Icons.calendar_month_rounded, size: 15),
                label: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
