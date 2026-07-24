// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorAssignSheet extends ConsumerWidget {
  const SupervisorAssignSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);

    return Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: _SearchField(
            hint: 'Search or enter job card number...',
            onChanged: notifier.updateJobCardSearch,
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Work Assignments',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    _TealChipButton(
                      icon: Icons.add_rounded,
                      label: 'Add Task',
                      onTap: notifier.addAssignmentRow,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s16),
                ...state.assignmentRows.asMap().entries.map(
                  (e) => Padding(
                    key: ValueKey(e.value.id),
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _AssignmentCard(
                      row: e.value,
                      index: e.key + 1,
                      departments: notifier.departments,
                      technicians: notifier.technicians,
                      onDelete: () => notifier.removeAssignmentRow(e.value.id),
                      onChanged: (updated) =>
                          notifier.updateAssignmentRow(e.value.id, updated),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.r9),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Task Details',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(AppDimensions.r9),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              children: [
                _FormRow(
                  label: 'Description of Work',
                  child: _PersistentInput(
                    controller: _descCtrl,
                    hint: 'Enter work description...',
                    onChanged: (v) =>
                        widget.onChanged(widget.row.copyWith(description: v)),
                  ),
                ),
                const SizedBox(height: AppDimensions.s14),
                Row(
                  children: [
                    Expanded(
                      child: _FormRow(
                        label: 'Department',
                        child: _LightDropdown(
                          value: widget.row.department.isEmpty
                              ? null
                              : widget.row.department,
                          hint: 'Select',
                          items: widget.departments,
                          onChanged: (v) => widget.onChanged(
                            widget.row.copyWith(department: v ?? ''),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: _FormRow(
                        label: 'Technician',
                        child: _LightDropdown(
                          value: widget.row.technicianName.isEmpty
                              ? null
                              : widget.row.technicianName,
                          hint: 'Select',
                          items: widget.technicians,
                          onChanged: (v) => widget.onChanged(
                            widget.row.copyWith(technicianName: v ?? ''),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s14),
                Row(
                  children: [
                    Expanded(
                      child: _FormRow(
                        label: 'Date of Work',
                        child: _PersistentInput(
                          controller: _dateCtrl,
                          hint: 'dd/mm/yyyy',
                          onChanged: (v) => widget.onChanged(
                            widget.row.copyWith(dateOfWork: v),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: _FormRow(
                        label: 'Std Time',
                        child: _PersistentInput(
                          controller: _stdTimeCtrl,
                          hint: '2h 30m',
                          onChanged: (v) =>
                              widget.onChanged(widget.row.copyWith(stdTime: v)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s14),
                _FormRow(
                  label: 'Status Completion: ${widget.row.statusPercent}%',
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 9,
                      ),
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.borderMd,
                      thumbColor: AppColors.accent,
                      overlayColor: AppColors.accent.withValues(alpha: 0.12),
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
                const SizedBox(height: AppDimensions.s14),
                _FormRow(
                  label: 'Remarks (optional)',
                  child: _PersistentInput(
                    controller: _remarksCtrl,
                    hint: 'Add any notes...',
                    maxLines: 2,
                    onChanged: (v) =>
                        widget.onChanged(widget.row.copyWith(remarks: v)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.rajdhaniLabel(color: AppColors.text2)),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

class _PersistentInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final void Function(String) onChanged;

  const _PersistentInput({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r11),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r11),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r11),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _LightDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;

  const _LightDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppDimensions.r11),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(color: AppColors.text3, fontSize: 13),
          ),
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.text3,
            size: 18,
          ),
          isExpanded: true,
          onChanged: onChanged,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final void Function(String) onChanged;
  const _SearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.text3,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r13),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r13),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r13),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _TealChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TealChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.navy, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.r22),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: AppDimensions.iconSm),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
