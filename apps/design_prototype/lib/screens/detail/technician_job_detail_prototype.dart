// D3 · Technician Job Detail prototype.
//
// Mirrors the production workspace (job_detail_sheet.dart): job + vehicle
// identity, current/next task focus panel with a one-handed primary action,
// the full task list where every task carries Start / Hold / Complete
// (tap targets >= 48 px, task rows >= 56 px), real state morphing
// (todo → in progress → done → held), vehicle/customer context, work
// description, and persistent part / escalate / complete actions gated
// exactly like production. Offline "saved, will sync" honesty chip included.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/prototype_theme.dart';
import '../../design/provisional_tokens.dart';
import '../../fixtures/technician_job_fixtures.dart';
import '../../l10n/provisional_strings.dart';
import '../../widgets/proto_primitives.dart';

class TechnicianJobDetailPrototype extends StatefulWidget {
  final String variant;

  const TechnicianJobDetailPrototype({super.key, required this.variant});

  @override
  State<TechnicianJobDetailPrototype> createState() => _TechnicianJobDetailPrototypeState();
}

enum _JobStage { active, delayed, qc, completed }

class _TechnicianJobDetailPrototypeState extends State<TechnicianJobDetailPrototype> {
  late _JobStage _stage;
  late List<TechnicianTaskFixture> _tasks;
  late TechnicianJobFixture _job;
  String? _busyTask;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _job = switch (widget.variant) {
      'noTasks' => technicianJobNoTasksFixture,
      _ => technicianJobFixture,
    };
    _stage = switch (widget.variant) {
      'delayed' => _JobStage.delayed,
      'completed' => _JobStage.completed,
      'noTasks' => _JobStage.active,
      _ => _JobStage.active,
    };
    // A completed job must not show half-finished tasks: the review variant
    // renders every task as completed with real times, consistent with the
    // locked-edits notice on screen.
    _tasks = widget.variant == 'completed'
        ? [
            for (var i = 0; i < _job.tasks.length; i++)
              TechnicianTaskFixture(
                id: _job.tasks[i].id,
                ref: _job.tasks[i].ref,
                description: _job.tasks[i].description,
                status: FixtureTaskStatus.completed,
                startTime: _job.tasks[i].startTime ?? _clock(9 * 60 + 30 + i * 35),
                endTime: _job.tasks[i].endTime ?? _clock(10 * 60 + i * 35),
              ),
          ]
        : [..._job.tasks];
  }

  static String _clock(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  bool get _actionable => _stage == _JobStage.active || _stage == _JobStage.delayed;
  bool get _loading => widget.variant == 'loading';
  bool get _error => widget.variant == 'error';

  int get _completed => _tasks.where((t) => t.status == FixtureTaskStatus.completed).length;

  void _setTaskStatus(TechnicianTaskFixture task, FixtureTaskStatus status) {
    if (_busyTask != null) return;
    setState(() => _busyTask = task.id.toString());
    unawaited(Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = TechnicianTaskFixture(
            id: task.id,
            ref: task.ref,
            description: task.description,
            status: status,
            startTime: status == FixtureTaskStatus.inProgress ? '11:05' : task.startTime,
            endTime: status == FixtureTaskStatus.completed ? '11:32' : task.endTime,
          );
        }
        _busyTask = null;
      });
    }));
  }

  Future<void> _completeRepair() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.check_circle_outline_rounded, color: context.palette.success, size: 30),
        title: Text(context.s('tech.confirm.title')),
        content: Text(context.s('tech.confirm.body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.s('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.s('tech.confirm.confirm')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _saving = true;
      _stage = _JobStage.qc;
      _tasks = [
        for (final task in _tasks)
          TechnicianTaskFixture(
            id: task.id,
            ref: task.ref,
            description: task.description,
            status: FixtureTaskStatus.completed,
            startTime: task.startTime ?? '11:00',
            endTime: task.endTime ?? '11:45',
          ),
      ];
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _saving = false);
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.windowClass.isCompact;

    final execution = _ExecutionColumn(
      job: _job,
      tasks: _tasks,
      stage: _stage,
      actionable: _actionable,
      busyTask: _busyTask,
      completed: _completed,
      onStart: (task) => _setTaskStatus(task, FixtureTaskStatus.inProgress),
      onHold: (task) => _setTaskStatus(task, FixtureTaskStatus.onHold),
      onComplete: (task) => _setTaskStatus(task, FixtureTaskStatus.completed),
    );

    final contextColumn = _ContextColumn(
      job: _job,
      stage: _stage,
      actionable: _actionable,
      canComplete: _actionable && _tasks.isNotEmpty && _completed != _tasks.length,
      saving: _saving,
      onRequestPart: () => _openPartsSheet(),
      onEscalate: () => _openEscalateSheet(),
      onCompleteRepair: _completeRepair,
    );

    Widget body;
    if (_loading) {
      body = const _DetailSkeleton();
    } else {
      body = SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? ProtoSpace.s16 : ProtoSpace.s24,
          ProtoSpace.s16,
          compact ? ProtoSpace.s16 : ProtoSpace.s24,
          compact ? ProtoSpace.actionBarClearance : ProtoSpace.s32,
        ),
        child: ProtoPageFrame(
          maxWidth: ProtoSpace.contentStandard,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error) ...[
                ProtoErrorBanner(
                  title: context.s('common.errorTitle'),
                  body: context.s('tech.delayed.body'),
                  onRetry: () {},
                ),
                const SizedBox(height: ProtoSpace.s16),
              ],
              _JobIdentity(job: _job, stage: _stage, completed: _completed, total: _tasks.length),
              const SizedBox(height: ProtoSpace.s12),
              _ContextRow(job: _job, stage: _stage),
              const SizedBox(height: ProtoSpace.s20),
              if (compact) ...[
                execution,
                const SizedBox(height: ProtoSpace.s24),
                contextColumn,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: execution),
                    const SizedBox(width: ProtoSpace.s24),
                    Expanded(flex: 4, child: contextColumn),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ProtoTopBar(
          title: context.s('tech.title'),
          subtitle: _job.dateOfWork.of(context),
          onBack: () {},
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: ProtoSpace.s12),
              child: _OfflineChip(),
            ),
          ],
        ),
        Expanded(child: body),
        if (compact && _actionable && _tasks.isNotEmpty) _StickyActionBar(
          saving: _saving,
          canComplete: _completed != _tasks.length,
          onRequestPart: _openPartsSheet,
          onEscalate: _openEscalateSheet,
          onCompleteRepair: _completeRepair,
        ),
      ],
    );
  }

  Future<void> _openPartsSheet() async {
    await showProtoSheet<void>(
      context,
      child: _SupportSheet(
        title: context.s('tech.parts.title'),
        body: context.s('tech.parts.body'),
        submitLabel: context.s('tech.parts.submit'),
        fields: [
          (label: context.s('tech.parts.item'), hint: 'Brake pad set — front', icon: Icons.build_circle_outlined),
          (label: context.s('tech.parts.qty'), hint: '1', icon: Icons.numbers_rounded),
          (label: context.s('tech.parts.note'), hint: '—', icon: Icons.edit_note_rounded),
        ],
        onSubmit: () => _notify(context.s('common.offlineSaved')),
      ),
    );
  }

  Future<void> _openEscalateSheet() async {
    await showProtoSheet<void>(
      context,
      child: _SupportSheet(
        title: context.s('tech.escalate.title'),
        body: context.s('tech.escalate.body'),
        submitLabel: context.s('tech.escalate.submit'),
        destructive: true,
        fields: [
          (label: context.s('tech.escalate.reason'), hint: '—', icon: Icons.report_problem_outlined),
          (label: context.s('tech.escalate.urgency'), hint: 'High', icon: Icons.priority_high_rounded),
        ],
        onSubmit: () => _notify(context.s('common.offlineSaved')),
      ),
    );
  }
}

