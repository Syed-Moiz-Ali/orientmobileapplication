import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Technician Job Detail — "how do I execute THIS job correctly?".
///
/// Phase 10 dossier workspace (home-grammar sibling of the advisor job
/// dossier): WorkspaceAppBar + breadcrumbs, identity header, the current
/// task with its live stopwatch and one-handed grease actions
/// (Start cobalt / Hold amber / Complete emerald), the full 28px-toggle
/// checklist, then parts/escalation support and the handover-to-QC dock.
///
/// Start/Hold/Complete/Resume call the exact same notifier methods as before
/// (local-first with offline queueing); the stopwatch is display-only
/// elapsed derived from the recorded start time. All copy is localized with
/// the established English values.
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
    // single-column stream with a handover dock below that.
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
        _JobIdentity(job: liveJob),
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
    // Compact viewports serve it from the sticky bottom dock; wide ones from
    // the rail — never both at once.
    final canComplete =
        isActionable &&
        liveJob.tasks.isNotEmpty &&
        liveJob.completedTasks != liveJob.tasks.length;

    final vehicle =
        '${liveJob.vehicleBrand} ${liveJob.vehicleModel}'.trim().isEmpty
        ? t.techVehicleFallback
        : '${liveJob.vehicleBrand} ${liveJob.vehicleModel}'.trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.techDetailTitle,
        showBack: true,
        onBack: () => Navigator.maybePop(context),
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
      ),
      bottomNavigationBar: wide || !canComplete
          ? null
          : SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s16,
                  AppDimensions.s12,
                  AppDimensions.s16,
                  AppDimensions.s12,
                ),
                child: PrimaryButton(
                  label: t.techDetailCompleteRepair,
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: state.isSaving || busy == 'job',
                  onPressed: state.isSaving || busy == 'job'
                      ? null
                      : () => _confirmComplete(notifier, liveJob),
                ),
              ),
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
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.techDetailConfirmTitle,
      message: t.techDetailConfirmBody,
      confirmLabel: t.techDetailCompleteRepair,
      cancelLabel: t.techDetailCancel,
      icon: Icons.check_circle_outline_rounded,
    );
    if (confirmed != true) return;
    await _mutate('job', () => notifier.completeJob(liveJob));
  }
}

/// Job + vehicle identity and real task progress.
class _JobIdentity extends StatelessWidget {
  final TechnicianJobEntity job;

