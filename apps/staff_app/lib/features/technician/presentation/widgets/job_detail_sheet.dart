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
import 'package:staff_app/features/technician/presentation/widgets/technician_today_search.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Technician Job Detail — "how do I execute THIS job correctly?".
///
/// C16 detail pattern (dossier + sticky action bar + sheets): WorkspaceAppBar
/// (back, search, offline status) + breadcrumbs header with one status pill,
/// hero identity card with progress, the current task with its live stopwatch
/// and one primary action, the full task checklist with latest-3 progressive
/// disclosure, parts/escalation as list rows opening AppBottomSheets, and the
/// handover CTA in the C16 sticky bar (compact) or the rail (wide).
///
/// Start/Hold/Complete/Resume call the exact same notifier methods as before
/// (local-first with offline queueing); the stopwatch is display-only
/// elapsed derived from the recorded start time. The job status machine is
/// untouched: task pending/inProgress/onHold/completed transitions, the
/// derived job sync (all-done → QC review), read-only locked states, and the
/// completeJob handover. All copy is localized with the established English
/// values; the handover dialog names the job reference (U10).
class TechnicianJobDetailView extends ConsumerStatefulWidget {
  final TechnicianJobEntity job;

  const TechnicianJobDetailView({super.key, required this.job});

  @override
  ConsumerState<TechnicianJobDetailView> createState() =>
      _TechnicianJobDetailViewState();
}

/// Backwards-compatible alias for the existing route/test wiring.
typedef JobDetailSheet = TechnicianJobDetailView;

class _TechnicianJobDetailViewState
    extends ConsumerState<TechnicianJobDetailView> {
  /// The mutation currently running (`task-<id>` or `job`), so a second tap can
  /// never double-execute.
  String? _busy;

  Future<void> _mutate(String key, Future<void> Function() action) async {
    if (_busy != null) return;
    setState(() => _busy = key);
    HapticFeedback.mediumImpact();
    await action();
    if (!mounted) return;
    // The mutation may settle asynchronously (server push / queued op); a short
    // guard window prevents a second tap racing the first.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _busy = null);
  }

  void _openSearch(TechnicianNotifier notifier) {
    HapticFeedback.selectionClick();
    showTechnicianTodaySearch(
      context,
      jobs: notifier.allJobs,
      onSelect: (job) {
        notifier.openJob(job);
        context
            .push(AppRoutes.technicianJobDetail, extra: job)
            .whenComplete(() => notifier.closeJob());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final pendingSync =
        ref.watch(technicianPendingSyncCountProvider).valueOrNull ?? 0;
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    // Prefer the live canonical job so a route-time entity never goes stale.
    final liveJob = notifier.allJobs.firstWhere(
      (j) => j.jobCardNo == widget.job.jobCardNo,
      orElse: () => state.selectedJob?.jobCardNo == widget.job.jobCardNo
          ? state.selectedJob!
          : widget.job,
    );
    final isActionable =
        liveJob.status != TechJobStatus.qcReview &&
        liveJob.status != TechJobStatus.completed;

    void start(WorkTaskEntity task) => _mutate(
      'task-${task.id}',
      () async => notifier.startTask(liveJob, task),
    );
    void hold(WorkTaskEntity task) => _mutate(
      'task-${task.id}',
      () async => notifier.updateTaskStatus(liveJob, task, TaskStatus.onHold),
    );
    void complete(WorkTaskEntity task) => _mutate(
      'task-${task.id}',
      () async => notifier.completeTask(liveJob, task),
    );

    // Dossier (60%) + support/handover rail (40%) on wide viewports; a
    // single-column stream with a sticky handover bar below that.
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );
    final busy = _busy;
    final dossier = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(job: liveJob),
        const SizedBox(height: AppDimensions.s16),
        _ExecutionArea(
          job: liveJob,
          isActionable: isActionable,
          busy: busy,
          onStart: start,
          onHold: hold,
          onComplete: complete,
        ),
      ],
    );
    final rail = _ContextColumn(
      job: liveJob,
      empId: notifier.profile.empId,
      isActionable: isActionable,
      isSaving: state.isSaving || busy == 'job',
      showHandover: wide,
      onCompleteRepair: () => _confirmComplete(notifier, liveJob),
    );

    // Handover is only meaningful once real tasks exist and not all are done.
    // Compact viewports serve it from the sticky bottom bar; wide ones from
    // the rail — never both at once.
    final canComplete =
        isActionable &&
        liveJob.tasks.isNotEmpty &&
        liveJob.completedTasks != liveJob.tasks.length;

    final vehicle =
        '${liveJob.vehicleBrand} ${liveJob.vehicleModel}'.trim().isEmpty
        ? t.techVehicleFallback
        : '${liveJob.vehicleBrand} ${liveJob.vehicleModel}'.trim();

    final ctaBusy = state.isSaving || busy == 'job';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.techDetailTitle,
        showBack: true,
        onBack: () => Navigator.maybePop(context),
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
        onSearch: () => _openSearch(notifier),
      ),
      // C16 sticky action bar: status summary on the start side, the ONE
      // job-level primary (handover to QC) on the end side. Hidden whenever
      // there is no handover to offer (empty / locked / all-done → U6).
      // Custom composition (not AppStickyActionBar): that atom splits the row
      // 50/50, which truncates the CTA label at 320 px (U5). Here the summary
      // takes its intrinsic width and the CTA takes the remainder, so the
      // CTA label never truncates. Same chrome as the spec bar (surface, top
      // hairline, safe area, keyboard viewInsets).
      bottomNavigationBar: wide || !canComplete
          ? null
          : _HandoverBar(
              job: liveJob,
              isLoading: ctaBusy,
              onCompleteRepair: ctaBusy
                  ? null
                  : () => _confirmComplete(notifier, liveJob),
            ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              breadcrumbs: [
                AppBreadcrumbItem(
                  label: t.techNavJobs,
                  onTap: () => Navigator.maybePop(context),
                ),
                AppBreadcrumbItem.current(liveJob.jobCardNo),
              ],
              title: vehicle,
              trailing: technicianStatusPill(liveJob.status),
            ),
            const SizedBox(height: AppDimensions.s16),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: dossier),
                  const SizedBox(width: AppDimensions.s24),
                  Expanded(flex: 2, child: rail),
                ],
              )
            else ...[
              dossier,
              const SizedBox(height: AppDimensions.s24),
              rail,
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmComplete(
    TechnicianNotifier notifier,
    TechnicianJobEntity liveJob,
  ) async {
    if (_busy != null) return;
    final t = StaffLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context,
      // U10: the destructive handover names the object under repair.
      title: t.techDetailCompleteRepairOn(liveJob.jobCardNo),
      message: t.techDetailConfirmBody,
      secondaryLabel: t.techDetailCancel,
      onSecondary: () => Navigator.of(context).pop(false),
      primaryLabel: t.techDetailCompleteRepair,
      onPrimary: () => Navigator.of(context).pop(true),
    );
    if (confirmed != true) return;
    await _mutate('job', () => notifier.completeJob(liveJob));
  }
}

