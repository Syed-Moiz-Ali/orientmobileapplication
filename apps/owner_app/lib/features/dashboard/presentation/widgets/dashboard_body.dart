import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/messages_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_app_bar.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_bottom_nav.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/top_sales_page.dart';

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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return DashboardShell(
      appBar: const OwnerAppBar(),
      body: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(dashboardUiProvider);
          return AppAdaptiveNavigationFrame(
            items: _navItems,
            selectedIndex: state.selectedIndex,
            onSelected: notifier.selectTab,
            child: IndexedStack(index: state.selectedIndex, children: _pages),
          );
        },
      ),
      bottomNavigationBar: !adaptive.useNavigationRail
          ? Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(dashboardUiProvider);
                return OwnerBottomNav(
                  items: _navItems,
                  selectedIndex: state.selectedIndex,
                  onTap: notifier.selectTab,
                );
              },
            )
          : null,
    );
  }
}
