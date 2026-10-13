import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_job_detail_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_reports_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_approval_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_contact_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_notification_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_profile_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_stat_dialog.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _testJob = JobCardEntity(
  id: 'JC-2026-1042',
  customerName: 'Rashid Al Nuaimi',
  vehicleInfo: '2024 Toyota Land Cruiser',
  time: '09:30 AM',
  status: JobCardStatus.inProgress,
  technician: 'Alex Morgan',
  odometer: 14200,
  fuelLevel: '75%',
);

const _mockStats = AdvisorStatsEntity(
  newJobCardsToday: 5,
  inspectionsToday: 3,
  pendingApprovals: 2,
  vehiclesWaiting: 1,
  readyForDelivery: 4,
  totalOpenJobCards: 12,
);

const _mockJobs = <JobCardEntity>[
  JobCardEntity(
    id: 'JC-2026-1042',
    customerName: 'Rashid Al Nuaimi',
    vehicleInfo: 'Toyota Land Cruiser',
    time: '09:30 AM',
    status: JobCardStatus.inProgress,
    technician: 'Alex Morgan',
    odometer: 14200,
    fuelLevel: '75%',
  ),
  JobCardEntity(
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

const _mockApprovals = <PendingApprovalEntity>[
  PendingApprovalEntity(
    estimateId: 'EST-5521',
    approvalType: 'estimate',
    customerName: 'Saeed Al Marzouqi',
    vehicleId: 'DXB-4821',
    amount: 2450,
    timeAgo: '12m ago',
  ),
];

const _mockReportData = AdvisorReportData(
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

void main() {
  setUp(() {
    // The export action uses the share plugin; keep it inert in tests.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/share'),
          (_) async => null,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/share'),
          null,
        );
  });

  testWidgets('Today renders header, metrics, attention and recent work', (
    tester,
  ) async {
    await _pump(tester, const AdvisorHomeView());

    expect(find.text('SERVICE ADVISOR'), findsOneWidget);
    expect(find.text('Service Desk'), findsOneWidget);
    expect(find.text('Work Summary'), findsOneWidget);
    expect(find.textContaining('Scan Vehicle'), findsWidgets);
    expect(find.textContaining('New Job'), findsWidgets);
    expect(find.textContaining('Vehicle Inspection'), findsWidgets);
    expect(find.textContaining('Workshop Reports'), findsWidgets);
    expect(find.text('Needs Attention'), findsOneWidget);
    expect(find.text('EST-5521'), findsWidgets);
    expect(find.text('Rashid Al Nuaimi'), findsWidgets);

    expect(find.text('ADVISOR INTAKE · COMMAND'), findsNothing);
    expect(find.text('Shift Throughput'), findsNothing);
    expect(find.text('RADAR'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Today renders Arabic copy and mirrors in RTL', (tester) async {
    await _pump(tester, const AdvisorHomeView(), locale: const Locale('ar'));

    expect(find.text('مستشار خدمة'), findsOneWidget);
    expect(find.text('مكتب الخدمة'), findsOneWidget);
    expect(find.text('ملخص العمل'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AdvisorHomeView))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in const [
    Size(320, 640),
    Size(390, 844),
    Size(768, 1024),
    Size(1280, 800),
  ]) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets(
        'Today no overflow ${size.width}px ${locale.languageCode} @1.3x',
        (tester) async {
          await _pump(
            tester,
            const AdvisorHomeView(),
            size: size,
            locale: locale,
            textScaler: const TextScaler.linear(1.3),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Jobs provides search, chips and the working list', (
    tester,
  ) async {
    await _pump(tester, AdvisorJobsListView(onJobCard: (_) {}));

    expect(find.byType(AppSearchField), findsOneWidget);
    expect(find.text('Toyota Land Cruiser'), findsOneWidget);
    expect(find.text('Nissan Patrol'), findsOneWidget);
    expect(find.text('All'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Jobs search produces a no-match state', (tester) async {
    await _pump(tester, AdvisorJobsListView(onJobCard: (_) {}));
    await tester.enterText(find.byType(TextField), 'zzz-none');
    await tester.pumpAndSettle();
    expect(find.text('No matching job cards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Jobs empty state when there are no cards', (tester) async {
    await _pump(
      tester,
      AdvisorJobsListView(onJobCard: (_) {}),
      overrides: [
        advisorRecentJobCardsProvider.overrideWith((ref) => Future.value([])),
      ],
    );
    expect(find.text('No job cards yet'), findsOneWidget);
  });

  testWidgets('Reports renders charts, range control and export', (
    tester,
  ) async {
    await _pump(tester, const AdvisorReportsView());

    expect(find.text('Advisor Analytics'), findsOneWidget);
    expect(find.text('Job Activity'), findsOneWidget);
    expect(find.byType(SegmentedButton<ReportRange>), findsOneWidget);

    expect(find.text('Throughput Analytics'), findsNothing);
    expect(find.text('Export Telemetry Report'), findsNothing);

    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Export CSV'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Status Allocation'), findsOneWidget);
    expect(find.text('Export CSV'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reports export action is invokable', (tester) async {
    await _pump(tester, const AdvisorReportsView());
    await tester.dragUntilVisible(
      find.text('Export CSV'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Job detail presents identity, sections and actions', (
    tester,
  ) async {
    await _pump(tester, const AdvisorJobDetailView(jc: _testJob));

    expect(find.text('JC-2026-1042'), findsWidgets);
    expect(find.text('Rashid Al Nuaimi'), findsWidgets);
    expect(find.text('Vehicle Details'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);
    expect(find.text('Call Customer'), findsOneWidget);
    expect(find.text('Vehicle Telemetry'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Job detail surfaces a load error with retry', (tester) async {
    await _pump(
      tester,
      const AdvisorJobDetailView(jc: _testJob),
      overrides: [
        advisorRemoteDataSourceProvider.overrideWithValue(
          _FailingAdvisorRemoteDataSource(),
        ),
      ],
    );
    expect(
      find.textContaining("We couldn't load this job card"),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Approval sheet exposes approve and send-back callbacks', (
    tester,
  ) async {
    var approved = 0;
    var rejected = 0;
    await _pumpSheets(
      tester,
      AdvisorApprovalSheet(
        pa: _mockApprovals.first,
        onApprove: () => approved++,
        onReject: () => rejected++,
      ),
    );
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Send Back'), findsOneWidget);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(approved, 1);
  });

  testWidgets('Contact sheet exposes call / WhatsApp / SMS callbacks', (
    tester,
  ) async {
    var calls = 0;
    await _pumpSheets(
      tester,
      AdvisorContactSheet(
        r: const FollowupReminderEntity(
          customerName: 'Saeed Al Marzouqi',
          vehicleId: 'DXB-4821',
          task: 'Follow up on estimate',
          dueDate: 'Today',
          priority: ReminderPriority.high,
        ),
        onCall: () => calls++,
        onWhatsApp: () {},
        onSms: () {},
        onDone: () {},
      ),
    );
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('SMS'), findsOneWidget);
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('Profile sheet and notification sheet render', (tester) async {
    await _pumpSheets(tester, AdvisorProfileSheet(onLogout: () {}));
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Attendance · Punch In / Out'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    await _pumpSheets(tester, const AdvisorNotificationSheet());
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('Stat dialog renders metric and view-all action', (tester) async {
    var viewAll = 0;
    await _pumpSheets(
      tester,
      AdvisorStatDialog(
        label: 'Total Orders',
        count: 12,
        color: AppColors.primary,
        onViewAll: () => viewAll++,
      ),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(viewAll, 1);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorDashboardProvider.overrideWith(
          (ref) => Future.value(_mockStats),
        ),
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future.value(_mockJobs),
        ),
        advisorPendingApprovalsProvider.overrideWith(
          (ref) => Future.value(_mockApprovals),
        ),
        advisorReportDataProvider.overrideWith(
          (ref) => Future.value(_mockReportData),
        ),
        advisorInfoProvider.overrideWithValue(
          const AdvisorInfo(
            name: 'Zayn Malik',
            id: 'ADV-014',
            branch: 'Al Quoz Central',
            shift: 'Morning Shift (08:00 - 17:00)',
          ),
        ),
        advisorRemoteDataSourceProvider.overrideWithValue(
          _FakeAdvisorRemoteDataSource(),
        ),
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
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

Future<void> _pumpSheets(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorInfoProvider.overrideWithValue(
          const AdvisorInfo(
            name: 'Zayn Malik',
            id: 'ADV-014',
            branch: 'Al Quoz Central',
            shift: 'Morning Shift',
          ),
        ),
        advisorRemoteDataSourceProvider.overrideWithValue(
          _FakeAdvisorRemoteDataSource(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAdvisorRemoteDataSource implements AdvisorRemoteDataSource {
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
  Future<List<WorkItemResponse>> getWorkItems(String jobCardRef) async =>
      const [];

  @override
  Future<AdvisorStatsResponse> getStats() async => const AdvisorStatsResponse();

  @override
  Future<PageResponse<JobCardResponse>> getJobCards({
    int page = 1,
    int size = 20,
  }) async => const PageResponse(
    content: [],
    totalElements: 0,
    totalPages: 0,
    page: 1,
    size: 20,
  );

  @override
  Future<List<PendingApprovalResponse>> getPendingApprovals() async => const [];

  @override
  Future<List<ReminderResponse>> getReminders() async => const [];

  @override
  Future<List<AdvisorBookingResponse>> getAssignedBookings() async => const [];

  @override
  Future<List<AdvisorTechnicianResponse>> getTechnicians() async => const [];

  @override
  Future<List<StaffNotificationResponse>> getStaffNotifications() async =>
      const [];

  @override
  Future<ReportResponse> getReports([String? range]) async =>
      const ReportResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FailingAdvisorRemoteDataSource extends _FakeAdvisorRemoteDataSource {
  @override
  Future<JobCardDetailResponse> getJobCard(String id) async {
    throw const NetworkException('offline');
  }
}
