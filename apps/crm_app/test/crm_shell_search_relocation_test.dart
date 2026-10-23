// Structural tests for ruling (a) search relocation (crm_app).
//
// Presentation-tree assertions only: the shell AppBar owns the SINGLE
// visible search path on the leads/tasks/team tabs (contextual per tab,
// same >5 gate, same EXISTING sheets); list headers show no search icon
// (filter + Add stay). Non-list tabs keep the palette; Ctrl+K stays wired.
// Behavior (providers, predicates, routes) is asserted nowhere.
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_dashboard_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

CrmLeadEntity _lead(int i) => CrmLeadEntity(
  id: 'l$i',
  sno: i,
  leadNumber: 'LD-100$i',
  customerName: 'Customer $i',
  phone: '+971 50 100 000$i',
  email: 'c$i@example.com',
  source: 'Meta',
  sourceColor: Colors.blue,
  assignedTo: 'Sara',
  status: 'ACTIVE',
  statusColor: Colors.green,
  lastActivity: 'Called',
  leadValue: 12000,
  followUpDate: '2026-10-20',
);

CrmTaskEntity _task(int i) => CrmTaskEntity(
  id: 't$i',
  title: 'Task $i',
  assignedTo: 'Sara',
  dueDate: '',
  priority: 'High',
  priorityColor: Colors.red,
);

SalesTeamMember _member(String name) => SalesTeamMember(
  name: name,
  role: 'Closer',
  leadsHandled: 4,
  wonDeals: 3,
  revenue: 'AED 12000',
  winRate: 0.75,
);

IntegrationEntity _integration() => IntegrationEntity(
  name: 'Meta',
  icon: Icons.hub_outlined,
  color: Colors.blue,
  connected: true,
);

class _FakeCrmRepo implements CrmRepository {
  final List<CrmLeadEntity> leads;
  final List<CrmTaskEntity> tasks;
  final List<SalesTeamMember> team;
  _FakeCrmRepo({required this.leads, required this.tasks, required this.team});

  @override
  List<CrmKpiEntity> get kpis => const [];
  @override
  List<CrmChannelEntity> get channels => const [];
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
  List<IntegrationEntity> get integrations => [_integration()];
  @override
  List<SalesTeamMember> get salesTeam => team;
  @override
  List<ConversationEntity> get conversations => const [];
  @override
  List<CrmLeadEntity> getLeads() => List.of(leads);
  @override
  List<CrmTaskEntity> getTasks() => List.of(tasks);
  @override
  Future<void> refreshLeads() async {}
  @override
  Future<void> refreshTasks() async {}
  @override
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<void> deleteTask(String id) async {}
  @override
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data) async => throw UnimplementedError();
  @override
  Future<void> deleteLead(String id) async {}
  @override
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> c) async => throw UnimplementedError();
  @override
  Future<IntegrationEntity> disconnectIntegration(String name) async => throw UnimplementedError();
  @override
  Future<IntegrationEntity> syncIntegration(String name) async => throw UnimplementedError();
  @override
  Future<List<TeamMemberEntity>> getTeamMembers() async => const [];
  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String id) async => const [];
  @override
  Future<LeadStatsEntity> getLeadStats() async => const LeadStatsEntity();
  @override
  Future<List<FollowUpEntity>> getFollowUps() async => const [];
  @override
  Future<List<ActivityFeedEntity>> getActivityFeed() async => const [];
  @override
  Future<void> loadAll() async {}
}

Future<ProviderContainer> _pumpShell(
  WidgetTester tester, {
  required List<CrmLeadEntity> leads,
  required List<CrmTaskEntity> tasks,
  required List<SalesTeamMember> team,
  required int tab,
  Size viewport = const Size(360, 800),
  double scale = 1.0,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  late ProviderContainer container;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        crmRepositoryProvider.overrideWithValue(
          _FakeCrmRepo(leads: leads, tasks: tasks, team: team),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: const CrmDashboardView(),
          );
        },
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  container = ProviderScope.containerOf(tester.element(find.byType(CrmDashboardView)));
  container.read(crmUiProvider.notifier).selectTab(tab);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
  return container;
}

