// BEFORE capture for the supervisor floor board (phase 5).
//
// Pumps the CURRENT SupervisorDashboardTab with deterministic fakes and
// writes viewport PNGs into docs/ui-redesign/baseline/before-supervisor-home/
// for before/after review. Staff light-only (light en + ar @360x800).
// Frozen record: do NOT --update-goldens this file after the recomposition.
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/supervisor_dashboard_capture_test.dart   (generate)
//   flutter test --tags baseline test/supervisor_dashboard_capture_test.dart                    (compare)
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

const _outDir = 'before-supervisor-home';

// ---------------------------------------------------------------- fixtures
// Same deterministic floor as supervisor_dashboard_view_test.dart: 1 QC +
// 1 occupied job + 1 parts job + 1 booking = 4 active bays, 12 idle bays,
// 1 breakdown in the rail.

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
  Future<T> _value<T>(T value) async => value;

  @override
  Future<List<KpiResponse>> getKpis() => _value(const []);
  @override
  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() => _value(const []);
  @override
  Future<List<JobTypeResponse>> getJobTypes() => _value(const []);
  @override
  Future<List<RevenueMetricResponse>> getRevenueMetrics() => _value(const []);
  @override
  Future<List<PendingStatusResponse>> getPendingStatuses() => _value(const []);
  @override
  Future<List<String>> getDepartments() => _value(const []);
  @override
  Future<List<String>> getTechnicians() => _value(const []);
  @override
  Future<List<SupervisorAssignedJob>> getAssignedJobs() => _value(_jobs);
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() => _value(_bookings);
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() =>
      _value(_breakdowns);
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() =>
      _value(const []);
  @override
  Future<bool> assignBooking(int id, int advisorId) async => true;
  @override
  Future<bool> assignBreakdown(int id, int advisorId) async => true;
  @override
  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() =>
      _value(_awaiting);
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
      _value(const []);
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

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  Locale locale = const Locale('en'),
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3.0;
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
  addTearDown(
    () =>
        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supervisorRemoteDataSourceProvider.overrideWithValue(
            _FakeSupervisorRemote(),
          ),
          connectivityStatusProvider.overrideWith(
            (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
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
          home: Scaffold(
            body: SupervisorDashboardTab(
              onOpenAssign: () {},
              onOpenQueue: () {},
              onOpenReview: () {},
            ),
          ),
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
    debugPrint('supervisor before capture: fonts ready');
  });

  testWidgets('before floor light en 360x800', (tester) async {
    await _capture(tester, name: 'floor_1.0_en_360x800.png');
  });

  testWidgets('before floor light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: 'floor_1.0_ar_360x800.png',
      locale: const Locale('ar'),
    );
  });
}
