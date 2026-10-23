// Follow-up checklist: priority flags, call reminders, overdue badges and
// the same complete/edit/delete flows. Due badges derive from parseable
// due dates only — free-text dates that cannot be parsed get no badge
// rather than a guessed one. There is no snooze endpoint, so none is
// offered (documented, not improvised).
//
// Presentation-only rebuild (brief `docs/ui-redesign/briefs/crm-tasks-list.md`):
// AppPageHeader + header find-aid (search icon only when > 5 loaded
// tasks), borderless cards with the toggle direct on each card and 48dp
// edit/delete targets, AppStatusChip pills, AppEmptyState, AppDialog
// delete confirm, AppBottomSheet form. Toggle/CRUD/due-badge derivation,
// refresh, team source and Keys are unchanged.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

/// Priority display kind by the stored English name (labels render via the
/// existing `tkHigh/Medium/Low` keys — same mapping as the form sheet —
/// so the AR pill reads localized copy; unknown server labels stay verbatim).
AppStatusKind _priorityKind(String priority) {
  switch (priority.toUpperCase()) {
    case 'HIGH':
      return AppStatusKind.error;
    case 'MEDIUM':
      return AppStatusKind.warning;
    default:
      return AppStatusKind.neutral;
  }
}

/// Localized priority label for the card chip (presentation display mapping
/// only; entity field is read verbatim, never rewritten).
String _priorityLabelOf(BuildContext context, String priority) {
  final t = context.cx;
  switch (priority.toUpperCase()) {
    case 'HIGH':
      return t.tkHigh;
    case 'MEDIUM':
      return t.tkMedium;
    case 'LOW':
      return t.tkLow;
    default:
      return priority;
  }
}

class CrmTasksPage extends ConsumerStatefulWidget {
  const CrmTasksPage({super.key});

  @override
  ConsumerState<CrmTasksPage> createState() => _CrmTasksPageState();
}

class _CrmTasksPageState extends ConsumerState<CrmTasksPage> {
  /// Row keys (presentation only; the search-result reveal that consumed
  /// them moved to the shell AppBar per ruling (a) — see STOP in the shell
  /// helper; no reveal closure remains here).
  final Map<String, GlobalKey> _scrollKeys = {};

  GlobalKey _scrollKeyFor(String id) =>
      _scrollKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final notifier = ref.read(crmTaskProvider.notifier);
    final tasks = ref.watch(crmTaskProvider).tasks;
    _scrollKeys.removeWhere((id, _) => !tasks.any((task) => task.id == id));

    // Ruling (a): the search find-aid relocated to the shell AppBar
    // (contextual per tab, same >5 condition, same tasks sheet) — the list
    // header shows no search icon; the shell trigger is the single visible
    // search path. Refresh + Add stay where they are.

