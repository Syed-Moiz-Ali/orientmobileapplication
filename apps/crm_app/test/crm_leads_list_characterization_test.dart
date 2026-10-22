// Structural tests for the recomposed CRM leads list (list family).
//
// Presentation-tree assertions only: header/find-aids threshold, per-card
// Call/menu reachability (tap budgets AFTER ≤ BEFORE), sentence-case
// status pills, search/filter sheets, remove dialog, loading/empty/
// no-match states, pull-to-refresh. Behavior (providers, navigation
// targets, launcher URIs, status payloads) is asserted nowhere.
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_kanban_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

CrmLeadEntity _lead(int i, {String status = 'ACTIVE'}) => CrmLeadEntity(
  id: 'l$i',
  sno: i,
  leadNumber: 'LD-100$i',
  customerName: i == 0 ? '' : 'Customer $i',
  phone: '+971 50 100 000$i',
  email: 'c$i@example.com',
  source: i.isEven ? 'Meta' : 'Zoho',
  sourceColor: Colors.blue,
  assignedTo: i.isEven ? 'Sara' : 'John',
  status: status,
  statusColor: Colors.green,
  lastActivity: 'Called',
  leadValue: 12000 + i * 1000,
  followUpDate: '2026-10-2$i',
);

class _FakeCrmRepo implements CrmRepository {
  final List<CrmLeadEntity> leads;
  final List<IntegrationEntity> _integrations;
  _FakeCrmRepo({required this.leads, required List<IntegrationEntity> integrations})
    : _integrations = integrations;

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
  List<IntegrationEntity> get integrations => _integrations;
  @override
  List<SalesTeamMember> get salesTeam => const [];
  @override
  List<ConversationEntity> get conversations => const [];
  // Copy-on-read like the production adapter: the notifier keeps the
  // returned list as state, so a mutated same-instance list would compare
  // equal and never notify. Copies keep invalidate-self honest.
  @override
  List<CrmLeadEntity> getLeads() => List.of(leads);
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
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data) async {
    final i = leads.indexWhere((l) => l.id == id);
    return leads[i];
  }

  @override
  Future<void> deleteLead(String id) async {
    leads.removeWhere((l) => l.id == id);
  }

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

IntegrationEntity _integration({required bool connected}) => IntegrationEntity(
  name: 'Meta',
  icon: Icons.hub_outlined,
  color: Colors.blue,
  connected: connected,
);

