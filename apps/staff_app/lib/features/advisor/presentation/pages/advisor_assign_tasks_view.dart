import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';

class TaskDraft {
  String description;
  bool selected;
  TaskDraft({required this.description, this.selected = true});
}

class AdvisorAssignTasksView extends ConsumerStatefulWidget {
  final String jobCardRef;

  const AdvisorAssignTasksView({super.key, required this.jobCardRef});

  @override
  ConsumerState<AdvisorAssignTasksView> createState() => _AdvisorAssignTasksViewState();
}

class _AdvisorAssignTasksViewState extends ConsumerState<AdvisorAssignTasksView> {
  final List<TaskDraft> _tasks = [TaskDraft(description: '', selected: true)];
  String? _selectedTechnicianId;
  DateTime? _estimatedCompletion;
  bool _isLoading = false;

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _estimatedCompletion = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _assignTasks() async {
    final selectedTasks = _tasks.where((t) => t.selected && t.description.trim().isNotEmpty).toList();
    if (_selectedTechnicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a technician')));
      return;
    }
    if (selectedTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one task')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final ok = await remote.assignTasks(widget.jobCardRef, {
        'technicianId': _selectedTechnicianId,
        'estimatedCompletion': _estimatedCompletion?.toIso8601String(),
        'tasks': selectedTasks.map((t) => {'description': t.description.trim()}).toList(),
      });
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tasks assigned successfully')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to assign tasks')));
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final techniciansAsync = ref.watch(advisorTechniciansProvider);
    final technicians = techniciansAsync.value ?? [];

    final validTasksCount = _tasks.where((t) => t.selected && t.description.trim().isNotEmpty).length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technician Task Allocation',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              widget.jobCardRef,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: AppFontFamilies.mono,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                disabledForegroundColor: colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r16),
                ),
              ),
              onPressed: (_isLoading || _selectedTechnicianId == null || validTasksCount == 0) ? null : _assignTasks,
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      'Dispatch $validTasksCount Task${validTasksCount == 1 ? '' : 's'} to Bay',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── 1. SELECT TECHNICIAN CARD ────────────────────────────────
              Text(
                'Assignee Technician',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              AppCard(
                padding: const EdgeInsets.all(16),
                borderRadius: AppDimensions.r20,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_pin_rounded, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  hint: Text(
                    'Select Assigned Mechanic / Specialist',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  initialValue: _selectedTechnicianId,
                  items: technicians
                      .map(
                        (tech) => DropdownMenuItem(
                          value: tech.empId,
                          child: Text(
                            '${tech.name} (${tech.empId})',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTechnicianId = v),
                ),
              ),
              const SizedBox(height: 28),

              // ── 2. TASKS CHECKLIST ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Work Item Tasks',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _tasks.add(TaskDraft(description: ''))),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              AppCard(
                padding: const EdgeInsets.all(16),
                borderRadius: AppDimensions.r24,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                child: Column(
                  children: [
                    for (int idx = 0; idx < _tasks.length; idx++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _tasks[idx].selected,
                              activeColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (v) => setState(() => _tasks[idx].selected = v ?? true),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: _tasks[idx].description,
                                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Flush brake fluid, replace oil filter…',
                                  hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerLow,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.r12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                onChanged: (v) => _tasks[idx].description = v,
                              ),
                            ),
                            if (_tasks.length > 1)
                              IconButton(
                                icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.error),
                                onPressed: () => setState(() => _tasks.removeAt(idx)),
                              ),
                          ],
                        ),
                      ),
                      if (idx < _tasks.length - 1)
                        Divider(height: 16, color: colorScheme.outlineVariant),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── 3. ESTIMATED COMPLETION ───────────────────────────────────
              Text(
                'Estimated Target Completion (Optional)',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _selectDateTime,
                borderRadius: BorderRadius.circular(AppDimensions.r20),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  borderRadius: AppDimensions.r20,
                  color: colorScheme.surface,
                  borderColor: colorScheme.outlineVariant,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                        ),
                        child: Icon(Icons.event_available_rounded, color: colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _estimatedCompletion == null
                                  ? 'Tap to select delivery deadline'
                                  : 'Target: ${_estimatedCompletion.toString().substring(0, 16)}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: _estimatedCompletion != null ? FontWeight.w800 : FontWeight.w500,
                                color: _estimatedCompletion != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.schedule_rounded, color: colorScheme.onSurfaceVariant, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
