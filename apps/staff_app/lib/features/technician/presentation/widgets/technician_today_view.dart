import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Today — "what needs my hands during this shift?".
///
/// Phase 10 execution surface: the shell banner owns the active-job identity
/// (vehicle + plate + stage + elapsed), so this tab leads with the shift
/// punch strip, then the one task that moves the bay forward (with its live
/// stopwatch), then the urgent-first queue in 72px high-touch rows, closing
/// with a slim shift strip and freshness. Every value shown comes from real
/// workshop state; nothing (progress, ETA, priority) is invented.
class TechnicianTodayView extends ConsumerStatefulWidget {
  /// Fixed freshness instant for deterministic golden stills. Production
  /// passes nothing and the footer reads the live clock.
  final DateTime? fixedRefreshAt;

  const TechnicianTodayView({super.key, this.fixedRefreshAt});

  @override
  ConsumerState<TechnicianTodayView> createState() =>
      _TechnicianTodayViewState();
}

class _TechnicianTodayViewState extends ConsumerState<TechnicianTodayView> {
  late DateTime _lastRefresh;

  @override
  void initState() {
    super.initState();
    _lastRefresh = widget.fixedRefreshAt ?? DateTime.now();
  }

  Future<void> _refresh(TechnicianNotifier notifier) async {
    await notifier.refresh();
    if (mounted) setState(() => _lastRefresh = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    ref.watch(technicianRefreshProvider);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final jobs = notifier.allJobs;
    final activeJob = _activeJob(jobs);
    // Urgent-first queue: delayed, then running, then pending, then the rest.
    final upcoming = _urgentFirst(jobs, activeJob)
        .where(
          (job) =>
              job != activeJob &&
              job.status != TechJobStatus.completed &&
              job.status != TechJobStatus.qcReview,
        )
        .take(5)
        .toList();

    final firstLoadError =
        jobs.isEmpty && !state.isLoading && state.dashboardError.isNotEmpty;
    final noJobs = jobs.isEmpty && !state.isLoading && !firstLoadError;
    final showSkeleton = state.isLoading && jobs.isEmpty;

    return RefreshIndicator(
      onRefresh: () => _refresh(notifier),
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (firstLoadError)
              EmptyState.error(
                message: t.techTodayLoadError,
                onRetry: () => _refresh(notifier),
              )
            else if (showSkeleton)
              const _TodaySkeleton()
            else if (noJobs)
              EmptyState(
                icon: Icons.assignment_outlined,
                title: t.techTodayEmpty,
                message: t.techTodayEmptyHint,
                actionLabel: t.techTodayRefresh,
                onAction: () => _refresh(notifier),
              )
            else ...[
              if (state.dashboardError.isNotEmpty) ...[
                _ConnectionNotice(
                  message: state.dashboardError,
                  onRetry: () => _refresh(notifier),
                ),
                const SizedBox(height: AppDimensions.s16),
              ],
              AppSplitView(
                primaryFlex: 3,
                secondaryFlex: 2,
                spacing: AppDimensions.s24,
                primary: _ExecutionColumn(
                  state: state,
                  notifier: notifier,
                  activeJob: activeJob,
                  onOpenJob: (job) => _openJob(job),
                  onPrimaryAction: (job) => _primaryAction(job),
                  onPartRequest: (job) =>
                      _openPartRequest(notifier, job),
                  onEscalate: (job) => _openEscalation(notifier, job),
                ),
                secondary: _QueueColumn(
                  upcoming: upcoming,
                  notifier: notifier,
                  onOpenJob: (job) => _openJob(job),
                  lastRefresh: _lastRefresh,
                ),
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

  List<TechnicianJobEntity> _urgentFirst(
    List<TechnicianJobEntity> jobs,
    TechnicianJobEntity? active,
  ) {
    int rank(TechnicianJobEntity job) {
      if (job == active) return -1;
      return switch (job.status) {
        TechJobStatus.delayed => 0,
        TechJobStatus.inProgress => 1,
        TechJobStatus.pending => 2,
        TechJobStatus.qcReview => 3,
        TechJobStatus.completed => 4,
      };
    }

    final sorted = List<TechnicianJobEntity>.from(jobs);
    sorted.sort((a, b) => rank(a).compareTo(rank(b)));
    return sorted;
  }

  void _primaryAction(TechnicianJobEntity job) {
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

  void _openJob(TechnicianJobEntity job) {
    HapticFeedback.selectionClick();
    ref.read(technicianDashboardProvider.notifier).openJob(job);
    context
        .push(AppRoutes.technicianJobDetail, extra: job)
        .whenComplete(
          () => ref.read(technicianDashboardProvider.notifier).closeJob(),
        );
  }

  void _openPartRequest(
    TechnicianNotifier notifier,
    TechnicianJobEntity job,
  ) {
    HapticFeedback.selectionClick();
    showAppModalSheet<void>(
      context: context,
      builder: (_) => PartsRequestSheet(
        jobCardRef: job.jobCardNo,
        technicianEmpId: notifier.profile.empId,
      ),
    );
  }

  void _openEscalation(
    TechnicianNotifier notifier,
    TechnicianJobEntity job,
  ) {
    HapticFeedback.selectionClick();
    showAppModalSheet<void>(
      context: context,
      builder: (_) => EscalationSheet(
        jobCardRef: job.jobCardNo,
        technicianEmpId: notifier.profile.empId,
      ),
    );
  }
}

// ─── EXECUTION COLUMN ────────────────────────────────────────────────────────
// Punch strip → current-task card (stopwatch + one primary action) → grease
// quick actions. The banner above already identifies the job, so this card
// spends its pixels on the task, not the vehicle.
class _ExecutionColumn extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;
  final TechnicianJobEntity? activeJob;
  final void Function(TechnicianJobEntity) onOpenJob;
  final void Function(TechnicianJobEntity) onPrimaryAction;
  final void Function(TechnicianJobEntity) onPartRequest;
  final void Function(TechnicianJobEntity) onEscalate;

  const _ExecutionColumn({
    required this.state,
    required this.notifier,
    required this.activeJob,
    required this.onOpenJob,
    required this.onPrimaryAction,
    required this.onPartRequest,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final job = activeJob;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ShiftStrip(state: state, notifier: notifier),
        const SizedBox(height: AppDimensions.s20),
        SectionHeader(
          title: job == null ? t.techTodayReady : t.techTodayOnBay,
          subtitle: t.techTodayCurrentWork,
        ),
        const SizedBox(height: AppDimensions.s12),
        if (job == null)
          EmptyState(
            icon: Icons.task_alt_rounded,
            title: t.techTodayNoActive,
            message: t.techTodayNoActiveHint,
            actionLabel: t.techTodayOpenJobs,
            onAction: () => notifier.selectTab(1),
          )
        else ...[
          _TaskFocusCard(
            job: job,
            onOpen: () => onOpenJob(job),
            onPrimaryAction: () => onPrimaryAction(job),
          ),
          const SizedBox(height: AppDimensions.s12),
          _QuickActions(
            onDetails: () => onOpenJob(job),
            onPart: () => onPartRequest(job),
            onEscalate: () => onEscalate(job),
          ),
        ],
      ],
    );
  }
}

// ─── QUEUE COLUMN ────────────────────────────────────────────────────────────
// Urgent-first 72px rows, then the slim shift strip and freshness. Matches
// the home grammar: assigned work owns the viewport, summary stays last.
class _QueueColumn extends StatelessWidget {
  final List<TechnicianJobEntity> upcoming;
  final TechnicianNotifier notifier;
  final void Function(TechnicianJobEntity) onOpenJob;
  final DateTime lastRefresh;

  const _QueueColumn({
    required this.upcoming,
    required this.notifier,
    required this.onOpenJob,
    required this.lastRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.techTodayQueue,
          subtitle: t.techTodayUpNext,
          action: upcoming.isEmpty ? null : t.techTodayViewAll,
          onAction: () => notifier.selectTab(1),
        ),
        const SizedBox(height: AppDimensions.s12),
        if (upcoming.isEmpty)
          EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: t.techTodayQueueClear,
            message: t.techTodayQueueClearHint,
          )
        else
          for (var i = 0; i < upcoming.length; i++) ...[
            if (i > 0) Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
            TechnicianJobSummary(
              job: upcoming[i],
              emphasised: i == 0,
              onTap: () => onOpenJob(upcoming[i]),
            ),
          ],
        const SizedBox(height: AppDimensions.s20),
        _ShiftSlimStrip(notifier: notifier),
        const SizedBox(height: AppDimensions.s8),
        _FreshnessFooter(lastRefresh: lastRefresh),
      ],
    );
  }
}

/// Compact shift/attendance strip with the real punch state.
class _ShiftStrip extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;

