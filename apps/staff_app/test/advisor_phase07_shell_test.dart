import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/scan_vehicle_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_delivery_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/vehicle_customer_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 07 — shell integration (Phase 04.1), offline-queue coordination,
/// permission states, draft save/resume and responsive composition for the
/// vehicle intake studio.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  group('shell integration', () {
    testWidgets('intake wizard adopts WorkspaceAppBar + OfflineStatusPill', (
      tester,
    ) async {
      await _pump(tester, const VehicleCustomerView());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      // Compact widths use the slim journey progress (the four-node stepper
      // would squeeze past its minimum); the position stays explicit.
      expect(find.byType(AppLinearProgress), findsOneWidget);
      // The position is explicit in three places: app-bar subtitle, slim
      // progress label and deck header kicker.
      expect(find.text(t.advisorIntakeWizardStepOf(1, 4)), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('intake shows the tappable stepper on tablet widths', (
      tester,
    ) async {
      await _pump(
        tester,
        const VehicleCustomerView(),
        size: const Size(768, 1024),
      );
      expect(find.byType(AppStepper), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('check-in carries breadcrumbs + offline pill', (tester) async {
      await _pump(
        tester,
        const AdvisorVehicleCheckinView(
          bookingId: 'BK-2026-0042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
        ),
      );
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(AppBreadcrumbs), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('delivery carries breadcrumbs + offline pill', (tester) async {
      await _pump(tester, const VehicleDeliveryView(jobCardRef: 'JC-1042'));
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      expect(find.byType(AppBreadcrumbs), findsOneWidget);
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scanner uses the shared app bar with a torch action', (
      tester,
    ) async {
      await _pump(
        tester,
        const ScanVehicleView(scanMode: 'VIN'),
        settle: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(WorkspaceAppBar), findsOneWidget);
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.byTooltip(t.advisorScanTorch), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('wizard flow', () {
    testWidgets('empty first step is blocked with localized errors', (
      tester,
    ) async {
      await _pump(tester, const VehicleCustomerView());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorIntakeErrCustomerName), findsOneWidget);
      expect(find.text(t.advisorIntakeWizardBlocked), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('valid contact advances to the vehicle deck', (tester) async {
      await _pump(tester, const VehicleCustomerView());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      final fields = find.byType(TextField);
      // Order on step 1: record search, customer name, phone, email.
      await tester.enterText(fields.at(1), 'Rashid Al Nuaimi');
      await tester.enterText(fields.at(2), '501234567');
      await tester.pump();
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorIntakeWizardVehicleTitle), findsOneWidget);
      expect(find.text(t.advisorIntakeSectionVehicle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vehicle deck gates on plate, brand and model', (
      tester,
    ) async {
      await _pump(tester, const VehicleCustomerView());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(VehicleCustomerView)),
      );
      container
          .read(vehicleCustomerFormProvider.notifier)
          .setCustomerName('Rashid Al Nuaimi');
      container.read(vehicleCustomerFormProvider.notifier).setPhone(
        '501234567',
      );
      await tester.pump();
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      // Step 2 with nothing filled: advancing is blocked with plate errors.
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorIntakeErrPlate), findsOneWidget);
      expect(find.text(t.advisorIntakeErrMake), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('completed decks reach capture, sign-off and create', (
      tester,
    ) async {
      await _pump(tester, const VehicleCustomerView());
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(VehicleCustomerView)),
      );
      final notifier = container.read(vehicleCustomerFormProvider.notifier);
      notifier
        ..setCustomerName('Rashid Al Nuaimi')
        ..setPhone('501234567')
        ..setPlateNumber('84920')
        ..setMake('Toyota')
        ..setModel('Land Cruiser');
      await tester.pump();
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorIntakeSectionVehicle), findsOneWidget);
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorIntakeSectionMedia), findsOneWidget);
      await tester.tap(find.text(t.advisorIntakeWizardNext));
      await tester.pumpAndSettle();
      // The job-scope label is shared by the deck card, the row header and
      // the field label — all three render the same localized string.
      expect(find.text(t.advisorIntakeSectionJob), findsNWidgets(3));
      expect(find.text(t.advisorIntakeActionCreate), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('check-in cluster', () {
    testWidgets('fuel dial exposes all five domain detents', (tester) async {
      await _pump(
        tester,
        const AdvisorVehicleCheckinView(
          bookingId: 'BK-2026-0042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
        ),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Word detents render once (rail); fractions also render in the dial
      // center readout (value + localized name share the same glyphs).
      expect(find.text(t.advisorCheckInFuelEmpty), findsOneWidget);
      expect(find.text(t.advisorCheckInFuelFull), findsOneWidget);
      for (final label in [
        t.advisorCheckInFuelQuarter,
        t.advisorCheckInFuelHalf,
        t.advisorCheckInFuelThreeQuarter,
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting Full then confirming shows the review state', (
      tester,
    ) async {
      await _pump(
        tester,
        const AdvisorVehicleCheckinView(
          bookingId: 'BK-2026-0042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
        ),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorCheckInFuelFull));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorCheckInComplete));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorCheckInConfirmTitle), findsOneWidget);
      expect(find.text(t.advisorCheckInConfirmBody), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('failed submit surfaces a localized error', (tester) async {
      await _pump(
        tester,
        const AdvisorVehicleCheckinView(
          bookingId: 'BK-2026-0042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
        ),
        remote: _NullRemote(),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(t.advisorCheckInComplete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorCheckInComplete));
      await tester.pumpAndSettle();
      expect(find.text(t.advisorCheckInFailed), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('delivery handover', () {
    testWidgets('complete is gated until protocol, mileage and rating', (
      tester,
    ) async {
      final remote = _CapturingRemote();
      await _pump(
        tester,
        const VehicleDeliveryView(jobCardRef: 'JC-1042'),
        remote: remote,
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      // Nothing complete yet: the bar names the remaining checks.
      expect(find.text(t.advisorDeliveryRemaining(5)), findsOneWidget);

      // Tick all five protocol checks first: focusing a field inside the
      // scrollable breaks later in-scroll taps in widget tests, so text
      // entry always comes last.
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(CheckboxListTile).at(i));
        await tester.pump();
      }
      // Five-star rating (below the fold: reveal it, clear the sticky
      // action bar, then tap).
      final fiveStar = find.bySemanticsLabel(
        t.advisorDeliveryRatingValue(5),
      );
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(fiveStar, 400, scrollable: scrollable);
      await tester.drag(scrollable, const Offset(0, -250));
      await tester.pumpAndSettle();
      await tester.tap(fiveStar);
      await tester.pumpAndSettle();
      // Mileage is required before the handover can complete.
      await tester.enterText(find.byType(TextField).first, '48250');
      await tester.pumpAndSettle();
      expect(find.text(t.advisorDeliveryComplete), findsWidgets);

      await tester.tap(find.text(t.advisorDeliveryComplete).last);
      // One timed pump: the success path keeps its loading spinner mounted
      // (the pop is a no-op on the test root), so a full settle would run
      // past the snackbar's auto-dismiss.
      await tester.pump(const Duration(seconds: 1));
      expect(remote.delivered, isTrue);
      expect(remote.notes, contains('48250'));
      expect(remote.notes, contains('5/5'));
      expect(find.text(t.advisorDeliverySuccess), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('failed delivery surfaces a localized error with retry', (
      tester,
    ) async {
      await _pump(
        tester,
        const VehicleDeliveryView(jobCardRef: 'JC-1042'),
        remote: _FailingRemote(),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(CheckboxListTile).at(i));
        await tester.pump();
      }
      final fourStar = find.bySemanticsLabel(
        t.advisorDeliveryRatingValue(4),
      );
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(fourStar, 400, scrollable: scrollable);
      await tester.drag(scrollable, const Offset(0, -250));
      await tester.pumpAndSettle();
      await tester.tap(fourStar);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '48250');
      await tester.pumpAndSettle();
      await tester.tap(find.text(t.advisorDeliveryComplete).last);
      await tester.pumpAndSettle();
      expect(find.text(t.advisorDeliveryFailed), findsOneWidget);
      // The protocol state is intact so the advisor can retry.
      expect(find.byType(VehicleDeliveryView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('scanner permission states', () {
    testWidgets('denied permission explains, retries and keeps manual entry', (
      tester,
    ) async {
      await _denyCamera();
      try {
        await _pump(
          tester,
          const ScanVehicleView(scanMode: 'VIN'),
          settle: false,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final t = await StaffLocalizations.delegate.load(const Locale('en'));
        // Permission title renders in the card and echoes in the status
        // readout strip so the state is announced twice, never zero times.
        expect(find.text(t.advisorScanPermissionTitle), findsNWidgets(2));
        expect(find.text(t.advisorScanGrant), findsOneWidget);
        // Manual fallback is always reachable: empty submit errors inline.
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();
        expect(find.text(t.advisorScanEnterValue), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        _allowCamera();
      }
    });
  });

  group('offline queue coordination', () {
    testWidgets('queued intake work is announced once via the pill', (
      tester,
    ) async {
      // NOTE: this deliberately avoids Hive box IO (too slow/flaky in this
      // environment). The queue→provider reactivity itself is covered by
      // `advisor_sync_reactivity_test.dart` against a real `sync_queue` box;
      // here we prove the intake shell renders the queued count exactly once.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            advisorRemoteDataSourceProvider.overrideWithValue(
              _FakeAdvisorRemote(),
            ),
            advisorPendingSyncCountProvider.overrideWith(
              (ref) => Stream<int>.value(1),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('en'),
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            home: const VehicleCustomerView(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // One announcement: the app-bar pill names the queued count and no
      // full-width banner is rendered alongside it.
      expect(find.byType(OfflineStatusPill), findsOneWidget);
      expect(find.text('1 queued'), findsOneWidget);
      expect(find.byType(OfflineBanner), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('draft save / resume', () {
    test('draft round-trips every provider-owned field', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(vehicleCustomerFormProvider.notifier);
      notifier
        ..setCustomerName('Draft Customer')
        ..setPhone('501112223')
        ..setEmirate('Dubai')
        ..setPlateCode('M')
        ..setPlateNumber('84920')
        ..setVin('JTMHU09JX04242424')
        ..setMake('Toyota')
        ..setModel('Land Cruiser')
        ..setModelYear('2024')
        ..setOdometer('48250')
        ..setFuelLevel(7)
        ..setConsent(true)
        ..setJobCategory('Insurance')
        ..setInsuranceProvider('RSA');

      final draft = buildIntakeDraft(
        container.read(vehicleCustomerFormProvider),
        2,
        jobPhotoPaths: const ['/tmp/a.jpg'],
        customerSignaturePath: '/tmp/sig.png',
      );
      expect(draft['step'], 2);
      expect(draft['version'], 1);

      final fresh = ProviderContainer();
      addTearDown(fresh.dispose);
      applyIntakeDraftToForm(
        fresh.read(vehicleCustomerFormProvider.notifier),
        draft,
      );
      final restored = fresh.read(vehicleCustomerFormProvider);
      expect(restored.customerName, 'Draft Customer');
      expect(restored.phoneNumber, '501112223');
      expect(restored.emirate, 'Dubai');
      expect(restored.plateCode, 'M');
      expect(restored.plateNumber, '84920');
      expect(restored.registrationNumber, 'Dubai M 84920');
      expect(restored.vin, 'JTMHU09JX04242424');
      expect(restored.make, 'Toyota');
      expect(restored.model, 'Land Cruiser');
      expect(restored.modelYear, '2024');
      expect(restored.odometerReading, '48250');
      expect(restored.fuelLevel, 7);
      expect(restored.customerConsent, isTrue);
      expect(restored.jobCategory, 'Insurance');
      expect(restored.insuranceProvider, 'RSA');
      expect(draft['jobPhotoPaths'], ['/tmp/a.jpg']);
      expect(draft['customerSignaturePath'], '/tmp/sig.png');
    });
  });

  group('responsive + themes', () {
    for (final size in const [
      Size(320, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(1280, 800),
    ]) {
      testWidgets('intake has no overflow at ${size.width}px', (tester) async {
        await _pump(tester, const VehicleCustomerView(), size: size);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('desktop intake docks the live summary beside the deck', (
      tester,
    ) async {
      await _pump(
        tester,
        const VehicleCustomerView(),
        size: const Size(1280, 800),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorIntakeSummaryTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('desktop scanner shows the guidance rail', (tester) async {
      await _pump(
        tester,
        const ScanVehicleView(scanMode: 'VIN'),
        size: const Size(1280, 800),
        settle: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorScanTipsTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact scanner hides the guidance rail', (tester) async {
      await _pump(
        tester,
        const ScanVehicleView(scanMode: 'VIN'),
        settle: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final t = await StaffLocalizations.delegate.load(const Locale('en'));
      expect(find.text(t.advisorScanTipsTitle), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('intake tolerates 1.3x text scaling', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _harness(
          const VehicleCustomerView(),
          textScaler: const TextScaler.linear(1.3),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('intake renders in Arabic RTL without overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        const VehicleCustomerView(),
        locale: const Locale('ar'),
      );
      final t = await StaffLocalizations.delegate.load(const Locale('ar'));
      expect(find.text(t.advisorIntakeTitle), findsWidgets);
      // Deck header title (also echoed in the compact journey context).
      expect(find.text(t.advisorIntakeWizardContactTitle), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('check-in and delivery render in dark theme', (tester) async {
      await _pump(
        tester,
        const AdvisorVehicleCheckinView(
          bookingId: 'BK-1',
          customerName: 'Layla Haddad',
          vehicleInfo: 'Nissan Patrol',
        ),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      await _pump(
        tester,
        const VehicleDeliveryView(jobCardRef: 'JC-7'),
        dark: true,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

// ── Harness ─────────────────────────────────────────────────────────────────

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  bool dark = false,
  bool settle = true,
  AdvisorRemoteDataSource? remote,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _harness(child, locale: locale, dark: dark, remote: remote),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Widget _harness(
  Widget child, {
  Locale locale = const Locale('en'),
  bool dark = false,
  TextScaler textScaler = TextScaler.noScaling,
  AdvisorRemoteDataSource? remote,
}) =>
    ProviderScope(
      overrides: [
        advisorRemoteDataSourceProvider.overrideWithValue(
          remote ?? _FakeAdvisorRemote(),
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
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: inner!,
        ),
        home: child,
      ),
    );

class _FakeAdvisorRemote implements AdvisorRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NullRemote implements AdvisorRemoteDataSource {
  @override
  Future<CheckInResult?> checkInVehicleResult(
    String bookingId,
    Map<String, dynamic> data,
  ) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CapturingRemote implements AdvisorRemoteDataSource {
  bool delivered = false;
  String notes = '';

  @override
  Future<bool> deliverVehicle(
    String jobCardRef,
    Map<String, dynamic> data,
  ) async {
    delivered = true;
    notes = (data['notes'] ?? '').toString();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingRemote implements AdvisorRemoteDataSource {
  @override
  Future<bool> deliverVehicle(
    String jobCardRef,
    Map<String, dynamic> data,
  ) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _denyCamera() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async {
          final args = call.arguments;
          if (args is Map) {
            return <int, int>{for (final key in args.keys) (key as int): 0};
          }
          return <int, int>{};
        },
      );
}

void _allowCamera() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        null,
      );
}
