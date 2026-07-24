import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'advisor_tab_button.dart';
import 'advisor_job_cards_page.dart';
import 'advisor_approvals_page.dart';
import 'advisor_reminders_page.dart';

class AdvisorTabPanel extends StatelessWidget {
  final TabController tabCtrl;
  final AdvisorStatsEntity stats;
  final List<JobCardEntity> jobCards;
  final List<PendingApprovalEntity> approvals;
  final List<FollowupReminderEntity> reminders;
  final void Function(JobCardEntity) onJobCard;
  final void Function(PendingApprovalEntity) onApproval;
  final void Function(FollowupReminderEntity) onContact;

  const AdvisorTabPanel({
    super.key,
    required this.tabCtrl,
    required this.stats,
    required this.jobCards,
    required this.approvals,
    required this.reminders,
    required this.onJobCard,
    required this.onApproval,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppDimensions.r13),
              ),
              child: Row(
                children: [
                  AdvisorTabButton(
                    label: 'Job Cards',
                    index: 0,
                    ctrl: tabCtrl,
                    badge: stats.totalOpenJobCards.toString(),
                  ),
                  AdvisorTabButton(
                    label: 'Approvals',
                    index: 1,
                    ctrl: tabCtrl,
                    badge: approvals.length.toString(),
                    badgeColor: AppColors.warning,
                  ),
                  AdvisorTabButton(
                    label: 'Reminders',
                    index: 2,
                    ctrl: tabCtrl,
                    badge: reminders.length.toString(),
                    badgeColor: AppColors.danger,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 340,
            child: TabBarView(
              controller: tabCtrl,
              children: [
                AdvisorJobCardsPage(jobCards: jobCards, onTap: onJobCard, onViewAll: () {}),
                AdvisorApprovalsPage(approvals: approvals, onTap: onApproval, onViewAll: () {}),
                AdvisorRemindersPage(reminders: reminders, onContact: onContact),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

