// AFTER capture for the technician job detail view (DETAIL family, C16
// recomposition onto App* pattern widgets).
//
// Pumps the CURRENT (recomposed) TechnicianJobDetailView with deterministic
// fakes and writes viewport PNGs into docs/ui-redesign/baseline/after-technician-job-detail/
// for before/after review. Staff light-only (en + ar 360x800, empty/locked/
// delayed/running/done/loading/error/sheet 360x800, 320x568 data, 1.3x data,
// tablet data).
//
// Determinism note (shell-fix precedent): the live TechnicianStopwatch ticks a
// wall-clock HH:MM:SS for in-progress tasks. Idle/empty/locked/delayed/done/
// sheet fixtures keep tasks pending/completed — no running task, no ticking
// stopwatch. The running (JC-107) frame renders the live stopwatch and can
// never be byte-stable across runs; the running-focus copy is pinned by the
// characterization tests instead.
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/technician_job_detail_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/technician_job_detail_after_capture_test.dart                    (compare)
// Default `flutter test` excludes this tag.
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
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-technician-job-detail';

// ---------------------------------------------------------------- fixtures
// No in-progress task anywhere (see header note): the idle job shows the
// Start-next-task focus with static start/end times only.

const _idleJob = TechnicianJobResponse(
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
      id: '1',
      description: 'Change engine oil',
      status: 'completed',
      startTime: '08:30',
      endTime: '08:50',
    ),
    TaskResponse(
      id: '2',
      description: 'Replace brake pads',
      status: 'pending',
    ),
    TaskResponse(id: '3', description: 'Rotate tires', status: 'pending'),
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
    TaskResponse(id: '4', description: 'Inspect brakes', status: 'pending'),
  ],
);

const _lockedJob = TechnicianJobResponse(
  jobCardNo: 'JC-105',
  dateOfWork: '2026-10-20',
  startTime: '08:00',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Corolla',
  plateNumber: 'JKL 7890',
  customerName: 'Omar',
  status: 'qualitycheck',
  tasks: [
    TaskResponse(
      id: '5',
      description: 'Change engine oil',
      status: 'completed',
      startTime: '08:00',
      endTime: '08:30',
    ),
  ],
);

const _emptyJob = TechnicianJobResponse(
  jobCardNo: 'JC-106',
  dateOfWork: '2026-10-21',
  startTime: '12:00',
  vehicleBrand: 'Honda',
  vehicleModel: 'Civic',
  plateNumber: 'MNO 1122',
  customerName: 'Lina',
  status: 'pending',
  tasks: [],
);

// Terminal job: every task completed -> "Repair tasks complete" focus,
// no handover CTA (canComplete false). Static start-end ranges only.
const _doneJob = TechnicianJobResponse(
  jobCardNo: 'JC-108',
  dateOfWork: '2026-10-21',
  startTime: '08:30',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Corolla',
  plateNumber: 'QRS 4455',
  customerName: 'Omar',
  status: 'completed',
  tasks: [
    TaskResponse(
      id: '1',
      description: 'Change engine oil',
      status: 'completed',
      startTime: '08:30',
      endTime: '08:50',
    ),
    TaskResponse(
      id: '2',
      description: 'Replace brake pads',
      status: 'completed',
      startTime: '09:00',
      endTime: '09:40',
    ),
  ],
);

// Many-task job: 4 pending tasks -> "View all" affordance opens the
// activity bottom sheet. All pending, so no stopwatch renders (stable).
const _manyJob = TechnicianJobResponse(
  jobCardNo: 'JC-109',
  dateOfWork: '2026-10-21',
  startTime: '08:30',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Camry',
  plateNumber: 'ABC 1234',
  customerName: 'Ahmed',
  status: 'inProgress',
  tasks: [
    TaskResponse(id: '1', description: 'Change engine oil', status: 'pending'),
    TaskResponse(id: '2', description: 'Replace brake pads', status: 'pending'),
    TaskResponse(id: '3', description: 'Rotate tires', status: 'pending'),
    TaskResponse(id: '4', description: 'Top up fluids', status: 'pending'),
  ],
);

class _DetailData {
  const _DetailData({this.fail = false, this.hang = false});

  final bool fail;
  final bool hang;

  List<TechnicianJobResponse> get jobs => const [
        _idleJob,
        _delayedJob,
        _lockedJob,
        _emptyJob,
        _doneJob,
        _manyJob,
      ];
}

class _FakeTechnicianRemote implements TechnicianRemoteDataSource {
  _FakeTechnicianRemote(this.data);

  final _DetailData data;

  Future<T> _maybeHang<T>(T value) async {
    if (data.fail) throw Exception('offline');
    if (data.hang) await Completer<void>().future;
    return value;
  }

  @override
  Future<TechnicianProfileResponse> getProfile(String empId) => _maybeHang(
        const TechnicianProfileResponse(
          name: 'Omar Haddad',
          empId: 'EMP-007',
          role: 'Technician',
          branch: 'Deira',
          shift: 'Morning shift',
          avatarInitials: 'OH',
        ),
      );

