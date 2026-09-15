import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';

/// The technician's action-first home screen.
///
/// Workshop users should be able to identify their current vehicle and next
/// action at a glance. Reporting is intentionally secondary on this screen.
class TechnicianTodayView extends ConsumerWidget {
  const TechnicianTodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(technicianRefreshProvider);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final jobs = notifier.allJobs;
    final activeJob = _activeJob(jobs);
    final upcoming = jobs
        .where(
          (job) =>
              job != activeJob &&
              job.status != TechJobStatus.completed &&
              job.status != TechJobStatus.qcReview,
        )
        .take(3)
        .toList();

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(context.pagePadding.left, 16, context.pagePadding.right, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShiftControl(state: state, notifier: notifier),
            if (state.dashboardError.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ConnectionNotice(message: state.dashboardError, onRetry: notifier.refresh),
            ],
            const SizedBox(height: 14),
            _ShiftKpiRow(notifier: notifier),
            const SizedBox(height: 20),
            _SectionLabel(eyebrow: 'CURRENT WORK', title: activeJob == null ? 'Ready for assignment' : 'On the bay'),
            const SizedBox(height: 12),
            if (activeJob == null)
              _NoActiveJob(onViewJobs: () => notifier.selectTab(1))
            else
              _ActiveJobCard(
                job: activeJob,
                onOpen: () => _openJob(context, ref, activeJob),
                onPrimaryAction: () => _primaryAction(ref, activeJob),
              ),
            const SizedBox(height: 16),
            _QuickActions(
              enabled: activeJob != null,
              onDetails: activeJob == null ? null : () => _openJob(context, ref, activeJob),
              onPart: activeJob == null ? null : () => _openPartRequest(context, notifier, activeJob),
              onEscalate: activeJob == null ? null : () => _openEscalation(context, notifier, activeJob),
            ),
            const SizedBox(height: 28),
            _SectionLabel(
              eyebrow: 'UP NEXT',
              title: 'Assigned queue',
              actionLabel: 'View all',
              onAction: () => notifier.selectTab(1),
            ),
            const SizedBox(height: 12),
            if (upcoming.isEmpty)
              const _QueueEmpty()
            else
              ...upcoming.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UpcomingJobTile(job: job, onTap: () => _openJob(context, ref, job)),
                ),
              ),
            const SizedBox(height: 20),
            _ShiftPulse(notifier: notifier),
          ],
        ),
      ),
    );
  }

  TechnicianJobEntity? _activeJob(List<TechnicianJobEntity> jobs) {
    for (final job in jobs) {
      if (job.status == TechJobStatus.inProgress) return job;
    }
    for (final job in jobs) {
      if (job.status == TechJobStatus.delayed) return job;
    }
    for (final job in jobs) {
      if (job.status == TechJobStatus.pending) return job;
    }
    return null;
  }

  void _primaryAction(WidgetRef ref, TechnicianJobEntity job) {
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final pending = job.tasks.where((task) => task.status == TaskStatus.pending).firstOrNull;
    final running = job.tasks.where((task) => task.status == TaskStatus.inProgress).firstOrNull;
    HapticFeedback.mediumImpact();
    if (running != null) {
      notifier.completeTask(job, running);
    } else if (pending != null) {
      notifier.startTask(job, pending);
    }
  }

  void _openJob(BuildContext context, WidgetRef ref, TechnicianJobEntity job) {
    HapticFeedback.selectionClick();
    ref.read(technicianDashboardProvider.notifier).openJob(job);
    context
        .push(AppRoutes.technicianJobDetail, extra: job)
        .whenComplete(() => ref.read(technicianDashboardProvider.notifier).closeJob());
  }

  void _openPartRequest(BuildContext context, TechnicianNotifier notifier, TechnicianJobEntity job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PartsRequestSheet(jobCardRef: job.jobCardNo, technicianEmpId: notifier.profile.empId),
    );
  }

  void _openEscalation(BuildContext context, TechnicianNotifier notifier, TechnicianJobEntity job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EscalationSheet(jobCardRef: job.jobCardNo, technicianEmpId: notifier.profile.empId),
    );
  }
}

