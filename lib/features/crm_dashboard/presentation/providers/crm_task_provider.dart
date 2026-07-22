import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmTaskState {
  final List<CrmTaskEntity> tasks;

  const CrmTaskState({required this.tasks});

  CrmTaskState copyWith({List<CrmTaskEntity>? tasks}) {
    return CrmTaskState(tasks: tasks ?? this.tasks);
  }
}

class CrmTaskNotifier extends Notifier<CrmTaskState> {
  @override
  CrmTaskState build() {
    final ds = ref.read(crmDataSourceProvider);
    return CrmTaskState(tasks: ds.getTasks());
  }

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
