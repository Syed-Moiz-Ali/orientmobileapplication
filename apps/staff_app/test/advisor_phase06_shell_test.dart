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
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_search_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 06 — Phase 04.1 shell integration, ⌘K/Ctrl+K search shortcut,
/// offline-pill coordination and responsive composition for the advisor hub.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

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
];

const _mockStats = AdvisorStatsEntity(
  newJobCardsToday: 5,
  inspectionsToday: 3,
  pendingApprovals: 2,
  vehiclesWaiting: 1,
  readyForDelivery: 4,
  totalOpenJobCards: 12,
);

// Six urgent-first rows for the 390px viewport test (distinct times).
const _mockViewportJobs = <JobCardEntity>[
  JobCardEntity(
    id: 'JC-2026-1041',
    customerName: 'Ahmed Al Farsi',
    vehicleInfo: 'Toyota Corolla',
    time: '08:00 AM',
    status: JobCardStatus.pendingApproval,
    technician: '',
    odometer: 20000,
    fuelLevel: '60%',
  ),
  JobCardEntity(
    id: 'JC-2026-1042',
    customerName: 'Rashid Al Nuaimi',
    vehicleInfo: 'Toyota Land Cruiser',
    time: '08:30 AM',
    status: JobCardStatus.waitingParts,
    technician: 'Alex Morgan',
    odometer: 14200,
    fuelLevel: '75%',
  ),
  JobCardEntity(
    id: 'JC-2026-1043',
    customerName: 'Fatima Al Mansoori',
    vehicleInfo: 'Nissan Patrol',
    time: '09:00 AM',
    status: JobCardStatus.inProgress,
    technician: 'Alex Morgan',
    odometer: 32000,
    fuelLevel: '50%',
  ),
  JobCardEntity(
    id: 'JC-2026-1044',
    customerName: 'Khalid Al Zaabi',
    vehicleInfo: 'Honda Accord',
    time: '09:30 AM',
    status: JobCardStatus.inProgress,
    technician: '',
    odometer: 45000,
    fuelLevel: '40%',
  ),
  JobCardEntity(
    id: 'JC-2026-1045',
    customerName: 'Mariam Al Suwaidi',
    vehicleInfo: 'Hyundai Tucson',
    time: '10:00 AM',
    status: JobCardStatus.completed,
    technician: '',
    odometer: 60000,
    fuelLevel: '80%',
  ),
  JobCardEntity(
    id: 'JC-2026-1046',
    customerName: 'Omar Al Shamsi',
    vehicleInfo: 'Kia Sportage',
    time: '10:30 AM',
    status: JobCardStatus.delivered,
    technician: '',
    odometer: 15000,
    fuelLevel: '90%',
  ),
];

void main() {
  testWidgets('advisor home uses a greeting header, not WorkspaceAppBar', (
    tester,
  ) async {
    await _pump(tester, const AdvisorHomeView());
    // Product exception (Phase 06 correction D2): shell chrome rejected for
    // this tab; the greeting header owns search + offline pill + bell + avatar.
    expect(find.byType(WorkspaceAppBar), findsNothing);
    expect(find.byType(OfflineStatusPill), findsOneWidget);
    expect(find.byType(WorkspaceSearchShortcuts), findsOneWidget);
    expect(find.textContaining('Good to see you'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ctrl+K opens the advisor search sheet', (tester) async {
    await _pump(tester, const AdvisorHomeView());
    expect(find.byType(AdvisorSearchSheet), findsNothing);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.byType(AdvisorSearchSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the header search button also opens the search sheet', (
    tester,
  ) async {
    await _pump(tester, const AdvisorHomeView());
    final trigger = find.widgetWithIcon(IconButton, Icons.search_rounded);
    expect(trigger, findsOneWidget);
    await tester.tap(trigger, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(AdvisorSearchSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search hero leads, all assigned rows reachable at 390', (
    tester,
  ) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      size: const Size(390, 844),
      overrides: [
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future.value(_mockViewportJobs),
        ),
      ],
    );
    // Live direction (30% search hero) trades first-fold rows for search
    // prominence: hero + grid own the first viewport, rows sit one scroll
    // below. All six urgent-first rows must be reachable with zero overflow.
    expect(find.text('Search'), findsOneWidget);
    for (final time in ['08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM']) {
      await tester.dragUntilVisible(
        find.text(time),
        find.byType(CustomScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text(time), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(390, 844), Size(768, 1024), Size(1280, 800)]) {
    testWidgets('advisor home renders without overflow at ${size.width}px', (
      tester,
    ) async {
      await _pump(tester, const AdvisorHomeView(), size: size);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dark theme renders the advisor home without exceptions', (
    tester,
  ) async {
    await _pump(tester, const AdvisorHomeView(), dark: true);
    expect(find.byType(OfflineStatusPill), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jobs uses a master-detail matrix on desktop', (tester) async {
    await _pump(
      tester,
      AdvisorJobsListView(onJobCard: (_) {}),
      size: const Size(1280, 800),
    );
    expect(find.byType(AppMasterDetailScaffold), findsOneWidget);
    expect(find.byType(AppTable<JobCardEntity>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jobs degrades to a single work list on mobile', (tester) async {
    await _pump(
      tester,
      AdvisorJobsListView(onJobCard: (_) {}),
      size: const Size(390, 844),
    );
    expect(find.byType(AppMasterDetailScaffold), findsNothing);
    expect(find.byType(AppSearchField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  bool dark = false,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorDashboardProvider.overrideWith((ref) => Future.value(_mockStats)),
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future.value(_mockJobs),
        ),
        advisorPendingApprovalsProvider.overrideWith(
          (ref) => Future.value(const <PendingApprovalEntity>[]),
        ),
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
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAdvisorRemoteDataSource implements AdvisorRemoteDataSource {
  @override
  Future<JobCardDetailResponse> getJobCard(String id) async =>
      const JobCardDetailResponse(
        id: 'JC-2026-1042',
        customerName: 'Rashid Al Nuaimi',
        vehicleInfo: '2024 Toyota Land Cruiser',
        status: 'inProgress',
        technician: 'Alex Morgan',
        odometer: 14200,
        fuelLevel: '75%',
      );

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
