import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart' as models;
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_job_detail_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/vehicle_customer_provider.dart';
import 'package:staff_app/features/advisor/presentation/widgets/job_card_pdf.dart';
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

const _extrasKey = 'job_extras_1042';

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
      const [
        WorkItemResponse(description: 'Replace brake pads', status: 'pending'),
        WorkItemResponse(description: 'Rotate tyres', status: 'completed'),
      ];

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
  Size size = const Size(390, 844),
  AdvisorRemoteDataSource? remote,
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
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
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: const Scaffold(body: AdvisorJobDetailView(jc: _testJob)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<ByteData> _arabicFont(String name) async {
  final sep = Platform.pathSeparator;
  final bytes = await File(
    '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
    '${sep}ibm_plex_sans_arabic$sep$name',
  ).readAsBytes();
  return ByteData.sublistView(bytes);
}

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('client_items_hive');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('inspections');
  });

  tearDownAll(() async {
    try {
      await Hive.box<dynamic>('inspections').clear();
      await Hive.box<dynamic>('inspections').close();
    } catch (_) {}
  });

  setUp(() async {
    AdvisorJobDetailView.debugShareOverride = null;
    try {
      await Hive.box<dynamic>('inspections').clear();
    } catch (_) {}
  });

  group('placement order (wrong order = FAIL)', () {
    testWidgets('detail dossier order is locked', (tester) async {
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'broughtBy': 'Driver Ahmed',
        'comments': [
          {'text': 'AC check', 'at': '2026-10-19 10:00', 'author': 'Zayn Malik'},
        ],
        'customerSigState': 'requested',
        'customerSigRequestedAt': '2026-10-19 10:01',
      });
      // Tall viewport renders the whole dossier at once for order checks.
      await _pumpDetail(tester, size: const Size(390, 4000));
      final ordered = [
        find.text('DXB A 12345'),
        find.textContaining('Brought by'),
        find.text('Comments'),
        find.text('Estimates'),
        find.text('Invoices'),
        find.text('Notes'),
        find.text('Signatures'),
        find.text('Share job card'),
      ];
      Offset? prev;
      for (final finder in ordered) {
        expect(finder, findsWidgets);
        final dy = tester.getCenter(finder.first).dy;
        if (prev != null) expect(dy, greaterThan(prev.dy));
        prev = Offset(0, dy);
      }
      // Sign flow lives INSIDE signatures; no standalone sign-link section.
      expect(find.text('Send sign link'), findsNothing);
      expect(find.textContaining('Coming soon'), findsNothing);
      // Zero leftover gated labels anywhere on screen.
      expect(find.textContaining('needs server field'), findsNothing);
      expect(find.textContaining('no PDF yet'), findsNothing);
      expect(find.textContaining('PDF export needs'), findsNothing);
    });
  });

  group('(6) vehicle plate dropdown (vehicle details only)', () {
    Future<void> pumpIntakeToVehicle(
      tester,
      AdvisorRemoteDataSource remote,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleCustomerFormProvider.overrideWith(
              () => VehicleCustomerFormNotifier()
                ..setCustomerName('Layla Haddad')
                ..setPhone('0501234567'),
            ),
            advisorRemoteDataSourceProvider.overrideWithValue(remote),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: VehicleCustomerView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Contact step has no plate UI — only the manual-free contact fields.
      expect(find.text('Existing plates'), findsNothing);
      // Valid contact advances to the vehicle deck.
      await tester.tap(find.text('Continue').first);
      await tester.pumpAndSettle();
      expect(find.text('Vehicle & plate'), findsOneWidget);
    }

    testWidgets('vehicle list replaces the manual number field', (
      tester,
    ) async {
      await pumpIntakeToVehicle(
        tester,
        _FakeClientRemote(
          vehicles: const [VehicleSearchResponse(plateNumber: 'DXB A 12345')],
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Existing plates'), findsOneWidget);
      // Manual emirate/code/number row is replaced by the vehicle list.
      expect(find.text('Plate number'), findsNothing);
      await tester.tap(find.text('Choose a plate or enter a new one'));
      await tester.pumpAndSettle();
      expect(find.text('DXB A 12345'), findsWidgets);
      expect(find.text('New plate'), findsOneWidget);
      // Selecting a vehicle fills the plate identity (preview strip).
      await tester.tap(find.text('DXB A 12345').last);
      await tester.pumpAndSettle();
      expect(find.text('Existing plates'), findsOneWidget);
      expect(find.text('DXB A 12345'), findsWidgets);
    });

    testWidgets('empty result keeps the manual plate field', (tester) async {
      await pumpIntakeToVehicle(tester, _FakeClientRemote());
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Existing plates'), findsNothing);
      expect(find.text('Plate number'), findsOneWidget);
    });

    testWidgets('"New plate" reveals manual entry', (tester) async {
      await pumpIntakeToVehicle(
        tester,
        _FakeClientRemote(
          vehicles: const [VehicleSearchResponse(plateNumber: 'DXB A 12345')],
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose a plate or enter a new one'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New plate').last);
      await tester.pumpAndSettle();
      expect(find.text('Plate number'), findsOneWidget);
    });

    test('PlateNumber validates manual entry inline', () {
      expect(models.PlateNumber.tryParse('DXB A 12345')?.isValid, isTrue);
      expect(models.PlateNumber.tryParse('bogus'), isNull);
    });
  });

  group('(1) brought-by after odometer + saved', () {
    testWidgets('identity shows brought-by under odo with saved pill', (
      tester,
    ) async {
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'broughtBy': 'Driver Ahmed',
      });
      await _pumpDetail(tester);
      expect(find.textContaining('Brought by: Driver Ahmed'), findsOneWidget);
      expect(find.text('Saved on device'), findsWidgets);
      final odoDy = tester.getCenter(find.text('14200 km').first).dy;
      final broughtDy = tester
          .getCenter(find.textContaining('Brought by').first)
          .dy;
      expect(broughtDy, greaterThan(odoDy));
    });

    testWidgets('check-in persists brought-by per job id (restart-proof)', (
      tester,
    ) async {
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
      await tester.enterText(
        find.widgetWithText(AppTextField, 'Name of the person who brought the vehicle'),
        'Driver Ahmed',
      );
      await tester.pump();
      // First tap moves to the confirmation review (brought-by listed).
      await tester.tap(find.text('Complete check-in').first);
      await tester.pumpAndSettle();
      expect(find.text('Driver Ahmed'), findsWidgets);
      // Second tap submits; extras land in Hive under the new job id.
      await tester.tap(find.text('Complete check-in').first);
      await tester.pumpAndSettle();
      final box = Hive.box<dynamic>('inspections');
      expect((box.get('job_extras_1042') as Map)['broughtBy'], 'Driver Ahmed');
      // Restart: a fresh detail instance shows it (Hive is truth).
      await _pumpDetail(tester);
      expect(find.textContaining('Brought by: Driver Ahmed'), findsOneWidget);
    });
  });

  group('(5) advisor name', () {
    testWidgets('identity footer + handled-by + saved byline', (tester) async {
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'broughtBy': 'Driver Ahmed',
      });
      await _pumpDetail(tester);
      expect(find.text('Zayn Malik'), findsWidgets);
      expect(find.text('Handled by Zayn Malik'), findsOneWidget);
      expect(find.text('ZM'), findsOneWidget);
      expect(
        find.text('Saved on device by Zayn Malik'),
        findsOneWidget,
      );
      // PhoneNumber stays LTR-safe for wa.me deep links.
      expect(
        models.PhoneNumber.normalizeLoose('0501234567'),
        '971501234567',
      );
    });
  });

  group('(4) comments CRUD after job descriptions', () {
    testWidgets('empty → composer → save → card → delete → gone', (
      tester,
    ) async {
      await _pumpDetail(tester);
      expect(find.text('No comments yet.'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Add comment').first,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Add comment').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      // Composer card with autofocus + save/cancel.
      expect(
        find.widgetWithText(AppTextField, 'Write a comment…'),
        findsOneWidget,
      );
      expect(find.text('Save'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(AppTextField, 'Write a comment…'),
        'Customer asked for AC check',
      );
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      // Card: author + locale timestamp + text + saved pill.
      expect(find.text('Customer asked for AC check'), findsOneWidget);
      expect(find.text('Zayn Malik'), findsWidgets);
      expect(find.text('Saved on device'), findsWidgets);
      final box = Hive.box<dynamic>('inspections');
      final stored = (box.get(_extrasKey) as Map)['comments'] as List;
      expect(stored.single['author'], 'Zayn Malik');
      // Dismiss swipe is guarded by a confirm dialog.
      await tester.scrollUntilVisible(
        find.text('Customer asked for AC check'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(
        find.text('Customer asked for AC check'),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete this comment?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Customer asked for AC check'), findsNothing);
      expect(find.text('No comments yet.'), findsOneWidget);
    });

    testWidgets('multiple comments coexist + restart persists', (tester) async {
      await _pumpDetail(tester);
      for (final text in ['First note', 'Second note']) {
        await tester.scrollUntilVisible(
          find.text('Add comment').first,
          500,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Add comment').first, warnIfMissed: false);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(AppTextField, 'Write a comment…'),
          text,
        );
        await tester.pump();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
      }
      expect(find.text('First note'), findsOneWidget);
      expect(find.text('Second note'), findsOneWidget);
      // Restart: fresh instance replays both from Hive in stable order.
      await _pumpDetail(tester);
      final firstDy = tester.getCenter(find.text('First note')).dy;
      final secondDy = tester.getCenter(find.text('Second note')).dy;
      expect(secondDy, greaterThan(firstDy));
    });
  });

  group('(signatures + (3) sign flow)', () {
    testWidgets('unsigned → request attempt; requested → resend + mark', (
      tester,
    ) async {
      await _pumpDetail(tester);
      // Unsigned customer pad offers request + direct capture.
      expect(find.text('Not signed yet'), findsNWidgets(2));
      expect(find.text('Request signature'), findsOneWidget);
      // No plugin in tests: the WA intent fails honestly, stays unsigned.
      await tester.scrollUntilVisible(
        find.text('Request signature'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Request signature'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text("Couldn't open WhatsApp. Try again."), findsOneWidget);
      expect(find.text('Request signature'), findsOneWidget);

      // Requested state seeded: timestamp + resend + mark signed.
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'customerSigState': 'requested',
        'customerSigRequestedAt': '2026-10-19 10:01',
      });
      await _pumpDetail(tester);
      expect(
        find.textContaining('Requested via WhatsApp'),
        findsOneWidget,
      );
      expect(find.text('Resend'), findsOneWidget);
      expect(find.text('Mark signed'), findsOneWidget);
      // Mark signed opens the capture pad.
      await tester.scrollUntilVisible(
        find.text('Mark signed'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Mark signed'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Sign in the box below'), findsOneWidget);
    });

    testWidgets('pad capture → signed with saved image path', (tester) async {
      await _pumpDetail(tester);
      await tester.scrollUntilVisible(
        find.text('Mark signed'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      // Seed requested so Mark signed is visible.
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'customerSigState': 'requested',
        'customerSigRequestedAt': '2026-10-19 10:01',
      });
      await _pumpDetail(tester);
      await tester.scrollUntilVisible(
        find.text('Mark signed'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Mark signed'), warnIfMissed: false);
      await tester.pumpAndSettle();
      // Draw two strokes on the pad (the 220px signing surface), then confirm.
      final pad = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxHeight == 220 &&
            w.constraints?.minHeight == 220,
      );
      expect(pad, findsOneWidget);
      await tester.drag(pad, const Offset(60, 20));
      await tester.drag(pad, const Offset(-40, 30));
      await tester.pump();
      await tester.tap(find.text('Use signature'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Signed'), findsWidgets);
      final box = Hive.box<dynamic>('inspections');
      final stored = box.get(_extrasKey) as Map;
      expect(stored['customerSigState'], 'signed');
      expect((stored['customerSigPath'] as String).isNotEmpty, isTrue);
      expect(
        File(stored['customerSigPath'] as String).existsSync(),
        isTrue,
      );
    });
  });

  group('(2) real PDF share after signatures', () {
    JobCardPdfData pdfData({String total = 'AED 150.00'}) => JobCardPdfData(
      title: 'Job Card',
      jobId: 'JC-2026-1042',
      generatedAt: '2026-10-19 10:00',
      customerLabel: 'Customer',
      customerName: 'Rashid Al Nuaimi',
      phone: '0501234567',
      vehicleLabel: 'Vehicle',
      vehicleInfo: 'Toyota Land Cruiser',
      plate: 'DXB A 12345',
      vin: '1HGCM82633A004352',
      odometer: '14200 km',
      fuelLevel: '1/2',
      broughtByLabel: 'Brought by',
      broughtBy: 'Driver Ahmed',
      advisorLabel: 'Advisor',
      advisorName: 'Zayn Malik',
      statusLabel: 'Stages',
      status: 'inProgress',
      workLabel: 'Work',
      lines: const [
        JobCardPdfLine(description: 'Replace brake pads', status: 'pending'),
      ],
      commentsLabel: 'Comments',
      comments: const [
        JobCardPdfComment(
          author: 'Zayn Malik',
          at: '2026-10-19 10:00',
          text: 'AC check — تم الفحص',
        ),
      ],
      totalLabel: 'Total',
      amounts: const [
        JobCardPdfAmount(label: 'Estimate · EST-1', value: 'AED 100.00'),
        JobCardPdfAmount(label: 'Estimate · EST-2', value: 'AED 50.00'),
      ],
      totalValue: total,
      signaturesLabel: 'Signatures',
      customerSigLabel: 'Customer',
      advisorSigLabel: 'Advisor',
      unsignedLabel: 'Not signed yet',
    );

    test('PDF bytes nonempty + figures travel verbatim', () async {
      final data = pdfData();
      // Figures travel verbatim: the doc carries the exact UI strings.
      expect(data.totalValue, 'AED 150.00');
      expect(data.amounts.map((a) => a.value), ['AED 100.00', 'AED 50.00']);
      final bytes = await buildJobCardPdf(
        data,
        fontRegular: () => _arabicFont('IBMPlexSansArabic-Regular.ttf'),
        fontBold: () => _arabicFont('IBMPlexSansArabic-Bold.ttf'),
      );
      expect(bytes.length, greaterThan(2000));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('PDF builds with Arabic + signatures + empty optionals', () async {
      // Valid 1x1 PNG (signature images are real PNGs on device).
      final sig = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      );
      final full = await buildJobCardPdf(
        pdfData().copyWithAr(customerSignature: sig, advisorSignature: sig),
        fontRegular: () => _arabicFont('IBMPlexSansArabic-Regular.ttf'),
        fontBold: () => _arabicFont('IBMPlexSansArabic-Bold.ttf'),
      );
      expect(full.length, greaterThan(2000));
      const empty = JobCardPdfData(
        title: 'Job Card',
        jobId: 'JC-1',
        generatedAt: '2026-10-19 10:00',
        customerLabel: 'Customer',
        customerName: 'X',
        phone: '',
        vehicleLabel: 'Vehicle',
        vehicleInfo: 'Y',
        plate: '',
        vin: '',
        odometer: '',
        fuelLevel: '',
        broughtByLabel: 'Brought by',
        broughtBy: '',
        advisorLabel: 'Advisor',
        advisorName: 'Z',
        statusLabel: 'Stages',
        status: 'pending',
        workLabel: 'Work',
        commentsLabel: 'Comments',
        totalLabel: 'Total',
        totalValue: '',
        signaturesLabel: 'Signatures',
        customerSigLabel: 'Customer',
        advisorSigLabel: 'Advisor',
        unsignedLabel: 'Not signed yet',
      );
      final minimal = await buildJobCardPdf(
        empty,
        fontRegular: () => _arabicFont('IBMPlexSansArabic-Regular.ttf'),
        fontBold: () => _arabicFont('IBMPlexSansArabic-Bold.ttf'),
      );
      expect(minimal.length, greaterThan(1000));
    });

    testWidgets('share sheet attaches the real file, toast says PDF shared', (
      tester,
    ) async {
      final shared = <String>[];
      AdvisorJobDetailView.debugShareOverride = (files, {text}) async {
        shared.addAll(files.map((f) => f.path));
        return ShareResult('', ShareResultStatus.success);
      };
      await _pumpDetail(tester);
      await tester.scrollUntilVisible(
        find.text('WhatsApp').last,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('WhatsApp').last, warnIfMissed: false);
      await tester.pumpAndSettle();
      // Preview sheet with truthful contents + Share PDF CTA.
      expect(find.text('Share job card'), findsWidgets);
      expect(find.text('Share PDF'), findsOneWidget);
      await tester.tap(find.text('Share PDF'));
      await tester.pumpAndSettle();
      expect(shared, hasLength(1));
      expect(shared.single.endsWith('.pdf'), isTrue);
      expect(File(shared.single).existsSync(), isTrue);
      expect(find.text('PDF shared'), findsOneWidget);
      AdvisorJobDetailView.debugShareOverride = null;
    });

    testWidgets('share failure keeps sheet + retry, no fake toast', (
      tester,
    ) async {
      var calls = 0;
      AdvisorJobDetailView.debugShareOverride = (files, {text}) async {
        calls++;
        if (calls == 1) throw StateError('denied');
        return ShareResult('', ShareResultStatus.success);
      };
      await _pumpDetail(tester);
      await tester.scrollUntilVisible(
        find.text('WhatsApp').last,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('WhatsApp').last, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Share PDF'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't share the PDF. Try again."), findsOneWidget);
      expect(find.text('PDF shared'), findsNothing);
      // Retry succeeds.
      await tester.tap(find.text('Share PDF'));
      await tester.pumpAndSettle();
      expect(find.text('PDF shared'), findsOneWidget);
      AdvisorJobDetailView.debugShareOverride = null;
    });
  });

  group('goldens (touched surfaces only, real fonts)', () {
    Future<void> loadFonts() async {
      Future<void> load(String family, String relative) async {
        final bytes = await File(relative).readAsBytes();
        await (FontLoader(
          family,
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      }

      const sep = '/';
      await load(
        AppFontFamilies.app,
        'packages/shared_core/assets/fonts'
        '${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
      );
      for (final weight in <String>[
        'Regular',
        'Medium',
        'SemiBold',
        'Bold',
      ]) {
        await load(
          AppFontFamilies.arabic,
          'packages/shared_core/assets/fonts'
          '${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$weight.ttf',
        );
      }
    }

    testWidgets('detail full dossier 390 en', (tester) async {
      await loadFonts();
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'broughtBy': 'Driver Ahmed',
        'comments': [
          {'text': 'AC check', 'at': '2026-10-19 10:00', 'author': 'Zayn Malik'},
        ],
        'customerSigState': 'signed',
        'customerSignedAt': '2026-10-19 10:01',
      });
      await _pumpDetail(tester, size: const Size(390, 4000));
      await expectLater(
        find.byType(AdvisorJobDetailView),
        matchesGoldenFile('goldens/job_complete_detail_full_390_en.png'),
      );
    });

    testWidgets('detail full dossier 390 ar', (tester) async {
      await loadFonts();
      await Hive.box<dynamic>('inspections').put(_extrasKey, {
        'type': 'job_card_extras',
        'version': 2,
        'broughtBy': 'Driver Ahmed',
      });
      await _pumpDetail(
        tester,
        locale: const Locale('ar'),
        size: const Size(390, 4000),
      );
      await expectLater(
        find.byType(AdvisorJobDetailView),
        matchesGoldenFile('goldens/job_complete_detail_full_390_ar.png'),
      );
    });
  });
}

extension on JobCardPdfData {
  JobCardPdfData copyWithAr({
    Uint8List? customerSignature,
    Uint8List? advisorSignature,
  }) => JobCardPdfData(
    title: title,
    jobId: jobId,
    generatedAt: generatedAt,
    customerLabel: customerLabel,
    customerName: customerName,
    phone: phone,
    vehicleLabel: vehicleLabel,
    vehicleInfo: vehicleInfo,
    plate: plate,
    vin: vin,
    odometer: odometer,
    fuelLevel: fuelLevel,
    broughtByLabel: broughtByLabel,
    broughtBy: broughtBy,
    advisorLabel: advisorLabel,
    advisorName: advisorName,
    statusLabel: statusLabel,
    status: status,
    workLabel: workLabel,
    lines: lines,
    commentsLabel: commentsLabel,
    comments: comments,
    totalLabel: totalLabel,
    amounts: amounts,
    totalValue: totalValue,
    signaturesLabel: signaturesLabel,
    customerSigLabel: customerSigLabel,
    advisorSigLabel: advisorSigLabel,
    unsignedLabel: unsignedLabel,
    customerSignature: customerSignature ?? this.customerSignature,
    advisorSignature: advisorSignature ?? this.advisorSignature,
    rtl: true,
  );
}