class _OfflineChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s10, vertical: ProtoSpace.s6),
      decoration: BoxDecoration(
        color: p.warningSubtle,
        borderRadius: BorderRadius.circular(ProtoRadius.pill),
        border: Border.all(color: p.warningBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done_rounded, size: 13, color: p.warning),
          const SizedBox(width: ProtoSpace.s6),
          Text(
            context.s('tech.offline.chip'),
            style: context.types.metadata.copyWith(color: p.warning, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _JobIdentity extends StatelessWidget {
  final TechnicianJobFixture job;
  final _JobStage stage;
  final int completed;
  final int total;

  const _JobIdentity({required this.job, required this.stage, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                job.jobCardNo,
                style: types.monoStrong.copyWith(color: p.primary, fontSize: 14),
              ),
              const Spacer(),
              _StagePill(stage: stage),
            ],
          ),
          const SizedBox(height: ProtoSpace.s10),
          Text(
            job.vehicleLabel,
            style: types.displaySmall.copyWith(color: p.textPrimary, fontSize: 22),
          ),
          const SizedBox(height: ProtoSpace.s8),
          Wrap(
            spacing: ProtoSpace.s8,
            runSpacing: ProtoSpace.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ProtoPlateChip(plate: job.plate, large: true),
              Text(
                job.customer.of(context),
                style: types.bodySmall.copyWith(color: p.textMuted),
              ),
              if (total > 0)
                Text(
                  '· ${job.dateOfWork.of(context)}',
                  style: types.metadata.copyWith(color: p.textDisabled),
                ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: ProtoSpace.s16),
            ProtoProgress(
              value: total == 0 ? 0 : completed / total,
              label: context.s('tech.progress', {'done': '$completed', 'total': '$total'}),
            ),
          ],
        ],
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  final _JobStage stage;

  const _StagePill({required this.stage});

  @override
  Widget build(BuildContext context) {
    final (key, tone) = switch (stage) {
      _JobStage.active => ('tech.stage.inProgress', ProtoTone.primary),
      _JobStage.delayed => ('tech.stage.delayed', ProtoTone.danger),
      _JobStage.qc => ('tech.stage.qc', ProtoTone.info),
      _JobStage.completed => ('tech.stage.completed', ProtoTone.success),
    };
    return ProtoStatusPill(label: context.s(key), tone: tone);
  }
}

class _ContextRow extends StatelessWidget {
  final TechnicianJobFixture job;
  final _JobStage stage;

  const _ContextRow({required this.job, required this.stage});

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String label, String value) {
      final p = context.palette;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s10),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
            border: Border.all(color: p.borderDefault),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: p.textMuted),
              const SizedBox(width: ProtoSpace.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.types.metadata.copyWith(color: p.textMuted, fontSize: 11)),
                    // Context values (bay, promised window) stay on one line;
                    // they scale down instead of truncating mid-word.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        value,
                        maxLines: 1,
                        softWrap: false,
                        style: context.types.bodyStrong.copyWith(color: p.textPrimary, fontSize: 12.5),
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

    return Row(
      children: [
        chip(Icons.schedule_rounded, context.s('tech.promised'), job.promised.of(context)),
        const SizedBox(width: ProtoSpace.s10),
        chip(Icons.garage_rounded, context.s('tech.bay'), context.s('tech.bayValue')),
      ],
    );
  }
}

