import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class VehicleHealthGaugeCard extends StatelessWidget {
  final String vehicleName;
  final String plateNumber;
  final int odometerKm;

  const VehicleHealthGaugeCard({
    super.key,
    required this.vehicleName,
    required this.plateNumber,
    this.odometerKm = 42500,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: AppColors.success,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Odometer: ${odometerKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                      style: const TextStyle(fontSize: 11, color: AppColors.text3),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '92% GOOD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.s14),
          const _HealthMetricRow(
            label: 'Engine Oil',
            status: 'OK',
            percent: 0.85,
            color: AppColors.success,
            detail: 'Next change in 3,500 km',
          ),
          const SizedBox(height: AppDimensions.s10),
          const _HealthMetricRow(
            label: 'Brake Pads',
            status: 'GOOD',
            percent: 0.70,
            color: AppColors.success,
            detail: 'Front 7mm / Rear 6mm',
          ),
          const SizedBox(height: AppDimensions.s10),
          const _HealthMetricRow(
            label: 'Battery Health',
            status: 'ATTENTION',
            percent: 0.45,
            color: AppColors.warning,
            detail: 'Charge at 12.2V — re-test soon',
          ),
          const SizedBox(height: AppDimensions.s10),
          const _HealthMetricRow(
            label: 'Tyre Tread',
            status: 'GOOD',
            percent: 0.80,
            color: AppColors.success,
            detail: 'Avg 5.5mm depth',
          ),
        ],
      ),
    );
  }
}

class _HealthMetricRow extends StatelessWidget {
  final String label;
  final String status;
  final double percent;
  final Color color;
  final String detail;

  const _HealthMetricRow({
    required this.label,
    required this.status,
    required this.percent,
    required this.color,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              detail,
              style: const TextStyle(fontSize: 11, color: AppColors.text3),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: AppColors.bg,
            color: color,
          ),
        ),
      ],
    );
  }
}
