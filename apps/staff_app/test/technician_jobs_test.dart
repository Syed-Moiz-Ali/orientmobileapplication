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
import 'package:staff_app/features/technician/presentation/widgets/technician_jobs_view.dart';

void main() {
  setUpAll(_loadFonts);

  group('Technician Jobs queue', () {
    testWidgets('renders real assigned jobs with identity and progress', (
      tester,
    ) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.textContaining('A 12345'), findsOneWidget);
      expect(find.textContaining('JO-1024'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsWidgets);
      expect(find.text('3 of 5 tasks completed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('zero tasks shows no decorative progress', (tester) async {
      await _pump(tester, jobs: const [_zeroTaskJob]);

      expect(find.textContaining('tasks completed'), findsNothing);
      expect(find.textContaining('%'), findsNothing);
      expect(find.text('Volvo XC90'), findsOneWidget);
    });

    testWidgets('exposes the canonical status filters with real counts', (
      tester,
    ) async {
      await _pump(
        tester,
        jobs: const [
          _inProgressJob,
          _pendingJob,
          _delayedJob,
          _qcJob,
          _completedJob,
        ],
      );

      for (final label in const [
        'All',
        'Pending',
        'In Progress',
        'Delayed',
        'QC Review',
        'Completed',
      ]) {
        expect(find.text(label), findsWidgets, reason: 'missing filter $label');
      }
      // All = 5 real jobs.
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('filters the queue by a real status', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob, _delayedJob],
      );

      await tester.tap(find.text('Delayed'));
      await tester.pumpAndSettle();

      expect(find.text('Ford Explorer'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsNothing);
      expect(find.text('Nissan Patrol'), findsNothing);
    });
  });

  group('Technician Jobs search', () {
    testWidgets('searches by vehicle', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);

      await tester.enterText(find.byType(TextField), 'Nissan');
      await tester.pumpAndSettle();

      expect(find.text('Nissan Patrol'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsNothing);
    });

    testWidgets('searches by plate, tolerating formatting', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);

      await tester.enterText(find.byType(TextField), 'a12345');
      await tester.pumpAndSettle();

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('Nissan Patrol'), findsNothing);
    });

    testWidgets('searches by job reference, case-insensitively', (
      tester,
    ) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);

      await tester.enterText(find.byType(TextField), 'jo-1049');
      await tester.pumpAndSettle();

      expect(find.text('Nissan Patrol'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsNothing);
    });

    testWidgets('combines search and status filter', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob, _delayedJob],
      );

      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'patrol');
      await tester.pumpAndSettle();

      expect(find.text('Nissan Patrol'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsNothing);
      expect(find.text('Ford Explorer'), findsNothing);
    });

    testWidgets('clearing filters restores the full queue', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No matching jobs'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('Nissan Patrol'), findsOneWidget);
    });
  });

  group('Technician Jobs states', () {
    testWidgets('shows a filtered-empty state distinct from global empty', (
      tester,
    ) async {
      await _pump(tester, jobs: const [_inProgressJob]);

      await tester.enterText(find.byType(TextField), 'no-such-job');
      await tester.pumpAndSettle();

      expect(find.text('No matching jobs'), findsOneWidget);
      expect(find.text('No assigned jobs'), findsNothing);
    });

    testWidgets('shows a truthful global empty state', (tester) async {
      await _pump(tester, jobs: const []);

      expect(find.text('No assigned jobs'), findsOneWidget);
      expect(
        find.text('There are no jobs assigned to you right now.'),
        findsOneWidget,
      );
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('shows job skeletons while loading', (tester) async {
      await _pump(tester, jobs: const [], loading: true);
      expect(find.byType(AppSkeleton), findsWidgets);
      expect(find.text('No assigned jobs'), findsNothing);
    });

    testWidgets('offers Retry when the first load fails', (tester) async {
      await _pump(tester, jobs: const [], error: 'offline');

      expect(find.text("We couldn't load your jobs"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('a refresh error retains the loaded jobs', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob], error: 'offline');

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
    });

    testWidgets('renders delayed, QC and completed states', (tester) async {
      await _pump(tester, jobs: const [_delayedJob, _qcJob, _completedJob]);

      expect(find.text('DELAYED'), findsWidgets);
      expect(find.text('QC REVIEW'), findsWidgets);
      expect(find.text('COMPLETED'), findsWidgets);
    });

    testWidgets('never shows fake priority, ETA or parts data', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob, _delayedJob, _qcJob],
      );

      expect(find.textContaining('ETA'), findsNothing);
      expect(find.textContaining('Priority'), findsNothing);
      expect(find.textContaining('Part'), findsNothing);
      expect(find.textContaining('mins'), findsNothing);
    });
  });

  group('Technician Jobs navigation', () {
    testWidgets('a job row opens the Job Detail flow', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob], router: true);

      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();

      expect(find.text('JOB_DETAIL'), findsOneWidget);
    });
  });

  group('Technician Jobs large list', () {
    testWidgets('a 30-item queue stays lazy and scrollable', (tester) async {
      await _pump(tester, jobs: _manyJobs(30));

      expect(find.textContaining('JO-0001'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(find.textContaining('JO-0030'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Technician Jobs responsive and accessibility', () {
    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(
          tester,
          jobs: const [_inProgressJob, _pendingJob, _delayedJob, _qcJob],
          size: Size(width, 844),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text scale', (tester) async {
      await _pump(
        tester,
        jobs: const [_verboseJob, _pendingJob],
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('composes on tablet and desktop', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob],
        size: const Size(1024, 768),
      );
      expect(tester.takeException(), isNull);

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

    testWidgets('keeps rows and filters at 48px or more', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob]);

      final rows = tester.widgetList(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label ?? '').startsWith('Open JO-'),
        ),
      );
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(
          tester.getSize(find.byWidget(row)).height,
          greaterThanOrEqualTo(AppDimensions.touchTarget),
        );
      }
      // The selected "All" filter chip is a 48px target.
      final allChip = find.ancestor(
        of: find.text('All'),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getSize(allChip.first).height,
        greaterThanOrEqualTo(AppDimensions.touchTarget),
      );
    });
  });

  group('Technician Jobs references', () {
    testWidgets('mixed mobile', (tester) async {
      await _pump(
        tester,
        jobs: const [
          _inProgressJob,
          _pendingJob,
          _delayedJob,
          _qcJob,
          _completedJob,
        ],
      );
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_mixed_mobile.png'),
      );
    });

    testWidgets('search mobile', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);
      await tester.enterText(find.byType(TextField), 'nissan');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_search_mobile.png'),
      );
    });

    testWidgets('filtered empty mobile', (tester) async {
      await _pump(tester, jobs: const [_inProgressJob, _pendingJob]);
      await tester.enterText(find.byType(TextField), 'nothing-here');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_filtered_empty_mobile.png'),
      );
    });

    testWidgets('empty mobile', (tester) async {
      await _pump(tester, jobs: const []);
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_empty_mobile.png'),
      );
    });

    testWidgets('tablet', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob, _delayedJob],
        size: const Size(1024, 768),
      );
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_tablet.png'),
      );
    });

    testWidgets('desktop', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob, _delayedJob],
        size: const Size(1440, 900),
      );
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_desktop.png'),
      );
    });

    testWidgets('dark mobile', (tester) async {
      await _pump(
        tester,
        jobs: const [_inProgressJob, _pendingJob, _delayedJob],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_dark_mobile.png'),
      );
    });

    testWidgets('large text mobile', (tester) async {
      await _pump(
        tester,
        jobs: const [_verboseJob, _pendingJob],
        textScaler: const TextScaler.linear(1.6),
      );
      await expectLater(
        find.byType(TechnicianJobsView),
        matchesGoldenFile('goldens/technician_jobs_large_text_mobile.png'),
      );
    });
  });
}

