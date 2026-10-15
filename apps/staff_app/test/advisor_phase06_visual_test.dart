import 'dart:io';

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
import 'package:staff_app/features/advisor/presentation/pages/advisor_job_detail_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_reports_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 06 — advisor workspace visual references (EN/AR, mobile/tablet/
/// desktop). Regenerated only for the screens intentionally redesigned in
/// Phase 06 and visually reviewed before re-baselining (J2 gate).
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
  setUpAll(_loadFonts);
  setUp(() {
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

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    for (final (sizeLabel, size) in <(String, Size)>[
      ('390', const Size(390, 844)),
      ('768', const Size(768, 1024)),
      ('1280', const Size(1280, 800)),
    ]) {
      testWidgets('today $sizeLabel $label', (tester) async {
        await _pump(tester, const AdvisorHomeView(), size, locale);
        await expectLater(
          find.byType(AdvisorHomeView),
          matchesGoldenFile('goldens/advisor_today_${sizeLabel}_$label.png'),
        );
      });
    }

    testWidgets('jobs 390 $label', (tester) async {
      await _pump(
        tester,
        AdvisorJobsListView(onJobCard: (_) {}),
        const Size(390, 844),
        locale,
      );
      await expectLater(
        find.byType(AdvisorJobsListView),
        matchesGoldenFile('goldens/advisor_jobs_390_$label.png'),
      );
    });

    testWidgets('reports 390 $label', (tester) async {
      await _pump(tester, const AdvisorReportsView(), const Size(390, 844), locale);
      await expectLater(
        find.byType(AdvisorReportsView),
        matchesGoldenFile('goldens/advisor_reports_390_$label.png'),
      );
    });

    for (final (sizeLabel, size) in <(String, Size)>[
      ('390', const Size(390, 844)),
      ('1280', const Size(1280, 800)),
    ]) {
      testWidgets('job detail $sizeLabel $label', (tester) async {
        await _pump(
          tester,
          const AdvisorJobDetailView(jc: _testJob),
          size,
          locale,
        );
        await expectLater(
          find.byType(AdvisorJobDetailView),
          matchesGoldenFile(
            'goldens/advisor_job_detail_${sizeLabel}_$label.png',
          ),
        );
      });
    }
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale,
) async {
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
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
      phoneNumber: '0501234567',
      vehicleInfo: '2024 Toyota Land Cruiser',
      registrationNumber: 'DXB M 84920',
      vin: '1HGCM82633A004352',
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
