import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_today_view.dart';

void main() {
  setUpAll(_loadFonts);

  group('Technician Today execution states', () {
    testWidgets(
      'renders the active job with real vehicle, reference and plate',
      (tester) async {
        await _pump(tester, jobs: const [_inProgressJob]);

        expect(find.text('CURRENT WORK'), findsOneWidget);
        expect(find.text('On the bay'), findsOneWidget);
        expect(find.text('Toyota Camry'), findsOneWidget);
        expect(find.text('A 12345'), findsOneWidget);
        expect(find.text('JO-1024'), findsOneWidget);
        expect(find.text('IN PROGRESS'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('shows task-derived progress and the current task', (
      tester,
    ) async {
      await _pump(tester, jobs: const [_inProgressJob]);

      expect(find.text('1 of 3 tasks completed'), findsOneWidget);
      expect(find.text('Replace front brake pads'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('a running task offers Complete task', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob]);
      expect(find.text('Complete task'), findsOneWidget);
    });

    testWidgets('pending work offers Start next task', (tester) async {
      await _pump(tester, jobs: const [_pendingJob]);
      expect(find.text('Start next task'), findsOneWidget);
    });

    testWidgets('shows the real shift control', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob]);
      expect(find.text('Start shift'), findsOneWidget);
    });

    testWidgets('an in-progress job shows no blocker', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob]);
      expect(find.text('Job on hold'), findsNothing);
    });

    testWidgets('a delayed job spells out the real blocker', (tester) async {
      await _pump(tester, jobs: const [_delayedJob]);
      expect(find.text('Job on hold'), findsOneWidget);
      expect(
        find.text('This repair is marked delayed at the workshop.'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty current work when only finished jobs remain', (
      tester,
    ) async {
      await _pump(tester, jobs: const [_completedJob]);

      expect(find.text('No active repair right now'), findsOneWidget);
      expect(find.text('Queue clear'), findsOneWidget);
    });

    testWidgets('shows a compact empty state when nothing is assigned', (
      tester,
    ) async {
      await _pump(tester, jobs: const []);

      expect(find.text('No assigned jobs right now'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('shows an operational skeleton while loading', (tester) async {
      await _pump(tester, jobs: const [], loading: true);

      expect(find.byType(AppSkeleton), findsWidgets);
      expect(find.text('No assigned jobs right now'), findsNothing);
    });

    testWidgets('offers a retry when the first load fails', (tester) async {
      await _pump(tester, jobs: const [], error: 'offline');

      expect(find.text("We couldn't load today's work"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('a refresh error retains the current work', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob], error: 'offline');

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
    });

    testWidgets('never invents progress, ETA or priority', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);

      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('ETA'), findsNothing);
      expect(find.textContaining('Priority'), findsNothing);
      expect(find.textContaining('mins'), findsNothing);
    });
  });

  group('Technician Today navigation', () {
    testWidgets('the current-job CTA opens the Job Detail flow', (
      tester,
    ) async {
      await _pump(tester, jobs: const [_inProgressJob], router: true);

      await tester.tap(find.text('Job details'));
      await tester.pumpAndSettle();

      expect(find.text('JOB_DETAIL'), findsOneWidget);
    });

    testWidgets('an upcoming job opens the same Job Detail flow', (
      tester,
    ) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        router: true,
      );

      await tester.tap(find.text('Nissan Patrol'));
      await tester.pumpAndSettle();

      expect(find.text('JOB_DETAIL'), findsOneWidget);
    });
  });

  group('Technician Today responsive and accessibility', () {
    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(
          tester,
          jobs: const [_inProgressJob, _pendingJob],
          size: Size(width, 844),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text scale', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Complete task'), findsOneWidget);
    });

    testWidgets('uses a two-column workspace on tablet', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        size: const Size(1024, 768),
      );

      final left = tester.getTopLeft(find.text('CURRENT WORK'));
      final right = tester.getTopLeft(find.text('UP NEXT'));
      expect(right.dx, greaterThan(left.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('composes cleanly on desktop', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        size: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Toyota Camry'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Toyota Camry'), findsOneWidget);
    });

    testWidgets('keeps every primary action at 48px or more', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob]);

      final buttons = tester
          .widgetList(
            find.byWidgetPredicate((widget) => widget is FilledButton),
          )
          .toList();
      expect(buttons, isNotEmpty);
      for (final button in buttons) {
        expect(
          tester.getSize(find.byWidget(button)).height,
          greaterThanOrEqualTo(AppDimensions.touchTarget),
        );
      }
    });
  });

  group('Technician Today references', () {
    testWidgets('active mobile', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_active_mobile.png'),
      );
    });

    testWidgets('no active mobile', (tester) async {
      await _pump(tester, jobs: const [_completedJob]);
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_no_active_mobile.png'),
      );
    });

    testWidgets('empty mobile', (tester) async {
      await _pump(tester, jobs: const []);
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_empty_mobile.png'),
      );
    });

    testWidgets('tablet', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        size: const Size(1024, 768),
      );
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_tablet.png'),
      );
    });

    testWidgets('desktop', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        size: const Size(1440, 900),
      );
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_desktop.png'),
      );
    });

    testWidgets('dark mobile', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_dark_mobile.png'),
      );
    });

    testWidgets('large text mobile', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        textScaler: const TextScaler.linear(1.6),
      );
      await expectLater(
        find.byType(TechnicianTodayView),
        matchesGoldenFile('goldens/technician_today_large_text_mobile.png'),
      );
    });
  });
}

