import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/add_vehicle_view.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

/// Phase 16 rendered-review goldens: the consumer garage surfaces at phone,
/// tablet and desktop widths in EN-LTR and AR-RTL plus a dark render, with
/// real fonts (including the Arabic face, which the older suites never
/// loaded). Deterministic fixtures; no live endpoints.
const _delegates = <LocalizationsDelegate<dynamic>>[
  CustomerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _profile = CustomerEntity(
  name: 'Ahmed Al Mansoori',
  firstName: 'Ahmed',
  avatarInitials: 'AM',
  memberId: 'CUST-042',
);

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

const _upcoming = CustomerBookingEntity(
  service: 'Brake Inspection',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '2026-09-18',
  time: '09:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

const _done = CustomerBookingEntity(
  service: 'Oil & Filter Change',
  vehicleName: 'Nissan Patrol',
  plateNumber: 'B 67890',
  date: '2026-08-02',
  time: '10:00',
  status: BookingStatus.completed,
  bookingRef: 'BK-2026-0151',
);

const _notice = CustomerNotificationEntity(
  id: 'n1',
  title: 'Your vehicle is ready',
  body: 'Please collect your Land Cruiser from Bay 3.',
  time: '2h ago',
  type: NotifType.completionApproved,
);

class _FakeDash extends CustomerDashboardNotifier {
  _FakeDash(this._state);
  final CustomerDashboardState _state;

  @override
  CustomerDashboardState build() => _state;

  @override
  Future<void> refresh() async {}
}

CustomerDashboardState _state({
  List<CustomerVehicleEntity> vehicles = const [_camry, _patrol],
  List<CustomerNotificationEntity> notifications = const [_notice],
}) =>
    CustomerDashboardState(
      selectedIndex: 0,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: vehicles,
      notifications: notifications,
      profile: _profile,
    );

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
        role: UserRole.customer,
        token: 'test_token',
        profile: null,
      );
}

List<Override> _overrides({
  List<CustomerBookingEntity> bookings = const [_upcoming, _done],
}) =>
    [
      customerDashboardProvider.overrideWith(() => _FakeDash(_state())),
      customerBookingsProvider.overrideWith((ref) async => bookings),
      customerApprovalsProvider.overrideWith((ref) async => const []),
      authNotifierProvider.overrideWith(_FakeAuth.new),
    ];

Future<void> _pumpSurface(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required Locale locale,
  bool dark = false,
  List<CustomerBookingEntity> bookings = const [_upcoming, _done],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(bookings: bookings),
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

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('garage home 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerScaffold(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerScaffold),
        matchesGoldenFile('goldens/garage_home_390_$label.png'),
      );
    });

    testWidgets('bookings 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerBookingsTab(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerBookingsTab),
        matchesGoldenFile('goldens/garage_bookings_390_$label.png'),
      );
    });

    testWidgets('vehicles 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerVehiclesTab(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/garage_vehicles_390_$label.png'),
      );
    });

    testWidgets('profile 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerProfileTab(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerProfileTab),
        matchesGoldenFile('goldens/garage_profile_390_$label.png'),
      );
    });

    testWidgets('add vehicle 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const AddVehicleView(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(AddVehicleView),
        matchesGoldenFile('goldens/garage_add_390_$label.png'),
      );
    });

    testWidgets('notifications 390 $label', (tester) async {
      await _pumpSurface(
        tester,
        const CustomerNotificationsView(),
        size: const Size(390, 844),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/garage_notifications_390_$label.png'),
      );
    });
  }

  for (final (name, surface) in <(String, Widget)>[
    ('home', CustomerScaffold()),
    ('bookings', CustomerBookingsTab()),
    ('vehicles', CustomerVehiclesTab()),
    ('profile', CustomerProfileTab()),
    ('add', AddVehicleView()),
    ('notifications', CustomerNotificationsView()),
  ]) {
    testWidgets('$name 834 en tablet', (tester) async {
      await _pumpSurface(
        tester,
        surface,
        size: const Size(834, 1112),
        locale: const Locale('en'),
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byWidget(surface),
        matchesGoldenFile('goldens/garage_${name}_834_en.png'),
      );
    });

    testWidgets('$name 1280 en desktop', (tester) async {
      await _pumpSurface(
        tester,
        surface,
        size: const Size(1280, 800),
        locale: const Locale('en'),
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byWidget(surface),
        matchesGoldenFile('goldens/garage_${name}_1280_en.png'),
      );
    });

    testWidgets('$name 390 en dark spot', (tester) async {
      await _pumpSurface(
        tester,
        surface,
        size: const Size(390, 844),
        locale: const Locale('en'),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byWidget(surface),
        matchesGoldenFile('goldens/garage_${name}_390_dark.png'),
      );
    });
  }
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
