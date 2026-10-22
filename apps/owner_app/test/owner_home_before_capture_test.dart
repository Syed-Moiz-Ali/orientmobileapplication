// BEFORE capture for the owner home / executive cockpit (phase 7).
//
// Pumps the CURRENT DashboardBody (shell + OwnerDashboardPage) with
// deterministic fakes and writes viewport PNGs into
// docs/ui-redesign/baseline/before-owner-home/ for before/after review.
// Owner light-only (en + ar 360x800, empty, search-open, 1.3x, 320x568,
// tablet medium + expanded). Frozen record: do NOT --update-goldens this
// file after the recomposition.
//
// Run (from apps/owner_app):
//   flutter test --tags baseline --update-goldens test/owner_home_before_capture_test.dart   (generate)
//   flutter test --tags baseline test/owner_home_before_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart' hide AsyncData;
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_adapters.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/dashboard_body.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

const _outDir = 'before-owner-home';

// ---------------------------------------------------------------- fixtures
// Same deterministic home as owner_dashboard_characterization_test.dart.

const _kpis = <KpiCardResponse>[
  KpiCardResponse(label: 'Revenue', value: 'AED 84K', sub: '+2.1% Ahead'),
  KpiCardResponse(label: 'Margin', value: '18.4%', sub: '+1.2% vs last week'),
  KpiCardResponse(
    label: 'Bay occupancy',
    value: '12/16',
    sub: '4 bays free',
  ),
  KpiCardResponse(
    label: 'Pending approvals',
    value: '3',
    sub: '2 need decisions',
  ),
  KpiCardResponse(label: 'Open jobs', value: '12', sub: '12 active'),
  KpiCardResponse(label: 'New today', value: '5', sub: '5 booked'),
];

const _sales = <TrendPointResponse>[
  TrendPointResponse(month: 'Jan', value: 10),
  TrendPointResponse(month: 'Feb', value: 20),
  TrendPointResponse(month: 'Mar', value: 30),
];

const _profit = <TrendPointResponse>[
  TrendPointResponse(month: 'Jan', value: 5),
  TrendPointResponse(month: 'Feb', value: 8),
  TrendPointResponse(month: 'Mar', value: 12),
];

const _expenses = <TrendPointResponse>[
  TrendPointResponse(month: 'Jan', value: 3),
  TrendPointResponse(month: 'Feb', value: 4),
  TrendPointResponse(month: 'Mar', value: 6),
];

const _register = <JobCardRegisterResponse>[
  JobCardRegisterResponse(label: 'Engine repair', open: 3, completed: 5, total: 8),
  JobCardRegisterResponse(label: 'AC service', open: 0, completed: 4, total: 4),
];

class _HomeData {
  const _HomeData({this.empty = false});

  final bool empty;
}

class _FakeOwnerRemote implements OwnerRemoteDataSource {
  _FakeOwnerRemote(this.data);

  final _HomeData data;

  @override
  Future<List<KpiCardResponse>> getKpis() async =>
      data.empty ? const <KpiCardResponse>[] : _kpis;

  @override
  Future<List<TrendPointResponse>> getSalesTrend() async =>
      data.empty ? const <TrendPointResponse>[] : _sales;

  @override
  Future<List<TrendPointResponse>> getProfitTrend() async =>
      data.empty ? const <TrendPointResponse>[] : _profit;

  @override
  Future<List<TrendPointResponse>> getExpensesTrend() async =>
      data.empty ? const <TrendPointResponse>[] : _expenses;

  @override
  Future<List<JobCardRegisterResponse>> getJobCardRegister() async =>
      data.empty ? const <JobCardRegisterResponse>[] : _register;

  @override
  Future<List<TopSalesCategoryResponse>> getTopSales() async =>
      const <TopSalesCategoryResponse>[];

  @override
  Future<List<DocumentExpiryResponse>> getDocumentExpiry() =>
      throw UnimplementedError();

  @override
  Future<List<JobStatusResponse>> getJobsByStatus(String stage) =>
      throw UnimplementedError();

  @override
  Future<List<ApprovalCategoryResponse>> getApprovalCategories() =>
      throw UnimplementedError();

  @override
  Future<List<PendingJobResponse>> getPendingJobs() =>
      throw UnimplementedError();

  @override
  Future<List<OwnerJobCardResponse>> getActiveJobs() =>
      throw UnimplementedError();

  @override
  Future<List<InvoiceResponse>> getInvoices(String? status) =>
      throw UnimplementedError();

  @override
  Future<ArSummaryResponse> getArSummary() => throw UnimplementedError();

  @override
  Future<List<ArRecordResponse>> getArRecords() => throw UnimplementedError();

  @override
  Future<List<MessageResponse>> getMessages() =>
      throw UnimplementedError();

  @override
  Future<MessageResponse> sendMessage(String recipient, String message) =>
      throw UnimplementedError();

