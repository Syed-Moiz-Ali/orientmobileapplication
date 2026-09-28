import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_job_detail_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_reports_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';

void main() {
  testWidgets('Advisor home renders operational header, work summary and quick actions', (
    tester,
  ) async {
    await _pumpAdvisorExperience(
      tester,
      const AdvisorHomeView(),
    );

    expect(find.text('SERVICE ADVISOR'), findsOneWidget);
    expect(find.text('Work Summary'), findsOneWidget);
    expect(find.textContaining('Scan Vehicle'), findsOneWidget);
    expect(find.textContaining('New Job'), findsOneWidget);
    expect(find.textContaining('Inspection'), findsOneWidget);
    expect(find.textContaining('Workshop'), findsOneWidget);

    // Ensure no sci-fi / tactical jargon is displayed
    expect(find.text('ADVISOR INTAKE · COMMAND'), findsNothing);
    expect(find.text('Shift Throughput'), findsNothing);
    expect(find.text('RADAR'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Advisor jobs view provides clean search and status filter chips', (
    tester,
  ) async {
    await _pumpAdvisorExperience(
      tester,
      AdvisorJobsListView(onJobCard: (_) {}),
    );

    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.text('Toyota Land Cruiser'), findsOneWidget);
    expect(find.text('Nissan Patrol'), findsOneWidget);

    // Verify filter chips exist
    expect(find.text('All'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Advisor job detail presents operational vehicle details and actions', (
    tester,
  ) async {
    const testJob = JobCardEntity(
      id: 'JC-2026-1042',
      customerName: 'Rashid Al Nuaimi',
      vehicleInfo: '2024 Toyota Land Cruiser',
      time: '09:30 AM',
      status: JobCardStatus.inProgress,
      technician: 'Alex Morgan',
      odometer: 14200,
      fuelLevel: '75%',
    );

    await _pumpAdvisorExperience(
      tester,
      const AdvisorJobDetailView(jc: testJob),
    );

    expect(find.text('JC-2026-1042'), findsWidgets);
    expect(find.text('Rashid Al Nuaimi'), findsWidgets);
    expect(find.text('Vehicle Details'), findsOneWidget);
    expect(find.text('Vehicle Telemetry'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Advisor reports displays job activity and export action cleanly', (
    tester,
  ) async {
    await _pumpAdvisorExperience(
      tester,
      const AdvisorReportsView(),
    );

    expect(find.text('Job Activity'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);

    // Verify removed sci-fi strings
    expect(find.text('Throughput Analytics'), findsNothing);
    expect(find.text('Export Telemetry Report'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Advisor home renders without overflow at 1.25x text scaling', (
    tester,
  ) async {
    await _pumpAdvisorExperience(
      tester,
      const AdvisorHomeView(),
      textScaler: const TextScaler.linear(1.25),
    );

    expect(find.text('SERVICE ADVISOR'), findsOneWidget);
    expect(find.text('Work Summary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAdvisorExperience(
  WidgetTester tester,
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final mockStats = const AdvisorStatsEntity(
    newJobCardsToday: 5,
    inspectionsToday: 3,
    pendingApprovals: 2,
    vehiclesWaiting: 1,
    readyForDelivery: 4,
    totalOpenJobCards: 12,
  );

  final mockJobs = <JobCardEntity>[
    const JobCardEntity(
      id: 'JC-2026-1042',
      customerName: 'Rashid Al Nuaimi',
      vehicleInfo: 'Toyota Land Cruiser',
      time: '09:30 AM',
      status: JobCardStatus.inProgress,
      technician: 'Alex Morgan',
      odometer: 14200,
      fuelLevel: '75%',
    ),
    const JobCardEntity(
      id: 'JC-2026-1049',
      customerName: 'Fatima Al Mansoori',
      vehicleInfo: 'Nissan Patrol',
      time: '11:00 AM',
      status: JobCardStatus.pending,
      technician: '',
      odometer: 32000,
      fuelLevel: '50%',
    ),
  ];

  final mockReportData = const AdvisorReportData(
    totalJobs: 14,
    completedJobs: 8,
    pendingJobs: 2,
    inProgressJobs: 4,
    cancelledJobs: 0,
    avgCompletionTime: 2.5,
    statusBreakdown: [
      StatusCount('Completed', 8, Color(0xFF16A34A)),
      StatusCount('In Progress', 4, Color(0xFF2563EB)),
      StatusCount('Pending', 2, Color(0xFFEAB308)),
    ],
    weeklyActivity: [4, 6, 8, 5, 7, 3, 2],
    weekLabels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorDashboardProvider.overrideWith((ref) => Future.value(mockStats)),
        advisorRecentJobCardsProvider.overrideWith((ref) => Future.value(mockJobs)),
        advisorInfoProvider.overrideWithValue(
          const AdvisorInfo(
            name: 'Zayn Malik',
            id: 'ADV-014',
            branch: 'Al Quoz Central',
            shift: 'Morning Shift (08:00 - 17:00)',
          ),
        ),
        advisorReportDataProvider.overrideWith((ref) => Future.value(mockReportData)),
        advisorRemoteDataSourceProvider.overrideWithValue(FakeAdvisorRemoteDataSource()),
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

class FakeAdvisorRemoteDataSource implements AdvisorRemoteDataSource {
  @override
  Future<JobCardDetailResponse> getJobCard(String id) async {
    return const JobCardDetailResponse(
      id: 'JC-2026-1042',
      customerName: 'Rashid Al Nuaimi',
      vehicleInfo: '2024 Toyota Land Cruiser',
      status: 'inProgress',
      technician: 'Alex Morgan',
      odometer: 14200,
      fuelLevel: '75%',
    );
  }

  @override
  Future<List<WorkItemResponse>> getWorkItems(String jobCardRef) async => const [];

  @override
  Future<AdvisorStatsResponse> getStats() async => const AdvisorStatsResponse();

  @override
  Future<PageResponse<JobCardResponse>> getJobCards({int page = 1, int size = 20}) async =>
      const PageResponse(content: [], totalElements: 0, totalPages: 0, page: 1, size: 20);

  @override
  Future<List<PendingApprovalResponse>> getPendingApprovals() async => const [];

  @override
  Future<List<ReminderResponse>> getReminders() async => const [];

  @override
  Future<List<AdvisorBookingResponse>> getAssignedBookings() async => const [];

  @override
  Future<List<AdvisorTechnicianResponse>> getTechnicians() async => const [];

  @override
  Future<List<StaffNotificationResponse>> getStaffNotifications() async => const [];

  @override
  Future<ReportResponse> getReports([String? range]) async => const ReportResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
