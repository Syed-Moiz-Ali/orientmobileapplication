// Structural tests for the recomposed CRM sales team list (list family).
//
// Presentation-tree assertions only: header, ranked rows, medal rule,
// figures, progress semantics, empty state. Behavior (providers, ranking
// math) is asserted nowhere.
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_search_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

SalesTeamMember _member(String name, int leads, int won) => SalesTeamMember(
  name: name,
  role: 'Closer',
  leadsHandled: leads,
  wonDeals: won,
  revenue: 'AED 12000',
  winRate: won / (leads == 0 ? 1 : leads),
);

class _FakeCrmRepo implements CrmRepository {
  final List<SalesTeamMember> team;
  _FakeCrmRepo(this.team);

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
  List<IntegrationEntity> get integrations => const [];
  @override
  List<SalesTeamMember> get salesTeam => team;
  @override
  List<ConversationEntity> get conversations => const [];
  @override
  List<CrmLeadEntity> getLeads() => const [];
  @override
  List<CrmTaskEntity> getTasks() => const [];
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

Future<void> _pumpTeam(
  WidgetTester tester,
  List<SalesTeamMember> team, {
  double scale = 1.0,
  Size viewport = const Size(360, 800),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [crmRepositoryProvider.overrideWithValue(_FakeCrmRepo(team))],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: CrmSalesTeamPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  group('crm sales team (after)', () {
    testWidgets('header + ranked rows render verbatim figures', (tester) async {
      await _pumpTeam(tester, [_member('Sara', 4, 3), _member('John', 2, 1)]);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.textContaining('Ranked by revenue won this period.'), findsOneWidget);
      expect(find.byType(AppSurfaceCard), findsNWidgets(2));
      expect(find.byType(AppAvatar), findsNWidgets(2));
      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
      // F7 display mapping: the `AED 12000` feed verbatim renders grouped.
      expect(find.text('AED 12,000'), findsNWidgets(2));
      expect(find.text('AED 12000'), findsNothing);
      // Small `Revenue` label above each figure (new `tmRevenue` key).
      expect(find.text('Revenue'), findsNWidgets(2));
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
    });

    testWidgets('win-rate bar keeps value + semantics', (tester) async {
      await _pumpTeam(tester, [_member('Sara', 4, 3)]);
      final bar = find.byWidgetPredicate(
        (w) => w is AppProgressBar && (w.value - 0.75).abs() < 0.001,
      );
      expect(bar, findsOneWidget);
      final semantics = find.byWidgetPredicate(
        (w) => w is AppProgressBar && (w.semanticLabel ?? '').contains('75%'),
      );
      expect(semantics, findsOneWidget);
    });

    testWidgets('empty team is a calm action-less empty state', (tester) async {
      await _pumpTeam(tester, const []);
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.textContaining('No salespeople yet'), findsOneWidget);
      expect(find.byType(AppPillButton), findsNothing);
    });

    testWidgets('rows are view-only (no destinations)', (tester) async {
      await _pumpTeam(tester, [_member('Sara', 4, 3)]);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
      // AppAvatar without onTap is display-only.
      expect(find.byType(AppAvatar), findsOneWidget);
    });

    testWidgets('rank 4+ rows lose the medal badge', (tester) async {
      await _pumpTeam(tester, [
        _member('A', 4, 3),
        _member('B', 4, 2),
        _member('C', 4, 1),
        _member('D', 4, 0),
      ]);
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#4'), findsOneWidget);
      expect(find.byType(AppSurfaceCard), findsNWidgets(4));
    });

    testWidgets('empty keeps the Leaderboard header for orientation', (tester) async {
      await _pumpTeam(tester, const []);
      expect(find.text('Leaderboard'), findsOneWidget);
      expect(find.textContaining('Ranked by revenue won this period.'), findsOneWidget);
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.byType(AppPillButton), findsNothing);
    });

    testWidgets('dark + 1.3x + 320px pump clean', (tester) async {
      await _pumpTeam(
        tester,
        [_member('Sara', 4, 3), _member('John', 2, 1)],
        scale: 1.3,
        viewport: const Size(640, 1136),
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(find.byType(AppSurfaceCard), findsNWidgets(2));
    });

    testWidgets('<=5: header + count, no find-aid', (tester) async {
      await _pumpTeam(tester, [_member('Sara', 4, 3), _member('John', 2, 1)]);
      expect(find.text('Leaderboard'), findsOneWidget);
      // Family > 5 rule: a 2-row roster is fully scannable, no search.
      expect(find.byTooltip('Search team'), findsNothing);
      expect(find.byType(AppSurfaceCard), findsNWidgets(2));
    });

    testWidgets('>5: no search in header; sheet filters roster when opened', (tester) async {
      final team = [
        _member('Sara', 4, 3),
        _member('John', 2, 1),
        _member('Mia', 6, 2),
        _member('Omar', 4, 0),
        _member('Lina', 5, 4),
        _member('Kris', 3, 1),
      ];
      await _pumpTeam(tester, team);
      // Ruling (a): the shell AppBar owns the single visible search path
      // (same >5 gate, same sheet) — the list header shows no search icon.
      // (ListView builds lazily, so no exact card count is pinned here.)
      expect(find.byTooltip('Search team'), findsNothing);
      expect(find.byType(AppSurfaceCard), findsWidgets);
      final ctx = tester.element(find.byType(CrmSalesTeamPage));
      showCrmSalesTeamSearchSheet(ctx, team: team, onSelect: (_) {});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Search team'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'zzz-no-such-member');
      await tester.pump();
      expect(find.text('No team members match your search.'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.text('Sara'), findsWidgets);
    });

    testWidgets('search result tap closes the sheet cleanly', (tester) async {
      final team = [
        _member('Sara', 4, 3),
        _member('John', 2, 1),
        _member('Mia', 6, 2),
        _member('Omar', 4, 0),
        _member('Lina', 5, 4),
        _member('Kris', 3, 1),
      ];
      await _pumpTeam(tester, team);
      // Ruling (a): shell owns the trigger; the sheet opens directly here.
      // Rows stay view-only (search reveals, never navigates) — the shell
      // STOP documents the scroll-reveal gap; this pin keeps the ≤ taps.
      final ctx = tester.element(find.byType(CrmSalesTeamPage));
      showCrmSalesTeamSearchSheet(ctx, team: team, onSelect: (_) {});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextField), 'lina');
      await tester.pump();
      // Sheet lists the match; tapping closes (no destinations, no
      // exception). No scroll-reveal is pinned here (shell STOP — the
      // page-owned anchors moved with the trigger); the ≤ tap budget holds.
      await tester.tap(find.text('Lina').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
