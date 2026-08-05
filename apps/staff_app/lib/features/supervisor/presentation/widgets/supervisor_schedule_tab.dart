import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorScheduleTab extends ConsumerWidget {
  const SupervisorScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final jobs = notifier.jobs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Today\'s Schedule',
                style: AppTextStyles.rajdhaniTitle(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${jobs.length} jobs scheduled',
            style: const TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: 16),
          ...jobs.map((j) {
            final isCompleted = j.status == 'Completed';
            final isInProgress = j.status == 'In Progress';
            final clr = isCompleted
                ? AppColors.success
                : isInProgress
                ? AppColors.accent
                : AppColors.warning;
            final bg = isCompleted
                ? AppColors.successBg
                : isInProgress
                ? AppColors.accent.withValues(alpha: 0.12)
                : AppColors.warningBg;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: clr,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              j.jobCard,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                j.status,
                                style: TextStyle(
                                  color: clr,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${j.customer}  \u00b7  ${j.vehicle}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.text3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.linear_scale_rounded,
                              size: 12,
                              color: AppColors.text3,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: j.total > 0 ? j.done / j.total : 0,
                                  minHeight: 5,
                                  backgroundColor: AppColors.canvas,
                                  valueColor: AlwaysStoppedAnimation(clr),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${j.done}/${j.total}',
                              style: TextStyle(
                                fontSize: 11,
                                color: clr,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
