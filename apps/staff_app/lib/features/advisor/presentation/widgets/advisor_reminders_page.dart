import 'package:flutter/material.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'advisor_reminder_row.dart';

class AdvisorRemindersPage extends StatelessWidget {
  final List<FollowupReminderEntity> reminders;
  final void Function(FollowupReminderEntity) onContact;
  const AdvisorRemindersPage({
    super.key,
    required this.reminders,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
    itemCount: reminders.length,
    itemBuilder: (_, i) => AdvisorReminderRow(
      r: reminders[i],
      onContact: () => onContact(reminders[i]),
    ),
  );
}

