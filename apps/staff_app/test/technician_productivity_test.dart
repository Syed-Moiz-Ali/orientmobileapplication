import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_productivity_view.dart';

void main() {
  setUpAll(_loadFonts);

  group('Technician Productivity metrics', () {
    testWidgets('shows real work completed and task progress', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        tasksDone: 3,
        tasksTotal: 5,
      );

      expect(find.text('WORK COMPLETED'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
      expect(find.text('repairs completed today'), findsOneWidget);
      expect(find.text('3 of 5 tasks completed'), findsOneWidget);
    });

    testWidgets('breaks the queue down by real status', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        tasksDone: 3,
        tasksTotal: 5,
      );

      expect(find.text('YOUR QUEUE'), findsOneWidget);
      expect(find.text('5 assigned'), findsOneWidget);

      for (final label in const [
        'In progress',
        'Pending',
        'Delayed',
        'QC review',
        'Completed',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      // Delayed = 1, Completed = 2 (real counts from the loaded queue).
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('shows the real shift record and clock control', (
      tester,
    ) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 1,
        attendance: AttendanceStatus.working,
      );

      expect(find.text('SHIFT'), findsOneWidget);
      expect(find.text('Working'), findsOneWidget);
      expect(find.text('Clocked in'), findsOneWidget);
      expect(find.text('Take break'), findsOneWidget);
      expect(find.text('End shift'), findsOneWidget);
    });

    testWidgets('uses truthful time-range wording', (tester) async {
      await _pump(tester, _jobs, completedToday: 2);
      expect(find.text("Today's productivity"), findsOneWidget);
      expect(find.textContaining('This week'), findsNothing);
      expect(find.textContaining('This month'), findsNothing);
    });

    testWidgets('never shows fabricated scoring or analytics', (tester) async {
      await _pump(tester, _jobs, completedToday: 3);

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final forbidden in const [
        'efficiency',
        'performance score',
        'score',
        'rank',
        'target',
        'goal',
        'sla',
        'utilization',
        'average repair',
        'avg repair',
        'customer rating',
        'top performer',
        'best technician',
      ]) {
        expect(texts.contains(forbidden), isFalse, reason: forbidden);
      }
      // No chart was added: the page is counts only.
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('handles large real counts', (tester) async {
      await _pump(tester, _manyJobs(64), completedToday: 128);
      expect(find.text('128'), findsWidgets);
      expect(find.text('64 assigned'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Technician Productivity states', () {
    testWidgets('shows the zero-data state', (tester) async {
      await _pump(tester, const [], completedToday: 0);
      expect(find.text('No productivity data yet'), findsOneWidget);
    });

    testWidgets('shows a skeleton while loading, not zeros', (tester) async {
      await _pump(tester, const [], loading: true);
      expect(find.byType(AppSkeleton), findsWidgets);
      expect(find.text('No productivity data yet'), findsNothing);
    });

    testWidgets('offers Retry when the first load fails', (tester) async {
      await _pump(tester, const [], error: 'offline');
      expect(find.text("We couldn't load your productivity"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('a refresh error retains the metrics', (tester) async {
      await _pump(tester, _jobs, completedToday: 3, error: 'offline');
      expect(find.text('WORK COMPLETED'), findsOneWidget);
      expect(find.text('offline'), findsOneWidget);
    });
  });

  group('Technician Productivity responsive', () {
    for (final width in const [320.0, 360.0, 390.0, 430.0]) {
      testWidgets('no overflow at ${width.toInt()}px', (tester) async {
        await _pump(
          tester,
          _jobs,
          completedToday: 3,
          tasksDone: 3,
          tasksTotal: 5,
          size: Size(width, 844),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('survives 1.6x text', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 128,
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a two-column workspace on tablet', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        size: const Size(1024, 768),
      );
      final left = tester.getTopLeft(find.text('WORK COMPLETED'));
      final right = tester.getTopLeft(find.text('SHIFT'));
      expect(right.dx, greaterThan(left.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('composes on desktop', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        size: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('WORK COMPLETED'), findsOneWidget);
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('WORK COMPLETED'), findsOneWidget);
    });
  });

  group('Technician Productivity references', () {
    Future<void> golden(WidgetTester tester, String name) => expectLater(
      find.byType(TechnicianProductivityView),
      matchesGoldenFile('goldens/$name.png'),
    );

    testWidgets('mobile', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        tasksDone: 3,
        tasksTotal: 5,
      );
      await golden(tester, 'technician_productivity_mobile');
    });

    testWidgets('empty mobile', (tester) async {
      await _pump(tester, const [], completedToday: 0);
      await golden(tester, 'technician_productivity_empty_mobile');
    });

    testWidgets('tablet', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        tasksDone: 3,
        tasksTotal: 5,
        size: const Size(1024, 768),
      );
      await golden(tester, 'technician_productivity_tablet');
    });

    testWidgets('desktop', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        tasksDone: 3,
        tasksTotal: 5,
        size: const Size(1440, 900),
      );
      await golden(tester, 'technician_productivity_desktop');
    });

    testWidgets('dark mobile', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 3,
        tasksDone: 3,
        tasksTotal: 5,
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await golden(tester, 'technician_productivity_dark_mobile');
    });

    testWidgets('large text mobile', (tester) async {
      await _pump(
        tester,
        _jobs,
        completedToday: 128,
        tasksDone: 3,
        tasksTotal: 5,
        textScaler: const TextScaler.linear(1.6),
      );
      await golden(tester, 'technician_productivity_large_text_mobile');
    });
  });
}

// ---------- Fixtures ----------

TechnicianJobEntity _job(
  String ref,
  TechJobStatus status, {
  int done = 0,
  int total = 0,
}) => TechnicianJobEntity(
  jobCardNo: ref,
  dateOfWork: '24 Aug',
  startTime: '09:00 AM',
  vehicleBrand: 'Toyota',
  vehicleModel: 'Model $ref',
  plateNumber: 'P $ref',
  status: status,
  tasks: [
    for (var i = 0; i < total; i++)
      WorkTaskEntity(
        id: i + 1,
        ref: 't$i',
        description: 'Task $i',
        status: i < done ? TaskStatus.completed : TaskStatus.pending,
      ),
  ],
);

final _jobs = <TechnicianJobEntity>[
  _job('JO-1', TechJobStatus.completed, done: 2, total: 2),
  _job('JO-2', TechJobStatus.completed, done: 1, total: 2),
  _job('JO-3', TechJobStatus.inProgress, done: 0, total: 1),
  _job('JO-4', TechJobStatus.delayed, done: 0, total: 0),
  _job('JO-5', TechJobStatus.qcReview, done: 0, total: 0),
];

List<TechnicianJobEntity> _manyJobs(int count) => [
  for (var i = 1; i <= count; i++) _job('JO-$i', TechJobStatus.pending),
];

// ---------- Harness ----------

class _FakeTechnicianNotifier extends TechnicianNotifier {
  _FakeTechnicianNotifier(
    this._jobs, {
    this.completedToday = 0,
    this.loading = false,
    this.error = '',
    this.attendance = AttendanceStatus.notPunchedIn,
  });

  final List<TechnicianJobEntity> _jobs;
  final int completedToday;
  final bool loading;
  final String error;
  final AttendanceStatus attendance;

  @override
  TechnicianState build() => TechnicianState(
    isLoading: loading,
    dashboardError: error,
    attendanceStatus: attendance,
    attendanceSummary: const AttendanceSummaryEntity(),
    assignedJobs: const [],
  );

  @override
  List<TechnicianJobEntity> get allJobs => _jobs;

  @override
  List<({TechnicianJobEntity job, WorkTaskEntity task})> get allTasks => [
    for (final job in _jobs)
      for (final task in job.tasks) (job: job, task: task),
  ];

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
}

Future<void> _pump(
  WidgetTester tester,
  List<TechnicianJobEntity> jobs, {
  int completedToday = 0,
  int? tasksDone,
  int? tasksTotal,
  bool loading = false,
  String error = '',
  AttendanceStatus attendance = AttendanceStatus.notPunchedIn,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final fake = _FakeTechnicianNotifier(
    jobs,
    completedToday: completedToday,
    loading: loading,
    error: error,
    attendance: attendance,
  );
  fake.productivity = TechnicianStatsEntity(
    assignedJobs: jobs.length,
    inProgress: 0,
    completedToday: completedToday,
    efficiency: 0,
    avgTimePerJob: '',
    totalHoursWorked: '',
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [technicianDashboardProvider.overrideWith(() => fake)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        home: const Scaffold(body: TechnicianProductivityView()),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
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
