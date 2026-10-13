import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/support/failed_vehicle_delete.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 (H3) — real-context layout smoke tests.
///
/// Pumps the real customer workspace shell (`CustomerScaffold` + four tabs)
/// and `CustomerHomeTab` with fake providers at default and 1.3x text scale,
/// phone / tablet widths, after the global text-scale lock removal.
void main() {
  for (final scale in <double>[1.0, 1.3]) {
    testWidgets('CustomerScaffold + CustomerHomeTab at ${scale}x on phone', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        size: const Size(390, 844),
        scale: scale,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomerScaffold), findsOneWidget);

      final context = tester.element(find.byType(CustomerHomeTab));
      expect(
        Theme.of(context).textTheme.bodyMedium?.fontFamily,
        AppFontFamilies.app,
      );
    });
  }

  for (final size in <Size>[
    const Size(800, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets('CustomerScaffold lays out at ${size.width} px, 1.3x', (
      tester,
    ) async {
      await _pumpScaffold(tester, size: size, scale: 1.3);

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomerScaffold), findsOneWidget);
    });
  }

  testWidgets('CustomerScaffold survives 320 px at 1.3x', (tester) async {
    await _pumpScaffold(tester, size: const Size(320, 640), scale: 1.3);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpScaffold(
  WidgetTester tester, {
  required Size size,
  required double scale,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final dashboard = _FakeDashboardNotifier(_initialState());

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const CustomerScaffold(),
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
        path: AppRoutes.customerNotifications,
        builder: (_, __) => const Scaffold(body: Text('NOTIFICATIONS')),
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
        path: AppRoutes.customerApprovals,
        builder: (_, __) => const Scaffold(body: Text('APPROVALS')),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        builder: (_, __) => const Scaffold(body: Text('BOOKING_DETAIL')),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const Scaffold(body: Text('FORGOT_PASSWORD')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(() => dashboard),
        customerBookingsProvider.overrideWith((ref) async => const []),
        customerApprovalsProvider.overrideWith((ref) async => const []),
        customerFailedBookingsProvider.overrideWithValue(const []),
        customerFailedVehicleDeletesProvider.overrideWithValue(const []),
        authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
        connectivityStatusProvider.overrideWith(
          (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

CustomerDashboardState _initialState() {
  return const CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    loadError: '',
    vehicles: [
      CustomerVehicleEntity(
        id: 'v1',
        brand: 'Toyota',
        model: 'Land Cruiser',
        plateNumber: 'A 12345',
        vin: '',
        color: 'White',
        year: 2021,
        mileage: '48,200 km',
        lastService: '2026-01-12',
        nextDue: '2026-07-12',
        healthScore: 82,
      ),
    ],
    notifications: [],
    activeService: CustomerServiceEntity(
      hasActiveJob: true,
      jobCardId: 'JC-2026-1042',
      plateNumber: 'A 12345',
      vehicleName: 'Toyota Land Cruiser',
      service: 'Full Service',
      started: '2026-09-14',
      estCompletion: '2026-09-16 17:00',
      progressPercent: 45,
      currentStage: 'Quality Check',
      technicianName: 'Ravi',
      stages: [],
    ),
    profile: CustomerEntity(
      name: 'Ahmed Al Mansoori',
      firstName: 'Ahmed',
      avatarInitials: 'AM',
      memberId: 'CUS-1042',
    ),
  );
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;

  @override
  CustomerDashboardState build() => _initial;

  @override
  void selectTab(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  @override
  void selectDestination(CustomerDestination destination) {
    state = state.copyWith(selectedIndex: destination.index);
  }

  @override
  Future<void> refresh() async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    role: UserRole.customer,
    token: 'test-token',
    profile: null,
  );
}
