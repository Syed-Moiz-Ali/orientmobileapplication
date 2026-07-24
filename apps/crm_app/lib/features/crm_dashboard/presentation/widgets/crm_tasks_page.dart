import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';

class CrmTasksPage extends ConsumerWidget {
  const CrmTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(crmTaskProvider.notifier);
    final tasks = taskNotifier.tasks;

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.s16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s10),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(AppDimensions.s14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(color: CrmColors.border),
          boxShadow: [
            BoxShadow(
              color: CrmColors.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => taskNotifier.toggleTask(i),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tasks[i].isDone ? CrmColors.green : CrmColors.textM,
                    width: 2,
                  ),
                  color: tasks[i].isDone ? CrmColors.green : Colors.transparent,
                ),
                child: tasks[i].isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasks[i].title,
                    style: TextStyle(
                      color: tasks[i].isDone ? CrmColors.textM : CrmColors.textH,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: tasks[i].isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, color: CrmColors.textM, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        tasks[i].assignedTo,
                        style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                      ),
                      const SizedBox(width: AppDimensions.s12),
                      const Icon(Icons.calendar_today_rounded, color: CrmColors.textM, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        tasks[i].dueDate,
                        style: const TextStyle(color: CrmColors.textM, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: tasks[i].priorityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: Text(
                tasks[i].priority,
                style: TextStyle(
                  color: tasks[i].priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
