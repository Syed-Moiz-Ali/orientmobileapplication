import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/action_button.dart';

class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardUiProvider.notifier);

    return Row(
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
    );
  }
}
