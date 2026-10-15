import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Technician Job Detail — "how do I execute THIS job correctly?".
///
/// A full contextual workspace (not a dashboard): job + vehicle identity, the
/// current/next task with a one-handed primary action, the complete task list
/// where every task has its own Start / Hold / Complete control, the real
/// delayed / QC / completed state, and the parts/escalation entry points.
///
/// Start/Complete are local-first in the existing architecture: the notifier
/// updates the task immediately and queues a `work_item` operation when the
/// workshop is unreachable. Hold is a technician-side pause — the task stays on
/// the device as held while the workshop is told it is not started.
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
    final colors = Theme.of(context).colorScheme;
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Job details'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 768;
            final busy = _busy;
            final mainColumn = Column(
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
            final supportColumn = _ContextColumn(
              job: liveJob,
              empId: notifier.profile.empId,
              isActionable: isActionable,
              isSaving: state.isSaving || busy == 'job',
              onCompleteRepair: () =>
                  _confirmComplete(context, notifier, liveJob),
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.s24),
                      child: mainColumn,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colors.outlineVariant,
                  ),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.s24),
                      child: supportColumn,
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s16,
                AppDimensions.s16,
                AppDimensions.s16,
                AppDimensions.s32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  mainColumn,
                  const SizedBox(height: AppDimensions.s24),
                  supportColumn,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmComplete(
    BuildContext context,
    TechnicianNotifier notifier,
    TechnicianJobEntity liveJob,
  ) async {
    if (_busy != null) return;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Complete repair?',
      message:
          'All remaining tasks will be recorded as completed and the job sent '
          'to supervisor QC review.',
      confirmLabel: 'Complete repair',
      cancelLabel: 'Cancel',
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
    final vehicle = '${job.vehicleBrand} ${job.vehicleModel}'.trim();

    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.outlineVariant),
        ),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      fontFamily: AppFontFamilies.mono,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                technicianStatusPill(job.status),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            Text(
              vehicle.isEmpty ? 'Vehicle' : vehicle,
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
                _PlateChip(plate: job.plateNumber),
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
                label:
                    '${job.completedTasks} of ${job.tasks.length} tasks completed',
              ),
            ],
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
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        value.isEmpty ? 'Plate not recorded' : value,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w800,
          fontFamily: AppFontFamilies.mono,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// The primary operational area: current/next task, one handed primary action,
