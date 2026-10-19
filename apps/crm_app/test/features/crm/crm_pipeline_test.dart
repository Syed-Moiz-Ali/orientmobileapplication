import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_dashboard_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_board_filter.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_form_sheet.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 19 pipeline contracts: funnel filtering, table sorting, kanban
/// quick-select through the existing endpoint, launcher failure honesty,
/// PhoneNumber form rules and task badges. Deterministic fakes; the frozen
/// providers are subclassed, never modified.
const _delegates = <LocalizationsDelegate<dynamic>>[
  CrmLocalizations.delegate,
  SharedCoreLocalizations.delegate,
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
      email: '',
      source: source,
      sourceColor: Colors.green,
      assignedTo: agent,
      status: status,
      statusColor: Colors.blue,
      lastActivity: 'Just now',
      leadValue: value,
      followUpDate: '',
    );

class _FakeLeads extends CrmLeadNotifier {
  _FakeLeads(this._leads);
  List<CrmLeadEntity> _leads;
  final List<Map<String, dynamic>> updates = [];
  final List<Map<String, dynamic>> creates = [];

  @override
  List<CrmLeadEntity> build() => _leads;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> updateLead(String id, Map<String, dynamic> data) async {
    updates.add({'id': id, ...data});
    final index = _leads.indexWhere((l) => l.id == id);
    if (index >= 0 && data['status'] is String) {
      final old = _leads[index];
      _leads = List.of(_leads)
        ..[index] = CrmLeadEntity(
          id: old.id,
          sno: old.sno,
          leadNumber: old.leadNumber,
          customerName: old.customerName,
          phone: old.phone,
          email: old.email,
          source: old.source,
          sourceColor: old.sourceColor,
          assignedTo: old.assignedTo,
          status: data['status'] as String,
          statusColor: old.statusColor,
          lastActivity: old.lastActivity,
          notes: old.notes,
          leadValue: old.leadValue,
          followUpDate: old.followUpDate,
        );
      state = _leads;
    }
  }

  @override
  Future<void> createLead(Map<String, dynamic> data) async {
    creates.add(data);
  }

  @override
  Future<void> deleteLead(String id) async {
    _leads = _leads.where((l) => l.id != id).toList();
    state = _leads;
  }
}

class _FakeTasks extends CrmTaskNotifier {
  _FakeTasks(List<CrmTaskEntity> tasks) : _tasks = tasks;
  List<CrmTaskEntity> _tasks;
  final toggles = <String>[];

  @override
  CrmTaskState build() => CrmTaskState(tasks: _tasks);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> toggleTask(String id, bool isDone) async {
    toggles.add(id);
    _tasks = _tasks
        .map((t) => t.id == id ? t.copyWith(isDone: isDone) : t)
        .toList();
    state = state.copyWith(tasks: _tasks);
  }

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
  _FakeAnalytics(this._state);
  final LeadAnalyticsState _state;

  @override
  LeadAnalyticsState build() => _state;

  @override
  Future<void> refresh() async {}
}

class _FakeUi extends CrmUiNotifier {
  int refreshes = 0;

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
  List<CrmKpiEntity> get kpis => const [];

  @override
  List<CrmChannelEntity> get channels => const [];

  @override
  List<IntegrationEntity> get integrations => const [];

  @override
  List<ConversationEntity> get conversations => const [];

  @override
  List<CrmTrendPoint> get conversionTrend => const [];

  @override
  List<SalespersonPerf> get salespersonPerf => const [];

  @override
  List<ResponseTimeBucket> get responseTimeBuckets => const [];

  @override
  List<LeadSourceSlice> get leadSources => const [];

  @override
  List<CrmKeyMetric> get keyMetrics => const [];

  @override
  List<SalesTeamMember> get salesTeam => const [];

  @override
  Future<void> refresh() async {
    refreshes++;
  }
}

