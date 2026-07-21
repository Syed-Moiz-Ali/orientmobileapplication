enum ReminderPriority { high, medium, low }

class FollowupReminderEntity {
  final String customerName;
  final String vehicleId;
  final String task;
  final String dueDate;
  final ReminderPriority priority;

  const FollowupReminderEntity({
    required this.customerName,
    required this.vehicleId,
    required this.task,
    required this.dueDate,
    required this.priority,
  });
}
