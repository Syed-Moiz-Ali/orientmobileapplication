import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 01 (H3) — real-context layout smoke tests.
///
/// After the 0.85x text-scale lock removal, the real Advisor Home and Staff
/// Profile compositions must build with no exceptions and no RenderFlex
/// overflow at default scale and 1.3x, at phone widths and with the shared
/// token typography resolving through the theme.
void main() {
  for (final scale in <double>[1.0, 1.3]) {
    testWidgets('AdvisorHomeView lays out at ${scale}x with real providers', (
      tester,
    ) async {
      await _pumpAdvisor(tester, const AdvisorHomeView(), scale: scale);

      expect(tester.takeException(), isNull);
      expect(find.text('Work Summary'), findsOneWidget);

      final context = tester.element(find.byType(AdvisorHomeView));
      expect(
        Theme.of(context).textTheme.bodyMedium?.fontFamily,
        AppFontFamilies.app,
      );
    });
  }

  testWidgets('AdvisorHomeView survives 320 px at 1.3x', (tester) async {
    await _pumpAdvisor(
      tester,
      const AdvisorHomeView(),
      scale: 1.3,
      size: const Size(320, 640),
    );
    expect(tester.takeException(), isNull);
  });

  for (final scale in <double>[1.0, 1.3]) {
    testWidgets('StaffProfileScreen lays out at ${scale}x', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final profile = ProfileData(
        name: 'Rashid Al Nuaimi',
        id: 'TECH-1042',
        role: 'Technician',
        branch: 'Al Quoz Central',
        shift: 'Morning Shift',
        email: 'rashid@orient.ae',
        phone: '+971 50 123 4567',
        avatarInitials: 'RN',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(
              () => _FakeAuthNotifier(role: UserRole.technician),
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
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(body: StaffProfileScreen(data: profile)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Rashid Al Nuaimi'), findsOneWidget);
    });
  }
}

Future<void> _pumpAdvisor(
  WidgetTester tester,
  Widget child, {
  required double scale,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
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
        advisorDashboardProvider.overrideWith((ref) => Future.value(mockStats)),
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({required UserRole role}) : _role = role;

  final UserRole _role;

  @override
  AuthState build() =>
      AuthAuthenticated(role: _role, token: 'test_token', profile: null);
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