  const _JobIdentity({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final vehicle = '${job.vehicleBrand} ${job.vehicleModel}'.trim();

    return Semantics(
      header: true,
      child: AppCard.standard(
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppFontFamilies.mono,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                technicianStatusPill(job.status),
              ],
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
              AppLinearProgress(
                value: job.completedTasks / job.tasks.length,
                label: t.techTodayProgress(
                  job.completedTasks,
                  job.tasks.length,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The primary operational area: current/next task with its live stopwatch,
/// one handed primary action, and the full 28px-toggle checklist.
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
    final pending = job.tasks
        .where((task) => task.status == TaskStatus.pending)
        .firstOrNull;
    final held = job.tasks
        .where((task) => task.status == TaskStatus.onHold)
        .firstOrNull;
    final allDone =
        job.tasks.isNotEmpty && job.completedTasks == job.tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (job.status == TechJobStatus.delayed) ...[
          const _DelayedNotice(),
          const SizedBox(height: AppDimensions.s16),
        ],
        SectionHeader(
          title: job.tasks.isEmpty
              ? t.techDetailNoTasks
              : allDone
              ? t.techDetailAllDone
              : running != null
              ? t.techDetailCurrentTitle
              : t.techDetailNextTitle,
          subtitle: t.techDetailExecution,
        ),
        const SizedBox(height: AppDimensions.s12),
        _FocusPanel(
          job: job,
          running: running,
          pending: pending,
          held: held,
          isActionable: isActionable,
          busy: busy,
          onStart: onStart,
          onHold: onHold,
          onComplete: onComplete,
        ),
        const SizedBox(height: AppDimensions.s20),
        _TaskList(
          job: job,
          isActionable: isActionable,
          busy: busy,
          onStart: onStart,
          onHold: onHold,
          onComplete: onComplete,
        ),
      ],
    );
  }
}

class _FocusPanel extends StatelessWidget {
  final TechnicianJobEntity job;
  final WorkTaskEntity? running;
  final WorkTaskEntity? pending;
  final WorkTaskEntity? held;
  final bool isActionable;
  final String? busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _FocusPanel({
    required this.job,
    required this.running,
    required this.pending,
    required this.held,
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

    if (job.tasks.isEmpty) {
      return AppCard.standard(
        child: Text(
          t.techDetailNoTasksHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      );
    }

    if (!isActionable) {
      final qc = job.status == TechJobStatus.qcReview;
      return Semantics(
        liveRegion: true,
        child: AppCard.standard(
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

    final run = running;
    final pend = pending;
    final heldTask = held;
    final active = run ?? pend ?? heldTask;
    final activeBusy = active != null && busy == 'task-${active.id}';

    final String? label;
    final VoidCallback? action;
    if (run != null) {
      label = activeBusy ? t.techDetailCompleting : t.techDetailCompleteTask;
      action = () => onComplete(run);
    } else if (pend != null) {
      label = activeBusy ? t.techDetailStarting : t.techDetailStartTask;
      action = () => onStart(pend);
    } else if (heldTask != null) {
      label = activeBusy ? t.techDetailResuming : t.techDetailResumeTask;
      action = () => onStart(heldTask);
    } else {
      label = null;
      action = null;
    }

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            run != null
                ? t.techDetailCurrentTask
                : heldTask != null && pend == null
                ? t.techDetailOnHold
                : t.techDetailNextTask,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            active?.description ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if (run ?? heldTask case final stopTask?
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
          if (label != null) ...[
            const SizedBox(height: AppDimensions.s12),
            _GreaseButton.fill(
              label: label,
              icon: run != null ? Icons.check_rounded : Icons.play_arrow_rounded,
              tone: run != null
                  ? context.semanticColors.success.base
                  : colors.primary,
              onPressed: activeBusy ? null : action,
            ),
            if (run != null) ...[
              const SizedBox(height: AppDimensions.s8),
              _GreaseButton.fill(
                label: activeBusy ? label : t.techDetailHoldTask,
                icon: Icons.pause_rounded,
                tone: context.semanticColors.warning.base,
                onPressed: activeBusy ? null : () => onHold(run),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Grease-first action button: 52px tall, bold label, optional semantic fill.
/// A local task composition (not a shared primitive): Start stays cobalt,
/// Hold renders amber, Complete emerald — text always carries the meaning.
class _GreaseButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? fill;
  final VoidCallback? onPressed;

  const _GreaseButton.fill({
    required this.label,
    required this.icon,
    Color? tone,
    required this.onPressed,
  }) : fill = tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = fill ?? colors.primary;
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!();
              },
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          // FIXED-INK: white label on the saturated grease fills.
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: bg.withValues(alpha: 0.4),
          textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}

/// The complete task checklist. Every row carries a 28px grease toggle plus
/// its own Start / Hold / Complete controls, so the technician can drive any
/// task directly with gloves on.
class _TaskList extends StatelessWidget {
  final TechnicianJobEntity job;
  final bool isActionable;
  final String? busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _TaskList({
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
    if (job.tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.techDetailTasksAssigned(job.tasks.length),
          subtitle: t.techDetailAllTasks,
        ),
        const SizedBox(height: AppDimensions.s12),
        for (var i = 0; i < job.tasks.length; i++) ...[
          _TaskRow(
            index: i + 1,
            task: job.tasks[i],
            isActionable: isActionable,
            busy: busy == 'task-${job.tasks[i].id}',
            onStart: onStart,
            onHold: onHold,
            onComplete: onComplete,
          ),
          if (i < job.tasks.length - 1)
            const SizedBox(height: AppDimensions.s8),
        ],
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final int index;
  final WorkTaskEntity task;
  final bool isActionable;
  final bool busy;
  final void Function(WorkTaskEntity task) onStart;
  final void Function(WorkTaskEntity task) onHold;
  final void Function(WorkTaskEntity task) onComplete;

  const _TaskRow({
    required this.index,
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
      label: t.techDetailTaskLabel(index, task.description, task.status.label),
      child: AppCard.standard(
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
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: AppDimensions.s8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            task.status.label.toUpperCase(),
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
                    _TaskAction(
                      label: busy
                          ? t.techDetailStarting
                          : t.techDetailStart,
                      icon: Icons.play_arrow_rounded,
                      tone: colors.primary,
                      onPressed: busy ? null : () => onStart(task),
                    ),
                  if (running || held)
                    _TaskAction(
                      label: held ? t.techDetailResume : t.techDetailHold,
                      icon: held
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      tone: null,
                      onPressed: busy
                          ? null
                          : () => held ? onStart(task) : onHold(task),
                    ),
                  if (running)
                    _TaskAction(
                      label: busy
                          ? t.techDetailCompleting
                          : t.techDetailComplete,
                      icon: Icons.check_rounded,
                      tone: semantic.success.base,
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

/// A single per-task control, always a 48px touch target. The optional tone
/// fills the button in the matching semantic colour (Start cobalt, Complete
/// emerald); the default renders the outlined treatment.
class _TaskAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? tone;
  final VoidCallback? onPressed;

  const _TaskAction({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final child = Icon(icon, size: 18);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
      child: tone == null
          ? OutlinedButton.icon(
              onPressed: onPressed == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onPressed!();
                    },
              icon: child,
              label: Text(label),
            )
          : FilledButton.icon(
              onPressed: onPressed == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onPressed!();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: tone,
                // FIXED-INK: white label on the saturated action fills.
                foregroundColor: colors.onPrimary,
              ),
              icon: child,
              label: Text(label),
            ),
    );
  }
}

/// Real blocker state derived from the job's own status.
class _DelayedNotice extends StatelessWidget {
  const _DelayedNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Semantics(
      liveRegion: true,
      container: true,
      label: '${t.techDetailDelayed}. ${t.techDetailDelayedHint}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s12,
        ),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.error.withValues(alpha: 0.22)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.pause_circle_outline_rounded,
              size: AppDimensions.iconMd,
              color: colors.error,
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.techDetailDelayed,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.techDetailDelayedHint,
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

/// The contextual tool column: parts/escalation entry and the completion action.
class _ContextColumn extends StatelessWidget {
  final TechnicianJobEntity job;
  final String empId;
  final bool isActionable;
  final bool isSaving;

  /// True on wide viewports, where this column owns the handover CTA.
  /// Compact viewports serve handover from the sticky bottom dock instead.
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
        SectionHeader(
          title: t.techDetailSupport,
          subtitle: t.techDetailNeedHelp,
        ),
        const SizedBox(height: AppDimensions.s12),
        _HelpActions(job: job, empId: empId),
        if (canComplete) ...[
          const SizedBox(height: AppDimensions.s16),
          PrimaryButton(
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

class _HelpActions extends StatelessWidget {
  final TechnicianJobEntity job;
  final String empId;

  const _HelpActions({required this.job, required this.empId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = StaffLocalizations.of(context)!;

    Widget sheetButton({
      required IconData icon,
      required String label,
      required Color tone,
      required Widget Function() sheet,
    }) {
      return SizedBox(
        height: AppDimensions.touchTarget,
        child: OutlinedButton.icon(
          onPressed: () {
            HapticFeedback.selectionClick();
            showAppModalSheet<void>(
              context: context,
              builder: (_) => sheet(),
            );
          },
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: tone,
            side: BorderSide(color: tone),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sheetButton(
          icon: Icons.build_circle_outlined,
          label: t.techTodayRequestPart,
          tone: colors.onSurface,
          sheet: () => PartsRequestSheet(
            jobCardRef: job.jobCardNo,
            technicianEmpId: empId,
            vehicleLabel: '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
            plateNumber: job.plateNumber,
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        sheetButton(
          icon: Icons.warning_amber_rounded,
          label: t.techEscSend,
          tone: colors.error,
          sheet: () => EscalationSheet(
            jobCardRef: job.jobCardNo,
            technicianEmpId: empId,
            vehicleLabel: '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
            plateNumber: job.plateNumber,
          ),
        ),
      ],
    );
  }
}