class _FakeTeam extends TeamNotifier {
  @override
  Future<List<TeamMemberEntity>> build() async => const [
        TeamMemberEntity(
          name: 'Ravi',
          role: '',
          designation: '',
          leadsHandled: 0,
          wonDeals: 0,
        ),
      ];
}

class _FakeRepo implements CrmRepository {
  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String id) async =>
      const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _stats = LeadAnalyticsState(
  stats: LeadStatsEntity(
    total: 3,
    pipeline: [
      PipelineStageEntity(status: 'NEW', count: 2, value: 2000),
      PipelineStageEntity(status: 'CONTACTED', count: 1, value: 1000),
    ],
  ),
);

List<Override> _overrides({
  List<CrmLeadEntity>? leads,
  List<CrmTaskEntity>? tasks,
  LeadAnalyticsState analytics = _stats,
  _FakeLeads? leadFake,
  _FakeUi? uiFake,
}) {
  final lf =
      leadFake ??
      _FakeLeads(
        leads ??
            [
              _lead(id: '1', name: 'Ahmed', status: 'NEW'),
              _lead(id: '2', name: 'Sara', status: 'NEW'),
              _lead(id: '3', name: 'Omar', status: 'CONTACTED'),
            ],
      );
  return [
    crmLeadProvider.overrideWith(() => lf),
    crmTaskProvider.overrideWith(
      () => _FakeTasks(
        tasks ??
            [
              const CrmTaskEntity(
                id: 't1',
                title: 'Call back',
                assignedTo: 'Ravi',
                dueDate: '2000-01-01',
                priority: 'High',
                priorityColor: Colors.red,
              ),
            ],
      ),
    ),
    leadAnalyticsProvider.overrideWith(() => _FakeAnalytics(analytics)),
    crmUiProvider.overrideWith(() => uiFake ?? _FakeUi()),
    teamMembersProvider.overrideWith(_FakeTeam.new),
    crmRepositoryProvider.overrideWithValue(_FakeRepo()),
  ];
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
  List<Override>? overrides,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides ?? _overrides(),
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
  group('crmLeadStatusMap', () {
    test('carries the exact status-change fields', () {
      final lead = _lead(id: '9', name: 'Zed', status: 'NEW');
      expect(
        crmLeadStatusMap(lead, 'WON'),
        {
          'customerName': 'Zed',
          'phone': '+971501234567',
          'email': '',
          'source': 'WhatsApp',
          'assignedTo': 'Ravi',
          'status': 'WON',
          'lastActivity': 'Status changed to WON',
          'notes': '',
          'leadValue': 1000,
          'followUpDate': '',
        },
      );
    });
  });

  group('Dashboard funnel', () {
    testWidgets('tapping a stage filters the leads board', (tester) async {
      final ui = _FakeUi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(uiFake: ui),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: _delegates,
            supportedLocales: AppLocales.supported,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: CrmDashboardView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Funnel shows real stages; tapping NEW filters + jumps to Leads.
      await tester.tap(find.text('NEW').first);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CrmDashboardView)),
      );
      expect(container.read(crmLeadStageFilterProvider), 'NEW');
      expect(container.read(crmUiProvider).selectedIndex, 1);
    });
  });

  group('Leads table', () {
    testWidgets('sorts by value on wide screens', (tester) async {
      final lf = _FakeLeads([
        _lead(id: '1', name: 'Ahmed', status: 'NEW', value: 3000),
        _lead(id: '2', name: 'Sara', status: 'NEW', value: 1000),
        _lead(id: '3', name: 'Omar', status: 'CONTACTED', value: 2000),
      ]);
      await _pump(
        tester,
        const CrmLeadsPage(),
        size: const Size(1280, 800),
        overrides: _overrides(leadFake: lf),
      );
      // Highest first after tapping the Value header twice (asc then desc).
      await tester.tap(find.text('Value'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Value'));
      await tester.pumpAndSettle();
      final table = tester.widget<AppTable<CrmLeadEntity>>(
        find.byType(AppTable<CrmLeadEntity>),
      );
      expect(table.items.first.customerName, 'Ahmed');
    });

    testWidgets('renders in Arabic without exceptions', (tester) async {
      await _pump(
        tester,
        const CrmLeadsPage(),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('ابحث في العملاء...'), findsOneWidget);
    });
  });

  group('Kanban quick-select', () {
    testWidgets('moves a card through the existing endpoint only', (
      tester,
    ) async {
      final lf = _FakeLeads([
        _lead(id: '1', name: 'Ahmed', status: 'NEW'),
      ]);
      await _pump(
        tester,
        const CrmLeadsPage(),
        size: const Size(1280, 800),
        overrides: _overrides(leadFake: lf),
      );
      // Switch to Kanban, open the card menu, move to WON.
      await tester.tap(find.byIcon(Icons.space_dashboard_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move to WON'));
      await tester.pumpAndSettle();

      expect(lf.updates, hasLength(1));
      expect(lf.updates.single['id'], '1');
      expect(lf.updates.single['status'], 'WON');
      expect(lf.updates.single['customerName'], 'Ahmed');
      expect(find.text('Lead moved to WON'), findsOneWidget);
    });
  });

  group('Detail launchers', () {
    testWidgets('failed launches say so instead of crashing', (tester) async {
      await _pump(tester, LeadDetailSheet(lead: _lead(id: '1', name: 'Ahmed', status: 'NEW')));
      await tester.tap(find.byKey(const ValueKey('leadWhatsAppButton')));
      // The launcher intent is bounded (3s); advance past it explicitly
      // because pumpAndSettle does not wait for pending timers.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Unable to open WhatsApp.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('leadCallButton')));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Unable to open the phone app.'), findsOneWidget);
    });
  });

  group('Lead form PhoneNumber', () {
    testWidgets('rejects an invalid phone inline', (tester) async {
      final lf = _FakeLeads([]);
      await _pump(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => LeadFormSheet.show(context),
            child: const Text('open'),
          ),
        ),
        overrides: _overrides(leadFake: lf),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Nadia');
      await tester.enterText(fields.at(1), '123');
      await tester.ensureVisible(find.byKey(const ValueKey('leadSaveButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('leadSaveButton')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid UAE mobile number.'), findsOneWidget);
      expect(lf.creates, isEmpty);
    });

    testWidgets('saves a valid phone in canonical format', (tester) async {
      final lf = _FakeLeads([]);
      await _pump(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => LeadFormSheet.show(context),
            child: const Text('open'),
          ),
        ),
        overrides: _overrides(leadFake: lf),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Nadia');
      await tester.enterText(fields.at(1), '0501234567');
      await tester.ensureVisible(find.byKey(const ValueKey('leadSaveButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('leadSaveButton')));
      await tester.pumpAndSettle();
      expect(lf.creates, hasLength(1));
      expect(lf.creates.single['phone'], '+971 50 123 4567');
    });
  });

  group('Tasks badges', () {
    testWidgets('overdue and done states badge honestly', (tester) async {
      await _pump(
        tester,
        const CrmTasksPage(),
        overrides: _overrides(tasks: [
          const CrmTaskEntity(
            id: 't1',
            title: 'Late call',
            assignedTo: 'Ravi',
            dueDate: '2000-01-01',
            priority: 'High',
            priorityColor: Colors.red,
          ),
          const CrmTaskEntity(
            id: 't2',
            title: 'Done thing',
            assignedTo: '',
            dueDate: '2000-01-01',
            priority: 'Low',
            priorityColor: Colors.green,
            isDone: true,
          ),
        ]),
      );
      expect(find.text('Overdue'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('taskToggle_t1')));
      await tester.pumpAndSettle();
      expect(find.text('Overdue'), findsNothing);
    });
  });
}