  const _ShiftStrip({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final status = state.attendanceStatus;
    final summary = state.attendanceSummary;
    final action = switch (status) {
      AttendanceStatus.notPunchedIn => (t.techShiftStart, Icons.login_rounded),
      AttendanceStatus.working => (t.techShiftBreak, Icons.coffee_rounded),
      AttendanceStatus.onBreak => (
        t.techShiftResume,
        Icons.play_arrow_rounded,
      ),
      AttendanceStatus.punchedOut => (t.techShiftDone, Icons.check_rounded),
    };
    final VoidCallback? callback = switch (status) {
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
              color: techAttendanceColor(
                context,
                status,
              ).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: techAttendanceColor(context, status),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _attendanceLabel(t, status),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status == AttendanceStatus.notPunchedIn
                      ? t.techShiftClockInHint
                      : t.techShiftWorked(
                          summary.workHours,
                          summary.breakTime,
                        ),
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

String _attendanceLabel(StaffLocalizations t, AttendanceStatus status) =>
    switch (status) {
      AttendanceStatus.working => t.techAttendanceWorking,
      AttendanceStatus.onBreak => t.techAttendanceOnBreak,
      AttendanceStatus.notPunchedIn => t.techAttendanceNotPunchedIn,
      AttendanceStatus.punchedOut => t.techAttendancePunchedOut,
    };

/// The one task that moves the bay forward: live stopwatch, struck-safe
/// title and exactly one primary action. Vehicle identity lives in the
/// shell banner, so no plate/customer repetition here.
class _TaskFocusCard extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onOpen;
  final VoidCallback onPrimaryAction;

  const _TaskFocusCard({
    required this.job,
    required this.onOpen,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final running = job.tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .firstOrNull;
    final pending = job.tasks
        .where((task) => task.status == TaskStatus.pending)
        .firstOrNull;
    final held = job.tasks
        .where((task) => task.status == TaskStatus.onHold)
        .firstOrNull;
    final nextTask = running ?? pending ?? held;
    final onHold = job.status == TechJobStatus.delayed;

    final primaryLabel = nextTask == null
        ? t.techTodayReviewJob
        : (running != null
              ? t.techTodayCompleteTask
              : t.techTodayStartTask);
    final primaryIcon = nextTask == null
        ? Icons.visibility_outlined
        : (running != null ? Icons.check_rounded : Icons.play_arrow_rounded);

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  running != null
                      ? t.techTodayInProgress
                      : t.techTodayNextTask,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              technicianStatusPill(job.status),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            nextTask?.description ??
                (job.tasks.isEmpty
                    ? t.techDetailNoTasksHint
                    : t.techDetailAllDone),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if (running != null && running.startTime != null) ...[
            const SizedBox(height: AppDimensions.s8),
            TechnicianStopwatch(task: running),
          ],
          if (job.tasks.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            AppLinearProgress(
              value: job.completedTasks / job.tasks.length,
              label: t.techTodayProgress(
                job.completedTasks,
                job.tasks.length,
              ),
            ),
          ],
          if (onHold) ...[
            const SizedBox(height: AppDimensions.s12),
            _BlockerNotice(),
          ],
          const SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: t.techTodayJobDetails,
                  leadingIcon: Icons.visibility_outlined,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onOpen();
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: primaryLabel,
                  icon: primaryIcon,
                  onPressed: nextTask == null
                      ? () {
                          HapticFeedback.selectionClick();
                          onOpen();
                        }
                      : () {
                          HapticFeedback.mediumImpact();
                          onPrimaryAction();
                        },
                ),
              ),
            ],
          ),
        ],
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
    final t = StaffLocalizations.of(context)!;

