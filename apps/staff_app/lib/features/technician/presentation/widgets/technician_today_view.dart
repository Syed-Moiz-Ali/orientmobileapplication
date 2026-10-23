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
/// Phase 5 recomposition onto App* pattern widgets: a same-row header (day
/// title + shift/attendance + end-side search opening a full-screen sheet
/// over technician jobs) owns the greeting, then the hero current-work card
/// (vehicle + ref + task + progress + ONE primary Start/Complete CTA), the
/// quick-action tile row, the "Up next" queue with Show-all, the task-step
/// list and freshness. Presentation only: providers/routes/sync/task state
/// machine (start/pause/complete/resume), progress math, filter predicates,
/// bottom nav + rail, pull-to-refresh, haptics and keys are untouched.
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
              AppErrorState(
                title: t.techTodayLoadError,
                message: t.techTodayErrorHint,
                retryLabel: t.techTodayRetry,
                onRetry: () => _refresh(notifier),
              )
            else if (showSkeleton)
              const _TodaySkeleton()
            else if (noJobs) ...[
              _TodayHeader(state: state, notifier: notifier),
              SizedBox(height: AppSpacing.lg),
              AppEmptyState(
                icon: Icons.assignment_outlined,
                title: t.techTodayEmpty,
                message: t.techTodayEmptyHint,
                actionLabel: t.techTodayRefresh,
                onAction: () => _refresh(notifier),
              ),
            ] else ...[
              _TodayHeader(state: state, notifier: notifier),
              if (state.dashboardError.isNotEmpty) ...[
                SizedBox(height: AppSpacing.lg),
                AppBanner(
                  kind: AppBannerKind.warning,
                  message: state.dashboardError,
                  actionLabel: t.techTodayRetry,
                  onAction: () => _refresh(notifier),
                ),
              ],
              SizedBox(height: AppSpacing.lg),
              AppSplitView(
                primaryFlex: 3,
                secondaryFlex: 2,
                primary: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (activeJob == null)
                      AppEmptyState(
                        icon: Icons.task_alt_rounded,
                        title: t.techTodayNoActive,
                        message: t.techTodayNoActiveHint,
                        actionLabel: t.techTodayOpenJobs,
                        onAction: () => notifier.selectTab(1),
                      )
                    else ...[
                      _TodayHero(
                        job: activeJob,
                        onOpen: () => _openJob(activeJob),
                        onPrimaryAction: () => _primaryAction(activeJob),
                      ),
                      SizedBox(height: AppSpacing.md),
                      _TodayQuickActions(
                        onDetails: () => _openJob(activeJob),
                        onPart: () => _openPartRequest(notifier, activeJob),
                        onEscalate: () =>
                            _openEscalation(notifier, activeJob),
                      ),
                    ],
                  ],
                ),
                secondary: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TodayQueue(
                      upcoming: upcoming,
                      notifier: notifier,
                      onOpenJob: (job) => _openJob(job),
                    ),
                    if (activeJob != null) ...[
                      SizedBox(height: AppSpacing.xl),
                      _TodayTaskSteps(job: activeJob),
                    ],
                    SizedBox(height: AppSpacing.lg),
                    _FreshnessFooter(lastRefresh: _lastRefresh),
                  ],
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
    final held = job.tasks
        .where((task) => task.status == TaskStatus.onHold)
        .firstOrNull;
    HapticFeedback.mediumImpact();
    if (running != null) {
      notifier.completeTask(job, running);
    } else if (held != null) {
      // A held task resumes before the next pending one starts.
      notifier.startTask(job, held);
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

// ─── HEADER ──────────────────────────────────────────────────────────────────
// Day title + shift/attendance subtitle. The search glyph moved to the shell
// AppBar top-right (ruling (a) — same today sheet/target); this header keeps
// title + subtitle only, so the Today tab shows exactly one search icon.
class _TodayHeader extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;

  const _TodayHeader({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profile = notifier.profile;
    final attendance = _attendanceLabel(t, state.attendanceStatus);
    final subtitle = [
      profile.shift.trim(),
      attendance,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.techNavToday,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
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

// ─── HERO ────────────────────────────────────────────────────────────────────
// The one task that moves the bay forward: vehicle + job ref + live task +
// progress + exactly one primary action. Borderless in light mode (shadow,
// no border); dark takes the tone border, never a shadow (C5).
class _TodayHero extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onOpen;
  final VoidCallback onPrimaryAction;

  const _TodayHero({
    required this.job,
    required this.onOpen,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final vehicle = '${job.vehicleBrand} ${job.vehicleModel}'.trim().isEmpty
        ? t.techVehicleFallback
        : '${job.vehicleBrand} ${job.vehicleModel}'.trim();
    final running = job.tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .firstOrNull;
    final pending = job.tasks
        .where((task) => task.status == TaskStatus.pending)
        .firstOrNull;
    final held = job.tasks
        .where((task) => task.status == TaskStatus.onHold)
        .firstOrNull;
    final nextTask = running ?? held ?? pending;
    final onHold = job.status == TechJobStatus.delayed;

    final primaryLabel = nextTask == null
        ? t.techTodayReviewJob
        : (running != null
              ? t.techTodayCompleteTask
              : t.techTodayStartTask);
    final primaryIcon = nextTask == null
        ? Icons.visibility_outlined
        : (running != null ? Icons.check_rounded : Icons.play_arrow_rounded);

    final progress = job.tasks.isEmpty
        ? 0.0
        : job.completedTasks / job.tasks.length;

    return AppSurfaceCard(
      outlined: false,
      headerTitle: vehicle,
      headerTrailing: AppStatusChip(
        label: job.status.label,
        kind: switch (job.status) {
          TechJobStatus.inProgress => AppStatusKind.accent,
          TechJobStatus.completed => AppStatusKind.success,
          TechJobStatus.qcReview => AppStatusKind.info,
          TechJobStatus.delayed => AppStatusKind.error,
          TechJobStatus.pending => AppStatusKind.warning,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    job.jobCardNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(
                      color: colors.onSurfaceVariant,
                    ).copyWith(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (job.plateNumber.isNotEmpty) ...[
                SizedBox(width: AppSpacing.sm),
                TechnicianPlateChip(plate: job.plateNumber),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.sm),
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
            SizedBox(height: AppSpacing.sm),
            TechnicianStopwatch(task: running),
          ],
          if (job.tasks.isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Text(
              t.techTodayProgress(job.completedTasks, job.tasks.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Semantics(
              label: t.techTodayProgress(
                job.completedTasks,
                job.tasks.length,
              ),
              value: '${(progress * 100).round()} percent',
              child: ExcludeSemantics(
                child: AppProgressBar(value: progress),
              ),
            ),
          ],
          if (onHold) ...[
            SizedBox(height: AppSpacing.md),
            AppBanner(
              kind: AppBannerKind.error,
              message:
                  '${t.techTodayJobOnHold}. ${t.techTodayDelayedHint}',
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          // U5 fix: CTA pair stacks vertically at full width so both
          // labels render in full at 320px and 1.3x text scale. The
          // side-by-side Row (flex 1 vs 2) squeezed the secondary to
          // `Jo…` at 360 and even the primary to `Complete ta…` at 1.3x.
          // Exactly one filled primary CTA is kept; order (primary
          // first), routes, haptics and callbacks are unchanged.
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPillButton.primary(
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
              SizedBox(height: AppSpacing.sm),
              AppPillButton.secondary(
                label: t.techTodayJobDetails,
                icon: Icons.visibility_outlined,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onOpen();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── QUICK ACTIONS ────────────────────────────────────────────────────────────
// The real workshop actions for the active job, one tap each. Borderless in
// light mode (soft shadow, no outline); dark keeps the tone border.
class _TodayQuickActions extends StatelessWidget {
  final VoidCallback onDetails;
  final VoidCallback onPart;
  final VoidCallback onEscalate;

  const _TodayQuickActions({
    required this.onDetails,
    required this.onPart,
    required this.onEscalate,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TodayQuickTile(
            icon: Icons.checklist_rounded,
            label: t.techTodayTasks,
            onTap: onDetails,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TodayQuickTile(
            icon: Icons.inventory_2_outlined,
            label: t.techTodayRequestPart,
            onTap: onPart,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TodayQuickTile(
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

class _TodayQuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCritical;
  final VoidCallback? onTap;

  const _TodayQuickTile({
    required this.icon,
    required this.label,
    this.isCritical = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final color = isCritical ? colors.error : colors.primary;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: colors.surface,
        elevation: !dark && onTap != null ? 2 : 0,
        shadowColor: !dark ? colors.shadow.withValues(alpha: 0.14) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: dark
              ? BorderSide(color: colors.outline)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: onTap == null ? colors.outline : color,
                    size: 22,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: onTap == null ? colors.outline : colors.onSurface,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── QUEUE ───────────────────────────────────────────────────────────────────
// Urgent-first assigned rows in the shared queue grammar (status bar +
// vehicle + LTR identifiers + status pill + chevron, hairline dividers —
// never cards-in-cards), with Show-all switching to the Jobs tab.
class _TodayQueue extends StatelessWidget {
  final List<TechnicianJobEntity> upcoming;
  final TechnicianNotifier notifier;
  final void Function(TechnicianJobEntity) onOpenJob;

  const _TodayQueue({
    required this.upcoming,
    required this.notifier,
    required this.onOpenJob,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;

    return AppSection(
      title: t.techTodayQueue,
      seeAllLabel: upcoming.isEmpty ? null : t.techTodayViewAll,
      onSeeAll: upcoming.isEmpty ? null : () => notifier.selectTab(1),
      child: upcoming.isEmpty
          ? AppEmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: t.techTodayQueueClear,
              message: t.techTodayQueueClearHint,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < upcoming.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  TechnicianJobSummary(
                    job: upcoming[i],
                    emphasised: i == 0,
                    onTap: () => onOpenJob(upcoming[i]),
                  ),
                ],
              ],
            ),
    );
  }
}

// ─── TASK STEPS ──────────────────────────────────────────────────────────────
// The active job's checklist, display only (no step flow): every step with
// its honest status, using the job-detail step grammar. Tapping a step opens
// the job dossier through the existing Job details entry.
class _TodayTaskSteps extends StatelessWidget {
  final TechnicianJobEntity job;

  const _TodayTaskSteps({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.techTodayTasks,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < job.tasks.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              color: colors.outlineVariant,
            ),
          _StepRow(
            label: t.techDetailTaskLabel(
              i + 1,
              job.tasks[i].description,
              job.tasks[i].status.label,
            ),
            status: job.tasks[i].status,
            doneColor: semantic.success.base,
            runningColor: colors.primary,
            heldColor: semantic.warning.base,
            idleColor: colors.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final TaskStatus status;
  final Color doneColor;
  final Color runningColor;
  final Color heldColor;
  final Color idleColor;

  const _StepRow({
    required this.label,
    required this.status,
    required this.doneColor,
    required this.runningColor,
    required this.heldColor,
    required this.idleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final done = status == TaskStatus.completed;
    final running = status == TaskStatus.inProgress;
    final held = status == TaskStatus.onHold;
    final tone = done
        ? doneColor
        : running
        ? runningColor
        : held
        ? heldColor
        : idleColor;
    final icon = done
        ? Icons.check_circle_rounded
        : running
        ? Icons.timelapse_rounded
        : held
        ? Icons.pause_circle_rounded
        : Icons.radio_button_unchecked_rounded;

    return Semantics(
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 20, color: tone),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: done ? colors.onSurfaceVariant : colors.onSurface,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppShimmerSkeleton(width: 160, height: 20),
        const SizedBox(height: AppSpacing.sm),
        const AppShimmerSkeleton(width: 220, height: 14),
        const SizedBox(height: AppSpacing.lg),
        const AppShimmerSkeleton.card(height: 240),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Expanded(child: AppShimmerSkeleton.card(height: 72)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: AppShimmerSkeleton.card(height: 72)),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: AppShimmerSkeleton.card(height: 72)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppShimmerSkeleton.listRows(rows: 3),
      ],
    );
  }
}
