import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/section_card.dart';

class ProductivitySection extends ConsumerWidget {
  const ProductivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final p = notifier.productivity;

    return SectionCard(
      title: "Today's Productivity",
      icon: Icons.insights_rounded,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: p.efficiency / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${p.efficiency.toInt()}%',
                            style: AppTextStyles.orbitronHeadline(
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            'Eff.',
                            style: AppTextStyles.rajdhaniBody(
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimensions.s20),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ProdCell(
                          label: 'Assigned',
                          value: '${p.assignedJobs}',
                          color: AppColors.accent,
                        ),
                        _ProdCell(
                          label: 'In Progress',
                          value: '${p.inProgress}',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.s8),
                    Row(
                      children: [
                        _ProdCell(
                          label: 'Completed',
                          value: '${p.completedToday}',
                          color: AppColors.success,
                        ),
                        _ProdCell(
                          label: 'Avg Time',
                          value: p.avgTimePerJob,
                          color: AppColors.text3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.s14),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s14,
              vertical: AppDimensions.s10,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r12),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: AppColors.accent, size: 18),
                SizedBox(width: AppDimensions.s10),
                Text(
                  'Total Hours Worked:',
                  style: AppTextStyles.rajdhaniBody(
                    color: AppColors.text2,
                  ),
                ),
                const Spacer(),
                Text(
                  p.totalHoursWorked,
                  style: AppTextStyles.orbitronHeadline(
                    color: AppColors.accent,
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

class _ProdCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ProdCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppDimensions.s4),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.s10,
          vertical: AppDimensions.s8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.r10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.orbitronDisplaySmall(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.rajdhaniBody(color: AppColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}
