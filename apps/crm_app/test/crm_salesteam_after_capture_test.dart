// AFTER captures for the recomposed CRM sales team list.
//
// Same matrix as the BEFORE captures. View every PNG against the
// C16/C17 checklists in the brief before blessing anything.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _outDir = 'after-crm-salesteam';

SalesTeamMember _member(String name, int leads, int won) => SalesTeamMember(
  name: name,
  role: 'Closer',
  leadsHandled: leads,
  wonDeals: won,
  revenue: 'AED 12000',
  winRate: won / leads,
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

String _fontRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final candidate =
        '${dir.path}${Platform.pathSeparator}packages${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory(candidate).existsSync()) return candidate;
    dir = dir.parent;
  }
  throw StateError('shared_core font root not found from ${Directory.current.path}');
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
    }
    await loader.load();
  }

  final root = _fontRoot();
  await load('packages/shared_core/Plus Jakarta Sans', [
    '$root/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
  ]);

  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File('${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf');
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(candidate.readAsBytesSync())));
      await loader.load();
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required List<SalesTeamMember> team,
  bool dark = false,
  Locale locale = const Locale('en'),
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [crmRepositoryProvider.overrideWithValue(_FakeCrmRepo(team))],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            CrmLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          darkTheme: AppTheme.dark(BrandConfig.orient, locale: locale),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const Scaffold(body: CrmSalesTeamPage()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

void main() {
  setUpAll(() async {
    await _loadFonts();
  });

  testWidgets('idle light en', (tester) async {
    await _capture(tester, name: 'team_idle_light_1.0_en_360x800.png',
      team: [_member('Sara', 4, 3), _member('John', 2, 1), _member('Mia', 6, 2)]);
  });
  testWidgets('empty light en', (tester) async {
    await _capture(tester, name: 'team_empty_light_1.0_en_360x800.png', team: const []);
  });
  testWidgets('idle dark en', (tester) async {
    await _capture(tester, name: 'team_idle_dark_1.0_en_360x800.png',
      team: [_member('Sara', 4, 3), _member('John', 2, 1)], dark: true);
  });
  testWidgets('idle light ar', (tester) async {
    await _capture(tester, name: 'team_idle_light_1.0_ar_360x800.png',
      team: [_member('Sara', 4, 3), _member('John', 2, 1)], locale: const Locale('ar'));
  });
}
