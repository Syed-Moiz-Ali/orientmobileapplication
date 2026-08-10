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
    final techniciansAsync = ref.watch(advisorTechniciansProvider);
    final technicians = techniciansAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assign Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            Text(widget.jobCardRef, style: const TextStyle(fontSize: 13, color: AppColors.text3)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.s16),
        children: [
          const Text(
            'Assigned Technician',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            hint: const Text('Select Technician'),
            initialValue: _selectedTechnicianId,
            items: technicians
                .map(
                  (tech) => DropdownMenuItem(
                    value: tech.empId,
                    child: Text(tech.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedTechnicianId = v),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tasks to Perform',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ..._tasks.asMap().entries.map((e) {
            final idx = e.key;
            final task = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: task.selected,
                    activeColor: AppColors.accent,
                    onChanged: (v) => setState(() => task.selected = v ?? true),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: task.description,
                      decoration: InputDecoration(
                        hintText: 'Task description',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.r12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => task.description = v,
                    ),
                  ),
                  if (_tasks.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                      onPressed: () => setState(() => _tasks.removeAt(idx)),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => setState(() => _tasks.add(TaskDraft(description: ''))),
            icon: const Icon(Icons.add, color: AppColors.accent),
            label: const Text('Add Task', style: TextStyle(color: AppColors.accent)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Estimated Completion (Optional)',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateTime,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.r12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _estimatedCompletion == null
                        ? 'Select Date & Time'
                        : _estimatedCompletion.toString().substring(0, 16),
                    style: TextStyle(
                      color: _estimatedCompletion == null ? AppColors.text4 : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
              ),
              onPressed: _isLoading ? null : _assignTasks,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Assign Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
