import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/customer/domain/entities/customer_entities.dart';

const Color _navy = AppColors.darkNavy;

class CustomerActiveServiceCard extends StatelessWidget {
  final CustomerServiceEntity svc;
  final VoidCallback onTap;

  const CustomerActiveServiceCard({
    super.key,
    required this.svc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navy, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.r18),
          boxShadow: [
            BoxShadow(
              color: _navy.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                const Text(
                  'Current Service',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            Text(
              svc.service,
              style: AppTextStyles.rajdhaniTitle(color: Colors.white),
            ),
            const SizedBox(height: AppDimensions.s4),
            Text(
              '${svc.vehicleName}  ·  ${svc.plateNumber}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: AppDimensions.s16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(fontSize: 10, color: Colors.white60),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.rPill,
                        ),
                        child: LinearProgressIndicator(
                          value: svc.progressPercent / 100,
                          minHeight: 7,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.s16),
                Text(
                  '${svc.progressPercent}%',
                  style: AppTextStyles.orbitronKpiNumber(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s10),
            Text(
              '⏱  Est. ready by ${svc.estCompletion}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerServiceStatusCard extends StatelessWidget {
  final CustomerServiceEntity svc;

  const CustomerServiceStatusCard({super.key, required this.svc});

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      svc.service,
                      style: AppTextStyles.rajdhaniTitle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      '${svc.vehicleName}  ·  ${svc.plateNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s12,
                  vertical: AppDimensions.s6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cyanLight,
                  borderRadius: BorderRadius.circular(AppDimensions.r20),
                ),
                child: const Text(
                  'In Progress',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          Row(
            children: [
              Text(
                '${svc.progressPercent}%',
                style: AppTextStyles.orbitronDisplayLarge(
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Completion',
                      style: TextStyle(
                        color: AppColors.text3,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.rPill),
                      child: LinearProgressIndicator(
                        value: svc.progressPercent / 100,
                        minHeight: 10,
                        backgroundColor: AppColors.cyanLight,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s16),
          Container(
            padding: const EdgeInsets.all(AppDimensions.s12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.text3,
                  size: 16,
                ),
                const SizedBox(width: AppDimensions.s8),
                Text(
                  'Est. ready by ${svc.estCompletion}',
                  style: const TextStyle(
                    color: AppColors.text3,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
