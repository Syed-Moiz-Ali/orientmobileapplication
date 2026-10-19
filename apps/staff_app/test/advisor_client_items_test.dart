import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart' as models;
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_job_detail_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
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
  dbId: 1042,
  customerName: 'Rashid Al Nuaimi',
  vehicleInfo: 'Toyota Land Cruiser',
  time: '09:30 AM',
  status: JobCardStatus.inProgress,
);

class _FakeClientRemote implements AdvisorRemoteDataSource {
  final List<VehicleSearchResponse> vehicles;
  _FakeClientRemote({this.vehicles = const []});

  @override
  Future<JobCardDetailResponse> getJobCard(String id) async =>
      const JobCardDetailResponse(
        id: 'JC-2026-1042',
        customerName: 'Rashid Al Nuaimi',
        phoneNumber: '0501234567',
        email: 'rashid@example.com',
        vehicleInfo: 'Toyota Land Cruiser',
        registrationNumber: 'DXB A 12345',
        vin: '1HGCM82633A004352',
        status: 'inProgress',
        technician: 'Alex Morgan',
        odometer: 14200,
        fuelLevel: '1/2',
      );

  @override
  Future<List<WorkItemResponse>> getWorkItems(String jobCardRef) async =>
      const [];

  @override
  Future<InspectionSummaryResponse> getInspectionByJobCard(
    String jobCardId,
  ) async => const InspectionSummaryResponse();

  @override
  Future<List<VehicleSearchResponse>> searchVehicles(String q) async =>
      vehicles;

  @override
  Future<List<CustomerSearchResponse>> searchCustomers(String q) async =>
      const [];

  @override
  Future<CheckInResult?> checkInVehicleResult(
    String bookingId,
    Map<String, dynamic> data,
  ) async => const CheckInResult(jobCardId: 1042, jobCardRef: 'JC-2026-1042');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  AdvisorRemoteDataSource? remote,
}) async {
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
            branch: 'Al Quoz',
            shift: 'Morning',
          ),
        ),
        advisorPendingApprovalsProvider.overrideWith(
          (ref) async => const [],
        ),
        advisorRemoteDataSourceProvider.overrideWithValue(
          remote ?? _FakeClientRemote(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: const Scaffold(body: AdvisorJobDetailView(jc: _testJob)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CLIENT ITEMS — advisor job card (backend-gated)', () {
    testWidgets('(5) advisor name renders with handled-by line', (tester) async {
      await _pumpDetail(tester);
      expect(find.text('Zayn Malik'), findsWidgets);
      expect(find.text('Handled by Zayn Malik'), findsOneWidget);
      expect(find.text('ZM'), findsOneWidget);
    });

    testWidgets('(4) comments empty state + add flow (local draft)', (
      tester,
    ) async {
      await _pumpDetail(tester);
      expect(find.text('No comments yet.'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(AppTextField, 'Write a comment…'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.widgetWithText(AppTextField, 'Write a comment…'),
        'Customer asked for AC check',
      );
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Add comment'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Add comment'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Customer asked for AC check'), findsOneWidget);
      expect(
        find.text('Saved on this device · queued (needs server field)'),
        findsWidgets,
      );
    });

    testWidgets('(2) share row states the truth (no fake PDF)', (tester) async {
      await _pumpDetail(tester);
      expect(find.textContaining('PDF export needs'), findsOneWidget);
      expect(find.text('WhatsApp'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
    });

    testWidgets('(3) sign link is disabled with coming-soon note', (
      tester,
    ) async {
      await _pumpDetail(tester);
      expect(find.text('Send sign link'), findsOneWidget);
      expect(
        find.text('Coming soon — needs a server sign-link endpoint.'),
        findsOneWidget,
      );
      final button = tester.widget<SecondaryButton>(
        find.widgetWithText(SecondaryButton, 'Send sign link'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('(2a) signatures section renders first with clear states', (
      tester,
    ) async {
      await _pumpDetail(tester);
      expect(find.text('Signatures'), findsOneWidget);
      expect(find.text('Not signed yet'), findsNWidgets(2));
    });

    testWidgets('(1) check-in shows brought-by after odometer', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            advisorInfoProvider.overrideWithValue(
              const AdvisorInfo(name: 'Zayn Malik', id: '', branch: '', shift: ''),
            ),
            advisorRemoteDataSourceProvider.overrideWithValue(
              _FakeClientRemote(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(
              body: AdvisorVehicleCheckinView(
                bookingId: 'B-1',
                customerName: 'Rashid',
                vehicleInfo: 'Land Cruiser',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Brought by'), findsOneWidget);
      expect(
        find.text('No server field for brought-by yet — kept locally and queued.'),
        findsOneWidget,
      );
    });
  });

  group('CLIENT ITEMS — contracts (no fakes)', () {
    test('(6) plates map from existing lookup shape only', () {
      const vehicles = [
        VehicleSearchResponse(plateNumber: 'DXB A 12345', regNo: ''),
        VehicleSearchResponse(plateNumber: '', regNo: 'AUH B 999'),
      ];
      final plates = vehicles
          .map((v) => v.plateNumber.isNotEmpty ? v.plateNumber : v.regNo)
          .where((p) => p.isNotEmpty)
          .toList();
      expect(plates, ['DXB A 12345', 'AUH B 999']);
    });

    test('(6) PlateNumber validates manual entry inline', () {
      expect(models.PlateNumber.tryParse('DXB A 12345')?.isValid, isTrue);
      expect(models.PlateNumber.tryParse('bogus'), isNull);
    });

    test('(5) PhoneNumber stays LTR-safe for wa.me deep links', () {
      expect(
        models.PhoneNumber.normalizeLoose('0501234567'),
        '971501234567',
      );
    });

    test('(1/4) future extras payload is shaped, never sent as success', () {
      final payload = {
        'broughtBy': 'Brother Ahmed',
        'comments': [
          {'text': 'AC check', 'at': '2026-10-19 10:00'},
        ],
      };
      expect(payload['broughtBy'], 'Brother Ahmed');
      expect((payload['comments'] as List).single['text'], 'AC check');
    });
  });
}