// ---------- Fixtures (real entity shapes only) ----------

TechnicianJobEntity _job({
  required String ref,
  required String brand,
  required String model,
  required String plate,
  required TechJobStatus status,
  int done = 0,
  int total = 0,
  String customer = '',
}) => TechnicianJobEntity(
  jobCardNo: ref,
  dateOfWork: '24 Aug',
  startTime: '09:30 AM',
  vehicleBrand: brand,
  vehicleModel: model,
  plateNumber: plate,
  customerName: customer,
  status: status,
  tasks: [
    for (var i = 0; i < total; i++)
      WorkTaskEntity(
        id: i + 1,
        ref: 'task-${i + 1}',
        description: 'Task ${i + 1}',
        status: i < done ? TaskStatus.completed : TaskStatus.pending,
      ),
  ],
);

const _inProgressJob = TechnicianJobEntity(
  jobCardNo: 'JO-1024',
  dateOfWork: '24 Aug',
  startTime: '09:30 AM',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Camry',
  plateNumber: 'A 12345',
  status: TechJobStatus.inProgress,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 'i-1',
      description: 'Task 1',
      status: TaskStatus.completed,
    ),
    WorkTaskEntity(
      id: 2,
      ref: 'i-2',
      description: 'Task 2',
      status: TaskStatus.completed,
    ),
    WorkTaskEntity(
      id: 3,
      ref: 'i-3',
      description: 'Task 3',
      status: TaskStatus.completed,
    ),
    WorkTaskEntity(
      id: 4,
      ref: 'i-4',
      description: 'Task 4',
      status: TaskStatus.inProgress,
    ),
    WorkTaskEntity(
      id: 5,
      ref: 'i-5',
      description: 'Task 5',
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
      id: 1,
      ref: 'p-1',
      description: 'Run diagnostics',
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
      id: 1,
      ref: 'd-1',
      description: 'Replace alternator',
      status: TaskStatus.pending,
    ),
  ],
);

