import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorJobsTab extends ConsumerWidget {
  const SupervisorJobsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              _StatPill(
                label: 'Total',
                value: '${notifier.totalAssigned}',
                color: AppColors.accent,
                bg: AppColors.primaryBg,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'In Progress',
                value: '${notifier.inProgressCount}',
                color: AppColors.warning,
                bg: AppColors.warningBg,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Done',
                value: '${notifier.completedCount}',
                color: AppColors.success,
                bg: AppColors.successBg,
              ),
              const Spacer(),
              GestureDetector(
                onTap: notifier.onNewAssignment,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.r22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: notifier.jobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _JobCard(job: notifier.jobs[i]),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color, bg;
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.r22),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.70),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final AssignedJobEntity job;
  const _JobCard({required this.job});

  Color get _statusColor {
    switch (job.status) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  Color get _statusBg {
    switch (job.status) {
      case 'Completed':
        return AppColors.successBg;
      case 'In Progress':
        return AppColors.warningBg;
      default:
        return AppColors.dangerBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = job.total > 0 ? job.done / job.total : 0.0;
    final progressPct = (progress * 100).toInt();
    final taskLabel = '${job.done}/${job.total} tasks';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 17,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 7),
                Text(
                  job.jobCard,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(AppDimensions.r20),
                  ),
                  child: Text(
                    job.status,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBg,
                      child: Text(
                        job.customer[0],
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.customer,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            job.vehicle,
                            style: const TextStyle(
                              color: AppColors.text3,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Assigned',
                          style: TextStyle(
                            color: AppColors.text3,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          job.dateAssigned,
                          style: const TextStyle(
                            color: AppColors.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: AppDimensions.s12),
                Row(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(color: AppColors.text3, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      taskLabel,
                      style: const TextStyle(
                        color: AppColors.text3,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$progressPct%',
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.r6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.borderMd,
                    valueColor: AlwaysStoppedAnimation(_statusColor),
                    minHeight: 7,
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