/// and the full task list where every task carries Start / Hold / Complete.
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
    final running = job.tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .firstOrNull;
    final pending = job.tasks
        .where((t) => t.status == TaskStatus.pending)
        .firstOrNull;
    final held = job.tasks
        .where((t) => t.status == TaskStatus.onHold)
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
              ? 'No tasks'
              : allDone
              ? 'Repair tasks complete'
              : running != null
              ? 'Current task'
              : 'Next task',
          subtitle: 'EXECUTION',
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

    if (job.tasks.isEmpty) {
      return _Panel(
        child: Text(
          'No tasks have been added to this job. Ask the advisor before '
          'starting work.',
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
        child: _Panel(
          emphasised: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                qc ? Icons.fact_check_rounded : Icons.verified_rounded,
                color: job.status.color,
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  qc
                      ? 'Repair work has been submitted for supervisor QC review.'
                      : 'This repair is completed. Technician edits are locked.',
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
      label = activeBusy ? 'Completing\u2026' : 'Complete task';
      action = () => onComplete(run);
    } else if (pend != null) {
      label = activeBusy ? 'Starting\u2026' : 'Start next task';
      action = () => onStart(pend);
    } else if (heldTask != null) {
      label = activeBusy ? 'Resuming\u2026' : 'Resume task';
      action = () => onStart(heldTask);
    } else {
      label = null;
      action = null;
    }

    return _Panel(
      emphasised: run != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            run != null
                ? 'CURRENT TASK'
                : heldTask != null && pend == null
                ? 'ON HOLD'
                : 'NEXT TASK',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppDimensions.r3),
          Text(
            active?.description ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          if (run?.startTime != null) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              'Started ${run!.startTime}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (label != null) ...[
            const SizedBox(height: AppDimensions.s12),
            SizedBox(
              height: AppDimensions.touchTarget,
              child: FilledButton(
                onPressed: activeBusy ? null : action,
                child: Text(label),
              ),
            ),
            if (run != null) ...[
              const SizedBox(height: AppDimensions.s8),
              SizedBox(
                height: AppDimensions.touchTarget,
                child: OutlinedButton.icon(
                  onPressed: activeBusy ? null : () => onHold(run),
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text('Hold task'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// The complete task list. Every task carries its own Start / Hold / Complete
/// control, so the technician can drive any task directly.
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
    if (job.tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: '${job.tasks.length} assigned',
          subtitle: 'ALL TASKS',
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
    final done = task.status == TaskStatus.completed;
    final running = task.status == TaskStatus.inProgress;
    final held = task.status == TaskStatus.onHold;
    final tone = done
        ? colors.tertiary
        : running
        ? colors.primary
        : held
        ? colors.error
        : colors.onSurfaceVariant;

    return Semantics(
      label: 'Task $index, ${task.description}, ${task.status.label}',
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s14),
        decoration: BoxDecoration(
          color: running
              ? Color.alphaBlend(
                  colors.primary.withValues(alpha: 0.04),
                  colors.surface,
                )
              : colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: running
                ? colors.primary.withValues(alpha: 0.45)
                : colors.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusControl,
                    ),
                  ),
                  child: Icon(_iconFor(task.status), size: 18, color: tone),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: done ? FontWeight.w600 : FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.r4),
                      Wrap(
                        spacing: AppDimensions.s8,
                        runSpacing: AppDimensions.r4,
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
                              'Started ${task.startTime}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          if (done && task.startTime != null)
                            Text(
                              '${task.startTime} \u2013 ${task.endTime ?? ''}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isActionable && !done) ...[
              const SizedBox(height: AppDimensions.s10),
              Wrap(
                spacing: AppDimensions.s8,
                runSpacing: AppDimensions.s8,
                children: [
                  if (task.status == TaskStatus.pending)
                    _TaskAction(
                      label: busy ? 'Starting\u2026' : 'Start',
                      icon: Icons.play_arrow_rounded,
                      primary: true,
                      onPressed: busy ? null : () => onStart(task),
                    ),
                  if (running || held)
                    _TaskAction(
                      label: held ? 'Resume' : 'Hold',
                      icon: held
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      primary: false,
                      onPressed: busy
                          ? null
                          : () => held ? onStart(task) : onHold(task),
                    ),
                  if (running)
                    _TaskAction(
                      label: busy ? 'Completing\u2026' : 'Complete',
                      icon: Icons.check_rounded,
                      primary: true,
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

  IconData _iconFor(TaskStatus status) => switch (status) {
    TaskStatus.completed => Icons.check_circle_rounded,
    TaskStatus.inProgress => Icons.play_circle_fill_rounded,
    TaskStatus.onHold => Icons.pause_circle_filled_rounded,
    TaskStatus.pending => Icons.radio_button_unchecked_rounded,
  };
}

/// A single per-task control, always a 48px touch target.
class _TaskAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback? onPressed;

  const _TaskAction({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon, size: 18);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
      child: primary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: child,
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
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

    return Semantics(
      liveRegion: true,
      container: true,
      label:
          'Delayed. This repair is marked as delayed at the workshop. '
          'You can continue the tasks below.',
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
                    'Delayed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.r2),
                  Text(
                    'This repair is marked as delayed at the workshop. You can '
                    'continue the tasks below once the issue is resolved.',
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
  final VoidCallback onCompleteRepair;

  const _ContextColumn({
    required this.job,
    required this.empId,
    required this.isActionable,
    required this.isSaving,
    required this.onCompleteRepair,
  });

  @override
  Widget build(BuildContext context) {
    // Completed work is a read-only summary: no parts/escalation entry points.
    if (job.status == TechJobStatus.completed) {
      return const SizedBox.shrink();
    }

    // Completion is only meaningful once real tasks exist and not all are done.
    final canComplete =
        isActionable &&
        job.tasks.isNotEmpty &&
        job.completedTasks != job.tasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Support', subtitle: 'NEED HELP?'),
        const SizedBox(height: AppDimensions.s12),
        _HelpActions(job: job, empId: empId),
        if (canComplete) ...[
          const SizedBox(height: AppDimensions.s16),
          SizedBox(
            height: AppDimensions.touchTarget,
            child: OutlinedButton.icon(
              onPressed: isSaving ? null : onCompleteRepair,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Complete repair'),
            ),
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
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
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
          label: 'Request part',
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
          label: 'Escalate issue',
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

class _Panel extends StatelessWidget {
  final Widget child;
  final bool emphasised;

  const _Panel({required this.child, this.emphasised = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: emphasised
            ? Color.alphaBlend(
                colors.primary.withValues(alpha: 0.05),
                colors.surface,
              )
            : colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: emphasised
              ? colors.primary.withValues(alpha: 0.35)
              : colors.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}
