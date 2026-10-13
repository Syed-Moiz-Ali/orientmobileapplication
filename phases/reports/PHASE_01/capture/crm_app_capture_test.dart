import 'dart:io';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_dashboard_view.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_team_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// TEMPORARY Phase 01 evidence capture harness (CRM shell).
/// Run from `apps/crm_app`; PNGs land in `phases/reports/PHASE_01/screens/`.
void main() {
  setUpAll(_loadFonts);

  final cases = <String, _Case>{
    'crm_shell_390_light': _Case(const Size(390, 844), 1.0),
    'crm_shell_768_light': _Case(const Size(768, 1024), 1.0),
    'crm_shell_1280_light': _Case(const Size(1280, 800), 1.0),
    'crm_shell_320_light': _Case(const Size(320, 640), 1.0),
    'crm_shell_390_scale13': _Case(const Size(390, 844), 1.3),
    'crm_shell_390_dark': _Case(const Size(390, 844), 1.0, dark: true),
  };

  cases.forEach((name, c) {
    testWidgets('capture $name', (tester) async {
      tester.view.physicalSize = c.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crmUiProvider.overrideWith(_FakeCrmUiNotifier.new),
            crmLeadProvider.overrideWith(_FakeLeadNotifier.new),
            leadAnalyticsProvider.overrideWith(_FakeAnalyticsNotifier.new),
            crmTaskProvider.overrideWith(_FakeTaskNotifier.new),
            teamMembersProvider.overrideWith(_FakeTeamNotifier.new),
            connectivityStatusProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: c.dark
                ? AppTheme.dark(BrandConfig.orient)
                : AppTheme.light(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(c.scale)),
              child: child!,
            ),
            home: const CrmDashboardView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CrmDashboardView),
        matchesGoldenFile(
          '../../../phases/reports/PHASE_01/screens/$name.png',
        ),
      );
    });
  });
}

class _Case {
  final Size size;
  final double scale;
  final bool dark;
  const _Case(this.size, this.scale, {this.dark = false});
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
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
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
      trend: '12%',
      trendUp: true,
    ),
    CrmKpiEntity(
      label: 'Won',
      value: '42',
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xFF1A8754),
      bgColor: Color(0xFFECFDF5),
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
    CrmKeyMetric(
      label: 'Response rate',
      value: '92%',
      sub: 'All channels',
      up: true,
      color: Color(0xFF1A8754),
    ),
    CrmKeyMetric(
      label: 'Follow-ups',
      value: '18',
      sub: 'Due today',
      up: false,
      color: Color(0xFFB7791F),
    ),
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
