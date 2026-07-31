import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmTaskState {
  final List<CrmTaskEntity> tasks;
  final bool isLoading;

  const CrmTaskState({required this.tasks, this.isLoading = false});

  CrmTaskState copyWith({List<CrmTaskEntity>? tasks, bool? isLoading}) {
    return CrmTaskState(tasks: tasks ?? this.tasks, isLoading: isLoading ?? this.isLoading);
  }
}

class CrmTaskNotifier extends Notifier<CrmTaskState> {
  @override
  CrmTaskState build() {
    final repo = ref.read(crmRepositoryProvider);
    return CrmTaskState(tasks: repo.getTasks());
  }

  List<CrmTaskEntity> get tasks => state.tasks;

  Future<void> refresh() async {
    await ref.read(crmRepositoryProvider).refreshTasks();
    ref.invalidateSelf();
  }

  Future<void> addTask({
    required String title,
    required String assignedTo,
    required String dueDate,
    required String priority,
  }) async {
    await ref.read(crmRepositoryProvider).createTask({
      'title': title,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
      'priority': priority,
      'isDone': false,
    });
    ref.invalidateSelf();
  }

  Future<void> updateTask(CrmTaskEntity task, {
    String? title,
    String? assignedTo,
    String? dueDate,
    String? priority,
    bool? isDone,
  }) async {
    await ref.read(crmRepositoryProvider).updateTask(task.id, {
      'title': title ?? task.title,
      'assignedTo': assignedTo ?? task.assignedTo,
      'dueDate': dueDate ?? task.dueDate,
      'priority': priority ?? task.priority,
      'isDone': isDone ?? task.isDone,
    });
    ref.invalidateSelf();
  }

  Future<void> toggleTask(String id, bool isDone) async {
    final task = tasks.firstWhere((t) => t.id == id);
    await updateTask(task, isDone: isDone);
  }

  Future<void> deleteTask(String id) async {
    await ref.read(crmRepositoryProvider).deleteTask(id);
    ref.invalidateSelf();
  }
}

final crmTaskProvider = NotifierProvider<CrmTaskNotifier, CrmTaskState>(
  CrmTaskNotifier.new,
);
