import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_book_service_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_success_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_help_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_result_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_breakdown_sync.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

/// Phase 17 rendered-review goldens: the booking wizard steps, booking
/// detail, success and the SOS pair at 390 EN/AR + 834 EN + dark spots, with
/// real fonts (including the Arabic face). Deterministic fixtures; the wizard
/// drives its real catalogue + availability fakes, so slots group into
/// morning/afternoon exactly as production would render them.
const _delegates = <LocalizationsDelegate<dynamic>>[
  CustomerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _camry = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: 'JT2BF22K1W0123456',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _patrol = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'B 67890',
  vin: '',
  color: 'Silver',
  year: 2022,
  mileage: '31,000 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _confirmed = CustomerBookingEntity(
  id: '77',
  service: 'Full Service',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '2026-09-22',
  time: '09:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

const _services = [
  ServiceTypeResponse(
    id: 's1',
    name: 'Full Service',
    price: 'AED 450',
    duration: '90 min',
  ),
  ServiceTypeResponse(
    id: 's2',
    name: 'AC Refresh',
    price: 'AED 120',
    duration: '30 min',
  ),
];

class _FakeDash extends CustomerDashboardNotifier {
  _FakeDash(this._state);
  final CustomerDashboardState _state;

  @override
  CustomerDashboardState build() => _state;

  @override
  Future<void> refresh() async {}
}

CustomerDashboardState _dashState({
  List<CustomerVehicleEntity> vehicles = const [_camry, _patrol],
}) =>
    CustomerDashboardState(
      selectedIndex: 0,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: vehicles,
      notifications: const [],
      profile: const CustomerEntity(
        name: 'Ahmed Al Mansoori',
        firstName: 'Ahmed',
        avatarInitials: 'AM',
        memberId: 'CUST-042',
      ),
    );

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        role: UserRole.customer,
        token: 'test_token',
        profile: null,
      );
}

class _FakeRemote implements CustomerRemoteDataSource {
  @override
  Future<List<ServiceTypeResponse>> getServiceTypes() async => _services;

  @override
  Future<List<String>> getAvailability(String date) async =>
      const ['09:00', '14:00'];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFailedSync implements FailedBreakdownSync {
  @override
  List<SyncOperation> failedBreakdowns() => const [];

  @override
  Future<bool> retry() async => true;

  @override
  Future<void> remove() async {}
}

List<Override> _overrides({
  List<CustomerVehicleEntity> vehicles = const [_camry, _patrol],
  List<CustomerBookingEntity> bookings = const [_confirmed],
}) =>
    [
      customerDashboardProvider.overrideWith(() => _FakeDash(_dashState(vehicles: vehicles))),
      customerRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      customerBookingsProvider.overrideWith((ref) async => bookings),
      customerApprovalsProvider.overrideWith((ref) async => const []),
      failedBreakdownSyncProvider.overrideWithValue(_FakeFailedSync()),
      authNotifierProvider.overrideWith(_FakeAuth.new),
    ];

Future<void> _pumpSurface(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required Locale locale,
  bool dark = false,
  List<CustomerVehicleEntity> vehicles = const [_camry, _patrol],
  List<CustomerBookingEntity> bookings = const [_confirmed],
  // False for surfaces owning an indeterminate animation (the SOS wait
  // bar): pumpAndSettle would never settle there.
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(vehicles: vehicles, bookings: bookings),
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// The wizard on [step]: vehicle and package steps settle on their own;
/// the slot step picks tomorrow (today's morning slots genuinely pass) and
/// the drop-off step picks the first real slot.
Future<void> _pumpWizardStep(
  WidgetTester tester,
  int step, {
  required Size size,
  required Locale locale,
  bool dark = false,
}) async {
  await _pumpSurface(
    tester,
    const CustomerBookServiceView(),
    size: size,
    locale: locale,
    dark: dark,
    vehicles: const [_camry],
  );
  for (var i = 0; i < step; i++) {
    if (i == 1) {
      await tester.tap(find.text('Full Service'));
      await tester.pumpAndSettle();
    }
    if (i == 2) {
      final date = find
          .descendant(of: find.byType(ListView), matching: find.byType(InkWell))
          .at(1);
      await tester.tap(date);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('9:00 AM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9:00 AM'));
      await tester.pumpAndSettle();
    }
    final cta = find.text(locale == const Locale('ar') ? 'متابعة' : 'Continue');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('wizard vehicle 390 $label', (tester) async {
      await _pumpWizardStep(tester, 0, size: const Size(390, 844), locale: locale);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/book_vehicle_390_$label.png'),
      );
    });

    testWidgets('wizard package 390 $label', (tester) async {
      await _pumpWizardStep(tester, 1, size: const Size(390, 844), locale: locale);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/book_package_390_$label.png'),
      );
    });

