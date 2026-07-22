import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_task_provider.dart';

class CrmTasksPage extends ConsumerWidget {
  const CrmTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskNotifier = ref.read(crmTaskProvider.notifier);
    final tasks = ref.watch(crmTaskProvider).tasks;

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.s16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s10),
      itemBuilder: (_, i) {
        final t = tasks[i];
        return GestureDetector(
          onTap: () => taskNotifier.toggleTask(i),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.isDone ? AppColors.surfaceAlt : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.r14),
              border: Border.all(
                color: t.isDone
                    ? CrmColors.border
                    : t.priorityColor.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: CrmColors.primary.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: t.isDone ? CrmColors.green : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: t.isDone ? CrmColors.green : CrmColors.textM,
                      width: 1.5,
                    ),
                  ),
                  child: t.isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 13,
                        )
                      : null,
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: TextStyle(
                          color: t.isDone ? CrmColors.textM : CrmColors.textH,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: t.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: CrmColors.textM,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.assignedTo,
                            style: const TextStyle(
                              color: CrmColors.textM,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s10),
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: CrmColors.textM,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.dueDate,
                            style: const TextStyle(
                              color: CrmColors.textM,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: t.priorityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Text(
                    t.priority,
                    style: TextStyle(
                      color: t.priorityColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
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
