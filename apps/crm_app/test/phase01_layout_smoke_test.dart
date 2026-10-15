import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_dashboard_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 (H3) — real-context layout smoke test.
///
/// Pumps the real `CrmDashboardView` workspace shell (adaptive navigation +
/// all eight tab pages) with fake providers at default and 1.3x text scale,
/// on phone / tablet / desktop widths, after the global text-scale lock
/// removal. Asserts: builds without exceptions, no RenderFlex overflow,
/// token typography resolves.
void main() {
  for (final scale in <double>[1.0, 1.3]) {
    testWidgets('CrmDashboardView lays out at ${scale}x on phone', (
      tester,
    ) async {
      await _pumpCrm(tester, size: const Size(390, 844), scale: scale);

      expect(tester.takeException(), isNull);
      expect(find.byType(CrmDashboardView), findsOneWidget);

      final context = tester.element(find.byType(CrmDashboardView));
      expect(
        Theme.of(context).textTheme.bodyMedium?.fontFamily,
        AppFontFamilies.app,
      );
    });
  }

  for (final size in <Size>[
    const Size(800, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets('CrmDashboardView lays out at ${size.width} px, 1.3x', (
      tester,
    ) async {
      await _pumpCrm(tester, size: size, scale: 1.3);

      expect(tester.takeException(), isNull);
      expect(find.byType(CrmDashboardView), findsOneWidget);
    });
  }

  testWidgets('CrmDashboardView survives 320 px at 1.3x', (tester) async {
    await _pumpCrm(tester, size: const Size(320, 640), scale: 1.3);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpCrm(
  WidgetTester tester, {
  required Size size,
  required double scale,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        crmUiProvider.overrideWith(_FakeCrmUiNotifier.new),
        crmLeadProvider.overrideWith(_FakeLeadNotifier.new),
        leadAnalyticsProvider.overrideWith(_FakeAnalyticsNotifier.new),
        crmTaskProvider.overrideWith(_FakeTaskNotifier.new),
        teamMembersProvider.overrideWith(_FakeTeamNotifier.new),
        // No plugin in tests: an empty stream keeps the offline banner hidden
        // without a direct connectivity_plus dependency in the CRM app.
        connectivityStatusProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const CrmDashboardView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeCrmUiNotifier extends CrmUiNotifier {
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
  Future<void> refresh() async {}

  @override
  List<CrmKpiEntity> get kpis => const [
    CrmKpiEntity(
      label: 'New Leads',
      value: '128',
      icon: Icons.person_add_alt_rounded,
      state: KpiSemanticState.info,
      trend: '12%',
      trendUp: true,
    ),
    CrmKpiEntity(
      label: 'Won',
      value: '42',
      icon: Icons.check_circle_outline_rounded,
      state: KpiSemanticState.success,
      trend: '8%',
      trendUp: true,
    ),
  ];

  @override
  List<CrmChannelEntity> get channels => const [
    CrmChannelEntity(
      label: 'WhatsApp',
      icon: Icons.chat_outlined,
      color: Color(0xFF1A8754),
      value: '128',
      trend: '12%',
      trendUp: true,
    ),
    CrmChannelEntity(
      label: 'Website',
      icon: Icons.language_rounded,
      color: Color(0xFF2563EB),
      value: '84',
      trend: '8%',
      trendUp: true,
    ),
  ];

  @override
  List<CrmTrendPoint> get conversionTrend => const [
    CrmTrendPoint('Jan', 10, 4, 6),
    CrmTrendPoint('Feb', 14, 5, 8),
  ];

  @override
  List<SalespersonPerf> get salespersonPerf => const [
    SalespersonPerf('John Doe', 40, 12),
    SalespersonPerf('Sarah Smith', 36, 10),
  ];

  @override
  List<ResponseTimeBucket> get responseTimeBuckets => const [
    ResponseTimeBucket('< 5 min', 22),
    ResponseTimeBucket('5-15 min', 14),
  ];

  @override
  List<LeadSourceSlice> get leadSources => const [
    LeadSourceSlice('WhatsApp', 46, Color(0xFF1A8754)),
    LeadSourceSlice('Website', 32, Color(0xFF2563EB)),
  ];

  @override
  List<CrmKeyMetric> get keyMetrics => const [
    CrmKeyMetric(label: 'Response rate', value: '92%', sub: 'All channels', up: true, color: Color(0xFF1A8754)),
    CrmKeyMetric(label: 'Follow-ups', value: '18', sub: 'Due today', up: false, color: Color(0xFFB7791F)),
  ];

  @override
  List<IntegrationEntity> get integrations => const [];

  @override
  List<SalesTeamMember> get salesTeam => const [
    SalesTeamMember(
      name: 'John Doe',
      role: 'Senior Sales',
      leadsHandled: 40,
      wonDeals: 12,
      revenue: 'AED 84K',
      winRate: 30,
    ),
    SalesTeamMember(
      name: 'Sarah Smith',
      role: 'Sales',
      leadsHandled: 36,
      wonDeals: 10,
      revenue: 'AED 61K',
      winRate: 28,
    ),
  ];

  @override
  List<ConversationEntity> get conversations => const [];
}

class _FakeLeadNotifier extends CrmLeadNotifier {
  @override
  List<CrmLeadEntity> build() => const [];
}

class _FakeAnalyticsNotifier extends LeadAnalyticsNotifier {
  @override
  LeadAnalyticsState build() => const LeadAnalyticsState();
}

class _FakeTaskNotifier extends CrmTaskNotifier {
  @override
  CrmTaskState build() => const CrmTaskState(tasks: []);
}

class _FakeTeamNotifier extends TeamNotifier {
  @override
  Future<List<TeamMemberEntity>> build() async => const [];
}
