import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class CustomerVehicleCard extends StatelessWidget {
  final CustomerVehicleEntity vehicle;
  final bool compact;

  const CustomerVehicleCard({
    super.key,
    required this.vehicle,
    this.compact = false,
  });

  Color get _scoreColor => vehicle.healthScore >= 80
      ? AppColors.success
      : vehicle.healthScore >= 60
      ? AppColors.warning
      : AppColors.danger;

  Color get _scoreBg => vehicle.healthScore >= 80
      ? AppColors.successBg
      : vehicle.healthScore >= 60
      ? AppColors.warningBg
      : AppColors.dangerBg;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
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
                  color: _scoreBg,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
                child: Text(
                  '${vehicle.healthScore}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _scoreColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            vehicle.displayName,
            style: AppTextStyles.rajdhaniBody(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            vehicle.plateNumber,
            style: const TextStyle(fontSize: 11, color: AppColors.text3),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            vehicle.mileage,
            style: const TextStyle(fontSize: 10, color: AppColors.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildFull() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r14)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: AppTextStyles.rajdhaniTitle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    Row(
                      children: [
                        Text(
                          vehicle.plateNumber,
                          style: AppTextStyles.rajdhaniLabel(
                            color: AppColors.text2,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s8),
                        Text(
                          '${vehicle.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
