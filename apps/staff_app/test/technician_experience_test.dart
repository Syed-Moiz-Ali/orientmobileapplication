import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_jobs_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_productivity_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_today_view.dart';

void main() {
  group('Technician Today View', () {
    testWidgets('renders operational shift control, active bay job, and shift summary', (
      tester,
    ) async {
      await _pumpTechnicianExperience(tester, const TechnicianTodayView());

      // Shift Control
      expect(find.text('CURRENT WORK'), findsOneWidget);
      expect(find.text('Start shift'), findsOneWidget);

      // Active Bay Job
      expect(find.text('On the bay'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser'), findsOneWidget);
      expect(find.text('DUBAI A 4821'), findsOneWidget);
      expect(find.text('Complete task'), findsOneWidget);
      expect(find.text('Request part'), findsOneWidget);
      expect(find.text('Escalate'), findsOneWidget);

      // Shift Summary
      expect(find.text("Today's Shift Output"), findsOneWidget);
      expect(find.text('Active Bay'), findsOneWidget);
      expect(find.text('Tasks Done'), findsOneWidget);
      expect(find.text('Repairs Done'), findsOneWidget);

      // Verify removal of gamified / fantasy widgets
      expect(find.text('LIVE SHIFT PULSE'), findsNothing);
      expect(find.text('WORKSHOP RATING'), findsNothing);
      expect(find.text('Optimal Efficiency'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Technician Jobs View', () {
    testWidgets('renders job queue with search and status filter chips', (
      tester,
    ) async {
      await _pumpTechnicianExperience(tester, const TechnicianJobsView());

      expect(find.text('Jobs for this shift'), findsOneWidget);
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(find.text('Search job, vehicle or plate'), findsOneWidget);

      // Both fake jobs present
      expect(find.text('Toyota Land Cruiser'), findsOneWidget);
      expect(find.text('Nissan Patrol'), findsOneWidget);

      // Status filters
      expect(find.text('All Status'), findsWidgets);
      expect(find.text('In Progress'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Completed'), findsWidgets);

      // Filter by searching 'Nissan'
      await tester.enterText(find.byType(TextField), 'Nissan');
      await tester.pumpAndSettle();

      // Only Nissan Patrol should remain in the filtered view
      expect(find.text('Nissan Patrol'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser'), findsNothing);

      expect(tester.takeException(), isNull);
    });
  });

  group('Technician Job Detail Workspace', () {
    testWidgets('renders mobile layout with touch-friendly task cards and complete button', (
      tester,
    ) async {
      await _pumpTechnicianExperience(
        tester,
        JobDetailSheet(job: _FakeTechnicianNotifier._jobs.first),
      );

      expect(find.text('JC-2026-1042'), findsWidgets);
      expect(find.text('Toyota Land Cruiser'), findsWidgets);
      expect(find.text('Work Tasks'), findsOneWidget);
      expect(find.text('Brake inspection and measurement'), findsOneWidget);
      expect(find.text('Replace front brake pads'), findsOneWidget);

      // Action buttons
      expect(find.text('Complete Repair'), findsOneWidget);
      expect(find.text('Request Parts'), findsOneWidget);
      expect(find.text('Flag Issue'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders responsive wide-screen layout with 2-column workspace', (
      tester,
    ) async {
      await _pumpTechnicianExperience(
        tester,
        JobDetailSheet(job: _FakeTechnicianNotifier._jobs.first),
        viewportSize: const Size(1024, 768),
      );

      // In wide view, tasks are on the left and vehicle overview + actions are on the right
      expect(find.text('Work Tasks'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser'), findsWidgets);
      expect(find.text('Complete Repair'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('shows supervisor QC notice when job is already completed', (
      tester,
    ) async {
      final completedJob = _FakeTechnicianNotifier._jobs.first.copyWith(
        jobCardNo: 'JC-COMPLETED-9999',
        status: TechJobStatus.completed,
      );

      await _pumpTechnicianExperience(
        tester,
        JobDetailSheet(job: completedJob),
      );

      expect(find.text('This repair is completed. Technician edits are locked.'), findsOneWidget);
      expect(find.text('Complete Repair'), findsNothing);

      expect(tester.takeException(), isNull);
    });
  });

  group('Technician Productivity View', () {
    testWidgets('renders clean shift performance summary without fabricated stats', (
      tester,
    ) async {
      await _pumpTechnicianExperience(tester, const TechnicianProductivityView());

      expect(find.text('SHIFT PERFORMANCE'), findsOneWidget);
      expect(find.text('Productivity & Shift'), findsOneWidget);
      expect(find.text('TURNAROUND EFFICIENCY'), findsOneWidget);
      expect(find.text('High Turnaround Pace'), findsOneWidget);
      expect(find.text('Completed Today'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Avg Repair Time'), findsOneWidget);
      expect(find.text('Total Worked'), findsOneWidget);

      // Real stats from fake
      expect(find.text('3'), findsWidgets); // completedToday
      expect(find.text('1h 20m'), findsOneWidget); // avgTimePerJob

      // Fantasy elements must not exist
      expect(find.text('WORKSHOP RATING'), findsNothing);
      expect(find.text('Exceptional Pace'), findsNothing);
      expect(find.text('Optimal Efficiency'), findsNothing);

      expect(tester.takeException(), isNull);
    });
  });

  group('Technician Action Sheets', () {
    testWidgets('parts request sheet displays inputs and submit button within max width', (
      tester,
    ) async {
      await _pumpTechnicianExperience(
        tester,
        const PartsRequestSheet(
          jobCardRef: 'JC-2026-1042',
          technicianEmpId: 'TECH-12',
        ),
        viewportSize: const Size(800, 900),
      );

      expect(find.text('Request a part'), findsOneWidget);
      expect(find.text('Part name'), findsOneWidget);
      expect(find.text('Part number (optional)'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Send part request'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('escalation sheet displays issue reasons and submit button within max width', (
      tester,
    ) async {
      await _pumpTechnicianExperience(
        tester,
        const EscalationSheet(
          jobCardRef: 'JC-2026-1042',
          technicianEmpId: 'TECH-12',
        ),
        viewportSize: const Size(800, 900),
      );

      expect(find.text('Escalate an issue'), findsOneWidget);
      expect(find.text('What happened?'), findsOneWidget);
      expect(find.text('Notify supervisor'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpTechnicianExperience(
  WidgetTester tester,
  Widget child, {
  Size viewportSize = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = viewportSize;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        technicianDashboardProvider.overrideWith(_FakeTechnicianNotifier.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeTechnicianNotifier extends TechnicianNotifier {
  static final _jobs = <TechnicianJobEntity>[
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-1042',
      dateOfWork: '24 Aug',
      startTime: '09:30 AM',
      vehicleBrand: 'Toyota',
      vehicleModel: 'Land Cruiser',
      plateNumber: 'DUBAI A 4821',
      status: TechJobStatus.inProgress,
      tasks: const [
        WorkTaskEntity(
          id: 1,
          ref: 'task-1',
          description: 'Brake inspection and measurement',
          status: TaskStatus.inProgress,
        ),
        WorkTaskEntity(
          id: 2,
          ref: 'task-2',
          description: 'Replace front brake pads',
          status: TaskStatus.pending,
        ),
      ],
    ),
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-1049',
      dateOfWork: '24 Aug',
      startTime: '11:00 AM',
      vehicleBrand: 'Nissan',
      vehicleModel: 'Patrol',
      plateNumber: 'DUBAI N 731',
      status: TechJobStatus.pending,
      tasks: const [
        WorkTaskEntity(
          id: 3,
          ref: 'task-3',
          description: 'Run engine diagnostics',
          status: TaskStatus.pending,
        ),
      ],
    ),
  ];

  @override
  TechnicianState build() {
    productivity = const TechnicianStatsEntity(
      assignedJobs: 2,
      inProgress: 1,
      completedToday: 3,
      efficiency: 92,
      avgTimePerJob: '1h 20m',
      totalHoursWorked: '6h 10m',
    );
    return const TechnicianState(
      attendanceSummary: AttendanceSummaryEntity(),
      assignedJobs: [],
    );
  }

  @override
  List<TechnicianJobEntity> get allJobs => _jobs;

  @override
  List<TechnicianJobEntity> get filteredJobs => _jobs.where((job) {
    final matchesSearch =
        state.searchQuery.isEmpty ||
        job.jobCardNo.toLowerCase().contains(state.searchQuery) ||
        job.vehicleBrand.toLowerCase().contains(state.searchQuery) ||
        job.vehicleModel.toLowerCase().contains(state.searchQuery) ||
        job.plateNumber.toLowerCase().contains(state.searchQuery);
    final matchesFilter =
        state.selectedFilter == 'All Status' ||
        job.status.label == state.selectedFilter;
    return matchesSearch && matchesFilter;
  }).toList();

  @override
  int get totalJobs => _jobs.length;

  @override
  int get inProgressJobs => 1;

  @override
  int get completedJobs => 0;

  @override
  int get delayedJobs => 0;

  @override
  Future<void> refresh() async {}

  @override
  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
  }

  @override
  void updateFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}
