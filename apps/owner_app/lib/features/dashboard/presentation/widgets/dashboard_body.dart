import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/models/profile_data.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/messages_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/top_sales_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/period_dropdown.dart';

class DashboardBody extends ConsumerWidget {
  const DashboardBody({super.key});

  static const _navItems = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    AppNavItem(
      selectedIcon: Icons.leaderboard_rounded,
      icon: Icons.leaderboard_outlined,
      label: 'Top Sales',
    ),
    AppNavItem(
      selectedIcon: Icons.chat_bubble_rounded,
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Messages',
    ),
    AppNavItem(
      selectedIcon: Icons.notifications_rounded,
      icon: Icons.notifications_outlined,
      label: 'Activity',
    ),
  ];

  static const _pages = <Widget>[
    OwnerDashboardPage(),
    TopSalesPage(),
    MessagesPage(),
    OwnerActivityFeedTab(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardUiProvider.notifier);
    final adaptive = context.adaptive;
    final state = ref.watch(dashboardUiProvider);

    return DashboardShell(
      appBar: _OwnerChrome(selectedIndex: state.selectedIndex),
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: state.selectedIndex,
        onSelected: notifier.selectTab,
        headerBuilder: (ctx, ext) => OrientBrandMark(
          workspace: 'Executive',
          compact: !ext,
        ),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: () => notifier.selectTab(3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ext ? AppDimensions.s8 : 0,
              vertical: AppDimensions.s4,
            ),
            child: ext
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.14),
                        child: Text(
                          'O',
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          'Owner Suite',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: 'Owner Suite',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.14),
                      child: Text(
                        'O',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        child: IndexedStack(index: state.selectedIndex, children: _pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: _navItems,
              selectedIndex: state.selectedIndex,
              onSelected: notifier.selectTab,
            ),
    );
  }
}

/// Phase 07.1 centralized chrome: the bespoke `OwnerAppBar` is deleted —
/// tab titles, branch subtitle, back-to-overview leading and the period /
/// notification / profile actions now compose the shared [WorkspaceAppBar]
/// with identical copy and behavior.
class _OwnerChrome extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;

  const _OwnerChrome({required this.selectedIndex});

  static const _titles = [
    'Owner Dashboard',
    'Top Sales',
    'Messages',
    'Activity',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(dashboardUiProvider.notifier);
    return WorkspaceAppBar(
      title: _titles[selectedIndex],
      subtitle: selectedIndex == 0
          ? ownerProfileData.branch
          : _subtitle(selectedIndex),
      toolbarHeight: 56,
      leading: selectedIndex == 0
          ? Icon(Icons.directions_car_rounded, color: colors.primary, size: 24)
          : IconButton(
              tooltip: 'Back to overview',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => notifier.selectTab(0),
            ),
      actions: [
        if (selectedIndex == 0)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: PeriodDropdown(),
          ),
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(
            initials: ownerProfileData.initials,
            onTap: () => showProfileSheet(
              context,
              ownerProfileData,
              onLogout: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ),
        ),
      ],
    );
  }

  static String _subtitle(int index) {
    switch (index) {
      case 1:
        return 'Performance Breakdown by Category';
      case 2:
        return 'Internal Messaging';
      case 3:
        return 'Workshop Activity Feed';
      default:
        return '';
    }
  }
}
