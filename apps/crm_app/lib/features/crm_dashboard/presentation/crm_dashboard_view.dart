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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(crmUiProvider.notifier);
    final state = ref.watch(crmUiProvider);

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
      drawer: CrmDrawer(notifier: notifier),
      body: IndexedStack(index: state.selectedIndex, children: pages),
    );
  }
}