class _ExecutionColumn extends StatelessWidget {
  final TechnicianJobFixture job;
  final List<TechnicianTaskFixture> tasks;
  final _JobStage stage;
  final bool actionable;
  final String? busyTask;
  final int completed;
  final void Function(TechnicianTaskFixture) onStart;
  final void Function(TechnicianTaskFixture) onHold;
  final void Function(TechnicianTaskFixture) onComplete;

  const _ExecutionColumn({
    required this.job,
    required this.tasks,
    required this.stage,
    required this.actionable,
    required this.busyTask,
    required this.completed,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final running = tasks.where((t) => t.status == FixtureTaskStatus.inProgress).firstOrNull;
    final pending = tasks.where((t) => t.status == FixtureTaskStatus.pending).firstOrNull;
    final held = tasks.where((t) => t.status == FixtureTaskStatus.onHold).firstOrNull;
    final allDone = tasks.isNotEmpty && completed == tasks.length;

    final title = tasks.isEmpty
        ? context.s('tech.noTasksTitle')
        : allDone
            ? context.s('tech.tasksComplete')
            : running != null
                ? context.s('tech.currentTask')
                : context.s('tech.nextTask');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stage == _JobStage.delayed) ...[
          ProtoInfoPanel(
            tone: ProtoTone.danger,
            icon: Icons.pause_circle_outline_rounded,
            text: context.s('tech.delayed.body'),
          ),
          const SizedBox(height: ProtoSpace.s16),
        ],
        ProtoSectionHeader(eyebrow: context.s('tech.eyebrow.execution'), title: title),
        const SizedBox(height: ProtoSpace.s12),
        _FocusPanel(
          job: job,
          tasks: tasks,
          stage: stage,
          actionable: actionable,
          busyTask: busyTask,
          running: running,
          pending: pending,
          held: held,
          onStart: onStart,
          onHold: onHold,
          onComplete: onComplete,
        ),
        if (tasks.isNotEmpty) ...[
          const SizedBox(height: ProtoSpace.s20),
          ProtoSectionHeader(
            eyebrow: context.s('tech.eyebrow.tasks'),
            title: context.s('tech.tasksAssigned', {'n': '${tasks.length}'}),
          ),
          const SizedBox(height: ProtoSpace.s10),
          for (var i = 0; i < tasks.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == tasks.length - 1 ? 0 : ProtoSpace.s10),
              child: _TaskRow(
                index: i + 1,
                task: tasks[i],
                actionable: actionable,
                busy: busyTask == tasks[i].id.toString(),
                onStart: onStart,
                onHold: onHold,
                onComplete: onComplete,
              ),
            ),
        ],
      ],
    );
  }
}

