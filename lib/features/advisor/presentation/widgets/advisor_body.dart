import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/presentation/providers/advisor_providers.dart';
import 'advisor_header.dart';
import 'advisor_stat_tile.dart';
import 'advisor_date_chip.dart';
import 'advisor_tab_panel.dart';

class AdvisorBody extends ConsumerWidget {
  final TabController tabCtrl;
  final VoidCallback onShowProfile;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowSearch;
  final VoidCallback onOpenScan;
  final VoidCallback onNewJobCard;
  final VoidCallback onOpenInspection;
  final void Function(JobCardEntity) onJobCard;
  final void Function(PendingApprovalEntity) onApproval;
  final void Function(FollowupReminderEntity) onContact;
  final void Function(String label, int count, Color color) onStat;

  const AdvisorBody({
    super.key,
    required this.tabCtrl,
    required this.onShowProfile,
    required this.onShowNotifications,
    required this.onShowSearch,
    required this.onOpenScan,
    required this.onNewJobCard,
    required this.onOpenInspection,
    required this.onJobCard,
    required this.onApproval,
    required this.onContact,
    required this.onStat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(advisorDashboardProvider).valueOrNull ?? const AdvisorStatsEntity(
      newJobCardsToday: 0,
      inspectionsToday: 0,
      pendingApprovals: 0,
      vehiclesWaiting: 0,
      readyForDelivery: 0,
      totalOpenJobCards: 0,
    );
    final jobCards = ref.watch(advisorRecentJobCardsProvider).valueOrNull ?? <JobCardEntity>[];
    final approvals = ref.watch(advisorPendingApprovalsProvider).valueOrNull ?? <PendingApprovalEntity>[];
    final reminders = ref.watch(advisorFollowupRemindersProvider).valueOrNull ?? <FollowupReminderEntity>[];
    final info = ref.watch(advisorInfoProvider);

    return RefreshIndicator(
      color: AppColors.accent,
      strokeWidth: 2.5,
      displacement: 20,
      onRefresh: () async {
        ref.invalidate(advisorDashboardProvider);
        ref.invalidate(advisorRecentJobCardsProvider);
        ref.invalidate(advisorPendingApprovalsProvider);
        ref.invalidate(advisorFollowupRemindersProvider);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: AdvisorHeader(
            advisorName: info.name,
            onShowProfile: onShowProfile,
            onShowNotifications: onShowNotifications,
            onShowSearch: onShowSearch,
            onOpenScan: onOpenScan,
            onNewJobCard: onNewJobCard,
            onOpenInspection: onOpenInspection,
          )),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _overviewLabel(),
                const SizedBox(height: 12),
                _statsRow(stats),
                const SizedBox(height: 20),
                AdvisorTabPanel(
                  tabCtrl: tabCtrl,
                  stats: stats,
                  jobCards: jobCards,
                  approvals: approvals,
                  reminders: reminders,
                  onJobCard: onJobCard,
                  onApproval: onApproval,
                  onContact: onContact,
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewLabel() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r2)),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "Today's Overview",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        const AdvisorDateChip(),
      ],
    );
  }

  Widget _statsRow(AdvisorStatsEntity stats) {
    return Row(
      children: [
        AdvisorStatTile(
          label: 'Orders', count: stats.newJobCardsToday,
          color: AppColors.accent, bg: AppColors.accent.withValues(alpha: 0.12),
          icon: Icons.inbox_outlined,
          onTap: () => onStat('Open Orders', stats.newJobCardsToday, AppColors.accent),
        ),
        const SizedBox(width: 9),
        AdvisorStatTile(
          label: 'WIP', count: stats.inspectionsToday,
          color: AppColors.warning, bg: AppColors.warningBg,
          icon: Icons.build_circle_outlined,
          onTap: () => onStat('WIP', stats.inspectionsToday, AppColors.warning),
        ),
        const SizedBox(width: 9),
        AdvisorStatTile(
          label: 'Ready', count: stats.readyForDelivery,
          color: AppColors.success, bg: AppColors.successBg,
          icon: Icons.verified_outlined,
          onTap: () => onStat('Ready', stats.readyForDelivery, AppColors.success),
        ),
        const SizedBox(width: 9),
        AdvisorStatTile(
          label: 'Delivered', count: 4,
          color: AppColors.info, bg: AppColors.infoBg,
          icon: Icons.local_shipping_outlined,
          onTap: () => onStat('Delivered', 4, AppColors.info),
        ),
      ],
    );
  }
}
