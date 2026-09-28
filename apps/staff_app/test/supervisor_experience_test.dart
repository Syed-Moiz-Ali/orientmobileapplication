import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_app_bar.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';

void main() {
  group('Supervisor Experience Redesign Tests', () {
    testWidgets('Supervisor App Bar displays operational title and subtitle', (
      tester,
    ) async {
      await _pumpSupervisorTestWidget(
        tester,
        const SupervisorAppBar(selectedIndex: 0),
      );

      expect(find.text('Workshop Overview'), findsOneWidget);
      expect(find.text('Shift operations & floor activity'), findsOneWidget);
      expect(find.byIcon(Icons.engineering_rounded), findsOneWidget);

      // Verify no tactical sci-fi titles
      expect(find.text('Command Center'), findsNothing);
      expect(find.text('Telemetry'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Supervisor Today Tab renders operational header, attention areas, and active jobs',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorDashboardTab());

        // Header and context
        expect(find.text('Workshop Overview'), findsOneWidget);
        expect(find.textContaining('active jobs •'), findsOneWidget);

        // Operational Attention Area
        expect(find.text('Attention Required'), findsOneWidget);
        expect(find.text('Unassigned Bookings'), findsOneWidget);
        expect(find.text('Breakdowns Waiting'), findsOneWidget);
        expect(find.text('Awaiting Inspection'), findsOneWidget);

        // Active jobs preview
        expect(find.text('Active Workshop Jobs'), findsOneWidget);
        expect(find.textContaining('JC-2026-1042'), findsWidgets);
        expect(find.textContaining('Toyota Land Cruiser'), findsWidgets);

        // Quick Navigation Matrix
        expect(find.text('Active Jobs'), findsOneWidget);
        expect(find.text('Workshop Roster'), findsOneWidget);
        expect(find.text('Bay Schedule'), findsOneWidget);
        expect(find.text('Operations Report'), findsOneWidget);

        // Verify purged sci-fi widgets
        expect(find.text('Command Center'), findsNothing);
        expect(find.text('Bottleneck Radar HUD'), findsNothing);
        expect(find.text('Real-Time Job Logs'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Assign Sheet renders target job card search and task roster',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorAssignSheet());

        expect(find.text('Target Job Card'), findsOneWidget);
        expect(find.byType(AppSearchField), findsOneWidget);
        expect(find.text('Task Assignment Roster'), findsOneWidget);
        expect(find.text('Add Task'), findsOneWidget);
        expect(find.text('Task Specifications'), findsOneWidget);
        expect(find.text('Work Description'), findsOneWidget);
        expect(find.text('Department / Section'), findsOneWidget);
        expect(find.text('Assigned Technician'), findsOneWidget);
        expect(find.text('Date of Work'), findsOneWidget);
        expect(find.text('Standard Time'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Queue Tab renders appointments and breakdowns with truthful advisor assignment',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorQueueTab());

        expect(find.text('Incoming Work Queue'), findsOneWidget);
        expect(find.text('Scheduled Appointments'), findsOneWidget);
        expect(find.text('Emergency Breakdowns'), findsOneWidget);
        expect(
          find.text('Engine Oil & Filter Service · Lexus LX 600'),
          findsOneWidget,
        );
        expect(find.text('Engine overheating on highway'), findsOneWidget);

        // Verify truthful copy: Assign Advisor, not Dispatch Squad
        expect(find.text('Assign Advisor'), findsWidgets);
        expect(find.text('Dispatch Squad'), findsNothing);
        expect(find.text('Breakdown Radar'), findsNothing);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Review Tab and QC Checklist Sheet handle checklist validation',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorReviewTab());

        expect(find.text('Quality Control Inspection'), findsOneWidget);
        expect(find.text('JC-2026-1042'), findsWidgets);
        expect(find.text('Start QC Inspection'), findsOneWidget);

        // Tap Start QC Inspection to open sheet
        await tester.tap(find.text('Start QC Inspection'));
        await tester.pumpAndSettle();

        expect(find.text('Quality Control Review'), findsOneWidget);
        expect(find.text('Send Back'), findsOneWidget);
        expect(find.text('Approve & Pass QC'), findsOneWidget);

        // Checklist items
        expect(find.text('Inspect front brake pads'), findsOneWidget);
        expect(find.text('Torque wheel lug nuts to spec'), findsOneWidget);

        // Approve button should be disabled initially (allChecked is false)
        final approveButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Approve & Pass QC'),
        );
        expect(approveButton.onPressed, isNull);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Jobs Tab renders active jobs with search field and progress',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorJobsTab());

        expect(find.text('Total Assigned'), findsOneWidget);
        expect(find.text('Active Workshop Jobs'), findsOneWidget);
        expect(find.byType(AppSearchField), findsOneWidget);
        expect(find.text('JC-2026-1042'), findsWidgets);
        expect(find.text('Rashid Al Nuaimi'), findsWidgets);
        expect(find.text('2/3 tasks completed'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Staff Tab renders registered roster without fake availability claims',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorStaffTab());

        expect(find.text('2 specialists on shift'), findsOneWidget);
        expect(find.text('Floor Technicians'), findsOneWidget);
        expect(find.text('Workshop Departments'), findsOneWidget);
        expect(find.text('Alex Morgan'), findsOneWidget);
        expect(find.text('Sam Rivera'), findsOneWidget);
        expect(find.text('Mechanical'), findsOneWidget);
        expect(find.text('Diagnostics'), findsOneWidget);

        // Verify purged fake claims
        expect(find.textContaining('Available for assignment'), findsNothing);
        expect(find.textContaining('CAPACITY'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Schedule Tab renders scheduled appointments without fake bay numbers',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorScheduleTab());

        expect(find.text('Scheduled Appointments'), findsOneWidget);
        expect(
          find.text('Periodic Maintenance · Toyota Land Cruiser'),
          findsOneWidget,
        );
        expect(find.text('View in Queue'), findsWidgets);

        // Verify fake bay allocation is purged
        expect(find.textContaining('BAY 01'), findsNothing);
        expect(find.textContaining('BAY 02'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor Reports Tab renders truthful metrics without fabricated charts',
      (tester) async {
        await _pumpSupervisorTestWidget(tester, const SupervisorReportsTab());

        expect(find.text('Workshop Operations Report'), findsOneWidget);
        expect(find.text('Total Volume'), findsOneWidget);
        expect(find.text('In Progress'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Job Category Distribution'), findsOneWidget);
        expect(find.text('Operational Status'), findsOneWidget);

        // Verify fabricated telemetry and charts are completely absent
        expect(find.text(r'$42,850.00'), findsNothing);
        expect(find.text('+24.6%'), findsNothing);
        expect(find.text('94.2% RATE'), findsNothing);
        expect(find.text('Financial Telemetry Logs'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor views maintain responsive layout under larger text scaling (1.25x)',
      (tester) async {
        await _pumpSupervisorTestWidget(
          tester,
          const SupervisorDashboardTab(),
          textScaler: const TextScaler.linear(1.25),
        );

        expect(find.text('Workshop Overview'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Supervisor views render cleanly on wide tablet/desktop screens (1024x768)',
      (tester) async {
        await _pumpSupervisorTestWidget(
          tester,
          const SupervisorDashboardTab(),
          physicalSize: const Size(1024, 768),
        );

        expect(find.text('Workshop Overview'), findsOneWidget);
        expect(find.text('Active Workshop Jobs'), findsOneWidget);
        final exc = tester.takeException();
        if (exc != null) {
          debugPrint('DEBUG WIDE SCREEN EXCEPTION: $exc');
        }
        expect(exc, isNull);
      },
    );
  });
}

Future<void> _pumpSupervisorTestWidget(
  WidgetTester tester,
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
  Size? physicalSize,
}) async {
  tester.view.physicalSize = physicalSize ?? const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supervisorDashboardProvider.overrideWith(
          _MockSupervisorDashboardNotifier.new,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: c!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _MockSupervisorDashboardNotifier extends SupervisorDashboardNotifier {
  @override
  SupervisorDashboardState build() {
    return SupervisorDashboardState(
      isDashboardLoading: false,
      isQueueLoading: false,
      isReviewLoading: false,
      selectedIndex: 0,
      assignmentRows: [
        const WorkAssignmentEntity(
          id: 1,
          description: 'Front brake rotor skim and pad replacement',
          department: 'Mechanical',
          technicianName: 'Alex Morgan',
          dateOfWork: '2026-09-17',
          statusPercent: 50,
          stdTime: '2.0 hrs',
          remarks: 'Use OEM brake pads',
        ),
      ],
    );
  }

  @override
  List<String> get technicians => const ['Alex Morgan', 'Sam Rivera'];

  @override
  List<String> get departments => const ['Mechanical', 'Diagnostics'];

  @override
  List<AssignableStaffResponse> get advisors => const [
    AssignableStaffResponse(id: 101, name: 'Zaid Khan', role: 'Advisor'),
    AssignableStaffResponse(id: 102, name: 'Maya Chen', role: 'Advisor'),
  ];

  @override
  List<BookingQueueResponse> get bookings => const [
    BookingQueueResponse(
      id: 1,
      customerName: 'Fatima Al Mansoori',
      vehicleName: 'Lexus LX 600',
      plateNumber: 'DXB B 1042',
      bookingDate: '2026-09-18 10:00 AM',
      serviceType: 'Engine Oil & Filter Service',
      status: 'pending',
    ),
    BookingQueueResponse(
      id: 2,
      customerName: 'Sultan Al Qasimi',
      vehicleName: 'Toyota Land Cruiser',
      plateNumber: 'SHJ K 889',
      bookingDate: '2026-09-18 11:30 AM',
      serviceType: 'Periodic Maintenance',
      status: 'confirmed',
    ),
  ];

  @override
  List<BreakdownQueueResponse> get breakdowns => const [
    BreakdownQueueResponse(
      id: 1,
      customerName: 'Omar Farooq',
      vehicleName: 'Nissan Patrol',
      vehiclePlate: 'DXB Z 772',
      issue: 'Engine overheating on highway',
      location: 'Sheikh Zayed Rd, Exit 42',
      status: 'pending',
    ),
  ];

  @override
  List<AssignedJobEntity> get jobs => const [
    AssignedJobEntity(
      jobCard: 'JC-2026-1042',
      customer: 'Rashid Al Nuaimi',
      vehicle: 'Toyota Land Cruiser (DXB A 4821)',
      status: 'In Progress',
      dateAssigned: '17 Sep',
      done: 2,
      total: 3,
    ),
    AssignedJobEntity(
      jobCard: 'JC-2026-1048',
      customer: 'Sara Al Humaidan',
      vehicle: 'Lexus RX 350 (DXB C 9901)',
      status: 'Completed',
      dateAssigned: '17 Sep',
      done: 4,
      total: 4,
    ),
  ];

  @override
  List<AwaitingCompletionResponse> get awaitingCompletions => const [
    AwaitingCompletionResponse(
      jobCardId: 1042,
      jobCardRef: 'JC-2026-1042',
      customerName: 'Rashid Al Nuaimi',
      vehicleInfo: '2024 Toyota Land Cruiser',
      done: 2,
      total: 2,
      items: [
        WorkItemDetail(id: 1, description: 'Inspect front brake pads'),
        WorkItemDetail(id: 2, description: 'Torque wheel lug nuts to spec'),
      ],
    ),
  ];

  @override
  List<AdvisorJobEntity> get advisorJobData => const [
    AdvisorJobEntity(name: 'Zaid Khan', count: 3),
    AdvisorJobEntity(name: 'Maya Chen', count: 2),
  ];

  @override
  List<JobTypeEntity> get jobTypes => const [
    JobTypeEntity(label: 'Periodic Maintenance', count: 8, color: Colors.blue),
    JobTypeEntity(label: 'Brakes & Suspension', count: 5, color: Colors.amber),
    JobTypeEntity(
      label: 'Electrical / Diagnostic',
      count: 3,
      color: Colors.purple,
    ),
  ];

  @override
  List<RevenueMetricEntity> get revenueMetrics => const [
    RevenueMetricEntity(
      icon: Icons.receipt_rounded,
      amount: 'AED 12,450',
      label: 'Completed Work Orders',
      change: 'Today',
    ),
  ];

  @override
  int get totalAssigned => 16;

  @override
  int get inProgressCount => 10;

  @override
  int get completedCount => 6;

  @override
  List<StaffNotificationResponse> get notifications => const [];

  @override
  int get unreadNotifications => 0;
}
