// AFTER capture for the supervisor floor board (phase 5 recomposition).
//
// Pumps the REBUILT SupervisorDashboardTab (App* pattern widgets) with
// deterministic fakes and writes viewport PNGs into
// docs/ui-redesign/baseline/after-phase-5-supervisor/ for before/after
// review + contact sheets. Staff light-only.
//
// Matrix (17 PNGs):
//   idle en/ar x1.0/1.3 @360x800 (4) | idle en 320x568 (1) |
//   idle en tablet 768x1024 + 1180x820 (2) |
//   hero busy / empty / all-idle (3) |
//   filter parts applied + QC no-match (2) |
//   search sheet open + with query (2) |
//   loading skeleton (1) | error+retry (1) | offline banner + stale board (1).
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/supervisor_dashboard_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/supervisor_dashboard_after_capture_test.dart                    (compare)
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
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-phase-5-supervisor';

// ---------------------------------------------------------------- fixtures
// Default deterministic floor (mirrors supervisor_dashboard_view_test.dart):
// 1 QC + 1 occupied job + 1 parts job + 1 booking = 4 active bays,
// 12 idle bays, 1 breakdown in the rail.

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

// Busy floor: 4 awaiting (QC) + 8 jobs (4 occupied + 4 parts) + 4 bookings
// = 16 active bays, 0 idle.
const _busyAwaiting = [
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
  AwaitingCompletionResponse(
    jobCardId: 8,
    jobCardRef: 'JC-208',
    customerName: 'Maha',
    vehicleInfo: 'Corolla JKL 2222',
    technician: 'Ali Hassan',
    done: 3,
    total: 3,
    updatedAt: '2026-10-20 15:00',
  ),
  AwaitingCompletionResponse(
    jobCardId: 9,
    jobCardRef: 'JC-209',
    customerName: 'Omar',
    vehicleInfo: 'Altima MNO 3333',
    technician: 'Sara Ali',
    done: 5,
    total: 5,
    updatedAt: '2026-10-20 15:30',
  ),
  AwaitingCompletionResponse(
    jobCardId: 10,
    jobCardRef: 'JC-210',
    customerName: 'Huda',
    vehicleInfo: 'Sunny PQR 4444',
    technician: 'Khalid Omar',
    done: 2,
    total: 2,
    updatedAt: '2026-10-20 16:00',
  ),
];

const _busyJobs = [
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
    jobCard: 'JC-102',
    customer: 'Faisal',
    vehicle: 'Accord BCD 2345',
    dateAssigned: '2026-10-20',
    done: 1,
    total: 6,
    status: 'In Progress',
  ),
  SupervisorAssignedJob(
    jobCard: 'JC-103',
    customer: 'Nora',
    vehicle: 'Elantra CDE 3456',
    dateAssigned: '2026-10-20',
    done: 3,
    total: 4,
    status: 'Assigned',
  ),
  SupervisorAssignedJob(
    jobCard: 'JC-104',
    customer: 'Tariq',
    vehicle: 'Cerato DEF 4567',
    dateAssigned: '2026-10-19',
    done: 0,
    total: 3,
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
  SupervisorAssignedJob(
    jobCard: 'JC-901',
    customer: 'Salem',
    vehicle: 'Navara EFG 5678',
    dateAssigned: '2026-10-19',
    done: 2,
    total: 5,
    status: 'Waiting for Parts',
  ),
  SupervisorAssignedJob(
    jobCard: 'JC-902',
    customer: 'Rania',
    vehicle: 'Tucson FGH 6789',
    dateAssigned: '2026-10-18',
    done: 0,
    total: 2,
    status: 'On Hold - Approval',
  ),
  SupervisorAssignedJob(
    jobCard: 'JC-903',
    customer: 'Adel',
    vehicle: 'Sportage GHI 7890',
    dateAssigned: '2026-10-18',
    done: 1,
    total: 3,
    status: 'Waiting for Parts',
  ),
];

