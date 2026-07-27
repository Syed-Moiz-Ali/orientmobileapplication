import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'advisor_reminder_row.dart';

class AdvisorRemindersPage extends ConsumerWidget {
  final List<FollowupReminderEntity> reminders;
  final void Function(FollowupReminderEntity) onContact;
  const AdvisorRemindersPage({
    super.key,
    required this.reminders,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_outlined, size: 40, color: AppColors.text4.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('No reminders', style: TextStyle(fontSize: 14, color: AppColors.text3)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showNewReminderSheet(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 70),
          itemCount: reminders.length,
          itemBuilder: (_, i) => AdvisorReminderRow(
            r: reminders[i],
            onContact: () => onContact(reminders[i]),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: FloatingActionButton.small(
            onPressed: () => _showNewReminderSheet(context, ref),
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showNewReminderSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final taskCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    var priority = ReminderPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    const Text('New Reminder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name', filled: true, fillColor: AppColors.canvas, border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: taskCtrl, decoration: const InputDecoration(labelText: 'Task', filled: true, fillColor: AppColors.canvas, border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Due Date (e.g. Today, 2:00 PM)', filled: true, fillColor: AppColors.canvas, border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Priority: ', style: TextStyle(fontSize: 13, color: AppColors.text2)),
                    const SizedBox(width: 8),
                    ...ReminderPriority.values.map((p) {
                      final sel = priority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => priority = p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.accent : AppColors.canvas,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.name[0].toUpperCase() + p.name.substring(1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.text2),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.isEmpty || taskCtrl.text.isEmpty) return;
                      ref.read(advisorFollowupRemindersProvider.notifier).addReminder(
                        FollowupReminderEntity(
                          customerName: nameCtrl.text,
                          vehicleId: '',
                          task: taskCtrl.text,
                          dueDate: dateCtrl.text.isEmpty ? 'Today' : dateCtrl.text,
                          priority: priority,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Reminder', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

