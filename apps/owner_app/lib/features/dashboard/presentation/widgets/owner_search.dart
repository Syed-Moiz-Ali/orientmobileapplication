import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

class _Destination {
  final String id;
  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback run;

  const _Destination({
    required this.id,
    required this.label,
    required this.hint,
    required this.icon,
    required this.run,
  });
}

/// Opens the existing owner command palette over the real destinations.
///
/// Single home for the palette contract: the shell search trigger and the
/// home header search action open the same sheet with the same ids, labels
/// and routes. Presentation-only — destinations, hints and selectTab/push
/// targets are unchanged from the shell version.
void openOwnerSearch(BuildContext context, WidgetRef ref) {
  final t = OwnerLocalizations.of(context)!;
  final notifier = ref.read(dashboardUiProvider.notifier);
  final destinations = <_Destination>[
    _Destination(
      id: 'tab-dashboard',
      label: t.ownerNavDashboard,
      hint: t.ownerBarDashboard,
      icon: Icons.dashboard_outlined,
      run: () => notifier.selectTab(0),
    ),
    _Destination(
      id: 'tab-topsales',
      label: t.ownerNavTopSales,
      hint: t.ownerBarTopSalesSub,
      icon: Icons.leaderboard_outlined,
      run: () => notifier.selectTab(1),
    ),
    _Destination(
      id: 'tab-messages',
      label: t.ownerNavMessages,
      hint: t.ownerBarMessagesSub,
      icon: Icons.chat_bubble_outline_rounded,
      run: () => notifier.selectTab(2),
    ),
    _Destination(
      id: 'tab-activity',
      label: t.ownerNavActivity,
      hint: t.ownerBarActivitySub,
      icon: Icons.notifications_outlined,
      run: () => notifier.selectTab(3),
    ),
    _Destination(
      id: 'route-job-cards',
      label: t.ownerActionJobCards,
      hint: t.ownerActionJobCardsHint,
      icon: Icons.assignment_rounded,
      run: () => context.push(AppRoutes.jobCards),
    ),
    _Destination(
      id: 'route-approvals',
      label: t.ownerActionApprovals,
      hint: t.ownerActionApprovalsHint,
      icon: Icons.hourglass_top_rounded,
      run: () => context.push(AppRoutes.pendingApprovals),
    ),
    _Destination(
      id: 'route-receivables',
      label: t.ownerActionReceivables,
      hint: t.ownerActionReceivablesHint,
      icon: Icons.receipt_long_rounded,
      run: () => context.push(AppRoutes.accountsReceivable),
    ),
    _Destination(
      id: 'route-team',
      label: t.ownerActionTeam,
      hint: t.ownerActionTeamHint,
      icon: Icons.groups_rounded,
      run: () => context.push(AppRoutes.team),
    ),
    _Destination(
      id: 'route-inventory',
      label: t.ownerActionInventory,
      hint: t.ownerActionInventoryHint,
      icon: Icons.inventory_2_rounded,
      run: () => context.push(AppRoutes.inventory),
    ),
  ];
  HapticFeedback.selectionClick();
  showAppCommandPalette(
    context: context,
    hint: t.ownerSearchHint,
    commands: [
      for (final d in destinations)
        AppCommand(
          id: d.id,
          label: d.label,
          hint: d.hint,
          icon: d.icon,
          onSelected: d.run,
        ),
    ],
    onSelected: (cmd) {
      Navigator.pop(context);
      cmd.onSelected();
    },
  );
}
