import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_garage_carousel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_quick_actions.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:shared_auth/shared_auth.dart';

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

const _upcoming = CustomerBookingEntity(
  service: 'Brake Inspection',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '2026-09-18',
  time: '09:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
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
  List<CustomerVehicleEntity> vehicles = const [],
}) =>
    CustomerDashboardState(
      selectedIndex: 0,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: vehicles,
      notifications: const [],
      profile: _profile,
    );

Future<void> _pumpShell(
  WidgetTester tester, {
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const CustomerScaffold(),
      ),
      GoRoute(
        path: AppRoutes.customerNotifications,
        builder: (_, __) => const Scaffold(body: Text('NOTIFICATIONS')),
      ),
      GoRoute(
        path: AppRoutes.customerBookService,
        builder: (_, __) => const Scaffold(body: Text('BOOK_SERVICE')),
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownHelp,
        builder: (_, __) => const Scaffold(body: Text('BREAKDOWN_HELP')),
      ),
      GoRoute(
        path: AppRoutes.customerApprovals,
        builder: (_, __) => const Scaffold(body: Text('APPROVALS')),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) => const Scaffold(body: Text('ADD_VEHICLE')),
      ),
      GoRoute(
        path: AppRoutes.customerServiceStatus,
        builder: (_, __) => const Scaffold(body: Text('SERVICE_STATUS')),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        builder: (_, __) => const Scaffold(body: Text('BOOKING_DETAIL')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(() => _FakeDash(state)),
        customerBookingsProvider.overrideWith((ref) async => bookings),
        customerApprovalsProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Consumer shell (no enterprise chrome)', () {
    testWidgets('bottom navigation stays on wide layouts', (tester) async {
      await _pumpShell(
        tester,
        state: _state(),
        size: const Size(1280, 800),
      );
      expect(find.byType(AppBottomNavigation), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('brand bar carries bell and avatar', (tester) async {
      await _pumpShell(tester, state: _state());
      expect(find.text('Orient Auto Garage'), findsOneWidget);
      expect(find.byType(NotificationBell), findsOneWidget);
      await tester.tap(find.byType(NotificationBell));
      await tester.pumpAndSettle();
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    });

    testWidgets('avatar opens the profile tab', (tester) async {
      await _pumpShell(tester, state: _state());
      await tester.tap(find.byType(CircleAvatar).first);
      await tester.pumpAndSettle();
      expect(find.text('Ahmed Al Mansoori'), findsOneWidget);
    });
  });

  group('Garage carousel (imagery-first, honest badges)', () {
    testWidgets('shows one card per vehicle with plate', (tester) async {
      await _pumpShell(
        tester,
        state: _state(vehicles: const [_camry]),
      );
      expect(find.byType(CustomerGarageCarousel), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      // No provenance, no contract: neither renders, ever.
      expect(find.textContaining('Health'), findsNothing);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
      expect(find.byIcon(Icons.favorite_outline_rounded), findsNothing);
    });

    testWidgets('tapping a card books that exact vehicle', (tester) async {
      await _pumpShell(
        tester,
        state: _state(vehicles: const [_camry]),
      );
      await tester.tap(find.text('Toyota Camry'));
      await tester.pumpAndSettle();
      expect(find.text('BOOK_SERVICE'), findsOneWidget);
    });

    testWidgets('upcoming booking renders its context badge', (tester) async {
      await _pumpShell(
        tester,
        state: _state(vehicles: const [_camry]),
        bookings: const [_upcoming],
      );
      expect(find.text('BOOKED'), findsOneWidget);
    });
  });

  group('Quick actions (four large tiles, one emphasis)', () {
    testWidgets('tiles navigate to real destinations', (tester) async {
      await _pumpShell(
        tester,
        state: _state(vehicles: const [_camry]),
      );
      expect(find.byType(CustomerHomeQuickActions), findsOneWidget);
      final sos = find.text('Breakdown help');
      await tester.ensureVisible(sos);
      await tester.pumpAndSettle();
      await tester.tap(sos);
      await tester.pumpAndSettle();
      expect(find.text('BREAKDOWN_HELP'), findsOneWidget);
    });
  });

  group('Warm Arabic rendering', () {
    testWidgets('home composes cleanly in Arabic', (tester) async {
      await _pumpShell(
        tester,
        state: _state(vehicles: const [_camry]),
        bookings: const [_upcoming],
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('الرئيسية'), findsOneWidget);
    });
  });
}
