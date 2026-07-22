import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'advisor_status_badge.dart';

class AdvisorReminderRow extends StatelessWidget {
  final FollowupReminderEntity r;
  final VoidCallback onContact;
  const AdvisorReminderRow({
    super.key,
    required this.r,
    required this.onContact,
  });

  Color get _pc => r.priority == ReminderPriority.high
      ? AppColors.danger
      : r.priority == ReminderPriority.medium
      ? AppColors.warning
      : AppColors.accent;
  Color get _pb => r.priority == ReminderPriority.high
      ? AppColors.dangerBg
      : r.priority == ReminderPriority.medium
      ? AppColors.warningBg
      : AppColors.accent.withValues(alpha: 0.12);
  String get _pl => r.priority == ReminderPriority.high
      ? 'High'
      : r.priority == ReminderPriority.medium
      ? 'Medium'
      : 'Low';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 56,
            decoration: BoxDecoration(
              color: _pc,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r2)),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.customerName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    AdvisorStatusBadge(_pl, _pc, _pb),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${r.vehicleId} · ${r.task}',
                  style: const TextStyle(fontSize: 12, color: AppColors.text2),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: AppColors.text3,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r.dueDate,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.text3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onContact,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.r8),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.phone_outlined,
                              size: 12,
                              color: AppColors.accent,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
