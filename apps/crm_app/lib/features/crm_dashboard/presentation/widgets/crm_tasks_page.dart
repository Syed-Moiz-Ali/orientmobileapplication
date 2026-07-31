import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';

class CrmTasksPage extends ConsumerWidget {
  const CrmTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  '${tasks.length} Tasks',
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 15, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Add Task',
                        style: TextStyle(
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
                      decoration: BoxDecoration(
                        color: CrmColors.accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.task_alt_rounded, size: 36, color: CrmColors.accent),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'No tasks yet',
                        style: TextStyle(
                          color: CrmColors.textH,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Create tasks for your team to follow up on leads',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: CrmColors.textM, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showTaskForm(context, ref),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Task'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: CrmColors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(crmTaskProvider.notifier).deleteTask(task.id);
    }
  }
}

class _TaskCard extends StatelessWidget {
  final CrmTaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TaskCard({required this.task, required this.onToggle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: CrmColors.border),
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
          GestureDetector(
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
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: CrmColors.textM, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      task.assignedTo.isEmpty ? 'Unassigned' : task.assignedTo,
                      style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    const Icon(Icons.calendar_today_rounded, color: CrmColors.textM, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate.isEmpty ? 'No due date' : task.dueDate,
                      style: const TextStyle(color: CrmColors.textM, fontSize: 11),
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
              isEdit ? 'Edit Task' : 'Add Task',
              style: const TextStyle(
                color: CrmColors.textH,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _field('Task Title', _titleCtrl, Icons.task_alt_rounded),
            const SizedBox(height: 12),
            _assigneeDropdown(),
            const SizedBox(height: 12),
            _field('Due Date', _dueCtrl, Icons.calendar_today_rounded),
            const SizedBox(height: 12),
            const Text(
              'Priority',
              style: TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700),
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
                          p,
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
                label: Text(_busy ? 'Saving...' : (isEdit ? 'Save Changes' : 'Add Task')),
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
    final teamAsync = ref.watch(teamMembersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned To', style: TextStyle(color: CrmColors.textM, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        teamAsync.when(
          loading: () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CrmColors.border),
            ),
            child: const Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 10),
                Text('Loading team...', style: TextStyle(color: CrmColors.textM, fontSize: 13)),
              ],
            ),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: CrmColors.redBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Could not load team', style: TextStyle(color: CrmColors.red, fontSize: 12)),
          ),
          data: (members) {
            final options = [...members.map((m) => m.name), 'Unassigned'];
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
                    _assignCtrl.text.isEmpty ? 'Select assignee' : _assignCtrl.text,
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
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Task title is required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(crmTaskProvider.notifier);
    final assigned = _assignCtrl.text.trim() == 'Unassigned' ? '' : _assignCtrl.text.trim();
    if (widget.task != null) {
      await notifier.updateTask(
        widget.task!,
        title: _titleCtrl.text.trim(),
        assignedTo: assigned,
        dueDate: _dueCtrl.text.trim(),
        priority: _priority,
      );
    } else {
      await notifier.addTask(
        title: _titleCtrl.text.trim(),
        assignedTo: assigned,
        dueDate: _dueCtrl.text.trim(),
        priority: _priority,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}
