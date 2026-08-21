import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/action_button.dart';

class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardUiProvider.notifier);
    final adaptive = context.adaptive;
    final actions = <Widget>[
      ActionButton(
        icon: Icons.leaderboard_rounded,
        label: 'View details',
        gradient: const [AppColors.navy, AppColors.accent],
        onTap: () => notifier.selectTab(1),
      ),
      ActionButton(
        icon: Icons.send_rounded,
        label: 'Send message',
        gradient: const [Color(0xFF1A8754), Color(0xFF2AA889)],
        onTap: () => notifier.selectTab(2),
      ),
      ActionButton(
        icon: Icons.receipt_long_outlined,
        label: 'Receivables',
        gradient: const [Color(0xFF1F6FEB), Color(0xFF4F9DFF)],
        onTap: () => context.push('/accounts-receivable'),
      ),
      ActionButton(
        icon: Icons.event_note_outlined,
        label: 'Document expiry',
        gradient: const [Color(0xFFB83A36), Color(0xFFE7615C)],
        onTap: () => context.push('/document-expiry'),
      ),
      ActionButton(
        icon: Icons.fact_check_outlined,
        label: 'Job status',
        gradient: const [Color(0xFF6746B8), Color(0xFF916EDB)],
        onTap: () => context.push('/job-status'),
      ),
      ActionButton(
        icon: Icons.hourglass_top_rounded,
        label: 'Approvals',
        gradient: const [Color(0xFFB7791F), Color(0xFFE4A83B)],
        onTap: () => context.push('/pending-approvals'),
      ),
      ActionButton(
        icon: Icons.assignment_outlined,
        label: 'Job cards',
        gradient: const [Color(0xFF0E7490), Color(0xFF199DB8)],
        onTap: () => context.push('/job-cards'),
      ),
      ActionButton(
        icon: Icons.inventory_2_outlined,
        label: 'Inventory',
        gradient: const [Color(0xFF6D3BC1), Color(0xFF9167D8)],
        onTap: () => context.push('/inventory'),
      ),
      ActionButton(
        icon: Icons.rate_review_outlined,
        label: 'Reviews',
        gradient: const [Color(0xFFA86108), Color(0xFFD98C16)],
        onTap: () => context.push('/feedback-moderation'),
      ),
      ActionButton(
        icon: Icons.groups_outlined,
        label: 'Team & roles',
        gradient: const [Color(0xFF0F766E), Color(0xFF1B9B91)],
        onTap: () => context.push('/team'),
      ),
      ActionButton(
        icon: Icons.workspace_premium_outlined,
        label: 'Subscription',
        gradient: const [Color(0xFF56349C), Color(0xFF7F5CC2)],
        onTap: () => context.push('/subscription'),
      ),
    ];

    return AppAdaptiveGrid(
      columns: adaptive.pick(compact: 2, medium: 3, expanded: 4, large: 4),
      minChildWidth: adaptive.isCompact ? 142 : 190,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.pick(
        compact: 2.65,
        medium: 3.25,
        expanded: 3.45,
        large: 3.8,
      ),
      children: actions,
    );
  }
}
