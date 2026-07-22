import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_app_bar.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_drawer.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_dashboard_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_reports_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_integrations_page.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_settings_page.dart';

import 'package:orientmobileapplication/core/widgets/exit_confirmation_dialog.dart';

class CrmDashboardView extends ConsumerStatefulWidget {
  const CrmDashboardView({super.key});

  @override
  ConsumerState<CrmDashboardView> createState() => _CrmDashboardViewState();
}

class _CrmDashboardViewState extends ConsumerState<CrmDashboardView> {
  @override
  Widget build(BuildContext context) {
    return const ExitConfirmationWrapper(
      child: _CrmScaffold(),
    );
  }
}

class _CrmScaffold extends ConsumerWidget {
  const _CrmScaffold();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(crmUiProvider.notifier);
    final state = ref.watch(crmUiProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: CrmColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
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

    return Scaffold(
      backgroundColor: CrmColors.scaffold,
      appBar: CrmAppBar(notifier: notifier),
      drawer: CrmDrawer(notifier: notifier),
      body: IndexedStack(index: state.selectedIndex, children: pages),
    );
  }
}
