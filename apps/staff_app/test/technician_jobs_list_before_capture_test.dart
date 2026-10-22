// BEFORE capture for the technician jobs list view (GROUP-C list-ops).
//
// Pumps the CURRENT TechnicianJobsView with deterministic fakes and writes
// viewport PNGs into docs/ui-redesign/baseline/before-technician-jobs/ for
// before/after review. Staff light-only (en + ar 360x800, empty/error/loading
// 360x800, 320x568 data, 1.3x data, tablet data). Frozen record: do NOT
// --update-goldens this file after the recomposition.
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/technician_jobs_list_before_capture_test.dart   (generate)
//   flutter test --tags baseline test/technician_jobs_list_before_capture_test.dart                    (compare)
// Default `flutter test` excludes this tag.
@Tags(['baseline'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_jobs_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'before-technician-jobs';

// ---------------------------------------------------------------- fixtures

const _runningJob = TechnicianJobResponse(
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
      status: 'inProgress',
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

class _JobsData {
  const _JobsData({
    this.jobs = const [_runningJob, _delayedJob, _pendingJob],
    this.fail = false,
    this.hang = false,
  });

  final List<TechnicianJobResponse> jobs;
  final bool fail;
  final bool hang;
}

class _FakeTechnicianRemote implements TechnicianRemoteDataSource {
  _FakeTechnicianRemote(this.data);

  final _JobsData data;

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
  }) => _maybeHang(List.of(data.jobs));

  @override
  Future<List<AssignedJobResponse>> getAssignedJobs(String empId) =>
      _maybeHang(const []);

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
  Future<AttendanceResponse> punchIn(Map<String, dynamic> data) =>
      _maybeHang(const AttendanceResponse(status: 'working'));

  @override
  Future<void> punchOut(Map<String, dynamic> data) => _maybeHang(null);

  @override
  Future<void> breakStart(Map<String, dynamic> data) => _maybeHang(null);

  @override
  Future<void> breakEnd(Map<String, dynamic> data) => _maybeHang(null);

  @override
  Future<void> updateAssignedJobStatus(
    String id,
    String empId,
    String status,
  ) => _maybeHang(null);

  @override
  Future<TechnicianJobResponse> searchJob(String q) =>
      _maybeHang(data.jobs.first);

  @override
  Future<TaskActionResponse> startTask(
    String jobCardNo,
    String taskId,
    String startTime,
  ) => _maybeHang(TaskActionResponse(startTime: startTime));

  @override
  Future<void> completeTask(
    String jobCardNo,
    String taskId,
    String endTime,
  ) => _maybeHang(null);

  @override
  Future<void> updateTaskStatus(
    String jobCardNo,
    String taskId,
    String status,
  ) => _maybeHang(null);

  @override
  Future<void> completeJob(Map<String, dynamic> data) => _maybeHang(null);

  @override
  Future<void> updateNotes(String jobCardNo, String notes) =>
      _maybeHang(null);

  @override
  Future<void> requestPart(Map<String, dynamic> data) =>
      _maybeHang(null);

  @override
  Future<void> escalateIssue(Map<String, dynamic> data) => _maybeHang(null);
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
    _JobsData data = const _JobsData(),
    Locale locale = const Locale('en'),
    Size size = const Size(360, 800),
    double scale = 1.0,
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
    ],
  );
  addTearDown(container.dispose);
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
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: TechnicianJobsView(
              fixedRefreshAt: DateTime(2026, 10, 21, 9, 41),
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

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$_outDir/$name'),
  );
  debugDisableShadows = oldShadows;
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
    final dir = await Directory.systemTemp.createTemp('tech_jobs_before');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
    debugPrint('technician jobs before capture: fonts ready');
  });

  testWidgets('before idle light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(360, 800)),
    );
  });

  testWidgets('before idle light ar 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'ar', const Size(360, 800)),
      locale: const Locale('ar'),
    );
  });

  testWidgets('before empty light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('empty', 1.0, 'en', const Size(360, 800)),
      data: const _JobsData(jobs: []),
    );
  });

  testWidgets('before error light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('error', 1.0, 'en', const Size(360, 800)),
      data: const _JobsData(fail: true),
    );
  });

  testWidgets('before loading light en 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('loading', 1.0, 'en', const Size(360, 800)),
      data: const _JobsData(hang: true),
    );
  });

  testWidgets('before idle light en 320x568', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(320, 568)),
      size: const Size(320, 568),
    );
  });

  testWidgets('before idle light en 1.3 360x800', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.3, 'en', const Size(360, 800)),
      scale: 1.3,
    );
  });

  testWidgets('before idle light en 768x1024', (tester) async {
    await _capture(
      tester,
      name: _name('idle', 1.0, 'en', const Size(768, 1024)),
      size: const Size(768, 1024),
    );
  });
}
