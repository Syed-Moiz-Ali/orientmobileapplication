// U5 regression: hero CTA-row labels must render fully (round-1 fixer).
//
// The side-by-side hero Row (secondary flex 1 vs primary flex 2) squeezed
// `Job details` to `Jo…` at 360x800 1.0x (`J…` at 320, `Job det…` at 768,
// `تفا…` in ar) and even the primary to `Complete ta…` at 1.3x. The hero
// now stacks both CTAs vertically at full width; these pins assert neither
// CTA label ellipsizes at 320px, at 1.3x text scale, or in ar.
//
// Presentation-only pins (no provider/state/route assertions).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_today_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ---------------------------------------------------------------- fixtures
// Same deterministic day as the characterization baseline: one running job
// (primary = Complete task) + one delayed + one pending.

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

class _FakeTechnicianRemote implements TechnicianRemoteDataSource {
  _FakeTechnicianRemote(this.jobs);

  final List<TechnicianJobResponse> jobs;

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
  }) async => jobs;

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
  Future<void> updateAssignedJobStatus(String id, String empId, String status) async {}

  @override
  Future<TechnicianJobResponse> searchJob(String q) async => jobs.first;

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

Future<void> _pumpToday(
  WidgetTester tester, {
  required List<TechnicianJobResponse> jobs,
  Locale locale = const Locale('en'),
  Size size = const Size(360, 800),
  double textScale = 1.0,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  tester.view.devicePixelRatio = 3.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  final container = ProviderContainer(
    overrides: [
      technicianRemoteDataSourceProvider.overrideWithValue(
        _FakeTechnicianRemote(jobs),
      ),
    ],
  );
  addTearDown(container.dispose);
  // Real async for the backend beat: Hive file I/O hangs under the
  // testWidgets FakeAsync clock, so the clear + first frame + load settle
  // run with real async (supervisor capture harness pattern).
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
          home: const Scaffold(body: TechnicianTodayView()),
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
  // Restore synchronously inside the test body (capture-test pattern):
  // leaving a painting debug var changed trips the test invariant.
  debugDisableShadows = oldShadows;
}

/// Asserts a hero CTA label renders in full (no ellipsis truncation).
void _expectFullLabel(WidgetTester tester, String label) {
  final finder = find.text(label);
  expect(finder, findsOneWidget, reason: 'CTA label "$label" must be shown');
  final render = tester.renderObject<RenderParagraph>(finder);
  expect(
    render.didExceedMaxLines,
    isFalse,
    reason: 'CTA label "$label" must not ellipsize',
  );
}

void main() {
  setUp(() {
    final binding = TestDefaultBinaryMessengerBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    // No stored session: secure storage reads resolve to null.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall call) async => null,
    );
    // Connectivity: wifi on both the v6 (`checkConnectivity`) and legacy
    // (`check`) method names.
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
    final dir = await Directory.systemTemp.createTemp('tech_today_hero_u5');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
  });

  testWidgets('hero CTA labels render fully at 320px', (tester) async {
    await _pumpToday(
      tester,
      jobs: const [_runningJob, _delayedJob, _pendingJob],
      size: const Size(320, 568),
    );

    _expectFullLabel(tester, 'Complete task');
    _expectFullLabel(tester, 'Job details');
  });

  testWidgets('hero CTA labels render fully at 1.3x text scale', (tester) async {
    await _pumpToday(
      tester,
      jobs: const [_runningJob, _delayedJob, _pendingJob],
      textScale: 1.3,
    );

    _expectFullLabel(tester, 'Complete task');
    _expectFullLabel(tester, 'Job details');
  });

  testWidgets('longest primary label renders fully at 320px + 1.3x', (
    tester,
  ) async {
    // Pending-only day: the hero primary is the longest en label.
    await _pumpToday(
      tester,
      jobs: const [_pendingJob],
      size: const Size(320, 568),
      textScale: 1.3,
    );

    _expectFullLabel(tester, 'Start next task');
    _expectFullLabel(tester, 'Job details');
  });

  testWidgets('hero CTA labels render fully in ar', (tester) async {
    await _pumpToday(
      tester,
      jobs: const [_runningJob, _delayedJob, _pendingJob],
      locale: const Locale('ar'),
    );

    _expectFullLabel(tester, 'إكمال المهمة');
    _expectFullLabel(tester, 'تفاصيل المهمة');
  });

  testWidgets('longest ar primary label renders fully at 320px + 1.3x', (
    tester,
  ) async {
    await _pumpToday(
      tester,
      jobs: const [_pendingJob],
      locale: const Locale('ar'),
      size: const Size(320, 568),
      textScale: 1.3,
    );

    _expectFullLabel(tester, 'بدء المهمة التالية');
    _expectFullLabel(tester, 'تفاصيل المهمة');
  });

  testWidgets('hero keeps exactly one filled primary CTA', (tester) async {
    await _pumpToday(
      tester,
      jobs: const [_runningJob, _delayedJob, _pendingJob],
    );

    // One filled Start/Complete primary + one secondary details entry.
    expect(find.text('Complete task'), findsOneWidget);
    expect(find.text('Job details'), findsOneWidget);
  });
}
