import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

/// Full workspace for assigning tasks to floor technicians.
class SupervisorAssignSheet extends ConsumerWidget {
  const SupervisorAssignSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // ── 1. TARGET JOB CARD HEADER ─────────────────────────────
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Target Job Card',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (state.jobCardSearch.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state.jobCardSearch.trim(),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppSearchField(
                      hintText: 'Job Card Number (e.g. JC-2026-1042)',
                      onChanged: notifier.updateJobCardSearch,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),

              // ── 2. TASK ROSTER LIST ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Assignment Roster',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${state.assignmentRows.length} task${state.assignmentRows.length == 1 ? '' : 's'} configured',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              notifier.addAssignmentRow();
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Task'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Error banner
                      if (state.assignWorkError.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.assignWorkError,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Empty state
                      if (state.assignmentRows.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: EmptyState(
                              icon: Icons.assignment_late_outlined,
                              title: 'No tasks configured',
                              message:
                                  'Add tasks to assign workshop jobs to floor technicians.',
                              actionLabel: 'Add First Task',
                              onAction: () {
                                HapticFeedback.lightImpact();
                                notifier.addAssignmentRow();
                              },
                            ),
                          ),
                        )
                      else
                        ...state.assignmentRows.asMap().entries.map(
                          (e) => Padding(
                            key: ValueKey(e.value.id),
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _AssignmentCard(
                              row: e.value,
                              index: e.key + 1,
                              departments: notifier.departments,
                              technicians: notifier.technicians,
                              onDelete: () {
                                HapticFeedback.selectionClick();
                                notifier.removeAssignmentRow(e.value.id);
                              },
                              onChanged: (updated) => notifier
                                  .updateAssignmentRow(e.value.id, updated),
                            ),
                          ),
                        ),
                    ],
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

class _AssignmentCard extends StatefulWidget {
  final WorkAssignmentEntity row;
  final int index;
  final List<String> departments;
  final List<String> technicians;
  final VoidCallback onDelete;
  final void Function(WorkAssignmentEntity) onChanged;

  const _AssignmentCard({
    required this.row,
    required this.index,
    required this.departments,
    required this.technicians,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _stdTimeCtrl;
  late final TextEditingController _remarksCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.row.description);
    _dateCtrl = TextEditingController(text: widget.row.dateOfWork);
    _stdTimeCtrl = TextEditingController(text: widget.row.stdTime);
    _remarksCtrl = TextEditingController(text: widget.row.remarks);
  }

  @override
  void didUpdateWidget(covariant _AssignmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncIfNeeded(_descCtrl, widget.row.description, oldWidget.row.description);
    _syncIfNeeded(_dateCtrl, widget.row.dateOfWork, oldWidget.row.dateOfWork);
    _syncIfNeeded(_stdTimeCtrl, widget.row.stdTime, oldWidget.row.stdTime);
    _syncIfNeeded(_remarksCtrl, widget.row.remarks, oldWidget.row.remarks);
  }

  void _syncIfNeeded(TextEditingController ctrl, String newVal, String oldVal) {
    if (newVal != oldVal && ctrl.text != newVal) {
      ctrl.value = ctrl.value.copyWith(
        text: newVal,
        selection: TextSelection.collapsed(offset: newVal.length),
      );
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _stdTimeCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _dateCtrl.text = formatted;
      widget.onChanged(widget.row.copyWith(dateOfWork: formatted));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Task Specifications',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: colorScheme.error,
                  tooltip: 'Delete task',
                  onPressed: widget.onDelete,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // ── Card Body ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                _FormFieldWrapper(
                  label: 'Work Description',
                  child: TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    minLines: 1,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    onChanged: (v) =>
                        widget.onChanged(widget.row.copyWith(description: v)),
                    decoration: InputDecoration(
                      hintText:
                          'Describe repair, part replacement, or servicing task...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Department & Technician
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDepartmentField(colorScheme)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildTechnicianField(colorScheme)),
                    ],
                  )
                else ...[
                  _buildDepartmentField(colorScheme),
                  const SizedBox(height: 12),
                  _buildTechnicianField(colorScheme),
                ],
                const SizedBox(height: 14),

                // Date of Work & Standard Time
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDateField(colorScheme)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildStdTimeField(colorScheme)),
                    ],
                  )
                else ...[
                  _buildDateField(colorScheme),
                  const SizedBox(height: 12),
                  _buildStdTimeField(colorScheme),
                ],
                const SizedBox(height: 14),

                // Status Percent Slider
                _FormFieldWrapper(
                  label: 'Initial Progress: ${widget.row.statusPercent}%',
                  child: Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                            activeTrackColor: colorScheme.primary,
                            inactiveTrackColor:
                                colorScheme.surfaceContainerHighest,
                            thumbColor: colorScheme.primary,
                            overlayColor: colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                          ),
                          child: Slider(
                            value: widget.row.statusPercent.toDouble(),
                            max: 100,
                            divisions: 20,
                            onChanged: (v) => widget.onChanged(
                              widget.row.copyWith(statusPercent: v.toInt()),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${widget.row.statusPercent}%',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Remarks
                _FormFieldWrapper(
                  label: 'Remarks (Optional)',
                  child: TextField(
                    controller: _remarksCtrl,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                    onChanged: (v) =>
                        widget.onChanged(widget.row.copyWith(remarks: v)),
                    decoration: InputDecoration(
                      hintText: 'Notes for technician, bay instructions...',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentField(ColorScheme colorScheme) {
    return _FormFieldWrapper(
      label: 'Department / Section',
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.row.department.isEmpty ? null : widget.row.department,
            hint: Text(
              'Select Department',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            dropdownColor: colorScheme.surface,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
            isExpanded: true,
            onChanged: (v) =>
                widget.onChanged(widget.row.copyWith(department: v ?? '')),
            items: widget.departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicianField(ColorScheme colorScheme) {
    return _FormFieldWrapper(
      label: 'Assigned Technician',
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.row.technicianName.isEmpty
                ? null
                : widget.row.technicianName,
            hint: Text(
              'Select Technician',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            dropdownColor: colorScheme.surface,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ),
            isExpanded: true,
            onChanged: (v) =>
                widget.onChanged(widget.row.copyWith(technicianName: v ?? '')),
            items: widget.technicians
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(ColorScheme colorScheme) {
    return _FormFieldWrapper(
      label: 'Date of Work',
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.row.dateOfWork.isEmpty
                      ? 'Select Date (YYYY-MM-DD)'
                      : widget.row.dateOfWork,
                  style: TextStyle(
                    color: widget.row.dateOfWork.isEmpty
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStdTimeField(ColorScheme colorScheme) {
    return _FormFieldWrapper(
      label: 'Standard Time',
      child: TextField(
        controller: _stdTimeCtrl,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
        onChanged: (v) => widget.onChanged(widget.row.copyWith(stdTime: v)),
        decoration: InputDecoration(
          hintText: 'e.g. 2.5 hrs',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FormFieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormFieldWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
