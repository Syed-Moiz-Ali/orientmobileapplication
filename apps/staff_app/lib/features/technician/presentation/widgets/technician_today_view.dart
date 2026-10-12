import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Today — "what needs my attention during this shift?".
///
/// An execution surface, not a dashboard: it leads with the current job and the
/// one action that moves it forward, then the assigned queue. Every value shown
/// comes from real workshop state; nothing (progress, ETA, priority, parts,
/// blockers) is invented.
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
        .take(4)
        .toList();

    final firstLoadError =
        jobs.isEmpty && !state.isLoading && state.dashboardError.isNotEmpty;
    final noJobs = jobs.isEmpty && !state.isLoading && !firstLoadError;
    final showSkeleton = state.isLoading && jobs.isEmpty;

    final currentWork = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ShiftControl(state: state, notifier: notifier),
        const SizedBox(height: AppDimensions.s20),
        TechnicianSectionHeader(
          eyebrow: 'CURRENT WORK',
          title: activeJob == null ? 'Ready for assignment' : 'On the bay',
        ),
        const SizedBox(height: AppDimensions.s12),
        if (activeJob == null)
          TechnicianEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No active repair right now',
            message:
                'Open your queue to review the next assigned vehicle, or start '
                'the next job below.',
            actionLabel: 'Open my jobs',
            onAction: () => notifier.selectTab(1),
          )
        else ...[
          _ActiveJobCard(
            job: activeJob,
            onOpen: () => _openJob(context, ref, activeJob),
            onPrimaryAction: () => _primaryAction(ref, activeJob),
          ),
          const SizedBox(height: AppDimensions.s12),
          _QuickActions(
            onDetails: () => _openJob(context, ref, activeJob),
            onPart: () => _openPartRequest(context, notifier, activeJob),
            onEscalate: () => _openEscalation(context, notifier, activeJob),
          ),
        ],
      ],
    );

    final workQueue = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TechnicianSectionHeader(
          eyebrow: 'UP NEXT',
          title: 'Assigned queue',
          actionLabel: upcoming.isEmpty ? null : 'View all',
          onAction: () => notifier.selectTab(1),
        ),
        const SizedBox(height: AppDimensions.s12),
        if (upcoming.isEmpty)
          const TechnicianEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'Queue clear',
            message:
                'No other repairs are waiting. New assignments appear here as '
                'they are scheduled.',
          )
        else
          for (final job in upcoming) ...[
            TechnicianJobSummary(
              job: job,
              onTap: () => _openJob(context, ref, job),
            ),
            if (job != upcoming.last) const SizedBox(height: AppDimensions.s10),
          ],
        const SizedBox(height: AppDimensions.s20),
        _ShiftSummary(notifier: notifier),
      ],
    );

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (firstLoadError)
              _FirstLoadError(onRetry: notifier.refresh)
            else if (showSkeleton)
              const _TodaySkeleton()
            else if (noJobs)
              TechnicianEmptyState(
                icon: Icons.assignment_outlined,
                title: 'No assigned jobs right now',
                message:
                    'You have no repairs assigned for this shift. Pull to '
                    'refresh, or check back when the desk schedules work.',
                actionLabel: 'Refresh',
                onAction: notifier.refresh,
              )
            else ...[
              if (state.dashboardError.isNotEmpty) ...[
                _ConnectionNotice(
                  message: state.dashboardError,
                  onRetry: notifier.refresh,
                ),
                const SizedBox(height: AppDimensions.s16),
              ],
              AppSplitView(
                primaryFlex: 3,
                secondaryFlex: 2,
                spacing: AppDimensions.s24,
                primary: currentWork,
                secondary: workQueue,
              ),
            ],
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
    final pending = job.tasks
        .where((task) => task.status == TaskStatus.pending)
        .firstOrNull;
    final running = job.tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .firstOrNull;
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
        .whenComplete(
          () => ref.read(technicianDashboardProvider.notifier).closeJob(),
        );
  }

  void _openPartRequest(
    BuildContext context,
    TechnicianNotifier notifier,
    TechnicianJobEntity job,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PartsRequestSheet(
        jobCardRef: job.jobCardNo,
        technicianEmpId: notifier.profile.empId,
      ),
    );
  }

  void _openEscalation(
    BuildContext context,
    TechnicianNotifier notifier,
    TechnicianJobEntity job,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EscalationSheet(
        jobCardRef: job.jobCardNo,
        technicianEmpId: notifier.profile.empId,
      ),
    );
  }
}

