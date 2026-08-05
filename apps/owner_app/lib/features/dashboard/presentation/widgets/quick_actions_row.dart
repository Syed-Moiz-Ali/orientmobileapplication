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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.leaderboard_rounded,
                label: 'View Details',
                gradient: const [AppColors.navy, AppColors.accent],
                onTap: () => notifier.selectTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                icon: Icons.send_rounded,
                label: 'Send Message',
                gradient: const [Color(0xFF1A8754), Color(0xFF2DD4BF)],
                onTap: () => notifier.selectTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.receipt_long_outlined,
                label: 'Accounts Receivable',
                gradient: const [Color(0xFF1F6FEB), Color(0xFF4F9DFF)],
                onTap: () => context.push('/accounts-receivable'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                icon: Icons.event_note_outlined,
                label: 'Document Expiry',
                gradient: const [Color(0xFFDA3633), Color(0xFFFF6B66)],
                onTap: () => context.push('/document-expiry'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.fact_check_outlined,
                label: 'Job Status',
                gradient: const [Color(0xFF8957E5), Color(0xFFB18CFF)],
                onTap: () => context.push('/job-status'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                icon: Icons.hourglass_top_rounded,
                label: 'Pending Approvals',
                gradient: const [Color(0xFFE3B341), Color(0xFFFFD976)],
                onTap: () => context.push('/pending-approvals'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.assignment_outlined,
                label: 'Job Cards',
                gradient: const [Color(0xFF0E7490), Color(0xFF22D3EE)],
                onTap: () => context.push('/job-cards'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
