import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_task_entity.freezed.dart';
part 'work_task_entity.g.dart';

@freezed
class WorkTaskEntity with _$WorkTaskEntity {
  const factory WorkTaskEntity({
    required int id,
    required String description,
    @Default(TaskStatus.pending) TaskStatus status,
    String? startTime,
    String? endTime,
  }) = _WorkTaskEntity;

  factory WorkTaskEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkTaskEntityFromJson(json);
}

enum TaskStatus { pending, inProgress, completed }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}
