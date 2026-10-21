// SHELL-FIX recapture for the technician today shell (shell rebuild
// verification).
//
// Pumps the FULL TechnicianDashboardView shell (spec-C8 AppAppBar + pinned
// active-job banner + rail / bottom-nav frame) with deterministic fakes and
// writes viewport PNGs into docs/ui-redesign/baseline/after-shell-fix/ for
// shell-defect review. The inner-view captures (technician_home_after_*) do
// NOT include the shell chrome (header, banner, bottom nav), so this file
// exists to cover those focus regions.
//
// Matrix (4 PNGs):
//   data en 1.0 360x800 | data ar 1.0 360x800 | data en 1.3 360x800 |
//   data en 1.0 320x568.
//
// Determinism note: TechnicianStopwatch renders a live wall-clock HH:MM:SS
// for in-progress tasks, which would make goldens unstable across runs. The
// fixtures here keep every task pending/completed (no in-progress task), so
// no stopwatch renders anywhere (card or banner) and the frames are stable.
// Status pills (Delayed / Pending / completed) still render for the
// sentence-case check.
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/shell_fix_technician_capture_test.dart   (generate)
//   flutter test --tags baseline test/shell_fix_technician_capture_test.dart                    (compare)
// Default `melos run test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/technician_dashboard_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-shell-fix';

// ---------------------------------------------------------------- fixtures
// Same deterministic day as technician_home_after_capture_test.dart, except
// the running task is held at pending so no live stopwatch renders (see
// header note). Pills still covered: completed + pending + delayed.

const _job101 = TechnicianJobResponse(
  jobCardNo: 'JC-101',
  dateOfWork: '2026-10-21',
  startTime: '08:30',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Camry',
  plateNumber: 'ABC 1234',
  customerName: 'Ahmed',
  status: 'inProgress',
  tasks: [
    TaskResponse(
      id: 't1',
      description: 'Change engine oil',
      status: 'completed',
      startTime: '08:30',
      endTime: '08:50',
    ),
    TaskResponse(
      id: 't2',
      description: 'Replace brake pads',
      status: 'pending',
      startTime: '09:00',
    ),
    TaskResponse(id: 't3', description: 'Rotate tires', status: 'pending'),
  ],
);

const _delayedJob = TechnicianJobResponse(
  jobCardNo: 'JC-102',
  dateOfWork: '2026-10-21',
  startTime: '10:30',
  vehicleBrand: 'Nissan',
  vehicleModel: 'Yaris',
  plateNumber: 'XYZ 5678',
  customerName: 'Sara',
  status: 'delayed',
  tasks: [
    TaskResponse(id: 't4', description: 'Inspect brakes', status: 'pending'),
  ],
);

const _pendingJob = TechnicianJobResponse(
  jobCardNo: 'JC-103',
  dateOfWork: '2026-10-21',
  startTime: '11:15',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Hilux',
  plateNumber: 'DEF 9012',
  customerName: 'Khalid',
  status: 'pending',
  tasks: [
    TaskResponse(id: 't5', description: 'Change air filter', status: 'pending'),
    TaskResponse(id: 't6', description: 'Top up fluids', status: 'pending'),
  ],
);

class _TodayData {
  const _TodayData();

  final List<TechnicianJobResponse> jobs = const [
    _job101,
    _delayedJob,
    _pendingJob,
  ];
}

class _FakeTechnicianRemote implements TechnicianRemoteDataSource {
  _FakeTechnicianRemote(this.data);

  final _TodayData data;

  @override
  Future<TechnicianProfileResponse> getProfile(String empId) async =>
      const TechnicianProfileResponse(
        name: 'Omar Haddad',
        empId: 'EMP-007',
        role: 'Technician',
        branch: 'Deira',
        shift: 'Morning shift',
        avatarInitials: 'OH',
      );

  @override
  Future<List<TechnicianJobResponse>> getJobs(
    String empId, {
    String? status,
  }) async => data.jobs;

  @override
  Future<List<AssignedJobResponse>> getAssignedJobs(String empId) async =>
      const [];

  @override
  Future<AttendanceResponse> getAttendance(String empId, {String? date}) async =>
      const AttendanceResponse(
        status: 'working',
        punchIn: '08:00',
        punchOut: '',
        breakTime: '0 min',
        workHours: '1h 0m',
      );

  @override
  Future<ProductivityResponse> getProductivity(String empId) async =>
      const ProductivityResponse();

  @override
  Future<AttendanceResponse> punchIn(Map<String, dynamic> data) async =>
      const AttendanceResponse(status: 'working');

  @override
  Future<void> punchOut(Map<String, dynamic> data) async {}

  @override
  Future<void> breakStart(Map<String, dynamic> data) async {}

  @override
  Future<void> breakEnd(Map<String, dynamic> data) async {}

  @override
  Future<void> updateAssignedJobStatus(
    String id,
    String empId,
    String status,
  ) async {}

  @override
  Future<TechnicianJobResponse> searchJob(String q) async => data.jobs.first;

  @override
  Future<TaskActionResponse> startTask(
    String jobCardNo,
    String taskId,
    String startTime,
  ) async => TaskActionResponse(startTime: startTime);

  @override
  Future<void> completeTask(
    String jobCardNo,
    String taskId,
    String endTime,
  ) async {}

  @override
  Future<void> updateTaskStatus(
    String jobCardNo,
    String taskId,
    String status,
  ) async {}

  @override
  Future<void> completeJob(Map<String, dynamic> data) async {}

  @override
  Future<void> updateNotes(String jobCardNo, String notes) async {}

  @override
  Future<void> requestPart(Map<String, dynamic> data) async {}

  @override
  Future<void> escalateIssue(Map<String, dynamic> data) async {}
}

/// Calm attendance behind the profile tab: no network fetch (the default
/// notifier fires a real ApiClient call from build via microtask).
class _CalmStaffAttendanceNotifier extends StaffAttendanceNotifier {
  @override
  StaffAttendanceState build() => const StaffAttendanceState(isLoading: false);
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

/// Pumps the full technician shell with deterministic fakes, then
/// golden-captures the MaterialApp.
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
      technicianRemoteDataSourceProvider.overrideWithValue(
        _FakeTechnicianRemote(const _TodayData()),
      ),
      staffAttendanceProvider.overrideWith(_CalmStaffAttendanceNotifier.new),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
      ),
    ],
  );
  addTearDown(container.dispose);
  // Deterministic footer: fixed refresh instant, real async for the Hive beat.
  await tester.runAsync(() async {
    await Hive.box<dynamic>('technician_jobs').clear();
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
              child: TechnicianDashboardView(
                fixedRefreshAt: DateTime(2026, 10, 21, 9, 41),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      if (!container.read(technicianDashboardProvider).isLoading) break;
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
    final dir = await Directory.systemTemp.createTemp('tech_shell_fix');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
    debugPrint('technician shell-fix capture: fonts ready');
  });

  testWidgets('shell-fix tech today en 1.0 360x800', (tester) async {
    await _capture(tester, name: 'tech_today_en_1.0_360x800.png');
  });

  testWidgets('shell-fix tech today ar 1.0 360x800', (tester) async {
    await _capture(
      tester,
      name: 'tech_today_ar_1.0_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('shell-fix tech today en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: 'tech_today_en_1.3_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('shell-fix tech today en 1.0 320x568', (tester) async {
    await _capture(
      tester,
      name: 'tech_today_en_1.0_320x568.png',
      logicalSize: const Size(320, 568),
    );
  });
}
