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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(AppDimensions.r8),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.accent,
                  size: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s8,
                  vertical: AppDimensions.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Text(
                  'ACTIVE',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            vehicle.displayName,
            style: AppTextStyles.bodyStrong(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.s4),
          // Styled plate badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFACC15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black54, width: 1),
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.accent,
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
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Yellow UK Plate Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Text(
                            vehicle.plateNumber.toUpperCase(),
                            style: textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              fontFamily: AppFontFamilies.mono,
                            ),
                          ),
                        ),
                        if (vehicle.year > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Year ${vehicle.year}',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.text3,
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
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 20,
                  color: AppColors.text3,
                ),
                tooltip: 'Edit Vehicle',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              if (vehicle.color.isNotEmpty) ...[
                const Icon(
                  Icons.palette_outlined,
                  size: 14,
                  color: AppColors.text3,
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.color,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.text3),
                ),
                const SizedBox(width: 14),
              ],
              if (vehicle.mileage.isNotEmpty) ...[
                const Icon(
                  Icons.speed_outlined,
                  size: 14,
                  color: AppColors.text3,
                ),
                const SizedBox(width: 4),
                Text(
                  vehicle.mileage,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.text3),
                ),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.customerBookService),
                icon: const Icon(Icons.calendar_month_rounded, size: 14),
                label: const Text('Book Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
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
