import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmTaskState {
  final List<CrmTaskEntity> tasks;

  const CrmTaskState({required this.tasks});

  CrmTaskState copyWith({List<CrmTaskEntity>? tasks}) {
    return CrmTaskState(tasks: tasks ?? this.tasks);
  }
}

class CrmTaskNotifier extends Notifier<CrmTaskState> {
  @override
  CrmTaskState build() => CrmTaskState(
    tasks: [
      const CrmTaskEntity(
        id: '1',
        title: 'Follow up with James Anderson',
        assignedTo: 'John Doe',
        dueDate: '2026-04-30',
        priority: 'HIGH',
        priorityColor: AppColors.red500,
      ),
      const CrmTaskEntity(
        id: '2',
        title: 'Send proposal to Emily Chen',
        assignedTo: 'Sarah Smith',
        dueDate: '2026-05-01',
        priority: 'MEDIUM',
        priorityColor: AppColors.warning,
      ),
      const CrmTaskEntity(
        id: '3',
        title: 'Update CRM data for Q2',
        assignedTo: 'Mike Johnson',
        dueDate: '2026-05-03',
        priority: 'LOW',
        priorityColor: AppColors.greenAccent,
      ),
      const CrmTaskEntity(
        id: '4',
        title: 'Review lost lead analysis',
        assignedTo: 'Joe Brown',
        dueDate: '2026-05-02',
        priority: 'HIGH',
        priorityColor: AppColors.red500,
      ),
    ],
  );

  List<CrmTaskEntity> get tasks => state.tasks;

  void toggleTask(int i) {
    final updated = state.tasks.map((t) => t.copyWith()).toList();
    updated[i] = CrmTaskEntity(
      id: updated[i].id,
      title: updated[i].title,
      assignedTo: updated[i].assignedTo,
      dueDate: updated[i].dueDate,
      priority: updated[i].priority,
      priorityColor: updated[i].priorityColor,
      isDone: !updated[i].isDone,
    );
    state = state.copyWith(tasks: updated);
  }
}

final crmTaskProvider = NotifierProvider<CrmTaskNotifier, CrmTaskState>(
  CrmTaskNotifier.new,
);
