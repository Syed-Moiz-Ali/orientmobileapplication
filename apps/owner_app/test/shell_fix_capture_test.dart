// SHELL-FIX recapture for the owner home (shell rebuild verification).
//
// Pumps the REBUILT DashboardBody shell (spec-C8 AppAppBar + AppBottomNav +
// offline-only OfflineBanner, sentence-case overlines) with deterministic
// fakes and writes viewport PNGs into
// docs/ui-redesign/baseline/after-shell-fix/ for shell-defect review.
//
// Matrix (4 PNGs):
//   data en 1.0 360x800 | data ar 1.0 360x800 | data en 1.3 360x800 |
//   data en 1.0 320x568.
//
// Fixtures mirror owner_home_after_capture_test.dart (token figures only).
// The stopwatch/live-clock risk does not apply here: the activity feed is
// faked empty, so frames are wall-clock stable.
//
// Run (from apps/owner_app):
//   flutter test --tags baseline --update-goldens test/shell_fix_capture_test.dart   (generate)
//   flutter test --tags baseline test/shell_fix_capture_test.dart                    (compare)
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
import 'package:owner_app/l10n/gen/owner_localizations.dart';

const _outDir = 'after-shell-fix';

// ---------------------------------------------------------------- fixtures
// Same deterministic home as owner_home_after_capture_test.dart: token
// figures only (Revenue AED 84K, Margin, Bay occupancy, approvals WIP,
// trends, 2-row register).

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

class _FakeOwnerRemote implements OwnerRemoteDataSource {
  Future<T> _gate<T>(T value) async => value;

  @override
  Future<List<KpiCardResponse>> getKpis() => _gate(_kpis);

  @override
  Future<List<TrendPointResponse>> getSalesTrend() => _gate(_sales);

  @override
  Future<List<TrendPointResponse>> getProfitTrend() => _gate(_profit);

  @override
  Future<List<TrendPointResponse>> getExpensesTrend() => _gate(_expenses);

  @override
  Future<List<JobCardRegisterResponse>> getJobCardRegister() =>
      _gate(_register);

  @override
  Future<List<TopSalesCategoryResponse>> getTopSales() =>
      _gate(const <TopSalesCategoryResponse>[]);

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
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
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
        DashboardUIRemoteAdapter(_FakeOwnerRemote()),
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

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

/// Drains the exception queue, tolerating ONLY RenderFlex overflows.
///
/// Overflow kept here is redesign evidence (striped in the PNG) and is
/// reported, not fixed, by the capture agent. Anything else rethrows.
void _drainExpected(WidgetTester tester, String name) {
  Object? error;
  while ((error = tester.takeException()) != null) {
    final current = error;
    if (current is FlutterError && current.message.contains('overflowed')) {
      debugPrint('shell-fix capture $name tolerates: ${current.message}');
      debugPrint(current.toString());
      continue;
    }
    throw TestFailure('unexpected exception in $name: $current');
  }
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  setUpAll(() async {
    await _loadFonts();
    final dir = await Directory.systemTemp.createTemp('owner_shell_fix');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('owner_messages');
    debugPrint('owner shell-fix capture: fonts ready');
  });

  testWidgets('shell-fix owner home en 1.0 360x800', (tester) async {
    await _capture(tester, name: 'owner_home_en_1.0_360x800.png');
  });

  testWidgets('shell-fix owner home ar 1.0 360x800', (tester) async {
    await _capture(
      tester,
      name: 'owner_home_ar_1.0_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('shell-fix owner home en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: 'owner_home_en_1.3_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('shell-fix owner home en 1.0 320x568', (tester) async {
    await _capture(
      tester,
      name: 'owner_home_en_1.0_320x568.png',
      logicalSize: const Size(320, 568),
    );
  });
}
