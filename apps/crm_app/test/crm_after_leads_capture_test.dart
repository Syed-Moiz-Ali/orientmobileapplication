// AFTER captures for the recomposed CRM leads list.
//
// Matrix: idle with-data (2 + 6 for the >5 find-aids threshold), empty-sync,
// empty-nocrm, search-sheet open, filter-sheet open, ar, 1.3x, 320px, tablet.
// View every PNG against the brief before blessing anything.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _outDir = 'after-crm-leads';

// ---------------------------------------------------------------- fixtures

CrmLeadEntity _lead(int i) => CrmLeadEntity(
  id: 'l$i',
  sno: i,
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

IntegrationEntity _integration({required bool connected}) => IntegrationEntity(
  name: 'Meta',
  icon: Icons.hub_outlined,
  color: Colors.blue,
  connected: connected,
);

// ---------------------------------------------------------------- harness

void _mockConnectivity() {
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (MethodCall call) async {
      if (call.method == 'checkConnectivity' || call.method == 'check') {
        return <String>['wifi'];
      }
      return null;
    },
  );
  binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(
      onListen: (Object? args, MockStreamHandlerEventSink events) {},
    ),
  );
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
  required _FakeCrmRepo repo,
  bool dark = false,
  double scale = 1.0,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double dpr = 3.0,
  Future<void> Function()? interact,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = Size(logicalSize.width * dpr, logicalSize.height * dpr);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [crmRepositoryProvider.overrideWithValue(repo)],
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
          builder: (context, c) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
            child: c!,
          ),
          home: const Scaffold(body: CrmLeadsPage()),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  if (interact != null) await interact();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

// ---------------------------------------------------------------- tests

void main() {
  setUpAll(() async {
    _mockConnectivity();
    await _loadFonts();
    debugPrint('after-crm-leads capture: fonts + connectivity ready');
  });

  _FakeCrmRepo leadsRepo({required List<CrmLeadEntity> leads, bool connected = true}) =>
      _FakeCrmRepo(leads: leads, integrations: [_integration(connected: connected)]);

  testWidgets('idle 2 light en', (tester) async {
    await _capture(
      tester,
      name: 'leads_idle-2_light_1.0_en_360x800.png',
      repo: leadsRepo(leads: [_lead(0), _lead(1)]),
    );
  });

  testWidgets('idle 6 light en (find-aids visible)', (tester) async {
    await _capture(
      tester,
      name: 'leads_idle-6_light_1.0_en_360x800.png',
      repo: leadsRepo(leads: [for (var i = 0; i < 6; i++) _lead(i)]),
    );
  });

  testWidgets('empty-sync light en', (tester) async {
    await _capture(
      tester,
      name: 'leads_empty-sync_light_1.0_en_360x800.png',
      repo: leadsRepo(leads: const []),
    );
  });

  testWidgets('empty-nocrm light en', (tester) async {
    await _capture(
      tester,
      name: 'leads_empty-nocrm_light_1.0_en_360x800.png',
      repo: leadsRepo(leads: const [], connected: false),
    );
  });

  testWidgets('search sheet open light en', (tester) async {
    await _capture(
      tester,
      name: 'leads_search-open_light_1.0_en_360x800.png',
      repo: leadsRepo(leads: [for (var i = 0; i < 6; i++) _lead(i)]),
      interact: () async {
        await tester.tap(find.byTooltip('Search leads'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      },
    );
  });

  testWidgets('filter sheet open light en', (tester) async {
    await _capture(
      tester,
      name: 'leads_filter-open_light_1.0_en_360x800.png',
      repo: leadsRepo(leads: [for (var i = 0; i < 6; i++) _lead(i)]),
      interact: () async {
        await tester.tap(find.byTooltip('Filter leads'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      },
    );
  });

  testWidgets('idle 2 light ar', (tester) async {
    await _capture(
      tester,
      name: 'leads_idle-2_light_1.0_ar_360x800.png',
      repo: leadsRepo(leads: [_lead(0), _lead(1)]),
      locale: const Locale('ar'),
    );
  });

  testWidgets('idle 2 light en 1.3x', (tester) async {
    await _capture(
      tester,
      name: 'leads_idle-2_light_1.3_en_360x800.png',
      repo: leadsRepo(leads: [_lead(0), _lead(1)]),
      scale: 1.3,
    );
  });

  testWidgets('idle 2 light en 320px', (tester) async {
    await _capture(
      tester,
      name: 'leads_idle-2_light_1.0_en_320x568.png',
      repo: leadsRepo(leads: [_lead(0), _lead(1)]),
      logicalSize: const Size(320, 568),
      dpr: 2.0,
    );
  });

  testWidgets('idle 6 light en tablet', (tester) async {
    await _capture(
      tester,
      name: 'leads_idle-6_light_1.0_en_768x1024.png',
      repo: leadsRepo(leads: [for (var i = 0; i < 6; i++) _lead(i)]),
      logicalSize: const Size(768, 1024),
      dpr: 2.0,
    );
  });
}
