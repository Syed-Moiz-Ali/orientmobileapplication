// CURRENT-STATE capture for the supervisor home (phase-5 home + 4+More nav +
// single-affordance shell: the shell AppBar search trigger is the single
// search path on every tab (floor scope here, same sheet); the floor header
// glyph is removed.
//
// Pumps the FULL SupervisorScaffold (greeting header + AppAppBar shell bar +
// floor tab + 4-primary+More AppBottomNav frame) with deterministic fakes and
// writes viewport PNGs into
// docs/ui-redesign/baseline/after-supervisor-home-current/ for current-state
// review + contact sheets. Staff light-only.
//
// Matrix (11 PNGs):
//   with-data en 1.0 360x800 | ar 1.0 360x800 | en 1.3 360x800 |
//   en 1.0 320x568 | en tablet 768x1024 + 1180x820 |
//   empty en 360x800 | loading en 360x800 | error en 360x800 |
//   search sheet open en 360x800 | More sheet open en 360x800.
//
// Fixtures mirror supervisor_dashboard_after_capture_test.dart (1 QC +
// 1 occupied + 1 parts job + 1 booking = 4 active bays, 12 idle, 1 breakdown).
// Frames are wall-clock stable: the greeting date is day-precision and no
// ticking stopwatch renders in this tree.
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/supervisor_home_current_capture_test.dart   (generate)
//   flutter test --tags baseline test/supervisor_home_current_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/data/datasources/supervisor_remote_datasource.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_scaffold.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-supervisor-home-current';

// ---------------------------------------------------------------- fixtures
// Default deterministic floor (mirrors
// supervisor_dashboard_after_capture_test.dart): 1 QC + 1 occupied job +
// 1 parts job + 1 booking = 4 active bays, 12 idle bays, 1 breakdown.

const _jobs = [
  SupervisorAssignedJob(
    jobCard: 'JC-101',
    customer: 'Ahmed',
    vehicle: 'Camry ABC 1234',
    dateAssigned: '2026-10-20',
    done: 2,
    total: 5,
    status: 'In Progress',
  ),
  SupervisorAssignedJob(
    jobCard: 'JC-900',
    customer: 'Khalid',
    vehicle: 'Hilux XYZ 1111',
    dateAssigned: '2026-10-19',
    done: 1,
    total: 4,
    status: 'Waiting for Parts',
  ),
];

const _awaiting = [
  AwaitingCompletionResponse(
    jobCardId: 7,
    jobCardRef: 'JC-207',
    customerName: 'Layla',
    vehicleInfo: 'Yaris XYZ 5678',
    technician: 'Omar Haddad',
    done: 4,
    total: 4,
    updatedAt: '2026-10-20 14:00',
  ),
];

const _bookings = [
  BookingQueueResponse(
    id: 3,
    bookingRef: 'BK-301',
    customerName: 'Sara',
    vehicleName: 'Civic',
    plateNumber: 'DEF 9012',
    serviceType: 'Oil change',
    bookingDate: '2026-10-21 10:00',
  ),
];

const _breakdowns = [
  BreakdownQueueResponse(
    id: 5,
    customerName: 'Nasser',
    issue: 'Engine overheating',
    vehicleName: 'Patrol',
    vehiclePlate: 'GHI 3456',
    location: 'Highway 40 km 12',
  ),
];

class _FloorData {
  const _FloorData({
    this.jobs = _jobs,
    this.awaiting = _awaiting,
    this.bookings = _bookings,
    this.breakdowns = _breakdowns,
    this.fail = false,
    this.hang = false,
  });

  final List<SupervisorAssignedJob> jobs;
  final List<AwaitingCompletionResponse> awaiting;
  final List<BookingQueueResponse> bookings;
  final List<BreakdownQueueResponse> breakdowns;
  final bool fail;
  final bool hang;
}

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  _FakeSupervisorRemote(this.data);

  final _FloorData data;

  Future<T> _maybeHang<T>(T value) async {
    if (data.fail) throw Exception('offline');
    if (data.hang) await Completer<void>().future;
    return value;
  }

  @override
  Future<List<KpiResponse>> getKpis() => _maybeHang(const []);
  @override
  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() =>
      _maybeHang(const []);
  @override
  Future<List<JobTypeResponse>> getJobTypes() => _maybeHang(const []);
  @override
  Future<List<RevenueMetricResponse>> getRevenueMetrics() =>
      _maybeHang(const []);
  @override
  Future<List<PendingStatusResponse>> getPendingStatuses() =>
      _maybeHang(const []);
  @override
  Future<List<String>> getDepartments() => _maybeHang(const []);
  @override
  Future<List<String>> getTechnicians() => _maybeHang(const []);
  @override
  Future<List<SupervisorAssignedJob>> getAssignedJobs() =>
      _maybeHang(data.jobs);
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() =>
      _maybeHang(data.bookings);
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() =>
      _maybeHang(data.breakdowns);
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() =>
      _maybeHang(const []);
  @override
  Future<bool> assignBooking(int id, int advisorId) async => true;
  @override
  Future<bool> assignBreakdown(int id, int advisorId) async => true;
  @override
  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() =>
      _maybeHang(data.awaiting);
  @override
  Future<bool> approveCompletion(int jobCardId) async => true;
  @override
  Future<bool> rejectCompletion(int jobCardId, String reason) async => true;
  @override
  Future<bool> qcReview(
    String jobCardRef,
    String action, {
    bool checklistPassed = true,
    String notes = '',
    String rejectReason = '',
  }) async => true;
  @override
  Future<List<StaffNotificationResponse>> getStaffNotifications() =>
      _maybeHang(const []);
  @override
  Future<bool> markStaffNotificationRead(String id) async => true;
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

