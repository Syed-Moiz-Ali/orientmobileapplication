import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_approval_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_contact_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_notification_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_profile_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_search_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 06 — additional visual-state references (dark theme, offline/queued,
/// loading/error/empty/no-match, search, modal sheets and the desktop jobs
/// matrix). These complement `advisor_phase06_visual_test.dart` and cover the
/// states flagged by the Gate 2 audit. New, Phase 06-owned golden names only.
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
  vehicleInfo: 'Toyota Land Cruiser',
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

const _reminder = FollowupReminderEntity(
  customerName: 'Saeed Al Marzouqi',
  vehicleId: 'DXB-4821',
  task: 'Follow up on estimate',
  dueDate: 'Today',
  priority: ReminderPriority.high,
);

void main() {
  setUpAll(_loadFonts);

  // ── Dark theme ─────────────────────────────────────────────────────────────
  testWidgets('dark home 390 en', (tester) async {
    await _pump(tester, const AdvisorHomeView(), dark: true);
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_dark_home_390_en.png'),
    );
  });

  testWidgets('dark home 390 ar', (tester) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      dark: true,
      locale: const Locale('ar'),
    );
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_dark_home_390_ar.png'),
    );
  });

  testWidgets('dark job detail 1280 en', (tester) async {
    await _pump(
      tester,
      const AdvisorJobDetailView(jc: _testJob),
      dark: true,
      size: const Size(1280, 800),
    );
    await expectLater(
      find.byType(AdvisorJobDetailView),
      matchesGoldenFile('goldens/advisor_states_dark_detail_1280_en.png'),
    );
  });

  // ── Offline + pending-sync ─────────────────────────────────────────────────
  testWidgets('offline home 390 en', (tester) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      overrides: [
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(ConnectivityResult.none),
        ),
      ],
    );
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_offline_390_en.png'),
    );
  });

  testWidgets('pending-sync queued home 390 en', (tester) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      overrides: [
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(ConnectivityResult.none),
        ),
        advisorPendingSyncCountProvider.overrideWith(
          (ref) => Stream.value(3),
        ),
      ],
    );
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_queued_390_en.png'),
    );
  });

  // ── Loading / error / empty / no-match ─────────────────────────────────────
  testWidgets('loading home 390 en', (tester) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      overrides: [
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Completer<List<JobCardEntity>>().future,
        ),
        advisorAssignedBookingsProvider.overrideWith(
          (ref) => Completer<List<AdvisorBookingResponse>>().future,
        ),
      ],
      settle: false,
    );
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_loading_390_en.png'),
    );
  });

  testWidgets('error home 390 en', (tester) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      overrides: [
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future<List<JobCardEntity>>.error(
            const NetworkException('offline'),
          ),
        ),
      ],
    );
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_error_390_en.png'),
    );
  });

  testWidgets('empty jobs 390 en', (tester) async {
    await _pump(
      tester,
      AdvisorJobsListView(onJobCard: (_) {}),
      overrides: [
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future.value(const <JobCardEntity>[]),
        ),
      ],
    );
    await expectLater(
      find.byType(AdvisorJobsListView),
      matchesGoldenFile('goldens/advisor_states_jobs_empty_390_en.png'),
    );
  });

  testWidgets('no-match jobs 390 en', (tester) async {
    await _pump(tester, AdvisorJobsListView(onJobCard: (_) {}));
    await tester.enterText(find.byType(TextField), 'zzz-none');
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AdvisorJobsListView),
      matchesGoldenFile('goldens/advisor_states_jobs_nomatch_390_en.png'),
    );
  });

  testWidgets('empty assigned home 390 en', (tester) async {
    await _pump(
      tester,
      const AdvisorHomeView(),
      overrides: [
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future.value(const <JobCardEntity>[]),
        ),
        advisorPendingApprovalsProvider.overrideWith(
          (ref) => Future.value(const <PendingApprovalEntity>[]),
        ),
      ],
    );
    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile('goldens/advisor_states_home_empty_390_en.png'),
    );
  });

  // ── Desktop jobs matrix ────────────────────────────────────────────────────
  testWidgets('jobs desktop matrix 1280 en', (tester) async {
    await _pump(
      tester,
      AdvisorJobsListView(onJobCard: (_) {}),
      size: const Size(1280, 800),
    );
    await expectLater(
      find.byType(AdvisorJobsListView),
      matchesGoldenFile('goldens/advisor_states_jobs_matrix_1280_en.png'),
    );
  });

  // ── Search sheet + results ─────────────────────────────────────────────────
  testWidgets('search results sheet 390 en', (tester) async {
    await _pumpSheet(
      tester,
      AdvisorSearchSheet(onScan: () {}),
    );
    await tester.enterText(find.byType(TextField), 'Rashid');
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AdvisorSearchSheet),
      matchesGoldenFile('goldens/advisor_states_search_390_en.png'),
    );
  });

  // ── Modal sheets ───────────────────────────────────────────────────────────
  testWidgets('notification sheet 390 en', (tester) async {
    await _pumpSheet(tester, const AdvisorNotificationSheet());
    await expectLater(
      find.byType(AdvisorNotificationSheet),
      matchesGoldenFile('goldens/advisor_states_sheet_notification_390_en.png'),
    );
  });

  testWidgets('profile sheet 390 en', (tester) async {
    await _pumpSheet(tester, AdvisorProfileSheet(onLogout: () {}));
    await expectLater(
      find.byType(AdvisorProfileSheet),
      matchesGoldenFile('goldens/advisor_states_sheet_profile_390_en.png'),
    );
  });

  testWidgets('contact sheet 390 en', (tester) async {
    await _pumpSheet(
      tester,
      AdvisorContactSheet(
        r: _reminder,
        onCall: () {},
        onWhatsApp: () {},
        onSms: () {},
        onDone: () {},
      ),
    );
    await expectLater(
      find.byType(AdvisorContactSheet),
      matchesGoldenFile('goldens/advisor_states_sheet_contact_390_en.png'),
    );
  });

  testWidgets('approval sheet 390 en', (tester) async {
    await _pumpSheet(
      tester,
      AdvisorApprovalSheet(
        pa: _mockApprovals.first,
        onApprove: () {},
        onReject: () {},
      ),
    );
    await expectLater(
      find.byType(AdvisorApprovalSheet),
      matchesGoldenFile('goldens/advisor_states_sheet_approval_390_en.png'),
    );
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  bool dark = false,
  bool settle = true,
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
          (ref) => Future.value(_mockApprovals),
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
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _pumpSheet(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorRecentJobCardsProvider.overrideWith(
          (ref) => Future.value(_mockJobs),
        ),
        advisorPendingApprovalsProvider.overrideWith(
          (ref) => Future.value(_mockApprovals),
        ),
        advisorNotificationsProvider.overrideWith(
          (ref) => Future.value(const <StaffNotificationResponse>[]),
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
  Future<JobCardDetailResponse> getJobCard(String id) async =>
      const JobCardDetailResponse(
        id: 'JC-2026-1042',
        customerName: 'Rashid Al Nuaimi',
        phoneNumber: '0501234567',
        vehicleInfo: '2024 Toyota Land Cruiser',
        registrationNumber: 'DXB M 84920',
        vin: '1HGCM82633A004352',
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