    return Column(
      children: [
        Padding(
          // Plain-Row header (F6, owner/supervisor precedent, ruling (a):
          // no search icon here — the shell AppBar owns the single visible
          // search path). The title shares ONE Row with refresh + Add on
          // wide; on compact the title sits in row 1 and refresh + Add in
          // an end-aligned second header row (still header chrome, never
          // body). Rows mirror in RTL. Same sheets/targets — placement
          // only (search relocated to shell, same >5 gate, same sheet).
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleBlock = Expanded(
                child: Semantics(
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.navTasks,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (tasks.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          t.tkCountN(tasks.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
              List<Widget> utilityActions() => [
                    AppIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: t.chromeRefresh,
                      onPressed: () => notifier.refresh(),
                    ),
                    if (tasks.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _showTaskForm(context, ref),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(t.tkAdd),
                      ),
                  ];
              if (constraints.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(width: AppDimensions.s12),
                    ...utilityActions(),
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titleBlock],
                  ),
                  const SizedBox(height: AppDimensions.s8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: AppDimensions.s8,
                      runSpacing: AppDimensions.s8,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: utilityActions(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 64),
                    AppEmptyState(
                      icon: Icons.task_alt_rounded,
                      title: t.tkEmpty,
                      message: t.tkEmptyBody,
                      actionLabel: t.tkAdd,
                      onAction: () => _showTaskForm(context, ref),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => Container(
                      key: _scrollKeyFor(tasks[i].id),
                      child: _TaskCard(
                        task: tasks[i],
                        onToggle: () => notifier.toggleTask(tasks[i].id, !tasks[i].isDone),
                        onEdit: () => _showTaskForm(context, ref, task: tasks[i]),
                        onDelete: () => _confirmDelete(context, ref, tasks[i]),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showTaskForm(BuildContext context, WidgetRef ref, {CrmTaskEntity? task}) {
    final t = context.cx;
    return showAppModalSheet(
      context: context,
      title: task != null ? t.tkFormEdit : t.tkFormAdd,
      builder: (_) => _TaskFormSheet(task: task),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CrmTaskEntity task) async {
    final t = context.cx;
    final confirmed = await showAppDialog<bool>(
      context,
      title: t.tkDeleteTitle,
      message: t.tkDeleteBody(task.title),
      secondaryLabel: t.tkCancel,
      primaryLabel: t.tkDelete,
      destructive: true,
      onPrimary: () => Navigator.of(context).pop(true),
    );
    if (confirmed == true) {
      await ref.read(crmTaskProvider.notifier).deleteTask(task.id);
    }
  }
}

/// Task due state from the stored string. Only ISO-parseable dates produce
/// badges; anything else (including empty) yields none — never a guess.
enum _DueState { none, overdue, today, upcoming }

_DueState _dueStateOf(CrmTaskEntity task) {
  if (task.isDone) return _DueState.none;
  final due = DateTime.tryParse(task.dueDate.trim());
  if (due == null) return _DueState.none;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(due.year, due.month, due.day);
  if (day.isBefore(today)) return _DueState.overdue;
  if (day == today) return _DueState.today;
  return _DueState.upcoming;
}

class _TaskCard extends StatelessWidget {
  final CrmTaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TaskCard({required this.task, required this.onToggle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final due = _dueStateOf(task);

    return AppSurfaceCard(
      outlined: false,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            selected: task.isDone,
            label: task.isDone ? t.tkReopen : t.tkMarkDone,
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('taskToggle_${task.id}'),
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isDone ? colors.primary : colors.onSurfaceVariant,
                        width: 2,
                      ),
                      color: task.isDone ? colors.primary : Colors.transparent,
                    ),
                    child: task.isDone
                        ? Icon(Icons.check, color: colors.onPrimary, size: 14)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: task.isDone ? colors.onSurfaceVariant : colors.onSurface,
                      fontWeight: FontWeight.w600,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded, color: colors.onSurfaceVariant, size: 12),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              task.assignedTo.isEmpty ? t.tkUnassigned : task.assignedTo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, color: colors.onSurfaceVariant, size: 11),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              task.dueDate.isEmpty ? t.tkNoDue : task.dueDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (due == _DueState.overdue)
                        AppStatusChip(label: t.tkOverdue, kind: AppStatusKind.error),
                      if (due == _DueState.today)
                        AppStatusChip(label: t.tkDueToday, kind: AppStatusKind.warning),
                      AppStatusChip(label: _priorityLabelOf(context, task.priority), kind: _priorityKind(task.priority)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppIconButton(
            icon: Icons.edit_outlined,
            tooltip: t.tkFormEdit,
            filled: true,
            onPressed: onEdit,
          ),
          const SizedBox(width: 4),
          AppIconButton(
            icon: Icons.delete_outline_rounded,
            tooltip: t.tkDeleteTitle,
            filled: true,
            color: colors.error,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _TaskFormSheet extends ConsumerStatefulWidget {
  final CrmTaskEntity? task;
  const _TaskFormSheet({this.task});

  @override
  ConsumerState<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _assignCtrl;
  late final TextEditingController _dueCtrl;
  late String _priority;
  bool _busy = false;
  String? _error;

  static const _priorities = ['High', 'Medium', 'Low'];

  String _priorityLabel(String p) {
    final t = context.cx;
    return switch (p) {
      'High' => t.tkHigh,
      'Low' => t.tkLow,
      _ => t.tkMedium,
    };
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _assignCtrl = TextEditingController(text: widget.task?.assignedTo ?? '');
    _dueCtrl = TextEditingController(text: widget.task?.dueDate ?? '');
    _priority = widget.task?.priority ?? 'Medium';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _assignCtrl.dispose();
    _dueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInputField(
            label: t.tkFormTitle,
            controller: _titleCtrl,
            prefixIcon: Icons.task_alt_rounded,
            error: _error,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _assigneeDropdown(),
          const SizedBox(height: 12),
          AppInputField(
            label: t.tkFormDue,
            controller: _dueCtrl,
            prefixIcon: Icons.calendar_today_rounded,
            forceLtr: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          Text(
            t.tkFormPriority,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _priorities.map((p) {
              return AppChip(
                label: _priorityLabel(p),
                selected: _priority == p,
                onSelected: (_) => setState(() => _priority = p),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          AppPillButton.primary(
            label: widget.task != null ? t.tkSaveChanges : t.tkFormAdd,
            busyLabel: t.tkSaving,
            isLoading: _busy,
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _assigneeDropdown() {
    final t = context.cx;
    final teamAsync = ref.watch(teamMembersProvider);
    return teamAsync.when(
      loading: () => AppInputField(
        label: t.tkFormAssigned,
        hint: t.tkLoadingTeam,
        enabled: false,
      ),
      error: (_, __) => AppBanner(
        kind: AppBannerKind.error,
        message: t.tkTeamFail,
      ),
      data: (members) {
        final options = [...members.map((m) => m.name), t.tkUnassigned];
        final current = _assignCtrl.text.isEmpty ? null : _assignCtrl.text;
        return AppDropdown<String>(
          label: t.tkFormAssigned,
          options: options,
          value: options.contains(current) ? current : null,
          hint: t.tkSelectAssignee,
          onChanged: (v) => setState(() => _assignCtrl.text = v ?? ''),
        );
      },
    );
  }

  Future<void> _save() async {
    final t = context.cx;
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = t.tkTitleRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(crmTaskProvider.notifier);
    if (widget.task != null) {
      await notifier.updateTask(
        widget.task!,
        title: _titleCtrl.text.trim(),
        assignedTo: _assignCtrl.text.trim() == t.tkUnassigned || _assignCtrl.text.trim() == 'Unassigned'
            ? ''
            : _assignCtrl.text.trim(),
        dueDate: _dueCtrl.text.trim(),
        priority: _priority,
      );
    } else {
      await notifier.addTask(
        title: _titleCtrl.text.trim(),
        assignedTo: _assignCtrl.text.trim() == t.tkUnassigned || _assignCtrl.text.trim() == 'Unassigned'
            ? ''
            : _assignCtrl.text.trim(),
        dueDate: _dueCtrl.text.trim(),
        priority: _priority,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}
