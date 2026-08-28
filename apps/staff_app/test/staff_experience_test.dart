import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_workflow_indicator.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_jobs_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_today_view.dart';

void main() {
  testWidgets('technician today prioritizes active work and safe actions', (
    tester,
  ) async {
    await _pumpExperience(tester, const TechnicianTodayView());

    expect(find.text('On the bay'), findsOneWidget);
    expect(find.text('Toyota Land Cruiser'), findsOneWidget);
    expect(find.text('Complete task'), findsOneWidget);
    expect(find.text('Request part'), findsOneWidget);
    expect(find.text('Escalate'), findsOneWidget);
    expect(find.text("Today's Productivity"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('technician jobs uses a mobile queue instead of a data table', (
    tester,
  ) async {
    await _pumpExperience(tester, const TechnicianJobsView());

    expect(find.text('Jobs for this shift'), findsOneWidget);
    expect(find.text('Toyota Land Cruiser'), findsOneWidget);
    expect(find.text('Nissan Patrol'), findsOneWidget);
    expect(find.text('JOB CARD #'), findsNothing);
    expect(find.text('Search job, vehicle or plate'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('technician today remains usable with larger text', (
    tester,
  ) async {
    await _pumpExperience(
      tester,
      const TechnicianTodayView(),
      textScaler: const TextScaler.linear(1.25),
    );

    expect(find.text('Start shift'), findsOneWidget);
    expect(find.text('Current work'.toUpperCase()), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('job details use touch-friendly task cards', (tester) async {
    await _pumpExperience(
      tester,
      JobDetailSheet(job: _FakeTechnicianNotifier._jobs.first),
      textScaler: const TextScaler.linear(1.25),
    );

    expect(find.text('Work Tasks'), findsOneWidget);
    expect(find.text('Brake inspection and measurement'), findsOneWidget);
    expect(find.text('S.No'), findsNothing);
    expect(find.text('Start'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('technician action sheets remain usable with larger text', (
    tester,
  ) async {
    await _pumpExperience(
      tester,
      const PartsRequestSheet(
        jobCardRef: 'JC-2026-1042',
        technicianEmpId: 'TECH-12',
      ),
      textScaler: const TextScaler.linear(1.25),
    );

    expect(find.text('Request a part'), findsOneWidget);
    expect(find.text('Send part request'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpExperience(
      tester,
      const EscalationSheet(
        jobCardRef: 'JC-2026-1042',
        technicianEmpId: 'TECH-12',
      ),
      textScaler: const TextScaler.linear(1.25),
    );

    expect(find.text('Escalate an issue'), findsOneWidget);
    expect(find.text('Notify supervisor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('advisor workflow makes every service step visible', (
    tester,
  ) async {
    await _pumpExperience(
      tester,
      const AdvisorWorkflowIndicator(currentStep: 2),
      textScaler: const TextScaler.linear(1.25),
    );

    for (final label in [
      'Intake',
      'Inspect',
      'Estimate',
      'Repair',
      'Deliver',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('supervisor staff view avoids fabricated performance claims', (
    tester,
  ) async {
    await _pumpSupervisorExperience(
      tester,
      const SupervisorStaffTab(),
      textScaler: const TextScaler.linear(1.25),
    );

    expect(find.text('2 specialists on shift'), findsOneWidget);
    expect(find.textContaining('100% station utilization'), findsNothing);
    expect(find.textContaining('Bay Efficiency 94%'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSupervisorExperience(
  WidgetTester tester,
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supervisorDashboardProvider.overrideWith(_FakeSupervisorNotifier.new),
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

Future<void> _pumpExperience(
  WidgetTester tester,
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = const Size(390, 844);
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
}

class _FakeSupervisorNotifier extends SupervisorDashboardNotifier {
  @override
  SupervisorDashboardState build() => SupervisorDashboardState();

  @override
  List<String> get technicians => const ['Alex Morgan', 'Sam Rivera'];

  @override
  List<String> get departments => const ['Diagnostics', 'Mechanical'];
}
