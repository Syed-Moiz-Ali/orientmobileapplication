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

/// TEMPORARY Phase 01 evidence capture harness — empty state (staff).
void main() {
  setUpAll(_loadFonts);

  testWidgets('capture staff_advisor_home_390_empty', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          advisorDashboardProvider.overrideWith(
            (ref) => Future.value(const AdvisorStatsEntity(
              newJobCardsToday: 0,
              inspectionsToday: 0,
              pendingApprovals: 0,
              vehiclesWaiting: 0,
              readyForDelivery: 0,
              totalOpenJobCards: 0,
            )),
          ),
          advisorRecentJobCardsProvider.overrideWith(
            (ref) => Future.value(const <JobCardEntity>[]),
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
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(body: AdvisorHomeView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AdvisorHomeView),
      matchesGoldenFile(
        '../../../phases/reports/PHASE_01/screens/'
        'staff_advisor_home_390_empty.png',
      ),
    );
  });
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