Future<void> _pumpLeads(
  WidgetTester tester, {
  required List<CrmLeadEntity> leads,
  required List<IntegrationEntity> integrations,
  double scale = 1.0,
  Size viewport = const Size(360, 800),
}) async {
  // Compact viewport: the list branch only renders below the medium
  // breakpoint; the default 800x600 test surface takes the master-detail
  // table branch instead.
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        crmRepositoryProvider.overrideWithValue(
          _FakeCrmRepo(leads: leads, integrations: integrations),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: CrmLeadsPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  group('crm leads list (after)', () {
    testWidgets('<=5: header + count + Add, no find-aids, direct Call', (tester) async {
      await _pumpLeads(
        tester,
        leads: [_lead(0), _lead(1)],
        integrations: [_integration(connected: true)],
      );
      expect(find.text('Leads'), findsOneWidget);
      expect(find.text('2 leads'), findsOneWidget);
      expect(find.text('Add Lead'), findsOneWidget);
      // Progressive disclosure: no search/filter icons with ≤ 5 items.
      expect(find.byTooltip('Search leads'), findsNothing);
      expect(find.byTooltip('Filter leads'), findsNothing);
      // Kanban/table toggle kept.
      expect(find.byTooltip('Kanban view'), findsOneWidget);
      // Borderless cards, one per lead.
      expect(find.byType(AppSurfaceCard), findsNWidgets(2));
      // Sentence-case pills (no ALL-CAPS).
      expect(find.text('Active'), findsNWidgets(2));
      expect(find.text('ACTIVE'), findsNothing);
      // Call directly on each card (≤ 1 tap from the list).
      expect(find.text('Call'), findsNWidgets(2));
      expect(find.byIcon(Icons.more_vert_rounded), findsNWidgets(2));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('records render name/phone/value; tap opens dossier', (tester) async {
      await _pumpLeads(
        tester,
        leads: [_lead(0), _lead(1)],
        integrations: [_integration(connected: true)],
      );
      // Lead 0 falls back to leadNumber when the name is empty.
      expect(find.text('LD-1000'), findsOneWidget);
      expect(find.text('Customer 1'), findsOneWidget);
      expect(find.textContaining('AED'), findsNWidgets(2));
      await tester.tap(find.byType(AppSurfaceCard).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BottomSheet), findsWidgets);
    });

    testWidgets('Call places the dialer intent (graceful notice in tests)', (tester) async {
      await _pumpLeads(
        tester,
        leads: [_lead(1)],
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.text('Call'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // url_launcher resolves on real event-loop turns; advance the fake
      // clock past the 3s launch bound so the graceful notice lands.
      await tester.pump(const Duration(seconds: 4));
      // No dialer in tests: the same failure notice the sheet shows.
      expect(find.text('Unable to open the phone app.'), findsOneWidget);
    });

    testWidgets('card menu holds WhatsApp + Edit + Delete', (tester) async {
      await _pumpLeads(
        tester,
        leads: [_lead(1)],
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Edit lead'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('menu Delete confirms via AppDialog and removes', (tester) async {
      final leads = [_lead(1)];
      await _pumpLeads(
        tester,
        leads: leads,
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppDialog), findsOneWidget);
      // AppDialog bidi-isolates its title; match the contained copy.
      expect(find.textContaining('Delete Lead'), findsOneWidget);
      await tester.tap(
        find.descendant(of: find.byType(AppDialog), matching: find.text('Delete')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AppSurfaceCard), findsNothing);
    });

    testWidgets('>5: search + filter icons appear together', (tester) async {
      await _pumpLeads(
        tester,
        leads: [for (var i = 0; i < 6; i++) _lead(i)],
        integrations: [_integration(connected: true)],
      );
      expect(find.text('6 leads'), findsOneWidget);
      expect(find.byTooltip('Search leads'), findsOneWidget);
      expect(find.byTooltip('Filter leads'), findsOneWidget);
    });

    testWidgets('search sheet filters loaded leads; no-match + Clear', (tester) async {
      await _pumpLeads(
        tester,
        leads: [for (var i = 0; i < 6; i++) _lead(i)],
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.byTooltip('Search leads'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Search leads'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'zzz-no-such-lead');
      await tester.pump();
      expect(find.text('No leads match your search.'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pump();
      // The sheet list restores (Customer 1 shows in the sheet row and the
      // card behind it).
      expect(find.text('Customer 1'), findsWidgets);
    });

    testWidgets('filter sheet applies source facet; count updates', (tester) async {
      await _pumpLeads(
        tester,
        leads: [for (var i = 0; i < 6; i++) _lead(i)],
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.byTooltip('Filter leads'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Filter leads'), findsWidgets);
      expect(find.text('Source'), findsOneWidget);
      expect(find.text('Agent'), findsOneWidget);
      await tester.tap(find.text('Zoho').first);
      await tester.pump();
      await tester.tap(find.text('Show results'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('3 leads · Filter leads'), findsOneWidget);
    });

    testWidgets('filtered-to-zero is a no-match with Clear', (tester) async {
      // Fixtures: even i -> Meta+Sara, odd i -> Zoho+John. Zoho + Sara is
      // disjoint, so the filtered list is honestly empty.
      await _pumpLeads(
        tester,
        leads: [for (var i = 0; i < 6; i++) _lead(i)],
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.byTooltip('Filter leads'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Zoho'));
      await tester.pump();
      await tester.tap(find.text('Sara'));
      await tester.pump();
      await tester.tap(find.text('Show results'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // AppEmptyState bidi-isolates its copy; match the contained text.
      expect(find.textContaining('No leads match this filter.'), findsOneWidget);
      expect(find.byType(AppSurfaceCard), findsNothing);
      // Scope to the no-match state's own CTA (the filter sheet may still
      // be dismissing above it with its own Clear action).
      await tester.tap(
        find.descendant(of: find.byType(AppEmptyState), matching: find.text('Clear')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('6 leads'), findsOneWidget);
    });

    testWidgets('empty-sync state offers Sync Now', (tester) async {
      await _pumpLeads(
        tester,
        leads: const [],
        integrations: [_integration(connected: true)],
      );
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.textContaining('No leads yet'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
      expect(find.byType(AppSurfaceCard), findsNothing);
    });

    testWidgets('no-crm state offers Connect Now', (tester) async {
      await _pumpLeads(
        tester,
        leads: const [],
        integrations: [_integration(connected: false)],
      );
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.textContaining('No third-party CRMs connected'), findsOneWidget);
      expect(find.text('Connect Now'), findsOneWidget);
    });

    testWidgets('kanban toggle switches to swimlanes', (tester) async {
      await _pumpLeads(
        tester,
        leads: [_lead(0), _lead(1)],
        integrations: [_integration(connected: true)],
      );
      await tester.tap(find.byTooltip('Kanban view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byTooltip('Table view'), findsOneWidget);
      expect(find.byType(CrmKanbanView), findsOneWidget);
    });

    testWidgets('dark + 1.3x + 320px pump clean (old overflow fixed)', (tester) async {
      tester.view.physicalSize = const Size(640, 1136); // 320x568 @2x
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crmRepositoryProvider.overrideWithValue(
              _FakeCrmRepo(
                leads: [_lead(0), _lead(1)],
                integrations: [_integration(connected: true)],
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const Scaffold(body: CrmLeadsPage()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.text('2 leads'), findsOneWidget);
    });
  });
}
