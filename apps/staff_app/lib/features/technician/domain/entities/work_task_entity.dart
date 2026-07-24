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

class WorkTaskEntity {
  final int id;
  final String description;
  final TaskStatus status;
  final String? startTime;
  final String? endTime;

  const WorkTaskEntity({
    required this.id,
    required this.description,
    this.status = TaskStatus.pending,
    this.startTime,
    this.endTime,
  });

  WorkTaskEntity copyWith({
    int? id,
    String? description,
    TaskStatus? status,
    String? startTime,
    String? endTime,
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return WorkTaskEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      status: status ?? this.status,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }

  factory WorkTaskEntity.fromJson(Map<String, dynamic> json) {
    return WorkTaskEntity(
      id: json['id'] as int,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'status': status.name,
    'startTime': startTime,
    'endTime': endTime,
  };
}
