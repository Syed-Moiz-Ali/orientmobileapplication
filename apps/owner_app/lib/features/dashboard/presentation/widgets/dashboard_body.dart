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

  static const _pages = <Widget>[
    OwnerDashboardPage(),
    TopSalesPage(),
    MessagesPage(),
    OwnerActivityFeedTab(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardUiProvider.notifier);

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
          return IndexedStack(index: state.selectedIndex, children: _pages);
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(dashboardUiProvider);
          return OwnerBottomNav(
            selectedIndex: state.selectedIndex,
            onTap: notifier.selectTab,
          );
        },
      ),
    );
  }
}