  @override
  Future<List<TechnicianJobResponse>> getJobs(
    String empId, {
    String? status,
  }) =>
      _maybeHang(List.of(data.jobs));

  @override
  Future<List<AssignedJobResponse>> getAssignedJobs(String empId) =>
      _maybeHang(const <AssignedJobResponse>[]);

  @override
  Future<AttendanceResponse> getAttendance(String empId, {String? date}) =>
      _maybeHang(
        const AttendanceResponse(
          status: 'working',
          punchIn: '08:00',
          punchOut: '',
          breakTime: '0 min',
          workHours: '1h 0m',
        ),
      );

  @override
  Future<ProductivityResponse> getProductivity(String empId) =>
      _maybeHang(const ProductivityResponse());

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
  Future<TechnicianJobResponse> searchJob(String q) =>
      _maybeHang(data.jobs.first);

  @override
  Future<TaskActionResponse> startTask(
    String jobCardNo,
    String taskId,
    String startTime,
  ) async =>
      TaskActionResponse(startTime: startTime);

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
  String jobCardNo = 'JC-101',
  Locale locale = const Locale('en'),
  Size size = const Size(360, 800),
  double scale = 1.0,
  _DetailData data = const _DetailData(),
  Future<void> Function(WidgetTester)? interact,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      technicianRemoteDataSourceProvider.overrideWithValue(
        _FakeTechnicianRemote(data),
      ),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    final job = TechnicianJobEntityShim(jobCardNo);
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(body: TechnicianJobDetailView(job: job.entity)),
        ),
      ),
    );
    for (var i = 0; i < 40; i++) {
      if (!container.read(technicianDashboardProvider).isLoading) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  if (interact != null) {
    await interact(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
}

/// Minimal route-time entity: the view resolves the live canonical job from
/// the provider by jobCardNo, so the shell only carries the reference.
class TechnicianJobEntityShim {
  TechnicianJobEntityShim(this.jobCardNo);

  final String jobCardNo;

  TechnicianJobEntity get entity => TechnicianJobEntity(
        jobCardNo: jobCardNo,
        dateOfWork: '',
        startTime: '',
        vehicleBrand: '',
        vehicleModel: '',
        plateNumber: '',
        tasks: const [],
      );
}

String _name(String state, double scale, String locale, Size size) =>
    '${state}_light_${scale.toStringAsFixed(1)}_${locale}_${size.width.toInt()}x${size.height.toInt()}.png';

void main() {
  setUp(() {
    final binding = TestDefaultBinaryMessengerBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall call) async => null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall call) async {
        if (call.method == 'checkConnectivity' || call.method == 'check') {
          return 'wifi';
        }
        return null;
      },
    );
  });

  setUpAll(() async {
    await _loadFonts();
    final dir = await Directory.systemTemp.createTemp('tech_detail_after');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
    debugPrint('technician job detail after capture: fonts ready');
  });

  testWidgets('after idle light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(360, 800)),
    );
  });

  testWidgets('after idle light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'ar', const Size(360, 800)),
      locale: const Locale('ar'),
    );
  });

  testWidgets('after empty light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('empty', 1.0, 'en', const Size(360, 800)),
      jobCardNo: 'JC-106',
    );
  });

  testWidgets('after locked light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('locked', 1.0, 'en', const Size(360, 800)),
      jobCardNo: 'JC-105',
    );
  });

  testWidgets('after delayed light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('delayed', 1.0, 'en', const Size(360, 800)),
      jobCardNo: 'JC-102',
    );
  });

  testWidgets('after idle light en 320x568', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(320, 568)),
      size: const Size(320, 568),
    );
  });

  testWidgets('after idle light en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.3, 'en', const Size(360, 800)),
      scale: 1.3,
    );
  });

  testWidgets('after idle light en 768x1024', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(768, 1024)),
      size: const Size(768, 1024),
    );
  });

  // NOTE: no running-task golden. A running task renders the live
  // TechnicianStopwatch (wall-clock HH:MM:SS, ticks every second), so any
  // running frame diffs ~0.06% (~1552px, stopwatch digits) on immediate
  // re-compare and can never be byte-stable (verified 2026-10-22).
  // The running-focus copy ("Complete task" CTA) is pinned by
  // characterization instead: "focus offers complete when a task is running".
  testWidgets('after done light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('done', 1.0, 'en', const Size(360, 800)),
      jobCardNo: 'JC-108',
    );
  });

  testWidgets('after loading light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('loading', 1.0, 'en', const Size(360, 800)),
      data: const _DetailData(hang: true),
    );
  });

  testWidgets('after error light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('error', 1.0, 'en', const Size(360, 800)),
      data: const _DetailData(fail: true),
    );
  });

  testWidgets('after sheet light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('sheet', 1.0, 'en', const Size(360, 800)),
      jobCardNo: 'JC-109',
      interact: (t) async {
        final seeAll = find.text('View all');
        expect(seeAll, findsOneWidget);
        await t.tap(seeAll);
        await t.pump();
        await t.pump(const Duration(milliseconds: 300));
      },
    );
  });
}
