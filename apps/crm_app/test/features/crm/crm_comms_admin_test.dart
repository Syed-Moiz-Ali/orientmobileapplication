import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_integrations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_reports_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_settings_page.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 20 comms/admin contracts: real threads with honest read-only
/// panes, ranked leaderboard figures, real chart data, integration flows
/// with exact payloads, and settings toggles. Deterministic fakes; the
/// frozen providers are subclassed, never modified.
const _delegates = <LocalizationsDelegate<dynamic>>[
  CrmLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _thread = ConversationEntity(
  id: 'c1',
  customerName: 'Ahmed Al Mansoori',
  lastMessage: 'Is my car ready for pickup?',
  time: '10:30 AM',
  channel: 'WhatsApp',
  channelColor: Colors.green,
  unread: 2,
  status: 'OPEN',
);

const _member = SalesTeamMember(
  name: 'Ravi Kumar',
  role: 'Senior Advisor',
  leadsHandled: 40,
  wonDeals: 12,
  revenue: 'AED 96,000',
  winRate: 0.3,
);

const _meta = IntegrationEntity(
  name: 'META',
  icon: Icons.facebook_rounded,
  color: Colors.blue,
  connected: true,
  lastSyncAt: '2026-10-18 09:00',
  syncStatus: 'IDLE',
  leadCount: 24,
);

class _FakeUi extends CrmUiNotifier {
  _FakeUi();
  final convList = const [_thread];
  final teamList = const [_member];
  final integList = const [_meta];
  final connects = <Map<String, dynamic>>[];
  final syncs = <String>[];
  final disconnects = <String>[];

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
  List<ConversationEntity> get conversations => convList;

  @override
  List<SalesTeamMember> get salesTeam => teamList;

  @override
  List<IntegrationEntity> get integrations => integList;

  @override
  List<CrmKpiEntity> get kpis => const [];

  @override
  List<CrmChannelEntity> get channels => const [];

  @override
  List<CrmTrendPoint> get conversionTrend => const [
        CrmTrendPoint('Jan', 10, 2, 5),
        CrmTrendPoint('Feb', 12, 3, 6),
      ];

  @override
  List<LeadSourceSlice> get leadSources => const [
        LeadSourceSlice('Meta', 60, Colors.blue),
        LeadSourceSlice('Zoho', 40, Colors.green),
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
  Future<IntegrationEntity> connectIntegration(
    String name,
    Map<String, String> credentials,
  ) async {
    connects.add({'name': name, ...credentials});
    return const IntegrationEntity(
      name: 'META',
      icon: Icons.facebook_rounded,
      color: Colors.blue,
      connected: true,
    );
  }

  @override
  Future<IntegrationEntity> syncIntegration(String name) async {
    syncs.add(name);
    return _meta;
  }

  @override
  Future<IntegrationEntity> disconnectIntegration(String name) async {
    disconnects.add(name);
    return const IntegrationEntity(
      name: 'META',
      icon: Icons.facebook_rounded,
      color: Colors.blue,
      connected: false,
    );
  }

  @override
  Future<void> refresh() async {}
}

class _FakeLeads extends CrmLeadNotifier {
  @override
  List<CrmLeadEntity> build() => const [];

  @override
  Future<void> refresh() async {}

  @override
  Future<void> createLead(Map<String, dynamic> data) async {}

  @override
  Future<void> updateLead(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteLead(String id) async {}
}

class _FakeTasks extends CrmTaskNotifier {
  @override
  CrmTaskState build() => const CrmTaskState(tasks: []);

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
  LeadAnalyticsState build() => const LeadAnalyticsState();

  @override
  Future<void> refresh() async {}
}

class _FakeTeam extends TeamNotifier {
  @override
  Future<List<TeamMemberEntity>> build() async => const [];
}

class _FakeRepo implements CrmRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<Override> _overrides({_FakeUi? ui}) => [
      crmUiProvider.overrideWith(() => ui ?? _FakeUi()),
      crmLeadProvider.overrideWith(_FakeLeads.new),
      crmTaskProvider.overrideWith(_FakeTasks.new),
      leadAnalyticsProvider.overrideWith(_FakeAnalytics.new),
      teamMembersProvider.overrideWith(_FakeTeam.new),
      crmRepositoryProvider.overrideWithValue(_FakeRepo()),
    ];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
  _FakeUi? ui,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(ui: ui),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Conversations console', () {
    testWidgets('lists real threads with unread badges', (tester) async {
      await _pump(tester, const CrmConversationsPage());
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
      expect(find.text('Is my car ready for pickup?'), findsOneWidget);
      expect(find.text('WhatsApp'), findsWidgets);
      expect(find.text('2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('drills into an honest read-only thread', (tester) async {
      await _pump(tester, const CrmConversationsPage());
      await tester.tap(find.text('Ahmed Al Mansoori'));
      await tester.pumpAndSettle();
      // Thread shows the real latest message + dossier, never a composer.
      expect(find.text('Latest message'), findsOneWidget);
      expect(find.textContaining('newest message shown here'), findsOneWidget);
      expect(find.text('Customer dossier'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Latest message'), findsNothing);
    });

    testWidgets('shows three panes together on desktop', (tester) async {
      await _pump(
        tester,
        const CrmConversationsPage(),
        size: const Size(1280, 800),
      );
      expect(find.text('Ahmed Al Mansoori'), findsWidgets);
      expect(find.text('Latest message'), findsOneWidget);
      expect(find.text('Customer dossier'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Arabic without exceptions', (tester) async {
      await _pump(
        tester,
        const CrmConversationsPage(),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('المحادثات'), findsOneWidget);
    });
  });

  group('Sales team leaderboard', () {
    testWidgets('ranks real figures with badges', (tester) async {
      await _pump(tester, const CrmSalesTeamPage());
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('AED 96,000'), findsOneWidget);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Reports suite', () {
    testWidgets('charts real provider data with placeholders', (tester) async {
      await _pump(tester, const CrmReportsPage());
      expect(find.text('Conversion Trends'), findsOneWidget);
      expect(find.text('Lead Sources'), findsOneWidget);
      expect(find.text('Salesperson Performance'), findsOneWidget);
      expect(find.text('Response Time Analysis'), findsOneWidget);
      expect(find.text('Key Metrics'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Integrations hub', () {
    testWidgets('syncs and disconnects through real flows', (tester) async {
      final ui = _FakeUi();
      await _pump(
        tester,
        const CrmIntegrationsPage(),
        ui: ui,
      );
      expect(find.text('META'), findsOneWidget);
      expect(find.text('Connected'), findsWidgets);
      await tester.tap(find.text('META'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();
      expect(ui.syncs, ['META']);
      expect(find.text('Sync completed - leads updated'), findsOneWidget);
      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();
      expect(ui.disconnects, ['META']);
    });
  });

  group('Connect sheet', () {
    testWidgets('validates Meta credentials inline', (tester) async {
      final ui = _FakeUi();
      await _pump(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConnectIntegrationSheet.show(context),
            child: const Text('open'),
          ),
        ),
        ui: ui,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Connect META'));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter both Page ID and Access Token'),
        findsOneWidget,
      );
      expect(ui.connects, isEmpty);
    });

    testWidgets('connects with the exact credential map', (tester) async {
      final ui = _FakeUi();
      await _pump(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConnectIntegrationSheet.show(context),
            child: const Text('open'),
          ),
        ),
        ui: ui,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '123456789012345');
      await tester.enterText(fields.at(1), 'EAAGtoken');
      await tester.ensureVisible(find.text('Connect META'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Connect META'));
      await tester.pumpAndSettle();
      expect(ui.connects, hasLength(1));
      expect(
        ui.connects.single,
        {
          'name': 'META',
          'pageId': '123456789012345',
          'accessToken': 'EAAGtoken',
        },
      );
      expect(
        find.text('META connected! Tap Sync Now to fetch leads'),
        findsOneWidget,
      );
    });
  });

  group('Settings rows', () {
    testWidgets('toggles map to real provider bools', (tester) async {
      await _pump(tester, const CrmSettingsPage());
      expect(find.text('Push notifications'), findsOneWidget);
      expect(find.text('Automatically assign leads'), findsOneWidget);
      expect(find.text('Dark appearance'), findsOneWidget);
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });
}
