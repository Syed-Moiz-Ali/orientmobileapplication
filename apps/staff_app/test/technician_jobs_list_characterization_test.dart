// Characterization baseline for the technician jobs list view (GROUP-C list-ops).
//
// Behavior pins against the CURRENT Jobs view UI. These tests assert behavior
// only (rail-only toolbar with no inline search, urgent-first order, filter
// predicate, dossier routing, empty/no-match/error/loading/stale/freshness
// affordances) — never legacy widget types — so they stay green across the
// App* recomposition and become the migration baseline. Do NOT modify these
// tests after the recomposition (see
// docs/ui-redesign/evaluation/technician-jobs-list-test-migration.md).

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_remote_datasource.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_jobs_view.dart';
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

  _JobsData data;

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

Future<ProviderContainer> _pumpJobs(
  WidgetTester tester,
  _FakeTechnicianRemote fake,
) async {
  final container = ProviderContainer(
    overrides: [
      technicianRemoteDataSourceProvider.overrideWithValue(fake),
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(
          body: TechnicianJobsView(
            fixedRefreshAt: DateTime(2026, 10, 21, 9, 41),
          ),
        ),
      ),
      GoRoute(
        path: '/technician/job-detail',
        builder: (_, __) =>
            const Scaffold(body: Text('job dossier destination')),
      ),
    ],
  );
  addTearDown(router.dispose);
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
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient),
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

/// Taps a status chip inside the shared filter bar (summary/footer copy never
/// repeats these labels, so the bar scope keeps the finder unambiguous).
Future<void> _tapFilter(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(AppFilterBar),
    matching: find.text(label),
  );
  expect(chip, findsOneWidget);
  await tester.tap(chip);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

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
    final dir = await Directory.systemTemp.createTemp('tech_jobs_char');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
  });

  testWidgets('toolbar is filter-rail only, no inline search field', (
    tester,
  ) async {
    await _pumpJobs(tester, _FakeTechnicianRemote(const _JobsData()));

    // Blessed single-search contract (ui/integration-1): the header search
    // icon owns search; this toolbar keeps the filter rail only.
    expect(find.byType(AppSearchField), findsNothing);
    expect(find.byType(AppFilterBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppFilterBar),
        matching: find.text('Delayed'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('rows render urgent-first: delayed above running above pending', (
    tester,
  ) async {
    await _pumpJobs(tester, _FakeTechnicianRemote(const _JobsData()));

    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-103'), findsOneWidget);
    final delayedDy = tester.getCenter(find.text('JC-102')).dy;
    final runningDy = tester.getCenter(find.text('JC-101')).dy;
    final pendingDy = tester.getCenter(find.text('JC-103')).dy;
    expect(delayedDy, lessThan(runningDy));
    expect(runningDy, lessThan(pendingDy));
    // Freshness footer ticks from the fixed instant (deterministic).
    expect(find.textContaining('09:41'), findsOneWidget);
  });

  testWidgets('status rail filters and re-tap restores the queue', (
    tester,
  ) async {
    await _pumpJobs(tester, _FakeTechnicianRemote(const _JobsData()));

    await _tapFilter(tester, 'Delayed');

    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-101'), findsNothing);
    expect(find.text('JC-103'), findsNothing);

    await _tapFilter(tester, 'Delayed');
    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-103'), findsOneWidget);
  });

  testWidgets('row tap opens the job dossier destination', (tester) async {
    await _pumpJobs(tester, _FakeTechnicianRemote(const _JobsData()));

    await tester.tap(find.text('JC-103'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);

    expect(find.text('job dossier destination'), findsOneWidget);
  });

  testWidgets('no match offers a clear action that resets the queue', (
    tester,
  ) async {
    final container =
        await _pumpJobs(tester, _FakeTechnicianRemote(const _JobsData()));
    final notifier = container.read(technicianDashboardProvider.notifier);

    await tester.runAsync(() async {
      notifier.updateFilter('Completed');
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // State copy is matched by containment: the recomposed atoms bidi-isolate
    // title + message (invisible), green on the current UI and the new atoms.
    expect(find.textContaining('No matching jobs'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-101'), findsOneWidget);
  });

  testWidgets('empty shows the no-work state with refresh', (tester) async {
    await _pumpJobs(
      tester,
      _FakeTechnicianRemote(const _JobsData(jobs: [])),
    );

    expect(
      find.textContaining('There are no jobs assigned'),
      findsOneWidget,
    );
  });

  testWidgets('first load failure shows the error with retry', (tester) async {
    final fake = _FakeTechnicianRemote(const _JobsData(fail: true));
    await _pumpJobs(tester, fake);

    expect(
      find.textContaining("We couldn't load your jobs"),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('loading shows no jobs and no error', (tester) async {
    await _pumpJobs(
      tester,
      _FakeTechnicianRemote(const _JobsData(hang: true)),
    );

    expect(find.text('JC-101'), findsNothing);
    expect(
      find.text("Could not load live workshop data. Tap to retry."),
      findsNothing,
    );
  });

  testWidgets('stale data stays visible under a connection notice', (
    tester,
  ) async {
    final fake = _FakeTechnicianRemote(const _JobsData());
    final container = await _pumpJobs(tester, fake);

    fake.data = const _JobsData(fail: true);
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
