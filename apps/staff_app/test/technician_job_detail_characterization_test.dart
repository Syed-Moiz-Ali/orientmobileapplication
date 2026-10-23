// Characterization baseline for the technician job detail view.
//
// Behavior pins against the CURRENT TechnicianJobDetailView (job_detail_sheet).
// These tests assert behavior only (hero copy, focus next-step, notifier calls
// via state, sheet/confirm contracts, read-only locked rendering) — never
// legacy widget types — so they stay green across the App* recomposition and
// become the migration baseline. Do NOT modify these tests after the
// recomposition (see
// docs/ui-redesign/evaluation/technician-job-detail-test-migration.md).

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
      id: '1',
      description: 'Change engine oil',
      status: 'completed',
      startTime: '08:30',
      endTime: '08:50',
    ),
    TaskResponse(
      id: '2',
      description: 'Replace brake pads',
      status: 'inProgress',
      startTime: '09:00',
    ),
    TaskResponse(id: '3', description: 'Rotate tires', status: 'pending'),
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
    TaskResponse(id: '4', description: 'Change air filter', status: 'pending'),
    TaskResponse(id: '5', description: 'Top up fluids', status: 'pending'),
  ],
);

const _heldJob = TechnicianJobResponse(
  jobCardNo: 'JC-104',
  dateOfWork: '2026-10-21',
  startTime: '10:00',
  vehicleBrand: 'Nissan',
  vehicleModel: 'Patrol',
  plateNumber: 'GHI 3456',
  customerName: 'Sara',
  status: 'inProgress',
  tasks: [
    TaskResponse(
      id: '6',
      description: 'Inspect brakes',
      status: 'completed',
      startTime: '10:00',
      endTime: '10:20',
    ),
    TaskResponse(
      id: '7',
      description: 'Adjust handbrake',
      status: 'onHold',
      startTime: '10:25',
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
    TaskResponse(id: '8', description: 'Inspect brakes', status: 'pending'),
  ],
);

const _qcJob = TechnicianJobResponse(
  jobCardNo: 'JC-105',
  dateOfWork: '2026-10-20',
  startTime: '08:00',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Corolla',
  plateNumber: 'JKL 7890',
  customerName: 'Omar',
  // Backend spelling (TechJobStatusX.parse maps qualitycheck -> qcReview).
  status: 'qualitycheck',
  tasks: [
    TaskResponse(
      id: '9',
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

class _DetailData {
  const _DetailData();

  List<TechnicianJobResponse> get jobs => const [
        _runningJob,
        _pendingJob,
        _heldJob,
        _delayedJob,
        _qcJob,
        _emptyJob,
      ];
}

class _FakeTechnicianRemote implements TechnicianRemoteDataSource {
  _FakeTechnicianRemote(this.data);

  _DetailData data;

  Future<T> _maybeHang<T>(T value) async => value;

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

Future<ProviderContainer> _pumpDetail(
  WidgetTester tester,
  _FakeTechnicianRemote fake,
  String jobCardNo,
) async {
  // Harness-only: pump at the production phone viewport (360x800) so the
  // focus panel sits above the fold exactly as the tap budgets assume.
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      technicianRemoteDataSourceProvider.overrideWithValue(fake),
      // Harness-only: the detail app bar reads the shared connectivity
      // source of truth; pin it to wifi (shell-fix capture pattern) so the
      // offline pill never throws on the raw platform channel.
      connectivityStatusProvider.overrideWith(
        (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
      ),
    ],
  );
  addTearDown(container.dispose);
  // Real async for the backend beat: Hive file I/O hangs under the
  // testWidgets FakeAsync clock, so the first frame + load settle run with
  // real async (supervisor capture harness pattern). The load is awaited by
  // polling isLoading (bounded) instead of a fixed delay.
  //
  // NOTE (harness-only): no per-pump Hive clear. The box lives in a fresh
  // temp dir per file run (setUpAll), and every notifier build reloads the
  // canonical jobs from the fake remote (overwriting any Hive-restored rows).
  // Clearing here deadlocks: mutation tests leave the production `_persistJob`
  // box.put unawaited, and a second clear() waits on it forever in FakeAsync.
  await tester.runAsync(() async {
    final job = TechnicianJobEntity(
      jobCardNo: jobCardNo,
      dateOfWork: '',
      startTime: '',
      vehicleBrand: '',
      vehicleModel: '',
      plateNumber: '',
      tasks: const [],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
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
          home: Scaffold(body: TechnicianJobDetailView(job: job)),
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

/// Harness-only: scrolls a below-fold target into view before tapping
/// (ensureVisible for below-fold rows; assertions unchanged).
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull);
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
    final dir = await Directory.systemTemp.createTemp('tech_detail_char');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('technician_jobs');
  });

  testWidgets('hero shows vehicle, job ref, status and progress', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    expect(find.text('Toyota Camry'), findsWidgets);
    expect(find.text('JC-101'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    // The progress sentence lives on the hero card (the sticky bar carries
    // status + job reference instead, so it can never break mid-word at
    // 320 px next to the CTA). The recomposed AppProgressBar bidi-isolates
    // its label, so containment is used.
    expect(find.textContaining('1 of 3 tasks completed'), findsOneWidget);
  });

  testWidgets('focus offers complete when a task is running', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    expect(find.text('Complete task'), findsOneWidget);
  });

  testWidgets('focus offers start when nothing is running', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-103');

    expect(find.text('Start next task'), findsOneWidget);
  });

  testWidgets('focus offers resume for the held task', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-104');

    expect(find.text('Resume task'), findsOneWidget);
  });

  testWidgets('start advances the pending task to in progress', (tester) async {
    final container =
        await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-103');

    await tester.tap(find.text('Start next task'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    final job = container
        .read(technicianDashboardProvider.notifier)
        .allJobs
        .firstWhere((j) => j.jobCardNo == 'JC-103');
    expect(
      job.tasks.firstWhere((t) => t.description == 'Change air filter').status,
      TaskStatus.inProgress,
    );
  });

  testWidgets('complete finishes the running task', (tester) async {
    final container =
        await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    await tester.tap(find.text('Complete task'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    final job = container
        .read(technicianDashboardProvider.notifier)
        .allJobs
        .firstWhere((j) => j.jobCardNo == 'JC-101');
    expect(
      job.tasks.firstWhere((t) => t.description == 'Replace brake pads').status,
      TaskStatus.completed,
    );
  });

  testWidgets('hold pauses the running task per row', (tester) async {
    final container =
        await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    await _tapVisible(tester, find.text('Hold').first);

    final job = container
        .read(technicianDashboardProvider.notifier)
        .allJobs
        .firstWhere((j) => j.jobCardNo == 'JC-101');
    expect(
      job.tasks.firstWhere((t) => t.description == 'Replace brake pads').status,
      TaskStatus.onHold,
    );
  });

  testWidgets('request part opens the parts sheet', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    await _tapVisible(tester, find.text('Request part'));

    expect(find.text('Request a part'), findsOneWidget);
  });

  testWidgets('escalate opens the escalation sheet', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    await _tapVisible(tester, find.text('Escalate issue'));

    expect(find.text('Escalate an issue'), findsOneWidget);
  });

  testWidgets('complete repair confirms then moves the job to QC review', (
    tester,
  ) async {
    final container =
        await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-101');

    await tester.tap(find.text('Complete repair'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // U10: the handover dialog names the object under repair.
    expect(
      find.textContaining("Complete repair on 'JC-101'?"),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Complete repair'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    // Contract pin: completeJob records every task completed and hands the
    // job to QC review. The notifier's own refresh() reloads the fake remote
    // afterwards (production: the server now reports the handover), so the
    // handover itself is read from selectedJob, which completeJob sets.
    final updated = container.read(technicianDashboardProvider).selectedJob;
    expect(updated?.jobCardNo, 'JC-101');
    expect(updated?.status, TechJobStatus.qcReview);
    expect(
      updated?.tasks.every((t) => t.status == TaskStatus.completed),
      isTrue,
    );
  });

  testWidgets('qc-locked job is read-only with a notice', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-105');

    expect(
      find.text(
        'Repair work has been submitted for supervisor QC review.',
      ),
      findsOneWidget,
    );
    expect(find.text('Start next task'), findsNothing);
    expect(find.text('Complete task'), findsNothing);
    expect(find.text('Complete repair'), findsNothing);
  });

  testWidgets('delayed job shows the delayed notice', (tester) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-102');

    expect(
      find.textContaining(
        'This repair is marked as delayed at the workshop.',
      ),
      findsWidgets,
    );
  });

  testWidgets('empty job shows the no-tasks hint without actions', (
    tester,
  ) async {
    await _pumpDetail(tester, _FakeTechnicianRemote(const _DetailData()), 'JC-106');

    // Structural (rendering-identical): the recomposed AppEmptyState
    // bidi-isolates its message (invisible U+2066...U+2069), so containment
    // pins the same sentence on the old and the new UI.
    expect(
      find.textContaining(
        'No tasks have been added to this job. Ask the advisor before starting work.',
      ),
      findsOneWidget,
    );
    expect(find.text('Start next task'), findsNothing);
    expect(find.text('Complete task'), findsNothing);
    expect(find.text('Complete repair'), findsNothing);
  });
}
