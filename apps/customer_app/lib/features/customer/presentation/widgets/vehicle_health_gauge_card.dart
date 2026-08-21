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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final score = healthScore.clamp(0, 100);
    final (color, label) = score >= 80
        ? (const Color(0xFF10B981), 'OPTIMAL')
        : score >= 50
        ? (const Color(0xFFD97706), 'ATTENTION')
        : (const Color(0xFFEF4444), 'CRITICAL');

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s18),
      borderRadius: AppDimensions.r24,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.r12),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$vehicleName · Health Score',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mileage.isEmpty
                          ? plateNumber
                          : '$plateNumber • $mileage km',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: '$score% $label',
                showDot: true,
                bg: color.withValues(alpha: 0.12),
                fg: color,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerLow,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Icon(
                nextServiceDue.isEmpty
                    ? Icons.info_outline_rounded
                    : Icons.event_available_rounded,
                size: 15,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  nextServiceDue.isEmpty
                      ? 'No pending service milestone on record'
                      : 'Next scheduled service due: $nextServiceDue',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
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