class _ShiftControl extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;

  const _ShiftControl({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = state.attendanceStatus;
    final summary = state.attendanceSummary;
    final action = switch (status) {
      AttendanceStatus.notPunchedIn => ('Start shift', Icons.login_rounded),
      AttendanceStatus.working => ('Take break', Icons.coffee_rounded),
      AttendanceStatus.onBreak => ('Resume shift', Icons.play_arrow_rounded),
      AttendanceStatus.punchedOut => ('Shift complete', Icons.check_rounded),
    };
    final callback = switch (status) {
      AttendanceStatus.notPunchedIn => notifier.punchIn,
      AttendanceStatus.working => notifier.startBreak,
      AttendanceStatus.onBreak => notifier.endBreak,
      AttendanceStatus.punchedOut => null,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(color: colors.shadow.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.schedule_rounded, color: status.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  status == AttendanceStatus.notPunchedIn
                      ? 'Clock in to begin today’s work'
                      : '${summary.workHours} worked • ${summary.breakTime} break',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonalIcon(
            onPressed: callback == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    callback();
                  },
            icon: Icon(action.$2, size: 18),
            label: Text(action.$1),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onOpen;
  final VoidCallback onPrimaryAction;

  const _ActiveJobCard({required this.job, required this.onOpen, required this.onPrimaryAction});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final running = job.tasks.where((task) => task.status == TaskStatus.inProgress).firstOrNull;
    final pending = job.tasks.where((task) => task.status == TaskStatus.pending).firstOrNull;
    final nextTask = running ?? pending;
    final completeAction = running != null;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.jobCardNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: colors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.circle, size: 8, color: Color(0xFF86EFAC)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    job.status.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.plateNumber.isEmpty ? 'Plate not recorded' : job.plateNumber,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (job.customerName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 16, color: colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.customerPhone.isEmpty ? job.customerName : '${job.customerName} · ${job.customerPhone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  Icon(Icons.build_circle_outlined, color: colors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          running != null ? 'IN PROGRESS' : 'NEXT TASK',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextTask?.description ?? 'All assigned tasks completed',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: job.progressPercent,
                      minHeight: 8,
                      backgroundColor: colors.outlineVariant,
                      valueColor: AlwaysStoppedAnimation(colors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(job.progressPercent * 100).round()}%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colors.primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpen,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outline),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Job details'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: nextTask == null ? onOpen : onPrimaryAction,
                    icon: Icon(completeAction ? Icons.check_rounded : Icons.play_arrow_rounded),
                    label: Text(
                      nextTask == null
                          ? 'Review job'
                          : completeAction
                          ? 'Complete task'
                          : 'Start next task',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onDetails;
  final VoidCallback? onPart;
  final VoidCallback? onEscalate;

  const _QuickActions({required this.enabled, this.onDetails, this.onPart, this.onEscalate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(icon: Icons.checklist_rounded, label: 'Tasks', onTap: onDetails),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(icon: Icons.inventory_2_outlined, label: 'Request part', onTap: onPart),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.report_problem_outlined,
            label: 'Escalate',
            isCritical: true,
            onTap: onEscalate,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCritical;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.label, this.isCritical = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isCritical ? colors.error : colors.primary;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: onTap == null ? colors.outline : color, size: 22),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: onTap == null ? colors.outline : colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingJobTile extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onTap;

  const _UpcomingJobTile({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Open ${job.jobCardNo}, ${job.vehicleBrand} ${job.vehicleModel}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(color: job.status.color, borderRadius: BorderRadius.circular(99)),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: job.status.color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.directions_car_outlined, color: job.status.color, size: 19),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${job.jobCardNo} · ${job.plateNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusPill(status: job.status),
                    const SizedBox(height: 4),
                    Icon(Icons.arrow_forward_rounded, color: colors.onSurfaceVariant, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final TechJobStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
      child: Text(
        status.label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: status.color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _ShiftPulse extends StatelessWidget {
  final TechnicianNotifier notifier;

  const _ShiftPulse({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final p = notifier.productivity;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.insights_rounded, color: colors.primary, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'LIVE SHIFT PULSE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Tooltip(
                message: 'Updates live',
                child: Icon(Icons.sync_rounded, color: colors.onSurfaceVariant, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (p.efficiency / 100).clamp(0, 1),
              minHeight: 6,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PulseMetric(value: '${p.completedToday}', label: 'Completed'),
              _PulseMetric(value: '${p.inProgress}', label: 'In progress'),
              _PulseMetric(value: '${p.efficiency.round()}%', label: 'Efficiency'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  final String value;
  final String label;

  const _PulseMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: colors.primary),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionLabel({required this.eyebrow, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.4),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _NoActiveJob extends StatelessWidget {
  final VoidCallback onViewJobs;

  const _NoActiveJob({required this.onViewJobs});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.task_alt_rounded, color: colors.primary, size: 42),
          const SizedBox(height: 12),
          Text(
            'No active repair right now',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Open your queue to review the next assigned vehicle.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onViewJobs,
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Open my jobs'),
          ),
        ],
      ),
    );
  }
}

class _QueueEmpty extends StatelessWidget {
  const _QueueEmpty();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(18)),
      child: Text(
        'Your queue is clear. New assignments will appear here.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

class _ConnectionNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ConnectionNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: colors.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.refresh_rounded, color: colors.onErrorContainer),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftKpiRow extends StatelessWidget {
  final TechnicianNotifier notifier;
  const _ShiftKpiRow({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final inProgress = notifier.inProgressJobs;
    final completed = notifier.productivity.completedToday > 0
        ? notifier.productivity.completedToday
        : notifier.completedJobs;
    final totalTasks = notifier.allTasks.length;
    final completedTasks = notifier.allTasks.where((t) => t.task.status == TaskStatus.completed).length;

    return Row(
      children: [
        Expanded(
          child: _ShiftKpiChip(
            label: 'Active Bay',
            value: '$inProgress',
            icon: Icons.run_circle_outlined,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ShiftKpiChip(
            label: 'Tasks Done',
            value: '$completedTasks/$totalTasks',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF0F9D73),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ShiftKpiChip(
            label: 'Repairs Done',
            value: '$completed',
            icon: Icons.done_all_rounded,
            color: colors.secondary,
          ),
        ),
      ],
    );
  }
}

class _ShiftKpiChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ShiftKpiChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: color),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