class _FocusPanel extends StatelessWidget {
  final TechnicianJobFixture job;
  final List<TechnicianTaskFixture> tasks;
  final _JobStage stage;
  final bool actionable;
  final String? busyTask;
  final TechnicianTaskFixture? running;
  final TechnicianTaskFixture? pending;
  final TechnicianTaskFixture? held;
  final void Function(TechnicianTaskFixture) onStart;
  final void Function(TechnicianTaskFixture) onHold;
  final void Function(TechnicianTaskFixture) onComplete;

  const _FocusPanel({
    required this.job,
    required this.tasks,
    required this.stage,
    required this.actionable,
    required this.busyTask,
    required this.running,
    required this.pending,
    required this.held,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;

    if (tasks.isEmpty) {
      return ProtoCard(
        child: Text(
          context.s('tech.noTasksBody'),
          style: types.bodySmall.copyWith(color: p.textMuted, height: 1.5),
        ),
      );
    }

    if (!actionable) {
      final qc = stage == _JobStage.qc;
      return ProtoCard(
        tone: qc ? ProtoTone.info : ProtoTone.success,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              qc ? Icons.fact_check_rounded : Icons.verified_rounded,
              color: qc ? p.info : p.success,
            ),
            const SizedBox(width: ProtoSpace.s10),
            Expanded(
              child: Text(
                qc ? context.s('tech.qc.notice') : context.s('tech.completed.notice'),
                style: types.bodyStrong.copyWith(color: p.textPrimary, height: 1.45),
              ),
            ),
          ],
        ),
      );
    }

    final active = running ?? pending ?? held;
    final busy = active != null && busyTask == active.id.toString();

    final (eyebrowKey, labelKey, icon, action) = switch ((running, pending, held)) {
      (final r?, _, _) => (
          'tech.task.current',
          busy ? 'tech.action.completing' : 'tech.action.completeTask',
          Icons.check_rounded,
          () => onComplete(r),
        ),
      (_, final pd?, _) => (
          'tech.task.next',
          busy ? 'tech.action.starting' : 'tech.action.startNext',
          Icons.play_arrow_rounded,
          () => onStart(pd),
        ),
      (_, _, final h?) => (
          'tech.task.onHold',
          busy ? 'tech.action.resuming' : 'tech.action.resume',
          Icons.play_arrow_rounded,
          () => onStart(h),
        ),
      _ => (null, null, null, null),
    };

    return Container(
      padding: const EdgeInsets.all(ProtoSpace.s16),
      decoration: BoxDecoration(
        color: running != null
            ? Color.alphaBlend(p.primary.withValues(alpha: 0.05), p.surface)
            : p.surface,
        borderRadius: BorderRadius.circular(ProtoRadius.panel),
        border: Border.all(
          color: running != null ? p.primaryBorder : p.borderDefault,
          width: running != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (eyebrowKey != null)
                Text(
                  context.s(eyebrowKey),
                  style: types.eyebrow.copyWith(color: p.primary),
                ),
              const Spacer(),
              if (active != null && active.status == FixtureTaskStatus.inProgress && active.startTime != null)
                Text(
                  context.s('tech.startedAt', {'time': active.startTime!}),
                  style: types.metadata.copyWith(color: p.textMuted),
                ),
            ],
          ),
          const SizedBox(height: ProtoSpace.s8),
          Text(
            active?.description.of(context) ?? '',
            style: types.cardTitle.copyWith(color: p.textPrimary, fontSize: 16, height: 1.4),
          ),
          if (labelKey != null) ...[
            const SizedBox(height: ProtoSpace.s14),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: busy ? null : action,
                icon: Icon(icon, size: 19),
                label: Text(context.s(labelKey)),
              ),
            ),
            if (running != null) ...[
              const SizedBox(height: ProtoSpace.s8),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => onHold(running!),
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: Text(context.s('tech.action.hold')),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final int index;
  final TechnicianTaskFixture task;
  final bool actionable;
  final bool busy;
  final void Function(TechnicianTaskFixture) onStart;
  final void Function(TechnicianTaskFixture) onHold;
  final void Function(TechnicianTaskFixture) onComplete;

  const _TaskRow({
    required this.index,
    required this.task,
    required this.actionable,
    required this.busy,
    required this.onStart,
    required this.onHold,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final done = task.status == FixtureTaskStatus.completed;
    final running = task.status == FixtureTaskStatus.inProgress;
    final held = task.status == FixtureTaskStatus.onHold;
    final tone = done
        ? p.success
        : running
            ? p.primary
            : held
                ? p.warning
                : p.textMuted;

    return Semantics(
      label: 'Task $index, ${task.description.en}, ${task.status.name}',
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.all(ProtoSpace.s14),
        decoration: BoxDecoration(
          color: running ? Color.alphaBlend(p.primary.withValues(alpha: 0.04), p.surface) : p.surface,
          borderRadius: BorderRadius.circular(ProtoRadius.card),
          border: Border.all(
            color: running ? p.primaryBorder : p.borderDefault,
            width: running ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(ProtoRadius.control),
                  ),
                  child: Icon(_iconFor(task.status), size: 17, color: tone),
                ),
                const SizedBox(width: ProtoSpace.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.description.of(context),
                        style: types.bodyStrong.copyWith(
                          color: p.textPrimary,
                          fontWeight: done ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: ProtoSpace.s8,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            task.ref,
                            style: types.mono.copyWith(color: p.textDisabled, fontSize: 11),
                          ),
                          Text(
                            _statusLabel(context, task.status),
                            style: types.metadata.copyWith(color: tone, fontWeight: FontWeight.w700),
                          ),
                          if (task.startTime != null && task.endTime == null)
                            Text(
                              context.s('tech.startedAt', {'time': task.startTime!}),
                              style: types.metadata.copyWith(color: p.textMuted),
                            ),
                          if (done && task.startTime != null)
                            Text(
                              '${task.startTime} – ${task.endTime ?? ''}',
                              style: types.metadata.copyWith(color: p.textMuted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actionable && !done) ...[
              const SizedBox(height: ProtoSpace.s10),
              Wrap(
                spacing: ProtoSpace.s8,
                runSpacing: ProtoSpace.s8,
                children: [
                  if (task.status == FixtureTaskStatus.pending)
                    SizedBox(
                      height: ProtoSpace.touchTarget,
                      child: FilledButton.icon(
                        onPressed: busy ? null : () => onStart(task),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(
                          busy ? context.s('tech.action.starting') : context.s('tech.action.start'),
                        ),
                      ),
                    ),
                  if (running)
                    SizedBox(
                      height: ProtoSpace.touchTarget,
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : () => onHold(task),
                        icon: const Icon(Icons.pause_rounded, size: 18),
                        label: Text(context.s('tech.action.hold')),
                      ),
                    ),
                  if (held)
                    SizedBox(
                      height: ProtoSpace.touchTarget,
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : () => onStart(task),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(context.s('tech.action.resume')),
                      ),
                    ),
                  if (running)
                    SizedBox(
                      height: ProtoSpace.touchTarget,
                      child: FilledButton.icon(
                        onPressed: busy ? null : () => onComplete(task),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          busy ? context.s('tech.action.completing') : context.s('tech.action.complete'),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, FixtureTaskStatus status) => switch (status) {
        FixtureTaskStatus.pending => context.s('tech.action.start'),
        FixtureTaskStatus.inProgress => context.s('tech.stage.inProgress'),
        FixtureTaskStatus.onHold => context.s('tech.action.hold'),
        FixtureTaskStatus.completed => context.s('tech.stage.completed'),
      };

  IconData _iconFor(FixtureTaskStatus status) => switch (status) {
        FixtureTaskStatus.completed => Icons.check_circle_rounded,
        FixtureTaskStatus.inProgress => Icons.play_circle_fill_rounded,
        FixtureTaskStatus.onHold => Icons.pause_circle_filled_rounded,
        FixtureTaskStatus.pending => Icons.radio_button_unchecked_rounded,
      };
}

class _ContextColumn extends StatelessWidget {
  final TechnicianJobFixture job;
  final _JobStage stage;
  final bool actionable;
  final bool canComplete;
  final bool saving;
  final VoidCallback onRequestPart;
  final VoidCallback onEscalate;
  final VoidCallback onCompleteRepair;

  const _ContextColumn({
    required this.job,
    required this.stage,
    required this.actionable,
    required this.canComplete,
    required this.saving,
    required this.onRequestPart,
    required this.onEscalate,
    required this.onCompleteRepair,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProtoSectionHeader(
                eyebrow: context.s('tech.vehicle.title'),
                title: job.vehicleLabel,
              ),
              const SizedBox(height: ProtoSpace.s10),
              ProtoKeyValueRow(label: 'VIN', value: job.vin, valueStyle: types.mono.copyWith(color: p.textPrimary, fontSize: 12)),
              ProtoKeyValueRow(label: context.s('tech.vehicle.odometer'), value: job.odometer.of(context)),
              ProtoKeyValueRow(label: context.s('tech.vehicle.fuel'), value: job.fuel.of(context)),
              ProtoKeyValueRow(label: context.s('tech.promised'), value: job.promised.of(context)),
            ],
          ),
        ),
        const SizedBox(height: ProtoSpace.s12),
        ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProtoSectionHeader(
                eyebrow: context.s('tech.customer.title'),
                title: job.customer.of(context),
              ),
              const SizedBox(height: ProtoSpace.s6),
              Text(job.phone, style: types.mono.copyWith(color: p.textMuted)),
              const SizedBox(height: ProtoSpace.s12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final call = OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.call_rounded, size: 17),
                    label: Text(context.s('tech.customer.call')),
                  );
                  final whatsapp = OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_rounded, size: 17),
                    label: Text(context.s('tech.customer.whatsapp')),
                  );
                  // Narrow columns stack the contact actions so the WhatsApp
                  // label never wraps mid-word.
                  if (constraints.maxWidth < 300) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [call, const SizedBox(height: ProtoSpace.s8), whatsapp],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: call),
                      const SizedBox(width: ProtoSpace.s8),
                      Expanded(child: whatsapp),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: ProtoSpace.s12),
        ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.s('tech.description.title'),
                style: types.cardTitle.copyWith(color: p.textPrimary),
              ),
              const SizedBox(height: ProtoSpace.s8),
              Text(
                context.s('tech.description.body'),
                style: types.bodySmall.copyWith(color: p.textMuted, height: 1.55),
              ),
            ],
          ),
        ),
        if (stage != _JobStage.completed) ...[
          const SizedBox(height: ProtoSpace.s20),
          ProtoSectionHeader(
            eyebrow: context.s('tech.eyebrow.help'),
            title: context.s('tech.support.title'),
          ),
          const SizedBox(height: ProtoSpace.s10),
          if (!context.windowClass.isCompact) ...[
            SizedBox(
              height: ProtoSpace.touchTarget,
              child: OutlinedButton.icon(
                onPressed: onRequestPart,
                icon: const Icon(Icons.build_circle_outlined, size: 18),
                label: Text(context.s('tech.action.requestPart')),
              ),
            ),
            const SizedBox(height: ProtoSpace.s10),
            SizedBox(
              height: ProtoSpace.touchTarget,
              child: OutlinedButton.icon(
                onPressed: onEscalate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.danger,
                  side: BorderSide(color: p.danger.withValues(alpha: 0.6)),
                ),
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: Text(context.s('tech.action.escalate')),
              ),
            ),
          ],
          if (canComplete) ...[
            const SizedBox(height: ProtoSpace.s16),
            SizedBox(
              height: ProtoSpace.touchTarget,
              child: OutlinedButton.icon(
                onPressed: saving ? null : onCompleteRepair,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(context.s('tech.action.completeRepair')),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _StickyActionBar extends StatelessWidget {
  final bool saving;
  final bool canComplete;
  final VoidCallback onRequestPart;
  final VoidCallback onEscalate;
  final VoidCallback onCompleteRepair;

  const _StickyActionBar({
    required this.saving,
    required this.canComplete,
    required this.onRequestPart,
    required this.onEscalate,
    required this.onCompleteRepair,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.borderDefault)),
        boxShadow: ProtoElevation.surface,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ProtoSpace.s16, ProtoSpace.s10, ProtoSpace.s16, ProtoSpace.s10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRequestPart,
                  icon: const Icon(Icons.build_circle_outlined, size: 17),
                  label: Text(context.s('tech.action.requestPart')),
                ),
              ),
              const SizedBox(width: ProtoSpace.s8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEscalate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.danger,
                    side: BorderSide(color: p.danger.withValues(alpha: 0.6)),
                  ),
                  icon: const Icon(Icons.warning_amber_rounded, size: 17),
                  label: Text(context.s('tech.action.escalate')),
                ),
              ),
              if (canComplete) ...[
                const SizedBox(width: ProtoSpace.s8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: saving ? null : onCompleteRepair,
                    icon: saving
                        ? SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(p.surface),
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 17),
                    label: Text(context.s('tech.action.completeRepair')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSheet extends StatefulWidget {
  final String title;
  final String body;
  final String submitLabel;
  final List<({String label, String hint, IconData icon})> fields;
  final bool destructive;
  final VoidCallback onSubmit;

  const _SupportSheet({
    required this.title,
    required this.body,
    required this.submitLabel,
    required this.fields,
    this.destructive = false,
    required this.onSubmit,
  });

  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<_SupportSheet> {
  int _filled = 0;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ProtoSpace.s20, ProtoSpace.s8, ProtoSpace.s20, ProtoSpace.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: types.sectionTitle.copyWith(color: p.textPrimary)),
            const SizedBox(height: ProtoSpace.s6),
            Text(widget.body, style: types.bodySmall.copyWith(color: p.textMuted, height: 1.5)),
            const SizedBox(height: ProtoSpace.s16),
            for (final field in widget.fields) ...[
              Row(
                children: [
                  Icon(field.icon, size: 16, color: p.textMuted),
                  const SizedBox(width: ProtoSpace.s8),
                  Expanded(
                    child: TextField(
                      onChanged: (_) => setState(() => _filled++),
                      decoration: InputDecoration(labelText: field.label, hintText: field.hint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ProtoSpace.s12),
            ],
            SizedBox(
              height: ProtoSpace.touchTarget,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSubmit();
                },
                style: widget.destructive
                    ? FilledButton.styleFrom(backgroundColor: p.danger)
                    : null,
                child: Text(widget.submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ProtoSpace.s16),
      child: ProtoPageFrame(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProtoSkeleton(height: 170, radius: ProtoRadius.card),
            const SizedBox(height: ProtoSpace.s12),
            Row(
              children: const [
                Expanded(child: ProtoSkeleton(height: 56, radius: ProtoRadius.control)),
                SizedBox(width: ProtoSpace.s10),
                Expanded(child: ProtoSkeleton(height: 56, radius: ProtoRadius.control)),
              ],
            ),
            const SizedBox(height: ProtoSpace.s24),
            const ProtoSkeleton(height: 18, width: 140),
            const SizedBox(height: ProtoSpace.s12),
            const ProtoSkeleton(height: 150, radius: ProtoRadius.panel),
            const SizedBox(height: ProtoSpace.s20),
            for (var i = 0; i < 4; i++) ...[
              const ProtoSkeleton(height: 84, radius: ProtoRadius.card),
              const SizedBox(height: ProtoSpace.s10),
            ],
          ],
        ),
      ),
    );
  }
}
