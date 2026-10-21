// Characterization baseline for the technician today view (phase 5).
//
// Behavior pins against the CURRENT today UI. These tests assert behavior
// only (active-job copy, task state machine, progress math, sheets, queue,
// error/empty/loading/offline affordances) — never legacy widget types — so
// they stay green across the App* recomposition and become the migration
// baseline. Do NOT modify these tests after the recomposition (see
// docs/ui-redesign/evaluation/technician-home-test-migration.md).

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
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_today_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

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
    TaskResponse(
      id: 't3',
      description: 'Rotate tires',
      status: 'pending',
    ),
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
  const _TodayData({
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

  _TodayData data;
  var partRequests = 0;
  var escalations = 0;

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
  }) => _maybeHang(data.jobs);

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
  Future<void> requestPart(Map<String, dynamic> data) async {
    await _maybeHang(null);
    partRequests++;
  }

  @override
  Future<void> escalateIssue(Map<String, dynamic> data) async {
    await _maybeHang(null);
    escalations++;
  }
}

Future<ProviderContainer> _pumpToday(
  WidgetTester tester,
  _FakeTechnicianRemote fake,
) async {
  final container = ProviderContainer(
    overrides: [
      technicianRemoteDataSourceProvider.overrideWithValue(fake),
    ],
  );
  addTearDown(container.dispose);
  // Real async for the backend beat: Hive file I/O hangs under the
  // testWidgets FakeAsync clock, so the clear + first frame + load settle
  // run with real async (supervisor capture harness pattern). The load is
  // awaited by polling isLoading (bounded) instead of a fixed delay so the
  // cold first test cannot observe the skeleton.
  await tester.runAsync(() async {
    await Hive.box<dynamic>('technician_jobs').clear();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          locale: const Locale('en'),
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(body: TechnicianTodayView()),
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
  expect(tester.takeException(), isNull);
  return container;
}

/// Runs a state-mutating action with real async active throughout.
///
/// Task mutations start Hive writes; a write started under the testWidgets
/// FakeAsync clock never completes and holds the box lock, deadlocking the
/// NEXT test's `clear()`. Tapping (or mutating) inside `runAsync` with a
/// real settle delay lets the persistence finish before the test ends.
Future<void> _mutate(
  WidgetTester tester,
  Future<void> Function() action,
) async {
  await tester.runAsync(() async {
    await action();
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

TechnicianJobEntity _job(ProviderContainer container, String ref) =>
    container.read(technicianDashboardProvider.notifier).allJobs.firstWhere(
      (j) => j.jobCardNo == ref,
    );

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
    final dir = await Directory.systemTemp.createTemp('tech_today_char');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
  });

  testWidgets('shows the active job with vehicle, progress and one primary action', (
    tester,
  ) async {
    await _pumpToday(tester, _FakeTechnicianRemote(const _TodayData()));

    // Active job is the running one: vehicle + live task + progress math.
    expect(find.text('Toyota Camry'), findsOneWidget);
    expect(find.text('Replace brake pads'), findsOneWidget);
    expect(find.text('1 of 3 tasks completed'), findsOneWidget);
    // Exactly one primary action for the running task.
    expect(find.text('Complete task'), findsOneWidget);
    expect(find.text('Job details'), findsOneWidget);
    // Urgent-first queue pins the other two jobs below.
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-103'), findsOneWidget);
  });

  testWidgets('start moves the next pending task to in-progress', (
    tester,
  ) async {
    await _pumpToday(
      tester,
      _FakeTechnicianRemote(const _TodayData(jobs: [_pendingJob])),
    );

    expect(find.text('Start next task'), findsOneWidget);
    expect(find.text('0 of 2 tasks completed'), findsOneWidget);

    await _mutate(tester, () => tester.tap(find.text('Start next task')));

    // The pending task is now running: complete becomes the primary action.
    expect(find.text('Complete task'), findsOneWidget);
  });

  testWidgets('complete finishes the running task and advances progress', (
    tester,
  ) async {
    final container = await _pumpToday(
      tester,
      _FakeTechnicianRemote(const _TodayData()),
    );

    await _mutate(tester, () => tester.tap(find.text('Complete task')));

    expect(find.text('2 of 3 tasks completed'), findsOneWidget);
    expect(find.text('Start next task'), findsOneWidget);
    final task = _job(container, 'JC-101').tasks.firstWhere((t) => t.id == 2);
    expect(task.status, TaskStatus.completed);
  });

  testWidgets('pause holds the running task and resume restarts it', (
    tester,
  ) async {
    final container = await _pumpToday(
      tester,
      _FakeTechnicianRemote(const _TodayData()),
    );
    final notifier = container.read(technicianDashboardProvider.notifier);

    await _mutate(tester, () async {
      notifier.updateTaskStatus(
        _job(container, 'JC-101'),
        _job(container, 'JC-101').tasks.firstWhere((t) => t.id == 2),
        TaskStatus.onHold,
      );
    });

    expect(
      _job(container, 'JC-101').tasks.firstWhere((t) => t.id == 2).status,
      TaskStatus.onHold,
    );
    // A held task offers start again (resume), never two primaries.
    expect(find.text('Start next task'), findsOneWidget);
    expect(find.text('Complete task'), findsNothing);

    await _mutate(tester, () => tester.tap(find.text('Start next task')));

    expect(
      _job(container, 'JC-101').tasks.firstWhere((t) => t.id == 2).status,
      TaskStatus.inProgress,
    );
    expect(find.text('Complete task'), findsOneWidget);
  });

  testWidgets('request part opens the parts sheet for the active job', (
    tester,
  ) async {
    await _pumpToday(tester, _FakeTechnicianRemote(const _TodayData()));

    await tester.tap(find.text('Request part'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.text('Request a part'), findsOneWidget);
    expect(find.text('JC-101'), findsWidgets);
  });

  testWidgets('escalate opens the escalation sheet for the active job', (
    tester,
  ) async {
    await _pumpToday(tester, _FakeTechnicianRemote(const _TodayData()));

    await tester.tap(find.text('Escalate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.text('Escalate an issue'), findsOneWidget);
  });

  testWidgets('queue lists upcoming work and view-all switches to jobs', (
    tester,
  ) async {
    final container = await _pumpToday(
      tester,
      _FakeTechnicianRemote(const _TodayData()),
    );

    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-103'), findsOneWidget);

    await tester.tap(find.text('View all'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      container.read(technicianDashboardProvider).selectedTab,
      1,
    );
  });

  testWidgets('first load failure shows the error with retry', (tester) async {
    final fake = _FakeTechnicianRemote(const _TodayData(fail: true));
    await _pumpToday(tester, fake);

    expect(
      find.textContaining("We couldn't load today's work"),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(
      find.textContaining("We couldn't load today's work"),
      findsOneWidget,
    );
  });

  testWidgets('loading shows no jobs and no error', (tester) async {
    await _pumpToday(
      tester,
      _FakeTechnicianRemote(const _TodayData(hang: true)),
    );

    expect(find.text('JC-101'), findsNothing);
    expect(
      find.text("Could not load live workshop data. Tap to retry."),
      findsNothing,
    );
  });

  testWidgets('empty shows the no-work state', (tester) async {
    await _pumpToday(
      tester,
      _FakeTechnicianRemote(const _TodayData(jobs: [])),
    );

    expect(
      find.textContaining('No assigned jobs right now'),
      findsOneWidget,
    );
    expect(
      find.text("Could not load live workshop data. Tap to retry."),
      findsNothing,
    );
  });

  testWidgets('stale data stays visible under a connection notice', (
    tester,
  ) async {
    final fake = _FakeTechnicianRemote(const _TodayData());
    final container = await _pumpToday(tester, fake);

    fake.data = const _TodayData(fail: true);
    await container.read(technicianDashboardProvider.notifier).refresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(
      find.textContaining(
        'Showing saved jobs while the workshop service reconnects.',
      ),
      findsOneWidget,
    );
    expect(find.text('JC-101'), findsWidgets);
  });
}
