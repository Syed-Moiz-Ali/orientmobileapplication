import 'package:freezed_annotation/freezed_annotation.dart';

part 'followup_reminder_entity.freezed.dart';

enum ReminderPriority { high, medium, low }

@freezed
class FollowupReminderEntity with _$FollowupReminderEntity {
  const factory FollowupReminderEntity({
    required String customerName,
    required String vehicleId,
    required String task,
    required String dueDate,
    required ReminderPriority priority,
  }) = _FollowupReminderEntity;
}
