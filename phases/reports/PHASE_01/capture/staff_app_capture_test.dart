import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';

/// TEMPORARY Phase 01 evidence capture harness.
/// Run: flutter test --update-goldens test\_phase01_evidence_capture_test.dart
/// from `apps/staff_app`; the PNGs land in
/// `phases/reports/PHASE_01/screens/`. Delete after capture.
void main() {
  setUpAll(_loadFonts);

  final cases = <String, _Case>{
    'staff_advisor_home_390_light': _Case(const Size(390, 844), 1.0),
    'staff_advisor_home_768_light': _Case(const Size(768, 1024), 1.0),
    'staff_advisor_home_1280_light': _Case(const Size(1280, 800), 1.0),
    'staff_advisor_home_320_light': _Case(const Size(320, 640), 1.0),
    'staff_advisor_home_390_scale13': _Case(const Size(390, 844), 1.3),
    'staff_advisor_home_390_dark': _Case(
      const Size(390, 844),
      1.0,
      dark: true,
    ),
  };

  cases.forEach((name, c) {
    testWidgets('capture $name', (tester) async {
      tester.view.physicalSize = c.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const mockStats = AdvisorStatsEntity(
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            advisorDashboardProvider.overrideWith(
              (ref) => Future.value(mockStats),
            ),
            advisorRecentJobCardsProvider.overrideWith(
              (ref) => Future.value(mockJobs),
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
            theme: c.dark
                ? AppTheme.dark(BrandConfig.orient)
                : AppTheme.light(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(c.scale)),
              child: child!,
            ),
            home: const Scaffold(body: AdvisorHomeView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AdvisorHomeView),
        matchesGoldenFile(
          '../../../phases/reports/PHASE_01/screens/$name.png',
        ),
      );
    });
  });
}

class _Case {
  final Size size;
  final double scale;
  final bool dark;
  const _Case(this.size, this.scale, {this.dark = false});
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
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
