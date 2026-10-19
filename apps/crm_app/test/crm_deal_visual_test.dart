import 'dart:io';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_dashboard_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_dashboard_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_reports_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_integrations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_settings_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 19 rendered-review goldens: deal-radar dashboard, leads table /
/// Kanban, tasks, lead sheets and the enterprise shell at 390 EN/AR +
/// 834/1280 EN + dark spots, with real fonts (including the Arabic face).
/// The CRM tree had no goldens before this phase — every file here is new.
/// Deterministic fixtures; no live endpoints.
const _delegates = <LocalizationsDelegate<dynamic>>[
  CrmLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

CrmLeadEntity _lead({
  required String id,
  required String name,
  required String status,
  String phone = '+971501234567',
  String source = 'WhatsApp',
  String agent = 'Ravi',
  double value = 1000,
}) =>
    CrmLeadEntity(
      id: id,
      sno: 1,
      leadNumber: 'LD-$id',
      customerName: name,
      phone: phone,
      email: 'a@b.co',
      source: source,
      sourceColor: Colors.green,
      assignedTo: agent,
      status: status,
      statusColor: Colors.blue,
      lastActivity: 'Just now',
      notes: 'Called twice, prefers mornings.',
      leadValue: value,
      followUpDate: '2026-10-25',
    );

final _leads = [
  _lead(id: '1', name: 'Ahmed Al Mansoori', status: 'NEW', value: 4500),
  _lead(id: '2', name: 'Sara Khan', status: 'CONTACTED', value: 1200, source: 'META', agent: 'Lina'),
  _lead(id: '3', name: 'Omar Farouk', status: 'WON', value: 8900, source: 'ZOHO', agent: ''),
];

const _stats = LeadAnalyticsState(
  stats: LeadStatsEntity(
    total: 3,
    totalValue: 14600,
    pipeline: [
      PipelineStageEntity(status: 'NEW', count: 1, value: 4500),
      PipelineStageEntity(status: 'CONTACTED', count: 1, value: 1200),
      PipelineStageEntity(status: 'WON', count: 1, value: 8900),
    ],
    conversionRate: 33.3,
    wonValue: 8900,
  ),
);

class _FakeLeads extends CrmLeadNotifier {
  @override
  List<CrmLeadEntity> build() => _leads;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> updateLead(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> createLead(Map<String, dynamic> data) async {}

  @override
  Future<void> deleteLead(String id) async {}
}

class _FakeTasks extends CrmTaskNotifier {
  @override
  CrmTaskState build() => const CrmTaskState(tasks: [
        CrmTaskEntity(
          id: 't1',
          title: 'Call Ahmed back',
          assignedTo: 'Ravi',
          dueDate: '2000-01-01',
          priority: 'High',
          priorityColor: Colors.red,
        ),
        CrmTaskEntity(
          id: 't2',
          title: 'Send Sara the estimate',
          assignedTo: 'Lina',
          dueDate: '2099-01-01',
          priority: 'Medium',
          priorityColor: Colors.amber,
        ),
      ]);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> toggleTask(String id, bool isDone) async {}

  @override
  Future<void> addTask({
    required String title,
    required String assignedTo,
    required String dueDate,
    required String priority,
  }) async {}

  @override
  Future<void> updateTask(
    CrmTaskEntity task, {
    String? title,
    String? assignedTo,
    String? dueDate,
    String? priority,
    bool? isDone,
  }) async {}

  @override
  Future<void> deleteTask(String id) async {}
}

class _FakeAnalytics extends LeadAnalyticsNotifier {
  @override
  LeadAnalyticsState build() => _stats;

  @override
  Future<void> refresh() async {}
}

class _FakeUi extends CrmUiNotifier {
  @override
  CrmUiState build() => const CrmUiState(
        selectedIndex: 0,
        period: 'Today',
        salesperson: 'All Salespeople',
        isLoading: false,
        searchQuery: '',
        notificationsEnabled: true,
        darkMode: true,
        autoAssign: true,
      );

  @override
  List<CrmKpiEntity> get kpis => const [
        CrmKpiEntity(
          label: 'Pipeline Value',
          value: 'AED 14,600',
          icon: Icons.payments_rounded,
          state: KpiSemanticState.info,
          trend: '+12%',
          trendUp: true,
        ),
        CrmKpiEntity(
          label: 'Conversion',
          value: '33.3%',
          icon: Icons.trending_up_rounded,
          state: KpiSemanticState.success,
          trend: '+2%',
          trendUp: true,
        ),
        CrmKpiEntity(
          label: 'Avg Cycle',
          value: '6 days',
          icon: Icons.schedule_rounded,
          state: KpiSemanticState.neutral,
          trend: '-1 day',
          trendUp: true,
        ),
        CrmKpiEntity(
          label: 'Active Leads',
          value: '3',
          icon: Icons.person_search_rounded,
          state: KpiSemanticState.warning,
          trend: '+1',
          trendUp: true,
        ),
      ];

  @override
  List<CrmChannelEntity> get channels => const [];

  @override
  List<IntegrationEntity> get integrations => const [
        IntegrationEntity(
          name: 'META',
          icon: Icons.facebook_rounded,
          color: Colors.blue,
          connected: true,
          lastSyncAt: '2026-10-18 09:00',
          syncStatus: 'IDLE',
          leadCount: 24,
        ),
      ];

  @override
  List<ConversationEntity> get conversations => const [
        ConversationEntity(
          id: 'c1',
          customerName: 'Ahmed Al Mansoori',
          lastMessage: 'Is my car ready for pickup?',
          time: '10:30 AM',
          channel: 'WhatsApp',
          channelColor: Colors.green,
          unread: 2,
          status: 'OPEN',
        ),
      ];

  @override
  List<CrmTrendPoint> get conversionTrend => const [
        CrmTrendPoint('Jan', 10, 2, 5),
        CrmTrendPoint('Feb', 12, 3, 6),
      ];

  @override
  List<SalespersonPerf> get salespersonPerf => const [
        SalespersonPerf('Ravi Kumar', 20, 12),
      ];

  @override
  List<ResponseTimeBucket> get responseTimeBuckets => const [
        ResponseTimeBucket('<5m', 8),
        ResponseTimeBucket('>1h', 2),
      ];

  @override
  List<LeadSourceSlice> get leadSources => const [
        LeadSourceSlice('Meta', 60, Colors.blue),
        LeadSourceSlice('Zoho', 40, Colors.green),
      ];

  @override
  List<CrmKeyMetric> get keyMetrics => const [
        CrmKeyMetric(
          label: 'Win rate',
          value: '30%',
          sub: 'this month',
          up: true,
          color: Colors.green,
        ),
      ];

  @override
  List<SalesTeamMember> get salesTeam => const [
        SalesTeamMember(
          name: 'Ravi Kumar',
          role: 'Senior Advisor',
          leadsHandled: 40,
          wonDeals: 12,
          revenue: 'AED 96,000',
          winRate: 0.3,
        ),
        SalesTeamMember(
          name: 'Lina Haddad',
          role: 'Advisor',
          leadsHandled: 28,
          wonDeals: 6,
          revenue: 'AED 41,000',
          winRate: 0.21,
        ),
      ];

  @override
  Future<void> refresh() async {}
}

class _FakeTeam extends TeamNotifier {
  @override
  Future<List<TeamMemberEntity>> build() async => const [];
}

class _FakeRepo implements CrmRepository {
  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String id) async =>
      const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Override> _overrides() => [
      crmLeadProvider.overrideWith(_FakeLeads.new),
      crmTaskProvider.overrideWith(_FakeTasks.new),
      leadAnalyticsProvider.overrideWith(_FakeAnalytics.new),
      crmUiProvider.overrideWith(_FakeUi.new),
      teamMembersProvider.overrideWith(_FakeTeam.new),
      crmRepositoryProvider.overrideWithValue(_FakeRepo()),
    ];

Future<void> _pumpSurface(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required Locale locale,
  bool dark = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('dashboard 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CrmDashboardPage(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CrmDashboardPage),
        matchesGoldenFile('goldens/crm_dash_390_$label.png'),
      );
    });

    testWidgets('leads list 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CrmLeadsPage(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CrmLeadsPage),
        matchesGoldenFile('goldens/crm_leads_390_$label.png'),
      );
    });

    testWidgets('tasks 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CrmTasksPage(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CrmTasksPage),
        matchesGoldenFile('goldens/crm_tasks_390_$label.png'),
      );
    });
  }

  testWidgets('leads table 1280 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmLeadsPage(),
      size: const Size(1280, 800),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmLeadsPage),
      matchesGoldenFile('goldens/crm_table_1280_en.png'),
    );
  });

  testWidgets('kanban 834 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmLeadsPage(),
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    // Switch the terminal into Kanban mode for the board render.
    await tester.tap(find.byTooltip('Kanban view'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmLeadsPage),
      matchesGoldenFile('goldens/crm_kanban_834_en.png'),
    );
  });

  testWidgets('dashboard 834 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmDashboardPage(),
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmDashboardPage),
      matchesGoldenFile('goldens/crm_dash_834_en.png'),
    );
  });

  testWidgets('dashboard 1280 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmDashboardPage(),
      size: const Size(1280, 800),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmDashboardPage),
      matchesGoldenFile('goldens/crm_dash_1280_en.png'),
    );
  });

  testWidgets('lead detail sheet 390 en', (tester) async {
    await _pumpSurface(
      tester,
      LeadDetailSheet(lead: _leads.first),
      size: const Size(390, 844),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(LeadDetailSheet),
      matchesGoldenFile('goldens/crm_detail_390_en.png'),
    );
  });

  testWidgets('lead form sheet 390 en', (tester) async {
    await _pumpSurface(
      tester,
      const LeadFormSheet(),
      size: const Size(390, 844),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(LeadFormSheet),
      matchesGoldenFile('goldens/crm_form_390_en.png'),
    );
  });

  testWidgets('shell 1280 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmDashboardView(),
      size: const Size(1280, 800),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmDashboardView),
      matchesGoldenFile('goldens/crm_shell_1280_en.png'),
    );
  });

  testWidgets('dashboard 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CrmDashboardPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmDashboardPage),
      matchesGoldenFile('goldens/crm_dash_390_dark.png'),
    );
  });

  testWidgets('shell 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CrmDashboardView(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmDashboardView),
      matchesGoldenFile('goldens/crm_shell_390_dark.png'),
    );
  });

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('conversations 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CrmConversationsPage(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CrmConversationsPage),
        matchesGoldenFile('goldens/crm_convos_390_$label.png'),
      );
    });

    testWidgets('team 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CrmSalesTeamPage(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CrmSalesTeamPage),
        matchesGoldenFile('goldens/crm_team_390_$label.png'),
      );
    });
  }

  testWidgets('conversations 1280 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmConversationsPage(),
      size: const Size(1280, 800),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmConversationsPage),
      matchesGoldenFile('goldens/crm_convos_1280_en.png'),
    );
  });

  testWidgets('reports 390 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmReportsPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmReportsPage),
      matchesGoldenFile('goldens/crm_reports_390_en.png'),
    );
  });

  testWidgets('reports 1280 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmReportsPage(),
      size: const Size(1280, 800),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmReportsPage),
      matchesGoldenFile('goldens/crm_reports_1280_en.png'),
    );
  });

  testWidgets('integrations 390 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmIntegrationsPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmIntegrationsPage),
      matchesGoldenFile('goldens/crm_integ_390_en.png'),
    );
  });

  testWidgets('settings 390 en', (tester) async {
    await _pumpSurface(
      tester,
      const CrmSettingsPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmSettingsPage),
      matchesGoldenFile('goldens/crm_settings_390_en.png'),
    );
  });

  testWidgets('connect sheet 390 en', (tester) async {
    await _pumpSurface(
      tester,
      const ConnectIntegrationSheet(),
      size: const Size(390, 844),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(ConnectIntegrationSheet),
      matchesGoldenFile('goldens/crm_connect_390_en.png'),
    );
  });

  testWidgets('conversations 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CrmConversationsPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmConversationsPage),
      matchesGoldenFile('goldens/crm_convos_390_dark.png'),
    );
  });

  testWidgets('team 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CrmSalesTeamPage(),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CrmSalesTeamPage),
      matchesGoldenFile('goldens/crm_team_390_dark.png'),
    );
  });
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String relative) async {
    final bytes = await File(relative).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  final sep = Platform.pathSeparator;
  await load(
    AppFontFamilies.app,
    '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
    '${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
      '${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$weight.ttf',
    );
  }
  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
