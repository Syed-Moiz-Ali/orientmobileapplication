import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_app_bar.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_drawer.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_dashboard_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_reports_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_integrations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_settings_page.dart';

class CrmDashboardView extends ConsumerWidget {
  const CrmDashboardView({super.key});

  static const _navItems = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    AppNavItem(
      selectedIcon: Icons.person_search_rounded,
      icon: Icons.person_search_outlined,
      label: 'Leads',
    ),
    AppNavItem(
      selectedIcon: Icons.chat_bubble_rounded,
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Conversations',
    ),
    AppNavItem(
      selectedIcon: Icons.groups_rounded,
      icon: Icons.groups_outlined,
      label: 'Sales Team',
    ),
    AppNavItem(
      selectedIcon: Icons.task_alt_rounded,
      icon: Icons.task_outlined,
      label: 'Tasks',
    ),
    AppNavItem(
      selectedIcon: Icons.bar_chart_rounded,
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
    ),
    AppNavItem(
      selectedIcon: Icons.power_rounded,
      icon: Icons.power_outlined,
      label: 'Integrations',
    ),
    AppNavItem(
      selectedIcon: Icons.settings_rounded,
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(crmUiProvider.notifier);
    final state = ref.watch(crmUiProvider);
    final adaptive = context.adaptive;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: CrmColors.primary, statusBarIconBrightness: Brightness.light),
    );

    final pages = <Widget>[
      const CrmDashboardPage(),
      const CrmLeadsPage(),
      const CrmConversationsPage(),
      const CrmSalesTeamPage(),
      const CrmTasksPage(),
      const CrmReportsPage(),
      const CrmIntegrationsPage(),
      const CrmSettingsPage(),
    ];

    return DashboardShell(
      appBar: CrmAppBar(notifier: notifier),
      drawer: !adaptive.useNavigationRail ? CrmDrawer(notifier: notifier) : null,
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: state.selectedIndex,
        onSelected: notifier.selectTab,
        child: IndexedStack(index: state.selectedIndex, children: pages),
      ),
    );
  }
}
