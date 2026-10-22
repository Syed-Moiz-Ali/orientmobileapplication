// Supervisor shell nav (ui/integration-1): 4 primary tabs + More overflow.
//
// Behavior pins for the compact bottom bar migration (presentation-only):
// - Bar shows Floor/Jobs/Queue/Review + More; Reports/Staff/Schedule live
//   behind the More AppBottomSheet only.
// - Primary tabs switch in one tap; More rows are 48dp+ and navigate to the
//   same tab targets/routes when tapped.
// - No logic touched: providers, routes, tab content, badge state unchanged.
// - 320px / 1.3x / ar RTL pump with zero overflow (takeException null).
//
// Harness rules: real fonts via FontLoader, debugShowCheckedModeBanner false,
// shadows restored, runAsync + delays, connectivity mocks for BOTH
// checkConnectivity + check, ar locale + delegates + AppTheme.

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

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  @override
  Future<List<KpiResponse>> getKpis() async => const [];
  @override
  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() async => const [];
  @override
  Future<List<JobTypeResponse>> getJobTypes() async => const [];
  @override
  Future<List<RevenueMetricResponse>> getRevenueMetrics() async => const [];
  @override
  Future<List<PendingStatusResponse>> getPendingStatuses() async => const [];
  @override
  Future<List<String>> getDepartments() async => const [];
  @override
  Future<List<String>> getTechnicians() async => const [];
  @override
  Future<List<SupervisorAssignedJob>> getAssignedJobs() async => _jobs;
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() async => _bookings;
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() async => _breakdowns;
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() async =>
      const [];
  @override
  Future<bool> assignBooking(int id, int advisorId) async => true;
  @override
  Future<bool> assignBreakdown(int id, int advisorId) async => true;
  @override
  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() async =>
      _awaiting;
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
  Future<List<StaffNotificationResponse>> getStaffNotifications() async =>
      const [];
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

Future<ProviderContainer> _pumpShell(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double textScale = 1.0,
  ConnectivityResult connectivity = ConnectivityResult.wifi,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  // Restored synchronously at the end of this helper (plus tearDown
  // safety): flutter_test verifies painting debug vars are unset when the
  // test body returns, which runs before teardowns.
  addTearDown(() => debugDisableShadows = oldShadows);
  tester.view.physicalSize = Size(
    logicalSize.width * 3,
    logicalSize.height * 3,
  );
  tester.view.devicePixelRatio = 3.0;
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
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  final container = ProviderContainer(
    overrides: [
      supervisorRemoteDataSourceProvider.overrideWithValue(
        _FakeSupervisorRemote(),
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
  expect(tester.takeException(), isNull);
  debugDisableShadows = oldShadows;
  return container;
}

Future<void> _tapBar(WidgetTester tester, String label) async {
  final target = find.descendant(
    of: find.byType(AppBottomNav),
    matching: find.text(label),
  );
  expect(target, findsOneWidget);
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('supervisor scaffold nav: fonts ready');
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  testWidgets('bar shows four primaries plus More; overflow tabs hide',
      (tester) async {
    await _pumpShell(tester);

    // Primaries + More ride the compact bar.
    expect(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('Floor'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('Jobs'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('Queue'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('Review'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('More'),
      ),
      findsOneWidget,
    );
    // Overflow destinations are NOT on the bar and their tabs stay offstage.
    expect(find.text('Operations report'), findsNothing);
    expect(find.text('Workshop roster'), findsNothing);
    expect(find.text('Bay schedule'), findsNothing);
    // Home tab content is up.
    expect(find.text('B-01'), findsOneWidget);
  });

  testWidgets('primary tabs switch in one tap each', (tester) async {
    await _pumpShell(tester);

    await _tapBar(tester, 'Jobs');
    expect(find.text('Active jobs'), findsOneWidget);
    expect(find.text('B-01'), findsNothing);

    await _tapBar(tester, 'Queue');
    expect(find.text('Incoming queue'), findsOneWidget);
    expect(find.text('B-01'), findsNothing);

    await _tapBar(tester, 'Review');
    expect(find.text('Quality control'), findsOneWidget);
    expect(find.text('B-01'), findsNothing);

    await _tapBar(tester, 'Floor');
    expect(find.text('B-01'), findsOneWidget);
  });

  testWidgets('More sheet lists overflow rows at 48dp+ and navigates',
      (tester) async {
    await _pumpShell(tester);

    await _tapBar(tester, 'More');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppBottomSheet), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Staff'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);

    // Every More row meets the 48dp touch target (tokens-only sheet rows).
    for (final label in ['Reports', 'Staff', 'Schedule']) {
      final row = find.ancestor(
        of: find.text(label),
        matching: find.byType(InkWell),
      );
      expect(row, findsWidgets);
      expect(tester.getSize(row.first).height, greaterThanOrEqualTo(48));
    }

    // Same tab target/route when tapped: Reports tab content comes up,
    // sheet closes, bar stays mounted with More selected.
    await tester.tap(find.text('Reports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AppBottomSheet), findsNothing);
    expect(find.text('Operations report'), findsOneWidget);
    expect(find.text('B-01'), findsNothing);
    expect(tester.takeException(), isNull);

    // Staff + Schedule reachable the same way (each one extra tap via More).
    await _tapBar(tester, 'More');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Staff'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Workshop roster'), findsOneWidget);

    await _tapBar(tester, 'More');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Schedule'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Bay schedule'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ar RTL pumps clean with translated bar', (tester) async {
    await _pumpShell(tester, locale: const Locale('ar'));

    expect(
      find.descendant(
        of: find.byType(AppBottomNav),
        matching: find.text('المزيد'),
      ),
      findsOneWidget,
    );
    expect(find.text('B-01'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px pumps clean', (tester) async {
    await _pumpShell(tester, logicalSize: const Size(320, 568));

    expect(find.text('B-01'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1.3x text scale pumps clean', (tester) async {
    await _pumpShell(tester, textScale: 1.3);

    expect(find.text('B-01'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