/// Sticky handover bar: status summary over the LTR-locked job reference on
/// the start side, the ONE job-level primary on the end side.
///
/// Same chrome as the spec sticky bar (surface, top hairline, safe area,
/// keyboard viewInsets, ≥ 48 dp targets, wraps at 1.3x). The summary keeps
/// its intrinsic width and the CTA takes the remainder, so the CTA label
/// never truncates — even at 320 px (U5).
class _HandoverBar extends StatelessWidget {
  final TechnicianJobEntity job;
  final bool isLoading;
  final VoidCallback? onCompleteRepair;

  const _HandoverBar({
    required this.job,
    required this.isLoading,
    required this.onCompleteRepair,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.all(AppSpacing.lg) +
              EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
          child: Row(
            children: [
              MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      job.status.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        job.jobCardNo,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppPillButton.primary(
                  label: t.techDetailCompleteRepair,
                  icon: Icons.check_circle_outline_rounded,
                  size: AppPillButtonSize.large,
                  isLoading: isLoading,
                  onPressed: onCompleteRepair,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Job + vehicle identity and real task progress (C9 hero).
///
/// One status pill lives on the screen (the header trailing pill above), so
/// the hero carries identity + progress only: LTR-locked reference, vehicle,
/// plate/customer, and the plain-language progress sentence.
class _HeroCard extends StatelessWidget {
  final TechnicianJobEntity job;

  const _HeroCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final vehicle = '${job.vehicleBrand} ${job.vehicleModel}'.trim();

    return Semantics(
      header: true,
      child: AppSurfaceCard(
        outlined: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                job.jobCardNo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppFontFamilies.mono,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            Text(
              vehicle.isEmpty ? t.techVehicleFallback : vehicle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            Wrap(
              spacing: AppDimensions.s8,
              runSpacing: AppDimensions.s6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TechnicianPlateChip(plate: job.plateNumber),
                if (job.customerName.isNotEmpty)
                  Text(
                    job.customerName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (job.tasks.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s16),
              AppProgressBar(
                value: job.completedTasks / job.tasks.length,
                label: t.techTodayProgress(
                  job.completedTasks,
                  job.tasks.length,
                ),
                tone: AppProgressTone.accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The primary operational area: current/next task with its live stopwatch,
/// one handed primary action, and the checklist with latest-3 progressive
/// disclosure (U7: "View all" only appears when more tasks exist).
class _ExecutionArea extends StatelessWidget {
  final TechnicianJobEntity job;
  final bool isActionable;
  final String? busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _ExecutionArea({
    required this.job,
    required this.isActionable,
    required this.busy,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final running = job.tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .firstOrNull;
    final allDone =
        job.tasks.isNotEmpty && job.completedTasks == job.tasks.length;

    if (job.tasks.isEmpty) {
      // U6 calm empty: icon + sentence + how to start, never a CTA to nothing.
      return AppEmptyState(
        icon: Icons.inbox_outlined,
        title: t.techDetailNoTasks,
        message: t.techDetailNoTasksHint,
      );
    }

    final showAll = job.tasks.length > 3;
    final visible = showAll ? job.tasks.take(3).toList() : job.tasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (job.status == TechJobStatus.delayed) ...[
          AppBanner(
            kind: AppBannerKind.warning,
            message: t.techDetailDelayedHint,
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        AppSection(
          title: allDone
              ? t.techDetailAllDone
              : running != null
              ? t.techDetailCurrentTitle
              : t.techDetailNextTitle,
          child: _FocusPanel(
            job: job,
            running: running,
            isActionable: isActionable,
            busy: busy,
            onStart: onStart,
            onHold: onHold,
            onComplete: onComplete,
          ),
        ),
        const SizedBox(height: AppDimensions.s20),
        AppSection(
          title: t.techDetailTasksAssigned(job.tasks.length),
          seeAllLabel: showAll ? t.techTodayViewAll : null,
          onSeeAll: showAll
              ? () => _showAllTasks(context)
              : null,
          child: _TaskList(
            tasks: visible,
            isActionable: isActionable,
            busy: busy,
            onStart: onStart,
            onHold: onHold,
            onComplete: onComplete,
          ),
        ),
      ],
    );
  }

  Future<void> _showAllTasks(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return showAppBottomSheet<void>(
      context,
      title: t.techDetailTasksAssigned(job.tasks.length),
      child: _TaskList(
        tasks: job.tasks,
        isActionable: isActionable,
        busy: busy,
        onStart: onStart,
        onHold: onHold,
        onComplete: onComplete,
      ),
    );
  }
}

class _FocusPanel extends StatelessWidget {
  final TechnicianJobEntity job;
  final WorkTaskEntity? running;
  final bool isActionable;
  final String? busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _FocusPanel({
    required this.job,
    required this.running,
    required this.isActionable,
    required this.busy,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    if (!isActionable) {
      final qc = job.status == TechJobStatus.qcReview;
      return Semantics(
        liveRegion: true,
        child: AppSurfaceCard(
          outlined: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                qc ? Icons.fact_check_rounded : Icons.verified_rounded,
                color: techStatusSideColor(context, job.status),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  qc ? t.techDetailQcNotice : t.techDetailLockedNotice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pending = job.tasks
        .where((task) => task.status == TaskStatus.pending)
        .firstOrNull;
    final held = job.tasks
        .where((task) => task.status == TaskStatus.onHold)
        .firstOrNull;
    final allDone =
        job.tasks.isNotEmpty && job.completedTasks == job.tasks.length;
    final run = running;
    final active = run ?? pending ?? held;
    final activeBusy = active != null && busy == 'task-${active.id}';

    if (allDone || active == null) {
      return AppSurfaceCard(
        outlined: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: context.semanticColors.success.base,
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                t.techDetailAllDone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String label;
    final String busyLabel;
    final VoidCallback action;
    final IconData icon;
    if (run != null) {
      label = t.techDetailCompleteTask;
      busyLabel = t.techDetailCompleting;
      action = () => onComplete(run);
      icon = Icons.check_rounded;
    } else if (pending != null) {
      label = t.techDetailStartTask;
      busyLabel = t.techDetailStarting;
      action = () => onStart(pending);
      icon = Icons.play_arrow_rounded;
    } else {
      label = t.techDetailResumeTask;
      busyLabel = t.techDetailResuming;
      action = () => onStart(held!);
      icon = Icons.play_arrow_rounded;
    }

    return AppSurfaceCard(
      outlined: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            active.description,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if ((run ?? held) case final stopTask?
              when stopTask.startTime != null) ...[
            const SizedBox(height: AppDimensions.s8),
            TechnicianStopwatch(task: stopTask),
            const SizedBox(height: AppDimensions.s4),
            Text(
              t.techBannerStarted(stopTask.startTime!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s12),
          // C16: exactly ONE filled accent in this section; Hold is ghost.
          AppPillButton.primary(
            label: label,
            busyLabel: busyLabel,
            isLoading: activeBusy,
            icon: icon,
            onPressed: activeBusy ? null : action,
          ),
          if (run != null) ...[
            const SizedBox(height: AppDimensions.s8),
            AppPillButton.ghost(
              label: t.techDetailHoldTask,
              icon: Icons.pause_rounded,
              size: AppPillButtonSize.large,
              isExpanded: true,
              onPressed: activeBusy ? null : () => onHold(run),
            ),
          ],
        ],
      ),
    );
  }
}

/// The task checklist rows. Glove-first execution is the content: every row
/// keeps its 28px grease toggle plus its own Start / Hold / Complete controls,
/// rebuilt with App* buttons (secondary progress actions, ghost Hold) so the
/// section carries no second filled accent next to the focus CTA.
class _TaskList extends StatelessWidget {
  final List<WorkTaskEntity> tasks;
  final bool isActionable;
  final String? busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _TaskList({
    required this.tasks,
    required this.isActionable,
    required this.busy,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < tasks.length; i++) ...[
          _TaskRow(
            task: tasks[i],
            isActionable: isActionable,
            busy: busy == 'task-${tasks[i].id}',
            onStart: onStart,
            onHold: onHold,
            onComplete: onComplete,
          ),
          if (i < tasks.length - 1)
            const SizedBox(height: AppDimensions.s8),
        ],
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final WorkTaskEntity task;
  final bool isActionable;
  final bool busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _TaskRow({
    required this.task,
    required this.isActionable,
    required this.busy,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final taskIndex = task.id;
    final done = task.status == TaskStatus.completed;
    final running = task.status == TaskStatus.inProgress;
    final held = task.status == TaskStatus.onHold;
    final tone = done
        ? semantic.success.base
        : running
        ? colors.primary
        : held
        ? semantic.warning.base
        : colors.onSurfaceVariant;

    return Semantics(
      label: t.techDetailTaskLabel(taskIndex, task.description, task.status.label),
      child: AppSurfaceCard(
        outlined: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreaseToggle(
                  done: done,
                  running: running,
                  held: held,
                  tone: tone,
                  task: task,
                  isActionable: isActionable,
                  busy: busy,
                  onStart: onStart,
                  onComplete: onComplete,
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: done
                              ? colors.onSurfaceVariant
                              : colors.onSurface,
                          fontWeight: done ? FontWeight.w600 : FontWeight.w700,
                          height: 1.35,
                          decoration: done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s4),
                      Wrap(
                        spacing: AppDimensions.s8,
                        runSpacing: AppDimensions.s4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            // C16: frozen entity label verbatim — never
                            // uppercased (same sentence case as the pills).
                            task.status.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tone,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (task.startTime != null && task.endTime == null)
                            Text(
                              t.techBannerStarted(task.startTime!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          if (done && task.startTime != null)
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${task.startTime} – ${task.endTime ?? ''}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((running || held) && task.startTime != null) ...[
              const SizedBox(height: AppDimensions.s8),
              TechnicianStopwatch(task: task),
            ],
            if (isActionable && !done) ...[
              const SizedBox(height: AppDimensions.s10),
              Wrap(
                spacing: AppDimensions.s8,
                runSpacing: AppDimensions.s8,
                children: [
                  if (task.status == TaskStatus.pending)
                    AppPillButton.secondary(
                      label: busy
                          ? t.techDetailStarting
                          : t.techDetailStart,
                      icon: Icons.play_arrow_rounded,
                      size: AppPillButtonSize.small,
                      isExpanded: false,
                      onPressed: busy ? null : () => onStart(task),
                    ),
                  if (running || held)
                    AppPillButton.ghost(
                      label: held ? t.techDetailResume : t.techDetailHold,
                      icon: held
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: AppPillButtonSize.small,
                      isExpanded: false,
                      onPressed: busy
                          ? null
                          : () => held ? onStart(task) : onHold(task),
                    ),
                  if (running)
                    AppPillButton.secondary(
                      label: busy
                          ? t.techDetailCompleting
                          : t.techDetailComplete,
                      icon: Icons.check_rounded,
                      size: AppPillButtonSize.small,
                      isExpanded: false,
                      onPressed: busy ? null : () => onComplete(task),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 28px grease toggle: completed state fills, running spins urgency, and a
/// tap advances the task (start pending/held, complete running). Locked and
/// busy states stay inert with the same geometry.
class _GreaseToggle extends StatelessWidget {
  final bool done;
  final bool running;
  final bool held;
  final Color tone;
  final WorkTaskEntity task;
  final bool isActionable;
  final bool busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onComplete;

  const _GreaseToggle({
    required this.done,
    required this.running,
    required this.held,
    required this.tone,
    required this.task,
    required this.isActionable,
    required this.busy,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final interactive = isActionable && !done && !busy;
    return Semantics(
      button: true,
      enabled: interactive,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: !interactive
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  if (running) {
                    onComplete(task);
                  } else {
                    onStart(task);
                  }
                },
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: SizedBox(
            width: AppDimensions.touchTarget,
            height: AppDimensions.touchTarget,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? tone
                      : tone.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: tone, width: done ? 0 : 2),
                ),
                child: done
                    ? Icon(
                        Icons.check_rounded,
                        size: 18,
                        // FIXED-INK: white glyph on the saturated done fill.
                        color: colors.onPrimary,
                      )
                    : Icon(
                        running
                            ? Icons.play_arrow_rounded
                            : held
                            ? Icons.pause_rounded
                            : Icons.circle_outlined,
                        size: 16,
                        color: tone,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The contextual tool column: parts/escalation as list-group rows opening
/// AppBottomSheets (same sheet content with its own submit — no added steps),
/// and the completion action on wide viewports (compact serves it from the
/// sticky bar instead — never both at once).
class _ContextColumn extends StatelessWidget {
  final TechnicianJobEntity job;
  final String empId;
  final bool isActionable;
  final bool isSaving;

  /// True on wide viewports, where this column owns the handover CTA.
  /// Compact viewports serve handover from the sticky bottom bar instead.
  final bool showHandover;
  final VoidCallback onCompleteRepair;

  const _ContextColumn({
    required this.job,
    required this.empId,
    required this.isActionable,
    required this.isSaving,
    required this.showHandover,
    required this.onCompleteRepair,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    // Completed work is a read-only summary: no parts/escalation entry points.
    if (job.status == TechJobStatus.completed) {
      return const SizedBox.shrink();
    }

    // Completion is only meaningful once real tasks exist and not all are done.
    final canComplete =
        showHandover &&
        isActionable &&
        job.tasks.isNotEmpty &&
        job.completedTasks != job.tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppListGroup(
          title: t.techDetailSupport,
          items: [
            AppListGroupItem(
              leadingIcon: Icons.build_circle_outlined,
              title: t.techTodayRequestPart,
              onTap: () {
                HapticFeedback.selectionClick();
                showAppBottomSheet<void>(
                  context,
                  child: PartsRequestSheet(
                    jobCardRef: job.jobCardNo,
                    technicianEmpId: empId,
                    vehicleLabel:
                        '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
                    plateNumber: job.plateNumber,
                  ),
                );
              },
            ),
            AppListGroupItem(
              leadingIcon: Icons.warning_amber_rounded,
              title: t.techEscSend,
              onTap: () {
                HapticFeedback.selectionClick();
                showAppBottomSheet<void>(
                  context,
                  child: EscalationSheet(
                    jobCardRef: job.jobCardNo,
                    technicianEmpId: empId,
                    vehicleLabel:
                        '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
                    plateNumber: job.plateNumber,
                  ),
                );
              },
            ),
          ],
        ),
        if (canComplete) ...[
          const SizedBox(height: AppDimensions.s16),
          AppPillButton.primary(
            label: t.techDetailCompleteRepair,
            icon: Icons.check_circle_outline_rounded,
            isLoading: isSaving,
            onPressed: isSaving ? null : onCompleteRepair,
          ),
        ],
      ],
    );
  }
}
