import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_scaffold.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';

/// Phase 11 — supervisor floor-command experience coverage. The composition is
/// a spatial floor board + task-specific tabs, so assertions follow the new
/// layout (bay board, priority rows, QC checklist) rather than the retired
/// dashboard template.
void main() {
  group('Supervisor Phase 11 experience', () {
    testWidgets('shell renders greeting header, floor pill and bottom nav', (
      tester,
    ) async {
      await _pump(tester, const SupervisorScaffold());
      expect(find.textContaining('Floor command'), findsOneWidget);
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.text('Floor'), findsWidgets);
      expect(find.text('Queue'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('floor tab renders 16-bay board with legend and job tiles', (
      tester,
    ) async {
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () {},
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
      );
      expect(find.text('Workshop floor'), findsOneWidget);
      expect(find.text('Occupied'), findsWidgets);
      expect(find.text('Idle'), findsWidgets);
      // Bay identifiers are Latin, LTR.
      expect(find.text('B-01'), findsOneWidget);
      expect(find.text('B-16'), findsOneWidget);
      // A real assigned job surfaces inside its tile.
      expect(find.text('Toyota Land Cruiser (DXB A 4821)'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('floor legend maps states and tapping a bay opens dispatch', (
      tester,
    ) async {
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () => _assignOpened = true,
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
      );
      _assignOpened = false;
      await tester.tap(find.text('B-01'));
      await tester.pump();
      expect(_assignOpened, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('assign sheet renders technician cards and a dispatch primary', (
      tester,
    ) async {
      await _pump(tester, const SupervisorAssignSheet());
      expect(find.text('Pick a technician to take this job'), findsOneWidget);
      expect(find.text('Technicians'), findsWidgets);
      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(find.text('Sam Rivera'), findsOneWidget);
      expect(find.text('Dispatch'), findsOneWidget);
      // Dispatch is disabled until a technician is selected.
      final dispatch = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Dispatch'),
      );
      expect(dispatch.onPressed, isNull);
      await tester.tap(find.text('Alex Morgan'));
      await tester.pump();
      final enabled = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Dispatch'),
      );
      expect(enabled.onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('queue tab renders priority rows and advisor routing', (
      tester,
    ) async {
      await _pump(tester, SupervisorQueueTab(onOpenReview: () {}));
      expect(find.text('Incoming queue'), findsWidgets);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Breakdowns'), findsOneWidget);
      expect(find.text('Assign advisor'), findsWidgets);
      expect(find.text('Engine overheating on highway'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('review tab opens the QC checklist with disabled approve', (
      tester,
    ) async {
      await _pump(tester, const SupervisorReviewTab());
      expect(find.text('Quality control'), findsWidgets);
      expect(find.text('Start QC'), findsOneWidget);

      await tester.tap(find.text('Start QC'));
      await tester.pumpAndSettle();

      expect(find.text('Quality control review'), findsOneWidget);
      expect(find.text('Road test'), findsOneWidget);
      expect(find.text('Torque audit'), findsOneWidget);
      expect(find.text('Fluid levels'), findsOneWidget);
      expect(find.text('Final wash'), findsOneWidget);
      expect(find.text('Send back'), findsOneWidget);

      final approve = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Approve & pass'),
      );
      expect(approve.onPressed, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('jobs tab renders search, filter and divider rows', (
      tester,
    ) async {
      await _pump(tester, SupervisorJobsTab(onOpenAssign: () {}));
      expect(find.text('Active jobs'), findsWidgets);
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(find.text('In progress'), findsWidgets);
      expect(find.text('JC-2026-1042'), findsWidgets);
      expect(find.text('2/3 tasks'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('staff tab renders roster without fabricated availability', (
      tester,
    ) async {
      await _pump(tester, const SupervisorStaffTab());
      expect(find.text('Workshop roster'), findsWidgets);
      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(find.text('Mechanical'), findsOneWidget);
      expect(find.textContaining('Available for assignment'), findsNothing);
      expect(find.textContaining('CAPACITY'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('schedule tab renders the agenda matrix with today highlight', (
      tester,
    ) async {
      await _pump(tester, SupervisorScheduleTab(onOpenQueue: () {}));
      expect(find.text('Bay schedule'), findsWidgets);
      expect(find.text('Today'), findsWidgets);
      expect(find.text('Periodic Maintenance'), findsWidgets);
      expect(find.textContaining('BAY 01'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reports tab renders a metric strip and sparse tables', (
      tester,
    ) async {
      await _pump(tester, const SupervisorReportsTab());
      expect(find.text('Operations report'), findsWidgets);
      expect(find.text('THROUGHPUT'), findsWidgets);
      expect(find.text('UTILISATION'), findsWidgets);
      expect(find.text('Job categories'), findsWidgets);
      expect(find.textContaining('RATE'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('views survive 1.3x text scale and wide desktop without error', (
      tester,
    ) async {
      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () {},
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
        size: const Size(320, 780),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);

      await _pump(
        tester,
        SupervisorDashboardTab(
          onOpenAssign: () {},
          onOpenQueue: () {},
          onOpenReview: () {},
        ),
        size: const Size(1280, 900),
      );
      expect(find.text('Workshop floor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

bool _assignOpened = false;

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
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
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          StaffLocalizations.delegate,
          SharedCoreLocalizations.delegate,
          SharedAuthLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
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
      technician: 'Alex Morgan',
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
