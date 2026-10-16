import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/technician_dashboard_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 10 — console behavior: greeting shell, pinned banner, live
/// stopwatch, grease checklist toggles, QC handover and per-list states.
///
/// Timer contract under test: elapsed is display-only, derived from the
/// recorded `startTime` and the wall clock. Start / Hold / Complete / Resume
/// call the same notifier methods as production; the fake below mirrors the
/// provider's own status-sync rules without touching any backend.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Bounded settle: the banner and focus panel own a live 1s stopwatch tick
/// while a task runs, so pumpAndSettle would wait on its timer forever.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

const _runningJob = TechnicianJobEntity(
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
      ref: 'task-1',
      description: 'Replace front brake pads',
      status: TaskStatus.inProgress,
      startTime: '10:42',
    ),
    WorkTaskEntity(
      id: 2,
      ref: 'task-2',
      description: 'Road test',
      status: TaskStatus.pending,
    ),
  ],
);

const _heldJob = TechnicianJobEntity(
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
      status: TaskStatus.onHold,
      startTime: '13:20',
    ),
  ],
);

void main() {
  setUpAll(_loadFonts);
  // Auth session restore hits secure storage; unit tests have no plugin.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (_) async => null,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  group('Console shell', () {
    testWidgets('greeting owns identity with sync pill and actions',
        (tester) async {
      await _pumpDashboard(tester, jobs: const [_runningJob]);

      expect(find.text('Hello, Ahmed'), findsOneWidget);
      expect(find.text('Al Quoz · Morning'), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pinned banner carries job identity and live elapsed',
        (tester) async {
      await _pumpDashboard(tester, jobs: const [_runningJob]);

      expect(find.text('ACTIVE JOB'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('A 12345'), findsWidgets);
      // Live elapsed in H:MM:SS mono tabular.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.data != null &&
              RegExp(r'^\d+:\d{2}:\d{2}$').hasMatch(w.data!),
        ),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('banner pause holds the running task', (tester) async {
      final fake = _FakeTechnicianNotifier(const [_runningJob]);
      await _pumpDashboard(tester, fake: fake);

      await tester.tap(
        find.byTooltip('Pause'),
      );
      await _settle(tester);

      expect(fake.holdCount, 1);
      // The banner flips to the resume action once the task is held.
      expect(find.byTooltip('Resume'), findsOneWidget);
    });

    testWidgets('banner resume restarts a held task', (tester) async {
      final fake = _FakeTechnicianNotifier(const [_heldJob]);
      await _pumpDashboard(tester, fake: fake);

      await tester.tap(find.byTooltip('Resume'));
      await _settle(tester);

      expect(fake.startCount, 1);
    });

    testWidgets('banner dismiss hides it for the session', (tester) async {
      await _pumpDashboard(tester, jobs: const [_runningJob]);
      expect(find.text('ACTIVE JOB'), findsOneWidget);

      await tester.tap(find.byTooltip('Close').first);
      await _settle(tester);

      expect(find.text('ACTIVE JOB'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty queue shows the ready banner', (tester) async {
      await _pumpDashboard(tester, jobs: const []);

      expect(find.text('Ready for assignment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('banner tap opens the job dossier', (tester) async {
      await _pumpDashboard(
        tester,
        jobs: const [_runningJob],
        router: true,
      );

      await tester.tap(find.text('Toyota Camry').first);
      await _settle(tester);

      expect(find.text('JOB_DETAIL'), findsOneWidget);
    });
  });

  group('Stopwatch display', () {
    testWidgets('shows elapsed derived from the recorded start',
        (tester) async {
      await _pumpDetail(tester, _runningJob);

      // Live clock in H:MM:SS derived from startTime 10:42 today. The
      // ticker itself is not awaited here (a waiting test would hang the
      // runner on the 1s timer); derivation is what this asserts.
      String fmt(Duration d) =>
          '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, 10, 42);
      final diff = now.difference(start);
      final base = diff.isNegative ? Duration.zero : diff;
      final shown = _elapsedText(tester);
      expect(shown, isNotNull);
      expect(
        {fmt(base), fmt(base - const Duration(seconds: 1))}.contains(shown),
        isTrue,
        reason: 'elapsed $shown matches wall-clock derivation',
      );
    });

    testWidgets('paused shows the static start, never a live clock',
        (tester) async {
      await _pumpDetail(tester, _heldJob);

      expect(find.text('PAUSED'), findsWidgets);
      expect(find.text('Started 13:20'), findsWidgets);
      // No pause instant is recorded anywhere, so a held task shows its
      // static start — never a ticking clock.
      expect(_elapsedText(tester), isNull);
      await tester.pump(const Duration(seconds: 2));
      expect(_elapsedText(tester), isNull);
    });

    testWidgets('unstarted tasks show no readout', (tester) async {
      const job = TechnicianJobEntity(
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
      await _pumpDetail(tester, job);

      expect(find.byType(TechnicianStopwatch), findsNothing);
    });
  });

  group('Grease checklist and handover', () {
    testWidgets('row start action starts a pending task', (tester) async {
      final fake = _FakeTechnicianNotifier(const [_runningJob]);
      await _pumpDetailWith(tester, fake, _runningJob);

      // The pending 'Road test' row offers Start.
      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await _settle(tester);

      expect(fake.startCount, 1);
    });

    testWidgets('completing every task hands the job to QC', (tester) async {
      final fake = _FakeTechnicianNotifier(const [_runningJob]);
      await _pumpDetailWith(tester, fake, _runningJob);

      await tester.tap(find.text('Complete task'));
      await _settle(tester);
      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      await _settle(tester);
      await tester.ensureVisible(find.text('Complete'));
      await tester.tap(find.text('Complete'));
      await _settle(tester);

      expect(fake.completeCount, 2);
      expect(
        find.text('Repair work has been submitted for supervisor QC review.'),
        findsOneWidget,
      );
    });

    testWidgets('handover cancel keeps the technician on the job',
        (tester) async {
      final fake = _FakeTechnicianNotifier(const [_runningJob]);
      await _pumpDetailWith(tester, fake, _runningJob);

      await tester.ensureVisible(find.text('Complete repair'));
      await tester.tap(find.text('Complete repair'));
      await _settle(tester);
      expect(find.text('Complete repair?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await _settle(tester);

      expect(find.text('Complete repair?'), findsNothing);
      expect(find.text('CURRENT TASK'), findsOneWidget);
    });
  });

  group('Console states', () {    testWidgets('jobs tab shows no-match with clear', (tester) async {
      await _pumpDashboard(tester, jobs: const [_runningJob]);

      await tester.tap(find.text('Jobs'));
      await _settle(tester);
      await tester.enterText(find.byType(AppSearchField), 'zzz');
      await _settle(tester);

      expect(find.text('No matching jobs'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await _settle(tester);
      expect(find.text('Toyota Camry'), findsWidgets);
    });

    testWidgets('server figures strip renders only with backend data',
        (tester) async {
      final fake = _FakeTechnicianNotifier(const [_runningJob]);
      fake.productivity = const TechnicianStatsEntity(
        assignedJobs: 4,
        inProgress: 1,
        completedToday: 2,
        efficiency: 0.87,
        avgTimePerJob: '1h 20m',
        totalHoursWorked: '6h 10m',
      );
      await _pumpDashboard(tester, fake: fake);

      await tester.tap(find.text('Productivity'));
      await _settle(tester);

      expect(find.text('Efficiency'), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
      expect(find.text("Today's progress"), findsOneWidget);
    });

    testWidgets('no server figures means no strip', (tester) async {
      await _pumpDashboard(tester, jobs: const [_runningJob]);

      await tester.tap(find.text('Productivity'));
      await _settle(tester);

      expect(find.text('Efficiency'), findsNothing);
      expect(find.text('WORK COMPLETED'), findsOneWidget);
    });

    testWidgets('renders in Arabic and dark without exceptions',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final fake = _FakeTechnicianNotifier(const [_runningJob]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [technicianDashboardProvider.overrideWith(() => fake)],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: StaffLocalizations.supportedLocales,
            localizationsDelegates: _delegates,
            theme: AppTheme.dark(BrandConfig.orient, locale: const Locale('ar')),
            home: const TechnicianDashboardView(),
          ),
        ),
      );
      await _settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(TechnicianDashboardView), findsOneWidget);
    });
  });

  group('Touch-target audit', () {
    testWidgets('zero interactive targets under 48dp', (tester) async {
      await _pumpDashboard(tester, jobs: const [_runningJob]);

      final small = <String>[];
      for (final element in find
          .byWidgetPredicate(
            (w) =>
                w is IconButton ||
                w is Checkbox ||
                w is FilledButton ||
                w is OutlinedButton ||
                w is ElevatedButton ||
                w is TextButton,
          )
          .evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        if (size.width < 48 || size.height < 48) {
          small.add('${element.widget.runtimeType} $size');
        }
      }
      expect(small, isEmpty, reason: small.join('\n'));
    });
  });
}

String? _elapsedText(WidgetTester tester) {
  final matches = find
      .byWidgetPredicate(
        (w) =>
            w is Text &&
            w.data != null &&
            RegExp(r'^\d+:\d{2}:\d{2}$').hasMatch(w.data!),
      )
      .evaluate();
  if (matches.isEmpty) return null;
  return (matches.first.widget as Text).data;
}

// ---------- Fakes & harness ----------

class _FakeTechnicianNotifier extends TechnicianNotifier {
  _FakeTechnicianNotifier(this._jobs);

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
  List<TechnicianJobEntity> get filteredJobs {
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _jobs;
    return _jobs
        .where(
          (j) =>
              j.jobCardNo.toLowerCase().contains(q) ||
              j.vehicleBrand.toLowerCase().contains(q) ||
              j.vehicleModel.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  int get totalJobs => _jobs.length;

  @override
  int get inProgressJobs =>
      _jobs.where((j) => j.status == TechJobStatus.inProgress).length;

  @override
  int get completedJobs => 0;

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

Future<void> _pumpDashboard(
  WidgetTester tester, {
  List<TechnicianJobEntity> jobs = const [],
  _FakeTechnicianNotifier? fake,
  bool router = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  final notifier = fake ?? _FakeTechnicianNotifier(jobs);
  notifier.profile = const TechnicianProfileEntity(
    name: 'Ahmed',
    empId: 'EMP-001',
    role: 'Technician',
    branch: 'Al Quoz',
    shift: 'Morning',
    avatarInitials: 'A',
  );

  Widget home = MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: const Locale('en'),
    supportedLocales: StaffLocalizations.supportedLocales,
    localizationsDelegates: _delegates,
    theme: AppTheme.light(BrandConfig.orient),
    home: const TechnicianDashboardView(),
  );
  if (router) {
    home = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: StaffLocalizations.supportedLocales,
      localizationsDelegates: _delegates,
      theme: AppTheme.light(BrandConfig.orient),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const TechnicianDashboardView(),
          ),
          GoRoute(
            path: AppRoutes.technicianJobDetail,
            builder: (_, __) => const Scaffold(body: Text('JOB_DETAIL')),
          ),
        ],
      ),
    );
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [technicianDashboardProvider.overrideWith(() => notifier)],
      child: home,
    ),
  );
  await _settle(tester);
}

Future<void> _pumpDetail(WidgetTester tester, TechnicianJobEntity job) =>
    _pumpDetailWith(tester, _FakeTechnicianNotifier([job]), job);

Future<void> _pumpDetailWith(
  WidgetTester tester,
  _FakeTechnicianNotifier fake,
  TechnicianJobEntity job,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [technicianDashboardProvider.overrideWith(() => fake)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        supportedLocales: StaffLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient),
        home: TechnicianJobDetailView(job: job),
      ),
    ),
  );
  await _settle(tester);
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String relative) async {
    final bytes = await File(relative).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  final sep = Platform.pathSeparator;
  await load(
    AppFontFamilies.app,
    '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
    '${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
      '${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$weight.ttf',
    );
  }

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
