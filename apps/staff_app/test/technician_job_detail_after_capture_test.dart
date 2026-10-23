// AFTER capture for the technician job detail (ruling (a) task-find).
//
// Pumps the CURRENT TechnicianJobDetailView with deterministic fakes and
// writes viewport PNGs into docs/ui-redesign/baseline/after-technician-job-detail/
// for review + contact sheets. Staff light-only.
//
// Matrix (5 PNGs):
//   data en 1.0 360x800 | data ar 1.0 360x800 | data en 1.3 360x800 |
//   data en 1.0 320x568 | search sheet open with query en 360x800.
//
// Determinism note: fixtures keep every task pending/completed (no
// in-progress task), so no live TechnicianStopwatch renders and the frames
// are stable. The search sheet opens from the shell WorkspaceAppBar
// top-right trigger (ruling (a)) over the detail's loaded tasks.
//
// Run (from apps/staff_app):
//   flutter test --tags baseline --update-goldens test/technician_job_detail_after_capture_test.dart   (generate)
//   flutter test --tags baseline test/technician_job_detail_after_capture_test.dart                    (compare)
// Default `flutter test` excludes this tag.
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
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _outDir = 'after-technician-job-detail';

// ---------------------------------------------------------------- fixtures
// Same deterministic job as the today captures (JC-101), but with no
// in-progress task so no live stopwatch renders: one completed + two
// pending tasks (static start-end text only).

const _jobs = [
  TechnicianJobResponse(
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
      TaskResponse(id: 't2', description: 'Replace brake pads', status: 'pending'),
      TaskResponse(id: 't3', description: 'Rotate tires', status: 'pending'),
    ],
  ),
];

class _FakeTechnicianRemote implements TechnicianRemoteDataSource {
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
  }) async => _jobs;

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
  Future<TechnicianJobResponse> searchJob(String q) async => _jobs.first;

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

/// Pumps the job detail with deterministic fakes, runs the optional [interact]
/// step (task-find sheet), then golden-captures the full MaterialApp (sheet
/// overlays included).
Future<void> _capture(
  WidgetTester tester, {
  required String name,
  Locale locale = const Locale('en'),
  Size logicalSize = const Size(360, 800),
  double pixelRatio = 3.0,
  double textScale = 1.0,
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
      return <String>['wifi'];
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
      technicianRemoteDataSourceProvider.overrideWithValue(
        _FakeTechnicianRemote(),
      ),
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
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
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: const TechnicianJobDetailView(
                job: TechnicianJobEntity(
                  jobCardNo: 'JC-101',
                  dateOfWork: '2026-10-21',
                  startTime: '08:30',
                  vehicleBrand: 'Toyota',
                  vehicleModel: 'Camry',
                  plateNumber: 'ABC 1234',
                  customerName: 'Ahmed',
                  tasks: [],
                ),
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

Future<void> _openTaskSearch(WidgetTester tester) async {
  // Ruling (a): exactly one search icon on the detail — the shell bar
  // top-right trigger. It opens the task find sheet over the loaded tasks.
  final search = find.byIcon(Icons.search_rounded);
  expect(search, findsOneWidget);
  await tester.tap(search);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final field = find.descendant(
    of: find.byType(AppSearchField),
    matching: find.byType(TextField),
  );
  expect(field, findsOneWidget);
  await tester.enterText(field, 'oil');
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  setUpAll(() async {
    await _loadFonts();
    final dir = await Directory.systemTemp.createTemp('tech_detail_after');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
    debugPrint('technician job detail after capture: fonts ready');
  });

  testWidgets('after detail data en 360x800', (tester) async {
    await _capture(tester, name: 'detail_1.0_en_360x800.png');
  });

  testWidgets('after detail data ar 360x800', (tester) async {
    await _capture(
      tester,
      name: 'detail_1.0_ar_360x800.png',
      locale: const Locale('ar'),
    );
  });

  testWidgets('after detail data 1.3x en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'detail_1.3_en_360x800.png',
      textScale: 1.3,
    );
  });

  testWidgets('after detail data en 320x568', (tester) async {
    await _capture(
      tester,
      name: 'detail_1.0_en_320x568.png',
      logicalSize: const Size(320, 568),
    );
  });

  testWidgets('after detail search open en 360x800', (tester) async {
    await _capture(
      tester,
      name: 'detail_search_open_en_360x800.png',
      interact: _openTaskSearch,
    );
  });
}