    return Semantics(
      liveRegion: true,
      container: true,
      label: '${t.techTodayJobOnHold}. ${t.techTodayDelayedHint}',
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
                    t.techTodayJobOnHold,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.techTodayDelayedHint,
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
    final t = StaffLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.checklist_rounded,
            label: t.techTodayTasks,
            onTap: onDetails,
          ),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: _QuickAction(
            icon: Icons.inventory_2_outlined,
            label: t.techTodayRequestPart,
            onTap: onPart,
          ),
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: _QuickAction(
            icon: Icons.report_problem_outlined,
            label: t.techTodayEscalate,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTap == null) return;
            HapticFeedback.selectionClick();
            onTap!();
          },
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
      ),
    );
  }
}

/// Slim inline shift metrics (home summary grammar): three real counts in one
/// quiet row, last on the page.
class _ShiftSlimStrip extends StatelessWidget {
  final TechnicianNotifier notifier;

  const _ShiftSlimStrip({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final active = notifier.inProgressJobs;
    final totalTasks = notifier.allTasks.length;
    final completedTasks = notifier.allTasks
        .where((entry) => entry.task.status == TaskStatus.completed)
        .length;
    final repairs = notifier.completedJobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.techTodaySummary,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        Row(
          children: [
            _SlimMetric(value: '$active', label: t.techTodayActiveBay),
            _SlimMetric(
              value: '$completedTasks/$totalTasks',
              label: t.techTodayTasksDone,
            ),
            _SlimMetric(value: '$repairs', label: t.techTodayRepairsDone),
          ],
        ),
      ],
    );
  }
}

class _SlimMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SlimMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 2),
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

class _FreshnessFooter extends StatelessWidget {
  final DateTime lastRefresh;
  const _FreshnessFooter({required this.lastRefresh});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final time = intl.DateFormat('HH:mm').format(lastRefresh);
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          t.techTodayUpdated(time),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Operational loading skeleton shaped like the workspace it replaces.
class _TodaySkeleton extends StatelessWidget {
  const _TodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeleton.card(height: 76),
        SizedBox(height: AppDimensions.s20),
        AppSkeleton.text(width: 120),
        SizedBox(height: AppDimensions.s10),
        AppSkeleton.card(height: 280),
        SizedBox(height: AppDimensions.s12),
        AppSkeleton.card(height: 76),
        SizedBox(height: AppDimensions.s20),
        AppSkeleton.listRows(rows: 3),
      ],
    );
  }
}
