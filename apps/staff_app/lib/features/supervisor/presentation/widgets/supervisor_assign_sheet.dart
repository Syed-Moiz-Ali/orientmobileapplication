import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── 1. UBER-STYLE QUICK SEARCH BAR ─────────────────────────────────
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _ModernSearchField(
              hint: 'Search job card number or registration...',
              onChanged: notifier.updateJobCardSearch,
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),

          // ── 2. WORK ASSIGNMENT CARDS ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Technician Task Roster',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                      _PressScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.addAssignmentRow();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded, color: colorScheme.onPrimary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Add Task',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.assignmentRows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState(
                        icon: Icons.assignment_late_outlined,
                        message: 'No task assignments configured',
                      ),
                    )
                  else
                    ...state.assignmentRows.asMap().entries.map(
                      (e) => Padding(
                        key: ValueKey(e.value.id),
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AssignmentCard(
                          row: e.value,
                          index: e.key + 1,
                          departments: notifier.departments,
                          technicians: notifier.technicians,
                          onDelete: () {
                            HapticFeedback.selectionClick();
                            notifier.removeAssignmentRow(e.value.id);
                          },
                          onChanged: (updated) => notifier.updateAssignmentRow(e.value.id, updated),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Task Specifications',
                  style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: colorScheme.error, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _FormFieldWrapper(
                  label: 'Work Description',
                  child: _PersistentFieldInput(
                    controller: _descCtrl,
                    hint: 'Describe component diagnostics, part replacement, or servicing...',
                    onChanged: (v) => widget.onChanged(widget.row.copyWith(description: v)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _FormFieldWrapper(
                        label: 'Department',
                        child: _ThemePillDropdown(
                          value: widget.row.department.isEmpty ? null : widget.row.department,
                          hint: 'Select Bay',
                          items: widget.departments,
                          onChanged: (v) => widget.onChanged(widget.row.copyWith(department: v ?? '')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormFieldWrapper(
                        label: 'Technician',
                        child: _ThemePillDropdown(
                          value: widget.row.technicianName.isEmpty ? null : widget.row.technicianName,
                          hint: 'Assign Staff',
                          items: widget.technicians,
                          onChanged: (v) => widget.onChanged(widget.row.copyWith(technicianName: v ?? '')),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _FormFieldWrapper(
                        label: 'Date of Work',
                        child: _PersistentFieldInput(
                          controller: _dateCtrl,
                          hint: 'YYYY-MM-DD',
                          onChanged: (v) => widget.onChanged(widget.row.copyWith(dateOfWork: v)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormFieldWrapper(
                        label: 'Standard Time',
                        child: _PersistentFieldInput(
                          controller: _stdTimeCtrl,
                          hint: 'e.g. 2.5 hrs',
                          onChanged: (v) => widget.onChanged(widget.row.copyWith(stdTime: v)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _FormFieldWrapper(
                  label: 'Task Progress: ${widget.row.statusPercent}%',
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.surfaceContainerHighest,
                      thumbColor: colorScheme.primary,
                      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    child: Slider(
                      value: widget.row.statusPercent.toDouble(),
                      max: 100,
                      divisions: 20,
                      onChanged: (v) => widget.onChanged(widget.row.copyWith(statusPercent: v.toInt())),
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
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _PersistentFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final void Function(String) onChanged;

  const _PersistentFieldInput({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ThemePillDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final void Function(String?) onChanged;

  const _ThemePillDropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
          dropdownColor: colorScheme.surface,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurfaceVariant, size: 18),
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        ),
      ),
    );
  }
}

class _ModernSearchField extends StatelessWidget {
  final String hint;
  final void Function(String) onChanged;
  const _ModernSearchField({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 20),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