  @override
  Future<List<ActivityResponse>> getActivity(int page, int limit) =>
      throw UnimplementedError();

  @override
  Future<List<OwnerJobCardResponse>> getOwnerJobCards() =>
      throw UnimplementedError();

  @override
  Future<bool> updateJobCardStatus(String id, String status) =>
      throw UnimplementedError();
}

/// Quiet team under the shell pump: no network, no fetch.
class _CalmTeamNotifier extends TeamNotifier {
  @override
  TeamState build() => const TeamState(isLoading: false);
}

// ---------------------------------------------------------------- harness

String _fontRoot() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final candidate =
        '${dir.path}${Platform.pathSeparator}packages${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets${Platform.pathSeparator}fonts';
    if (Directory(candidate).existsSync()) return candidate;
    dir = dir.parent;
  }
  throw StateError(
    'shared_core font root not found from ${Directory.current.path}',
  );
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
      );
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
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(ByteData.sublistView(candidate.readAsBytesSync())),
        );
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
  _HomeData data = const _HomeData(),
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  // Restored even when the capture body throws, otherwise the framework
  // painting-vars invariant fails every later test in the file.
  addTearDown(() => debugDisableShadows = oldShadows);
  tester.view.physicalSize = Size(
    logicalSize.width * pixelRatio,
    logicalSize.height * pixelRatio,
  );
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
    MethodCall call,
  ) async {
    if (call.method == 'checkConnectivity' || call.method == 'check') {
      return <String>['wifi'];
    }
    return null;
  });
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall call) async => null,
  );
  binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(
      onListen: (Object? args, MockStreamHandlerEventSink events) {},
    ),
  );
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  final container = ProviderContainer(
    overrides: [
      dashboardDataSourceProvider.overrideWithValue(
        DashboardUIRemoteAdapter(_FakeOwnerRemote(data)),
      ),
      teamProvider.overrideWith(_CalmTeamNotifier.new),
      ownerActivityFeedProvider.overrideWith(
        (ref) async => const <Map<String, dynamic>>[],
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await Hive.box<dynamic>('owner_messages').clear();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            OwnerLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: const DashboardBody(),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      if (!container.read(dashboardUiProvider).isLoading) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  _drainExpected(tester, name);

  if (interact != null) {
    await interact(tester);
    _drainExpected(tester, name);
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

/// Drains the exception queue, tolerating ONLY RenderFlex overflows.
///
/// The current home overflows horizontally on narrow/dense stills
/// (320x568, 1.3x) — that overflow is the redesign's evidence, so before
/// frames keep it (striped) instead of failing. Anything else rethrows.
void _drainExpected(WidgetTester tester, String name) {
  Object? error;
  while ((error = tester.takeException()) != null) {
    final current = error;
    if (current is FlutterError && current.message.contains('overflowed')) {
      debugPrint('before capture $name tolerates: ${current.message}');
      continue;
    }
    throw TestFailure('unexpected exception in $name: $current');
  }
}

/// Opens the palette via the home header search action (U1) — scoped to
/// OwnerDashboardPage so the finder names the single remaining affordance
/// (search-affordance audit, ui/integration-1: the shell bar trigger is
/// hidden on the dashboard tab; same palette, same route).
Future<void> _openSearch(WidgetTester tester) async {
  final search = find.descendant(
    of: find.byType(OwnerDashboardPage),
    matching: find.byIcon(Icons.search_rounded),
  );
  expect(search, findsOneWidget);
  await tester.tap(search);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  setUpAll(() async {
    await _loadFonts();
    final dir = await Directory.systemTemp.createTemp('owner_home_before');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('owner_messages');
    debugPrint('owner home before capture: fonts ready');
  });

  testWidgets('before home light en 360x800', (tester) async {
    await _capture(tester, name: 'home_1.0_en_360x800.png');
  });

  testWidgets('before home empty en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'home_empty_en_360x800.png',
      data: const _HomeData(empty: true),
    );
  });

  testWidgets('before home search-open en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'home_search_open_en_360x800.png',
      interact: _openSearch,
    );
  });

  testWidgets('before home light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: 'home_1.0_ar_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('before home 1.3x en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'home_1.3_en_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('before home light en 320x568', (tester) async {
    await _capture(
      tester,
      name: 'home_1.0_en_320x568.png',
      logicalSize: const Size(320, 568),
    );
  });

  testWidgets('before home light en 768x1024', (tester) async {
    await _capture(
      tester,
      name: 'home_1.0_en_768x1024.png',
      logicalSize: const Size(768, 1024),
    );
  });

  testWidgets('before home light en 1280x800', (tester) async {
    await _capture(
      tester,
      name: 'home_1.0_en_1280x800.png',
      logicalSize: const Size(1280, 800),
    );
  });
}