const _busyBookings = [
  BookingQueueResponse(
    id: 3,
    bookingRef: 'BK-301',
    customerName: 'Sara',
    vehicleName: 'Civic',
    plateNumber: 'DEF 9012',
    serviceType: 'Oil change',
    bookingDate: '2026-10-21 10:00',
  ),
  BookingQueueResponse(
    id: 4,
    bookingRef: 'BK-302',
    customerName: 'Lina',
    vehicleName: 'Sentra',
    plateNumber: 'HIJ 3456',
    serviceType: 'Brake pads',
    bookingDate: '2026-10-21 11:00',
  ),
  BookingQueueResponse(
    id: 5,
    bookingRef: 'BK-303',
    customerName: 'Majed',
    vehicleName: 'Kicks',
    plateNumber: 'KLM 7890',
    serviceType: 'AC service',
    bookingDate: '2026-10-21 12:00',
  ),
  BookingQueueResponse(
    id: 6,
    bookingRef: 'BK-304',
    customerName: 'Reem',
    vehicleName: 'Versa',
    plateNumber: 'NOP 1234',
    serviceType: 'Inspection',
    bookingDate: '2026-10-21 13:00',
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

/// Pumps the rebuilt floor board with deterministic fakes, runs the optional
/// [interact] step (filter tap / search sheet), then golden-captures the full
/// MaterialApp (sheet overlays included).
Future<void> _capture(
  WidgetTester tester, {
  required String name,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
  _FloorData data = const _FloorData(),
  ConnectivityResult connectivity = ConnectivityResult.wifi,
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
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
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supervisorRemoteDataSourceProvider.overrideWithValue(
            _FakeSupervisorRemote(data),
          ),
          connectivityStatusProvider.overrideWith(
            (ref) => Stream<ConnectivityResult>.value(connectivity),
          ),
        ],
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
              child: Scaffold(
                body: SupervisorDashboardTab(
                  onOpenAssign: () {},
                  onOpenQueue: () {},
                  onOpenReview: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);

  if (interact != null) {
    await interact(tester);
    expect(tester.takeException(), isNull);
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

Future<void> _tapFilter(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(AppFilterBar),
    matching: find.text(label),
  );
  expect(chip, findsOneWidget);
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _openSearch(WidgetTester tester) async {
  final search = find.byIcon(Icons.search_rounded);
  expect(search, findsOneWidget);
  await tester.tap(search);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('supervisor after capture: fonts ready');
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  // ---- idle matrix (light-only) ----

  testWidgets('after idle en 1.0 360x800', (tester) async {
    await _capture(tester, name: 'floor_1.0_en_360x800.png');
  });

  testWidgets('after idle en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.3_en_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('after idle ar 1.0 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.0_ar_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('after idle ar 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.3_ar_360x800.png',
      locale: const Locale('ar'),
      textScale: 1.3,
    );
  });

  testWidgets('after idle en 320x568', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.0_en_320x568.png',
      logicalSize: const Size(320, 568),
      pixelRatio: 2.0,
    );
  });

  testWidgets('after idle en tablet 768x1024', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.0_en_768x1024.png',
      logicalSize: const Size(768, 1024),
      pixelRatio: 2.0,
    );
  });

  testWidgets('after idle en tablet 1180x820', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.0_en_1180x820.png',
      logicalSize: const Size(1180, 820),
      pixelRatio: 2.0,
    );
  });

  // ---- hero variants ----

  testWidgets('after hero busy en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_hero_busy_en_360x800.png',
      data: const _FloorData(
        jobs: _busyJobs,
        awaiting: _busyAwaiting,
        bookings: _busyBookings,
      ),
    );
  });

  testWidgets('after hero empty en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_hero_empty_en_360x800.png',
      data: const _FloorData(
        jobs: [],
        awaiting: [],
        bookings: [],
        breakdowns: [],
      ),
    );
  });

  testWidgets('after hero all-idle en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_hero_allidle_en_360x800.png',
      interact: (t) => _tapFilter(t, 'Idle'),
    );
  });

  // ---- filter states ----

  testWidgets('after filter parts en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_filter_parts_en_360x800.png',
      interact: (t) => _tapFilter(t, 'Parts delay'),
    );
  });

  testWidgets('after filter no-match en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_filter_nomatch_en_360x800.png',
      data: const _FloorData(awaiting: [], breakdowns: []),
      interact: (t) => _tapFilter(t, 'QC'),
    );
  });

  // ---- search sheet ----

  testWidgets('after search open en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_search_open_en_360x800.png',
      interact: _openSearch,
    );
  });

  testWidgets('after search query en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_search_query_en_360x800.png',
      interact: (t) async {
        await _openSearch(t);
        await t.enterText(find.byType(TextField), 'JC-101');
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
      },
    );
  });

  // ---- loading / error / offline ----

  testWidgets('after loading en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_loading_en_360x800.png',
      data: const _FloorData(hang: true),
    );
  });

  testWidgets('after error en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_error_en_360x800.png',
      data: const _FloorData(fail: true),
    );
  });

  testWidgets('after offline en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_offline_en_360x800.png',
      connectivity: ConnectivityResult.none,
    );
  });
}