/// Counts visible search icons (shell trigger). After ruling (a) the list
/// headers show none, so every search icon found is the shell path.
int _searchIconCount() => find.byIcon(Icons.search_rounded).evaluate().length;

void main() {
  group('crm shell search relocation (ruling a)', () {
    testWidgets('leads <=5: no visible search (sanctioned exception holds)', (tester) async {
      await _pumpShell(
        tester,
        leads: [_lead(0), _lead(1)],
        tasks: const [],
        team: const [],
        tab: 1,
      );
      expect(find.text('Leads'), findsWidgets);
      expect(_searchIconCount(), 0);
      expect(find.byTooltip('Search leads'), findsNothing);
      expect(find.byTooltip('Filter leads'), findsNothing);
    });

    testWidgets('leads >5: single shell search opens the leads sheet', (tester) async {
      await _pumpShell(
        tester,
        leads: [for (var i = 0; i < 6; i++) _lead(i)],
        tasks: const [],
        team: const [],
        tab: 1,
      );
      expect(_searchIconCount(), 1);
      expect(find.byTooltip('Search leads'), findsNothing);
      expect(find.byTooltip('Filter leads'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Search leads'), findsWidgets);
      await tester.pump(const Duration(milliseconds: 200));
      // Dismiss for a clean teardown.
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('tasks <=5: no visible search', (tester) async {
      await _pumpShell(
        tester,
        leads: const [],
        tasks: [_task(0), _task(1)],
        team: const [],
        tab: 4,
      );
      expect(find.text('Tasks'), findsWidgets);
      expect(_searchIconCount(), 0);
      expect(find.byTooltip('Search tasks'), findsNothing);
    });

    testWidgets('tasks >5: single shell search opens the tasks sheet', (tester) async {
      await _pumpShell(
        tester,
        leads: const [],
        tasks: [for (var i = 0; i < 6; i++) _task(i)],
        team: const [],
        tab: 4,
      );
      expect(_searchIconCount(), 1);
      expect(find.byTooltip('Search tasks'), findsNothing);
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Search tasks'), findsWidgets);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('team <=5: no visible search', (tester) async {
      await _pumpShell(
        tester,
        leads: const [],
        tasks: const [],
        team: [_member('Sara'), _member('John')],
        tab: 3,
      );
      expect(find.text('Leaderboard'), findsWidgets);
      expect(_searchIconCount(), 0);
      expect(find.byTooltip('Search team'), findsNothing);
    });

    testWidgets('team >5: single shell search opens the team sheet', (tester) async {
      await _pumpShell(
        tester,
        leads: const [],
        tasks: const [],
        team: [_member('Sara'), _member('John'), _member('Mia'), _member('Omar'), _member('Lina'), _member('Kris')],
        tab: 3,
      );
      expect(_searchIconCount(), 1);
      expect(find.byTooltip('Search team'), findsNothing);
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Search team'), findsWidgets);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('non-list tab keeps the palette; Ctrl+K stays wired', (tester) async {
      await _pumpShell(
        tester,
        leads: [_lead(0)],
        tasks: const [],
        team: const [],
        tab: 0,
      );
      // Palette trigger visible on non-list tabs.
      expect(_searchIconCount(), 1);
      expect(find.byType(WorkspaceSearchShortcuts), findsOneWidget);
      final shortcuts = tester.widget<WorkspaceSearchShortcuts>(
        find.byType(WorkspaceSearchShortcuts),
      );
      expect(shortcuts.onSearch, isNotNull);
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // Palette hint (jump-to-dossier), not a list sheet.
      expect(find.textContaining('Type to filter'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('RTL + 320px + 1.3x pump clean on a relocated tab', (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crmRepositoryProvider.overrideWithValue(
              _FakeCrmRepo(
                leads: [for (var i = 0; i < 6; i++) _lead(i)],
                tasks: const [],
                team: const [],
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: AppLocales.supported,
            localizationsDelegates: const [
              CrmLocalizations.delegate,
              SharedCoreLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(BrandConfig.orient, locale: const Locale('ar')),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const CrmDashboardView(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final container = ProviderScope.containerOf(tester.element(find.byType(CrmDashboardView)));
      container.read(crmUiProvider.notifier).selectTab(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(_searchIconCount(), 1);
    });
  });
}