/// Compact shift/attendance control with the real punch state.
class _ShiftControl extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;

  const _ShiftControl({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Icon(Icons.schedule_rounded, color: status.color),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.r2),
                Text(
                  status == AttendanceStatus.notPunchedIn
                      ? 'Clock in to begin today\u2019s work'
                      : '${summary.workHours} worked \u00b7 ${summary.breakTime} break',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s10),
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
              minimumSize: const Size(0, AppDimensions.touchTarget),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The operational current-job card: the vehicle, the reference, the current or
/// next task, real task progress, a real blocker state and ONE primary action.
class _ActiveJobCard extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onOpen;
  final VoidCallback onPrimaryAction;

  const _ActiveJobCard({
    required this.job,
    required this.onOpen,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final running = job.tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .firstOrNull;
    final pending = job.tasks
        .where((task) => task.status == TaskStatus.pending)
        .firstOrNull;
    final nextTask = running ?? pending;
    final vehicle = '${job.vehicleBrand} ${job.vehicleModel}'.trim();
    final onHold = job.status == TechJobStatus.delayed;

    final primaryLabel = nextTask == null
        ? 'Review job'
        : (running != null ? 'Complete task' : 'Start next task');
    final primaryIcon = nextTask == null
        ? Icons.visibility_outlined
        : (running != null ? Icons.check_rounded : Icons.play_arrow_rounded);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s18),
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
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      fontFamily: AppFontFamilies.mono,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                TechnicianStatusPill(status: job.status),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),
            Text(
              vehicle.isEmpty ? 'Vehicle' : vehicle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            _PlateChip(plate: job.plateNumber),
            if (job.customerName.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: AppDimensions.iconSm,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Expanded(
                    child: Text(
                      job.customerPhone.isEmpty
                          ? job.customerName
                          : '${job.customerName} \u00b7 ${job.customerPhone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (onHold) ...[
              const SizedBox(height: AppDimensions.s12),
              _BlockerNotice(),
            ],
            const SizedBox(height: AppDimensions.s16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.s14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusControl,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    color: colors.primary,
                    size: AppDimensions.iconMd,
                  ),
                  const SizedBox(width: AppDimensions.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          running != null ? 'IN PROGRESS' : 'NEXT TASK',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.r2),
                        Text(
                          nextTask?.description ??
                              (job.tasks.isEmpty
                                  ? 'No tasks recorded'
                                  : 'All assigned tasks completed'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (job.tasks.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s16),
              TechnicianTaskProgress(
                completed: job.completedTasks,
                total: job.tasks.length,
              ),
            ],
            const SizedBox(height: AppDimensions.s18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppDimensions.touchTarget,
                    child: OutlinedButton(
                      onPressed: onOpen,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        side: BorderSide(color: colors.outline),
                      ),
                      child: const Text('Job details'),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: AppDimensions.touchTarget,
                    child: FilledButton.icon(
                      onPressed: nextTask == null ? onOpen : onPrimaryAction,
                      icon: Icon(primaryIcon),
                      label: Text(primaryLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                      ),
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

class _PlateChip extends StatelessWidget {
  final String plate;

  const _PlateChip({required this.plate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final value = plate.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.r4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        value.isEmpty ? 'Plate not recorded' : value,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
          fontFamily: AppFontFamilies.mono,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Real blocker state derived from the job's own status.
class _BlockerNotice extends StatelessWidget {
  const _BlockerNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Job on hold. This repair is marked delayed.',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s12,
          vertical: AppDimensions.s10,
        ),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          border: Border.all(color: colors.error.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.pause_circle_outline_rounded,
              size: AppDimensions.iconSm,
              color: colors.error,
            ),
            const SizedBox(width: AppDimensions.s6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job on hold',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.r2),
                  Text(
                    'This repair is marked delayed at the workshop.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary contextual actions for the active job. These are the real
/// workshop actions — nothing here is decorative.
class _QuickActions extends StatelessWidget {
  final VoidCallback onDetails;
  final VoidCallback onPart;
  final VoidCallback onEscalate;

  const _QuickActions({
    required this.onDetails,
    required this.onPart,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.checklist_rounded,
            label: 'Tasks',
            onTap: onDetails,
          ),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: _QuickAction(
            icon: Icons.inventory_2_outlined,
            label: 'Request part',
            onTap: onPart,
          ),
        ),
        const SizedBox(width: AppDimensions.s10),
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

  const _QuickAction({
    required this.icon,
    required this.label,
    this.isCritical = false,
    this.onTap,
  });

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
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Ink(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: onTap == null ? colors.outline : color,
                size: 22,
              ),
              const SizedBox(height: AppDimensions.s6),
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

/// Compact, real shift summary — deliberately not an analytics panel.
class _ShiftSummary extends StatelessWidget {
  final TechnicianNotifier notifier;

  const _ShiftSummary({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final active = notifier.inProgressJobs;
    final totalTasks = notifier.allTasks.length;
    final completedTasks = notifier.allTasks
        .where((entry) => entry.task.status == TaskStatus.completed)
        .length;
    final repairs = notifier.completedJobs;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shift summary',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              _SummaryItem(value: '$active', label: 'Active bay'),
              _SummaryItem(
                value: '$completedTasks/$totalTasks',
                label: 'Tasks done',
              ),
              _SummaryItem(value: '$repairs', label: 'Repairs done'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppDimensions.r2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.s14),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: colors.onErrorContainer),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.refresh_rounded, color: colors.onErrorContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _FirstLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return TechnicianEmptyState(
      icon: Icons.cloud_off_rounded,
      title: "We couldn't load today's work",
      message: 'Check your connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Operational loading skeleton shaped like the workspace it replaces.
class _TodaySkeleton extends StatelessWidget {
  const _TodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        AppSkeleton.card(height: 76),
        SizedBox(height: AppDimensions.s20),
        AppSkeleton.text(width: 120, height: 12),
        SizedBox(height: AppDimensions.s10),
        AppSkeleton.card(height: 240),
        SizedBox(height: AppDimensions.s16),
        AppSkeleton.card(height: 92),
        SizedBox(height: AppDimensions.s20),
        AppSkeleton.text(width: 140, height: 12),
        SizedBox(height: AppDimensions.s10),
        AppSkeleton.card(height: 72),
        SizedBox(height: AppDimensions.s10),
        AppSkeleton.card(height: 72),
      ],
    );
  }
}