    testWidgets('wizard slot 390 $label', (tester) async {
      await _pumpWizardStep(tester, 2, size: const Size(390, 844), locale: locale);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/book_slot_390_$label.png'),
      );
    });

    testWidgets('wizard dropoff 390 $label', (tester) async {
      await _pumpWizardStep(tester, 3, size: const Size(390, 844), locale: locale);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookServiceView),
        matchesGoldenFile('goldens/book_dropoff_390_$label.png'),
      );
    });

    testWidgets('booking detail 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        CustomerBookingDetailView(booking: _confirmed),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookingDetailView),
        matchesGoldenFile('goldens/book_detail_390_$label.png'),
      );
    });

    testWidgets('booking success 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerBookingSuccessView(
          bookingRef: 'BK-2026-0042',
          bookingId: '77',
          service: 'Full Service + AC Refresh',
          date: '2026-09-22',
          time: '09:00',
          vehicle: 'Toyota Camry',
          plate: 'A 12345',
        ),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookingSuccessView),
        matchesGoldenFile('goldens/book_success_390_$label.png'),
      );
    });

    testWidgets('sos form 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerBreakdownHelpView(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBreakdownHelpView),
        matchesGoldenFile('goldens/sos_form_390_$label.png'),
      );
    });

    testWidgets('sos sent 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerBreakdownResultView(
          result: {
            'sent': true,
            'reference': 'BD-2026-0007',
            'vehicleName': 'Toyota Camry',
            'vehiclePlate': 'A 12345',
            'location': 'Level B2, Marina Mall',
            'issue': 'Flat tyre',
          },
        ),
        size: const Size(390, 844),
        locale: locale,
        // Bounded pumps: the honest indeterminate wait bar never settles.
        settle: false,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBreakdownResultView),
        matchesGoldenFile('goldens/sos_sent_390_$label.png'),
      );
    });
  }

  testWidgets('wizard slot 834 en', (tester) async {
    await _pumpWizardStep(
      tester,
      2,
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerBookServiceView),
      matchesGoldenFile('goldens/book_slot_834_en.png'),
    );
  });

  testWidgets('booking detail 834 en', (tester) async {
    await _pumpSurface(
      tester,
      CustomerBookingDetailView(booking: _confirmed),
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerBookingDetailView),
      matchesGoldenFile('goldens/book_detail_834_en.png'),
    );
  });

  testWidgets('sos form 834 en', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerBreakdownHelpView(),
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerBreakdownHelpView),
      matchesGoldenFile('goldens/sos_form_834_en.png'),
    );
  });

  testWidgets('wizard package 390 dark', (tester) async {
    await _pumpWizardStep(
      tester,
      1,
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerBookServiceView),
      matchesGoldenFile('goldens/book_package_390_dark.png'),
    );
  });

  testWidgets('booking success 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerBookingSuccessView(
        bookingRef: 'BK-2026-0042',
        bookingId: '77',
        service: 'Full Service + AC Refresh',
        date: '2026-09-22',
        time: '09:00',
        vehicle: 'Toyota Camry',
        plate: 'A 12345',
      ),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerBookingSuccessView),
      matchesGoldenFile('goldens/book_success_390_dark.png'),
    );
  });

  testWidgets('sos sent 390 dark', (tester) async {
    await _pumpSurface(
      tester,
      const CustomerBreakdownResultView(
        result: {
          'sent': true,
          'reference': 'BD-2026-0007',
          'vehicleName': 'Toyota Camry',
          'vehiclePlate': 'A 12345',
          'location': 'Level B2, Marina Mall',
          'issue': 'Flat tyre',
        },
      ),
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
      settle: false,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(CustomerBreakdownResultView),
      matchesGoldenFile('goldens/sos_sent_390_dark.png'),
    );
  });
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