const _qcJob = TechnicianJobEntity(
  jobCardNo: 'JO-1031',
  dateOfWork: '24 Aug',
  startTime: '10:00 AM',
  vehicleBrand: 'BMW',
  vehicleModel: 'X5',
  plateNumber: 'E 11111',
  status: TechJobStatus.qcReview,
  tasks: [
    WorkTaskEntity(
      id: 1,
      ref: 'q-1',
      description: 'Final inspection',
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
      ref: 'c-1',
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
      ref: 'v-1',
      description: 'Comprehensive inspection',
      status: TaskStatus.inProgress,
    ),
  ],
);

List<TechnicianJobEntity> _manyJobs(int count) => [
  for (var i = 1; i <= count; i++)
    _job(
      ref: 'JO-${i.toString().padLeft(4, '0')}',
      brand: 'Toyota',
      model: 'Model $i',
      plate: 'P $i',
      status: TechJobStatus.pending,
      done: 0,
      total: 2,
    ),
];

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

  static String _norm(String value) =>
      value.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();

  @override
  List<TechnicianJobEntity> get allJobs => _jobs;

  @override
  List<TechnicianJobEntity> get filteredJobs => _jobs.where((j) {
    final q = state.searchQuery.trim();
    final matchSearch =
        q.isEmpty ||
        j.jobCardNo.toLowerCase().contains(q) ||
        j.vehicleBrand.toLowerCase().contains(q) ||
        j.vehicleModel.toLowerCase().contains(q) ||
        j.customerName.toLowerCase().contains(q) ||
        (q.isNotEmpty && _norm(j.plateNumber).contains(_norm(q)));
    final matchFilter =
        state.selectedFilter == 'All' || j.status.label == state.selectedFilter;
    return matchSearch && matchFilter;
  }).toList();

  @override
  int get totalJobs => _jobs.length;

  @override
  int get inProgressJobs =>
      _jobs.where((j) => j.status == TechJobStatus.inProgress).length;

  @override
  int get completedJobs =>
      _jobs.where((j) => j.status == TechJobStatus.completed).length;

  @override
  int get delayedJobs =>
      _jobs.where((j) => j.status == TechJobStatus.delayed).length;

  @override
  Future<void> refresh() async {}

  @override
  void updateSearch(String query) =>
      state = state.copyWith(searchQuery: query.toLowerCase());

  @override
  void updateFilter(String filter) =>
      state = state.copyWith(selectedFilter: filter);
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
            builder: (_, __) => const Scaffold(body: TechnicianJobsView()),
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
      home: const Scaffold(body: TechnicianJobsView()),
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
