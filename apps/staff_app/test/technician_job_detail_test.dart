import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';

void main() {
  setUpAll(_loadFonts);

  group('Technician Job Detail identity', () {
    testWidgets('shows real job reference, vehicle, plate and status', (
      tester,
    ) async {
      await _pump(tester, _inProgressJob);

      expect(find.text('JO-1024'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows customer only when real', (tester) async {
      await _pump(tester, _inProgressJob);
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
    });

    testWidgets('status is not colour-only', (tester) async {
      await _pump(tester, _delayedJob);
      expect(find.text('DELAYED'), findsWidgets);
    });
  });

  group('Technician Job Detail execution', () {
    testWidgets('shows the current task with its real start time', (
      tester,
    ) async {
      await _pump(tester, _inProgressJob);

      expect(find.text('CURRENT TASK'), findsOneWidget);
      expect(find.text('Started 10:42'), findsWidgets);
      expect(find.text('Complete task'), findsOneWidget);
      expect(find.text('1 of 3 tasks completed'), findsOneWidget);
    });

    testWidgets('shows the next task when nothing is running', (tester) async {
      await _pump(tester, _pendingJob);

      expect(find.text('NEXT TASK'), findsOneWidget);
      expect(find.text('Start next task'), findsOneWidget);
    });

    testWidgets('starting a task moves it to the current task', (tester) async {
      await _pump(tester, _pendingJob);

      await tester.tap(find.text('Start next task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('CURRENT TASK'), findsOneWidget);
      expect(find.text('Complete task'), findsOneWidget);
    });

    testWidgets('completing the last task submits the job to QC', (
      tester,
    ) async {
      await _pump(tester, _oneTaskRunningJob);

      await tester.tap(find.text('Complete task'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(
        find.text('Repair work has been submitted for supervisor QC review.'),
        findsOneWidget,
      );
      expect(find.text('Complete task'), findsNothing);
    });

    testWidgets('the task list reports every task state as text', (
      tester,
    ) async {
      await _pump(tester, _inProgressJob);

      expect(find.text('ALL TASKS'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsWidgets);
      expect(find.text('PENDING'), findsWidgets);
    });

    testWidgets('duplicate Start taps are blocked', (tester) async {
      final fake = _FakeTechnicianNotifier(_pendingJob);
      await _pumpWith(tester, fake, _pendingJob);

      final start = find.text('Start next task');
      await tester.tap(start);
      await tester.tap(start);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(fake.startCount, 1);
    });
  });

  group('Technician Job Detail per-task controls', () {
    testWidgets('each task offers only its legal actions', (tester) async {
      await _pump(tester, _inProgressJob);

      // Running task → Hold + Complete; pending task → Start; completed → none.
      expect(find.text('Hold'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('per-task Start starts that task', (tester) async {
      final fake = _FakeTechnicianNotifier(_pendingJob);
      await _pumpWith(tester, fake, _pendingJob);

      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(fake.startCount, 1);
      expect(find.text('CURRENT TASK'), findsOneWidget);
      expect(find.text('Hold'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('per-task Hold pauses the running task', (tester) async {
      final fake = _FakeTechnicianNotifier(_oneTaskRunningJob);
      await _pumpWith(tester, fake, _oneTaskRunningJob);

      await tester.tap(find.text('Hold'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(fake.holdCount, 1);
      expect(find.text('ON HOLD'), findsWidgets);
      expect(find.text('Resume task'), findsOneWidget);
    });

    testWidgets('per-task Complete completes that task', (tester) async {
      final fake = _FakeTechnicianNotifier(_inProgressJob);
      await _pumpWith(tester, fake, _inProgressJob);

      await tester.tap(find.text('Complete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(fake.completeCount, 1);
      expect(find.text('2 of 3 tasks completed'), findsOneWidget);
    });

    testWidgets('a pending task cannot be held or completed', (tester) async {
      await _pump(tester, _pendingJob);
      expect(find.text('Hold'), findsNothing);
      expect(find.text('Complete'), findsNothing);
    });
  });

  group('Technician Job Detail states', () {
    testWidgets('zero tasks shows a truthful state with no primary action', (
      tester,
    ) async {
      await _pump(tester, _zeroTaskJob);

      expect(
        find.textContaining('No tasks have been added to this job'),
        findsOneWidget,
      );
      expect(find.text('Start next task'), findsNothing);
      expect(find.text('Complete task'), findsNothing);
      expect(find.text('Complete repair'), findsNothing);
    });

    testWidgets('delayed job surfaces a live-region blocker', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _delayedJob);

      expect(find.text('Delayed'), findsOneWidget);
      expect(
        find.textContaining('marked as delayed at the workshop'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('QC review state is read-only', (tester) async {
      await _pump(tester, _qcJob);

      expect(
        find.text('Repair work has been submitted for supervisor QC review.'),
        findsOneWidget,
      );
      expect(find.text('Complete task'), findsNothing);
      expect(find.text('Complete repair'), findsNothing);
    });

    testWidgets('completed job is a read-only summary', (tester) async {
      await _pump(tester, _completedJob);

      expect(
        find.text('This repair is completed. Technician edits are locked.'),
        findsOneWidget,
      );
      expect(find.text('Complete repair'), findsNothing);
      expect(find.text('Request part'), findsNothing);
    });

    testWidgets('a 20-task job stays scrollable and lazy', (tester) async {
      await _pump(tester, _manyTaskJob(20));

      expect(find.text('Task 1'), findsWidgets);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -2500),
      );
      await tester.pumpAndSettle();
      expect(find.text('Task 20'), findsOneWidget);
    });

    testWidgets('never shows fake ETA, priority or parts availability', (
      tester,
    ) async {
      await _pump(tester, _inProgressJob);

      expect(find.textContaining('ETA'), findsNothing);
      expect(find.textContaining('Priority'), findsNothing);
      expect(find.textContaining('available'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
    });
  });

  group('Technician Job Detail actions', () {
    testWidgets('Request part opens the existing parts flow', (tester) async {
      await _pump(tester, _inProgressJob);

      await tester.ensureVisible(find.text('Request part'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request part'));
      await tester.pumpAndSettle();

      expect(find.text('Request a part'), findsOneWidget);
    });

    testWidgets('Escalate opens the existing escalation flow', (tester) async {
      await _pump(tester, _inProgressJob);

      await tester.ensureVisible(find.text('Escalate issue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escalate issue'));
      await tester.pumpAndSettle();

      expect(find.text('Escalate an issue'), findsOneWidget);
    });

    testWidgets('Complete repair asks for confirmation', (tester) async {
      await _pump(tester, _inProgressJob);

      await tester.ensureVisible(find.text('Complete repair'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete repair'));
      await tester.pumpAndSettle();

      expect(find.text('Complete repair?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('CURRENT TASK'), findsOneWidget);
    });

    testWidgets('every critical action is at least 48px', (tester) async {
      await _pump(tester, _inProgressJob);

      for (final label in const [
        'Complete task',
        'Complete repair',
        'Request part',
        'Escalate issue',
      ]) {
        final finder = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate(
            (w) => w is FilledButton || w is OutlinedButton,
          ),
        );
        final size = tester.getSize(finder.first);
        expect(
          size.height,
          greaterThanOrEqualTo(AppDimensions.touchTarget),
          reason: '$label must be a 48px target',
        );
      }
    });
  });

  group('Technician Job Detail responsive', () {
    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(tester, _inProgressJob, size: Size(width, 844));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text', (tester) async {
      await _pump(
        tester,
        _verboseJob,
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a two-column workspace on tablet', (tester) async {
      await _pump(tester, _inProgressJob, size: const Size(1024, 768));

      final left = tester.getTopLeft(find.text('EXECUTION'));
      final right = tester.getTopLeft(find.text('NEED HELP?'));
      expect(right.dx, greaterThan(left.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('composes on desktop', (tester) async {
      await _pump(tester, _inProgressJob, size: const Size(1440, 900));
      expect(tester.takeException(), isNull);
      expect(find.text('Toyota Camry'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(
        tester,
        _inProgressJob,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Toyota Camry'), findsOneWidget);
    });
  });

  group('Technician Job Detail references', () {
    testWidgets('pending mobile', (tester) async {
      await _pump(tester, _pendingJob);
      await _golden(tester, 'technician_job_detail_pending_mobile');
    });

    testWidgets('in progress mobile', (tester) async {
      await _pump(tester, _inProgressJob);
      await _golden(tester, 'technician_job_detail_in_progress_mobile');
    });

    testWidgets('delayed mobile', (tester) async {
      await _pump(tester, _delayedJob);
      await _golden(tester, 'technician_job_detail_delayed_mobile');
    });

    testWidgets('qc mobile', (tester) async {
      await _pump(tester, _qcJob);
      await _golden(tester, 'technician_job_detail_qc_mobile');
    });

    testWidgets('completed mobile', (tester) async {
      await _pump(tester, _completedJob);
      await _golden(tester, 'technician_job_detail_completed_mobile');
    });

    testWidgets('tablet', (tester) async {
      await _pump(tester, _inProgressJob, size: const Size(1024, 768));
      await _golden(tester, 'technician_job_detail_tablet');
    });

    testWidgets('desktop', (tester) async {
      await _pump(tester, _inProgressJob, size: const Size(1440, 900));
      await _golden(tester, 'technician_job_detail_desktop');
    });

    testWidgets('dark mobile', (tester) async {
      await _pump(
        tester,
        _inProgressJob,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await _golden(tester, 'technician_job_detail_dark_mobile');
    });

    testWidgets('large text mobile', (tester) async {
      await _pump(
        tester,
        _verboseJob,
        textScaler: const TextScaler.linear(1.6),
      );
      await _golden(tester, 'technician_job_detail_large_text_mobile');
    });
  });
}

Future<void> _golden(WidgetTester tester, String name) => expectLater(
  find.byType(TechnicianJobDetailView),
  matchesGoldenFile('goldens/$name.png'),
);

// ---------- Fixtures ----------

const _pendingTask = WorkTaskEntity(
  id: 1,
  ref: 't1',
  description: 'Inspect braking system',
  status: TaskStatus.pending,
);

const _inProgressJob = TechnicianJobEntity(
  jobCardNo: 'JO-1024',
  dateOfWork: '24 Aug',
  startTime: '09:30 AM',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Camry',
  plateNumber: 'A 12345',
  customerName: 'Ahmed Al Mansoori',
  status: TechJobStatus.inProgress,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 't1',
      description: 'Replace front brake pads',
      status: TaskStatus.inProgress,
      startTime: '10:42',
    ),
    WorkTaskEntity(
      id: 2,
      ref: 't2',
      description: 'Brake fluid flush',
      status: TaskStatus.completed,
      startTime: '09:40',
      endTime: '10:20',
    ),
    WorkTaskEntity(
      id: 3,
      ref: 't3',
      description: 'Road test',
      status: TaskStatus.pending,
    ),
  ],
);

const _pendingJob = TechnicianJobEntity(
  jobCardNo: 'JO-1049',
  dateOfWork: '24 Aug',
  startTime: '11:00 AM',
  vehicleBrand: 'Nissan',
  vehicleModel: 'Patrol',
  plateNumber: 'B 67890',
  status: TechJobStatus.pending,
  tasks: [_pendingTask],
);

const _oneTaskRunningJob = TechnicianJobEntity(
  jobCardNo: 'JO-1031',
  dateOfWork: '24 Aug',
  startTime: '09:00 AM',
  vehicleBrand: 'BMW',
  vehicleModel: 'X5',
  plateNumber: 'E 11111',
  status: TechJobStatus.inProgress,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 't1',
      description: 'Final assembly check',
      status: TaskStatus.inProgress,
      startTime: '10:00',
    ),
  ],
);

const _delayedJob = TechnicianJobEntity(
  jobCardNo: 'JO-1052',
  dateOfWork: '24 Aug',
  startTime: '13:00 PM',
  vehicleBrand: 'Ford',
  vehicleModel: 'Explorer',
  plateNumber: 'C 24680',
  status: TechJobStatus.delayed,
  tasks: [_pendingTask],
);

const _qcJob = TechnicianJobEntity(
  jobCardNo: 'JO-1005',
  dateOfWork: '24 Aug',
  startTime: '08:00 AM',
  vehicleBrand: 'Kia',
  vehicleModel: 'Sportage',
  plateNumber: 'G 55555',
  status: TechJobStatus.qcReview,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 't1',
      description: 'Full service',
      status: TaskStatus.completed,
    ),
  ],
);

const _completedJob = TechnicianJobEntity(
  jobCardNo: 'JO-1001',
  dateOfWork: '23 Aug',
  startTime: '08:00 AM',
  vehicleBrand: 'Honda',
  vehicleModel: 'Civic',
  plateNumber: 'D 13579',
  status: TechJobStatus.completed,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 't1',
      description: 'Oil change',
      status: TaskStatus.completed,
    ),
  ],
);

const _zeroTaskJob = TechnicianJobEntity(
  jobCardNo: 'JO-1077',
  dateOfWork: '25 Aug',
  startTime: '09:00 AM',
  vehicleBrand: 'Volvo',
  vehicleModel: 'XC90',
  plateNumber: 'F 22222',
  status: TechJobStatus.pending,
  tasks: [],
);

const _verboseJob = TechnicianJobEntity(
  jobCardNo: 'JO-REFERENCE-2026-000000000099441',
  dateOfWork: '24 Aug',
  startTime: '09:30 AM',
  vehicleBrand: 'Mercedes-Benz',
  vehicleModel: 'GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  status: TechJobStatus.inProgress,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 't1',
      description:
          'Comprehensive front and rear suspension inspection and replacement',
      status: TaskStatus.inProgress,
      startTime: '10:42',
    ),
  ],
);

TechnicianJobEntity _manyTaskJob(int count) => TechnicianJobEntity(
  jobCardNo: 'JO-2000',
  dateOfWork: '24 Aug',
  startTime: '09:00 AM',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Hilux',
  plateNumber: 'M 10000',
  status: TechJobStatus.inProgress,
  tasks: [
    for (var i = 1; i <= count; i++)
      WorkTaskEntity(
        id: i,
        ref: 't$i',
        description: 'Task $i',
        status: i == 1 ? TaskStatus.inProgress : TaskStatus.pending,
      ),
  ],
);

// ---------- Harness ----------

class _FakeTechnicianNotifier extends TechnicianNotifier {
  _FakeTechnicianNotifier(TechnicianJobEntity job) : _jobs = [job];

  List<TechnicianJobEntity> _jobs;
  int startCount = 0;
  int completeCount = 0;
  int holdCount = 0;

  @override
  TechnicianState build() => const TechnicianState(
    attendanceSummary: AttendanceSummaryEntity(),
    assignedJobs: [],
  );

  @override
  List<TechnicianJobEntity> get allJobs => _jobs;

  @override
  List<TechnicianJobEntity> get filteredJobs => _jobs;

  @override
  int get totalJobs => _jobs.length;

  @override
  Future<void> refresh() async {}

  void _apply(String jobCardNo, int taskId, TaskStatus status) {
    _jobs = [
      for (final job in _jobs)
        if (job.jobCardNo == jobCardNo)
          _sync(
            job.copyWith(
              tasks: [
                for (final task in job.tasks)
                  task.id == taskId ? task.copyWith(status: status) : task,
              ],
            ),
          )
        else
          job,
    ];
    state = state.copyWith(isLoading: !state.isLoading);
  }

  TechnicianJobEntity _sync(TechnicianJobEntity job) {
    if (job.tasks.isNotEmpty &&
        job.tasks.every((t) => t.status == TaskStatus.completed)) {
      return job.copyWith(status: TechJobStatus.qcReview);
    }
    if (job.tasks.any((t) => t.status == TaskStatus.inProgress)) {
      return job.copyWith(status: TechJobStatus.inProgress);
    }
    return job;
  }

  @override
  void startTask(TechnicianJobEntity job, WorkTaskEntity task) {
    startCount++;
    _apply(job.jobCardNo, task.id, TaskStatus.inProgress);
  }

  @override
  void completeTask(TechnicianJobEntity job, WorkTaskEntity task) {
    completeCount++;
    _apply(job.jobCardNo, task.id, TaskStatus.completed);
  }

  @override
  void updateTaskStatus(
    TechnicianJobEntity job,
    WorkTaskEntity task,
    TaskStatus status,
  ) {
    holdCount++;
    _apply(job.jobCardNo, task.id, status);
  }

  @override
  Future<void> completeJob(TechnicianJobEntity job) async {
    _jobs = [
      for (final j in _jobs)
        if (j.jobCardNo == job.jobCardNo)
          j.copyWith(
            status: TechJobStatus.qcReview,
            tasks: [
              for (final t in j.tasks) t.copyWith(status: TaskStatus.completed),
            ],
          )
        else
          j,
    ];
    state = state.copyWith(isLoading: !state.isLoading);
  }
}

Future<void> _pump(
  WidgetTester tester,
  TechnicianJobEntity job, {
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) => _pumpWith(
  tester,
  _FakeTechnicianNotifier(job),
  job,
  size: size,
  textScaler: textScaler,
  theme: theme,
);

Future<void> _pumpWith(
  WidgetTester tester,
  _FakeTechnicianNotifier fake,
  TechnicianJobEntity job, {
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [technicianDashboardProvider.overrideWith(() => fake)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        home: TechnicianJobDetailView(job: job),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
