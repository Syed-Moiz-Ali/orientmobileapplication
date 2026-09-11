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
        icon: Icons.assignment_rounded,
        label: 'Job Cards',
        subtitle: 'Repair Register',
        accentColor: const Color(0xFF0284C7),
        onTap: () => context.push('/job-cards'),
      ),
      ActionButton(
        icon: Icons.inventory_2_rounded,
        label: 'Inventory',
        subtitle: 'Spare Parts & Stock',
        accentColor: const Color(0xFF8B5CF6),
        onTap: () => context.push('/inventory'),
      ),
      ActionButton(
        icon: Icons.receipt_long_rounded,
        label: 'Receivables',
        subtitle: 'Aging & Invoices',
        accentColor: const Color(0xFF2563EB),
        onTap: () => context.push('/accounts-receivable'),
      ),
      ActionButton(
        icon: Icons.hourglass_top_rounded,
        label: 'Approvals',
        subtitle: 'Estimates & Discounts',
        accentColor: const Color(0xFFD97706),
        onTap: () => context.push('/pending-approvals'),
      ),
      ActionButton(
        icon: Icons.fact_check_rounded,
        label: 'Job Status',
        subtitle: 'Live Repair Pipeline',
        accentColor: const Color(0xFF7C3AED),
        onTap: () => context.push('/job-status'),
      ),
      ActionButton(
        icon: Icons.event_note_rounded,
        label: 'Compliance',
        subtitle: 'Document Expiry',
        accentColor: const Color(0xFFDC2626),
        onTap: () => context.push('/document-expiry'),
      ),
      ActionButton(
        icon: Icons.rate_review_rounded,
        label: 'Reviews',
        subtitle: 'Customer Ratings',
        accentColor: const Color(0xFFEA580C),
        onTap: () => context.push('/feedback-moderation'),
      ),
      ActionButton(
        icon: Icons.badge_rounded,
        label: 'Attendance',
        subtitle: 'Shift Register',
        accentColor: const Color(0xFF059669),
        onTap: () => context.push('/attendance'),
      ),
      ActionButton(
        icon: Icons.groups_rounded,
        label: 'Team & Roles',
        subtitle: 'Staff Permissions',
        accentColor: const Color(0xFF0D9488),
        onTap: () => context.push('/team'),
      ),
      ActionButton(
        icon: Icons.leaderboard_rounded,
        label: 'Top Sales',
        subtitle: 'Category Insights',
        accentColor: const Color(0xFF4F46E5),
        onTap: () => notifier.selectTab(1),
      ),
      ActionButton(
        icon: Icons.chat_bubble_rounded,
        label: 'Messages',
        subtitle: 'Internal Chat',
        accentColor: const Color(0xFF10B981),
        onTap: () => notifier.selectTab(2),
      ),
      ActionButton(
        icon: Icons.workspace_premium_rounded,
        label: 'Subscription',
        subtitle: 'Workshop Plan',
        accentColor: const Color(0xFF9333EA),
        onTap: () => context.push('/subscription'),
      ),
    ];

    return AppAdaptiveGrid(
      columns: adaptive.pick(compact: 2, medium: 3, expanded: 4, large: 4),
      minChildWidth: adaptive.isCompact ? 150 : 200,
      spacing: 10,
      runSpacing: 10,
      childAspectRatio: adaptive.pick(
        compact: 2.1,
        medium: 2.4,
        expanded: 2.6,
        large: 2.8,
      ),
      children: actions,
    );
  }
}