/// Pumps the full current supervisor shell with deterministic fakes, then
/// golden-captures the MaterialApp.
Future<void> _capture(
  WidgetTester tester, {
  required String name,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
  _FloorData data = const _FloorData(),
  ConnectivityResult connectivity = ConnectivityResult.wifi,
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
      return <String>[connectivity.name];
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
      supervisorRemoteDataSourceProvider.overrideWithValue(
        _FakeSupervisorRemote(data),
      ),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(connectivity),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
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
              child: const SupervisorScaffold(),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      if (!container.read(supervisorDashboardProvider).isDashboardLoading) {
        break;
      }
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

/// Search-open variant: same shell pump as [_capture], then taps the shell
/// AppBar search trigger (the single search path on the floor tab — the floor
/// header glyph is removed) and golden-captures with the floor search
/// sheet open.
Future<void> _captureSearchOpen(
  WidgetTester tester, {
  required String name,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
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
      return <String>[ConnectivityResult.wifi.name];
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
      supervisorRemoteDataSourceProvider.overrideWithValue(
        _FakeSupervisorRemote(const _FloorData()),
      ),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
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
              child: const SupervisorScaffold(),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      if (!container.read(supervisorDashboardProvider).isDashboardLoading) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  _drainExpected(tester, name);

  // Single search affordance on the floor tab: the shell AppBar owns the one
  // search glyph (floor scope); the floor header keeps title + subtitle only.
  final search = find.byIcon(Icons.search_rounded);
  expect(search, findsOneWidget);
  await tester.tap(search);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  _drainExpected(tester, '$name-sheet');
  expect(find.text('Find on the floor'), findsOneWidget);

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

/// More-open variant: same shell pump as [_capture], then taps the 5th
/// "More" slot to open the Reports/Staff/Schedule [AppBottomSheet] and
/// golden-captures with the sheet open. Verifies the 3 overflow rows are
/// present at 48dp+ before capturing.
Future<void> _captureMoreOpen(
  WidgetTester tester, {
  required String name,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
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
      return <String>[ConnectivityResult.wifi.name];
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
      supervisorRemoteDataSourceProvider.overrideWithValue(
        _FakeSupervisorRemote(const _FloorData()),
      ),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
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
              child: const SupervisorScaffold(),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      if (!container.read(supervisorDashboardProvider).isDashboardLoading) {
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  _drainExpected(tester, name);

  final moreTarget = find.descendant(
    of: find.byType(AppBottomNav),
    matching: find.text('More'),
  );
  expect(moreTarget, findsOneWidget);
  await tester.tap(moreTarget);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  _drainExpected(tester, '$name-sheet');
  expect(find.byType(AppBottomSheet), findsOneWidget);
  for (final label in ['Reports', 'Staff', 'Schedule']) {
    final row = find.ancestor(
      of: find.text(label),
      matching: find.byType(InkWell),
    );
    expect(row, findsWidgets, reason: 'More sheet row $label missing');
    expect(
      tester.getSize(row.first).height,
      greaterThanOrEqualTo(48),
      reason: 'More sheet row $label under 48dp',
    );
  }

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
      debugPrint('supervisor-current capture $name tolerates: ${current.message}');
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
    debugPrint('supervisor current-state capture: fonts ready');
  });

  testWidgets('current supervisor home en 1.0 360x800', (tester) async {
    await _capture(tester, name: 'sv_home_en_1.0_360x800.png');
  });

  testWidgets('current supervisor home ar 1.0 360x800', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_ar_1.0_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('current supervisor home en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_en_1.3_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('current supervisor home en 1.0 320x568', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_en_1.0_320x568.png',
      logicalSize: const Size(320, 568),
      pixelRatio: 2.0,
    );
  });

  testWidgets('current supervisor home en tablet 768x1024', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_en_1.0_768x1024.png',
      logicalSize: const Size(768, 1024),
      pixelRatio: 2.0,
    );
  });

  testWidgets('current supervisor home en tablet 1180x820', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_en_1.0_1180x820.png',
      logicalSize: const Size(1180, 820),
      pixelRatio: 2.0,
    );
  });

  testWidgets('current supervisor home empty en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_empty_en_360x800.png',
      data: const _FloorData(
        jobs: [],
        awaiting: [],
        bookings: [],
        breakdowns: [],
      ),
    );
  });

  testWidgets('current supervisor home loading en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_loading_en_360x800.png',
      data: const _FloorData(hang: true),
    );
  });

  testWidgets('current supervisor home error en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'sv_home_error_en_360x800.png',
      data: const _FloorData(fail: true),
    );
  });

  testWidgets('current supervisor home search open en 360x800', (tester) async {
    await _captureSearchOpen(
      tester,
      name: 'sv_home_search_open_en_360x800.png',
    );
  });

  testWidgets('current supervisor home More open en 360x800', (tester) async {
    await _captureMoreOpen(
      tester,
      name: 'sv_home_more_open_en_360x800.png',
    );
  });
}
