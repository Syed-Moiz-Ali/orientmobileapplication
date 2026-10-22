// Round-1 fixer pins (presentation only): tablet Stage chip fits whole and
// the wide dossier placeholder no longer reuses the search hint.
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

CrmLeadEntity _lead(int i) => CrmLeadEntity(
  sno: i,
  id: 'l$i',
  leadNumber: 'LD-100$i',
  customerName: i == 0 ? '' : 'Customer $i',
  phone: '+971 50 100 000$i',
  email: 'c$i@example.com',
  source: i.isEven ? 'Meta' : 'Zoho',
  sourceColor: Colors.blue,
  assignedTo: i.isEven ? 'Sara' : 'John',
  status: 'ACTIVE',
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
  @override
  List<CrmLeadEntity> getLeads() => leads;
  @override
  List<CrmTaskEntity> getTasks() => const [];
  @override
  Future<void> refreshLeads() async {}
  @override
  Future<void> refreshTasks() async {}
  @override
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteTask(String id) async {}
  @override
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteLead(String id) async {}
  @override
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> c) async =>
      throw UnimplementedError();
  @override
  Future<IntegrationEntity> disconnectIntegration(String name) async =>
      throw UnimplementedError();
  @override
  Future<IntegrationEntity> syncIntegration(String name) async =>
      throw UnimplementedError();
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

IntegrationEntity _integration() => IntegrationEntity(
  name: 'Meta',
  icon: Icons.hub_outlined,
  color: Colors.blue,
  connected: true,
);

Future<void> _pumpLeads(
  WidgetTester tester, {
  required List<CrmLeadEntity> leads,
  required Size viewport,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        crmRepositoryProvider.overrideWithValue(
          _FakeCrmRepo(leads: leads, integrations: [_integration()]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        home: const Scaffold(body: CrmLeadsPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('tablet wide: dossier placeholder is the select prompt, not the search hint', (
    tester,
  ) async {
    await _pumpLeads(
      tester,
      leads: [for (var i = 0; i < 6; i++) _lead(i)],
      viewport: const Size(768, 1024),
    );
    expect(tester.takeException(), isNull);
    // Empty-selection prompt (new leadsSelectLead key).
    expect(find.text('Select a lead to view details'), findsOneWidget);
    // The search hint must not stand in for dossier copy when idle.
    expect(find.text('Search leads...'), findsNothing);
    // All six rows keep a whole-word Stage chip.
    expect(find.text('Active'), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact intact: cards + count + direct Call unchanged', (tester) async {
    await _pumpLeads(
      tester,
      leads: [_lead(0), _lead(1)],
      viewport: const Size(360, 800),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('2 leads'), findsOneWidget);
    expect(find.byType(AppSurfaceCard), findsNWidgets(2));
    expect(find.text('Call'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
