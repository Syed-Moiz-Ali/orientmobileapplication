import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/customer/domain/entities/customer_entities.dart';
import 'package:orientmobileapplication/features/customer/presentation/widgets/customer_service_card.dart';
import 'package:orientmobileapplication/features/customer/providers/customer_providers.dart';

class CustomerServiceStatusTab extends ConsumerWidget {
  const CustomerServiceStatusTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(customerDashboardProvider.notifier);
    final svc = CustomerServiceEntity.mock;
    final steps = notifier.serviceSteps;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s16,
        AppDimensions.s24,
        AppDimensions.s16,
        AppDimensions.s32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerServiceStatusCard(svc: svc),
          const SizedBox(height: AppDimensions.s24),
          _sectionLabel('Job Progress'),
          const SizedBox(height: AppDimensions.s12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.all(
                Radius.circular(AppDimensions.r14),
              ),
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
              children: steps.asMap().entries.map((e) {
                final i = e.key;
                final step = e.value;
                final isLast = i == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: step.isCompleted
                                  ? AppColors.success
                                  : step.isCurrent
                                  ? AppColors.accent
                                  : AppColors.surfaceAlt,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: step.isCompleted
                                    ? AppColors.success
                                    : step.isCurrent
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              step.isCompleted
                                  ? Icons.check_rounded
                                  : step.isCurrent
                                  ? Icons.autorenew_rounded
                                  : Icons.circle_outlined,
                              size: 14,
                              color: step.isCompleted || step.isCurrent
                                  ? Colors.white
                                  : AppColors.text3,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 36,
                              color: step.isCompleted
                                  ? AppColors.success
                                  : AppColors.border,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                color: step.isCurrent
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.s4),
                            Text(
                              step.time,
                              style: const TextStyle(
                                color: AppColors.text3,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: AppDimensions.s10),
      Text(
        text,
        style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
      ),
    ],
  );
}
