import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

/// Follow-up checklist: priority flags, call reminders, overdue badges and
/// the same complete/edit/delete flows. Due badges derive from parseable
/// due dates only — free-text dates that cannot be parsed get no badge
/// rather than a guessed one. There is no snooze endpoint, so none is
/// offered (documented, not improvised).
class CrmTasksPage extends ConsumerWidget {
  const CrmTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.cx;
    final notifier = ref.read(crmTaskProvider.notifier);
    final tasks = ref.watch(crmTaskProvider).tasks;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: CrmColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CrmColors.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  t.tkCount(tasks.length),
                  style: const TextStyle(
                    color: CrmColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => notifier.refresh(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CrmColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: CrmColors.accent, size: 17),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showTaskForm(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: CrmColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 15, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        t.tkAdd,
                        style: const TextStyle(
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
        Expanded(
          child: tasks.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  children: [
                    const SizedBox(height: 80),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: CrmColors.accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.task_alt_rounded, size: 36, color: CrmColors.accent),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        t.tkEmpty,
                        style: const TextStyle(
                          color: CrmColors.textH,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        t.tkEmptyBody,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: CrmColors.textM, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showTaskForm(context, ref),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(t.tkAdd),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CrmColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: () => notifier.refresh(),
                  color: CrmColors.accent,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.s16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s10),
                    itemBuilder: (_, i) => _TaskCard(
                      task: tasks[i],
                      onToggle: () => notifier.toggleTask(tasks[i].id, !tasks[i].isDone),
                      onEdit: () => _showTaskForm(context, ref, task: tasks[i]),
                      onDelete: () => _confirmDelete(context, ref, tasks[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showTaskForm(BuildContext context, WidgetRef ref, {CrmTaskEntity? task}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TaskFormSheet(task: task),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, CrmTaskEntity task) async {
    final t = context.cx;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.tkDeleteTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(t.tkDeleteBody(task.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.tkCancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: CrmColors.red, foregroundColor: Colors.white),
            child: Text(t.tkDelete),
          ),
        ],
      ),
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
    final due = _dueStateOf(task);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(
          color: due == _DueState.overdue ? CrmColors.red.withValues(alpha: 0.4) : CrmColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: CrmColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            selected: task.isDone,
            label: task.isDone ? t.tkReopen : t.tkMarkDone,
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('taskToggle_${task.id}'),
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isDone ? CrmColors.green : CrmColors.textM,
                    width: 2,
                  ),
                  color: task.isDone ? CrmColors.green : Colors.transparent,
                ),
                child: task.isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isDone ? CrmColors.textM : CrmColors.textH,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: AppDimensions.s12,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline_rounded, color: CrmColors.textM, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          task.assignedTo.isEmpty ? t.tkUnassigned : task.assignedTo,
                          style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: CrmColors.textM, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          task.dueDate.isEmpty ? t.tkNoDue : task.dueDate,
                          style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                        ),
                      ],
                    ),
                    if (due == _DueState.overdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: CrmColors.redBg,
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                        ),
                        child: Text(
                          t.tkOverdue,
                          style: const TextStyle(
                            color: CrmColors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    if (due == _DueState.today)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: CrmColors.amberBg,
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                        ),
                        child: Text(
                          t.tkDueToday,
                          style: const TextStyle(
                            color: CrmColors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: task.priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Text(
              task.priority,
              style: TextStyle(
                color: task.priorityColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CrmColors.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined, size: 14, color: CrmColors.accent),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CrmColors.redBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 14, color: CrmColors.red),
            ),
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
    final isEdit = widget.task != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CrmColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEdit ? t.tkFormEdit : t.tkFormAdd,
              style: const TextStyle(
                color: CrmColors.textH,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _field(t.tkFormTitle, _titleCtrl, Icons.task_alt_rounded),
            const SizedBox(height: 12),
            _assigneeDropdown(),
            const SizedBox(height: 12),
            _field(t.tkFormDue, _dueCtrl, Icons.calendar_today_rounded),
            const SizedBox(height: 12),
            Text(
              t.tkFormPriority,
              style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: _priorities.map((p) {
                final sel = _priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: EdgeInsets.only(right: p == _priorities.last ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? CrmColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? CrmColors.primary : CrmColors.border),
                      ),
                      child: Center(
                        child: Text(
                          _priorityLabel(p),
                          style: TextStyle(
                            color: sel ? Colors.white : CrmColors.textB,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CrmColors.redBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!, style: const TextStyle(color: CrmColors.red, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(isEdit ? Icons.save_outlined : Icons.add_rounded, size: 18),
                label: Text(_busy ? t.tkSaving : (isEdit ? t.tkSaveChanges : t.tkFormAdd)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CrmColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: CrmColors.textH, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 17, color: CrmColors.textM),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CrmColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CrmColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: CrmColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _assigneeDropdown() {
    final t = context.cx;
    final teamAsync = ref.watch(teamMembersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.tkFormAssigned, style: const TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        teamAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CrmColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 10),
                Text(t.tkLoadingTeam, style: const TextStyle(color: CrmColors.textM, fontSize: 13)),
              ],
            ),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CrmColors.redBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(t.tkTeamFail, style: const TextStyle(color: CrmColors.red, fontSize: 12)),
          ),
          data: (members) {
            final options = [...members.map((m) => m.name), t.tkUnassigned];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CrmColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: options.contains(_assignCtrl.text) ? _assignCtrl.text : null,
                  hint: Text(
                    _assignCtrl.text.isEmpty ? t.tkSelectAssignee : _assignCtrl.text,
                    style: const TextStyle(color: CrmColors.textM, fontSize: 13),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: CrmColors.textH, fontSize: 13),
                  isExpanded: true,
                  items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (v) => setState(() => _assignCtrl.text = v ?? ''),
                ),
              ),
            );
          },
        ),
      ],
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