// ---------- Fixtures (real entity shapes only) ----------

const _inProgressJob = TechnicianJobEntity(
  jobCardNo: 'JO-1024',
  dateOfWork: '24 Aug',
  startTime: '09:30 AM',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Camry',
  plateNumber: 'A 12345',
  customerName: 'Ahmed Al Mansoori',
  customerPhone: '+971 50 111 2233',
  status: TechJobStatus.inProgress,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 'task-1',
      description: 'Replace front brake pads',
      status: TaskStatus.inProgress,
      startTime: '10:42',
    ),
    WorkTaskEntity(
      id: 2,
      ref: 'task-2',
      description: 'Brake fluid flush',
      status: TaskStatus.completed,
    ),
    WorkTaskEntity(
      id: 3,
      ref: 'task-3',
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
  tasks: [
    WorkTaskEntity(
      id: 4,
      ref: 'task-4',
      description: 'Run engine diagnostics',
      status: TaskStatus.pending,
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
  tasks: [
    WorkTaskEntity(
      id: 5,
      ref: 'task-5',
      description: 'Replace alternator',
      status: TaskStatus.pending,
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
      id: 6,
      ref: 'task-6',
      description: 'Oil and filter change',
      status: TaskStatus.completed,
    ),
  ],
);

// ---------- Harness ----------

class _FakeTechnicianNotifier extends TechnicianNotifier {
  _FakeTechnicianNotifier(this._jobs, {this.loading = false, this.error = ''});

  final List<TechnicianJobEntity> _jobs;
  final bool loading;
  final String error;

  @override
  TechnicianState build() => TechnicianState(
    isLoading: loading,
    dashboardError: error,
    attendanceSummary: const AttendanceSummaryEntity(),
    assignedJobs: const [],
  );

  @override
  List<TechnicianJobEntity> get allJobs => _jobs;

  @override
  List<TechnicianJobEntity> get filteredJobs => _jobs;

  @override
  int get totalJobs => _jobs.length;

  @override
  int get inProgressJobs =>
      _jobs.where((j) => j.status == TechJobStatus.inProgress).length;

  @override
  int get completedJobs => _jobs
      .where(
        (j) =>
            j.status == TechJobStatus.completed ||
            j.status == TechJobStatus.qcReview,
      )
      .length;

  @override
  int get delayedJobs =>
      _jobs.where((j) => j.status == TechJobStatus.delayed).length;

  @override
  List<({TechnicianJobEntity job, WorkTaskEntity task})> get allTasks => [
    for (final job in _jobs)
      for (final task in job.tasks) (job: job, task: task),
  ];

  @override
  Future<void> refresh() async {}
}

Future<void> _pump(
  WidgetTester tester, {
  required List<TechnicianJobEntity> jobs,
  bool loading = false,
  String error = '',
  bool router = false,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final overrides = <Override>[
    technicianDashboardProvider.overrideWith(
      () => _FakeTechnicianNotifier(jobs, loading: loading, error: error),
    ),
  ];

  final Widget home;
  if (router) {
    home = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.light(BrandConfig.orient),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: TechnicianTodayView()),
          ),
          GoRoute(
            path: AppRoutes.technicianJobDetail,
            builder: (_, __) => const Scaffold(body: Text('JOB_DETAIL')),
          ),
        ],
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
    );
  } else {
    home = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.light(BrandConfig.orient),
      home: const Scaffold(body: TechnicianTodayView()),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
    );
  }

  await tester.pumpWidget(ProviderScope(overrides: overrides, child: home));
  if (loading) {
    await tester.pump();
  } else {
    await tester.pumpAndSettle();
  }
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
