import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class VehicleHealthGaugeCard extends StatelessWidget {
  final String vehicleName;
  final String plateNumber;
  final String mileage;
  final int healthScore;
  final String nextServiceDue;

  const VehicleHealthGaugeCard({
    super.key,
    required this.vehicleName,
    required this.plateNumber,
    required this.healthScore,
    this.mileage = '',
    this.nextServiceDue = '',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final score = healthScore.clamp(0, 100);
    final (color, label) = score >= 80
        ? (AppColors.success, 'GOOD')
        : score >= 50
        ? (AppColors.warning, 'ATTENTION')
        : (AppColors.danger, 'CRITICAL');

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$vehicleName · Health Score',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mileage.isEmpty
                          ? plateNumber
                          : '$plateNumber - $mileage km',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                child: Text(
                  '$score% $label',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.r6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: AppColors.bg,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          Row(
            children: [
              Icon(
                nextServiceDue.isEmpty
                    ? Icons.info_outline_rounded
                    : Icons.event_available_rounded,
                size: 14,
                color: AppColors.text3,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  nextServiceDue.isEmpty
                      ? 'No service due date on record'
                      : 'Next service due $nextServiceDue',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.text3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
