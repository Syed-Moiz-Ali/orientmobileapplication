import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';

/// Booking Details is reached from the Bookings list with the booking itself
/// passed through route `extra`. A deep link or a stale entry has no such data,
/// and must recover instead of rendering an empty screen.
void main() {
  group('booking detail route', () {
    test('is registered once against the canonical path', () {
      final container = ProviderContainer(
        overrides: [authNotifierProvider.overrideWith(_CustomerAuth.new)],
      );
      addTearDown(container.dispose);

      final routes = container
          .read(appRouterProvider)
          .configuration
          .routes
          .whereType<GoRoute>()
          .toList();

      final matches = routes
          .where((route) => route.path == AppRoutes.customerBookingDetail)
          .toList();
      expect(matches, hasLength(1));
      expect(matches.single, same(customerBookingDetailRoute));
    });

    testWidgets('renders the booking passed through route extra', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);

      router.go(AppRoutes.customerBookingDetail, extra: _booking);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingDetailView), findsOneWidget);
      expect(find.text('Booking Details'), findsOneWidget);
      expect(find.text('Brake Inspection'), findsOneWidget);
    });

    testWidgets('parses a booking map extra into the detail surface', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);

      router.go(AppRoutes.customerBookingDetail, extra: _booking.toJson());
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingDetailView), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
    });

    testWidgets('a booking-less deep link recovers to Bookings', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);

      router.go(AppRoutes.customerBookingDetail);
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBookingDetailView), findsNothing);
      expect(
        find.textContaining("We couldn't find this booking"),
        findsOneWidget,
      );

      await tester.tap(find.text('Return to bookings'));
      await tester.pumpAndSettle();

      final uri = router.routerDelegate.currentConfiguration.uri;
      expect(uri.path, AppRoutes.customerDashboard);
      expect(uri.queryParameters['tab'], CustomerDestination.bookings.name);
    });

    testWidgets('unusable booking data recovers instead of crashing', (
      tester,
    ) async {
      final router = await _pumpRouter(tester);

      router.go(AppRoutes.customerBookingDetail, extra: 'not-a-booking');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Booking detail unavailable'), findsWidgets);
      expect(find.text('Return to bookings'), findsOneWidget);
    });
  });
}

const _booking = CustomerBookingEntity(
  id: 'b-near',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2026-09-22',
  time: '09:00',
  status: BookingStatus.confirmed,
  jobCardRef: 'BK-2026-0188',
);

class _CustomerAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 'test-token');
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  @override
  CustomerDashboardState build() => CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: const [],
    notifications: const [],
  );
}

Future<GoRouter> _pumpRouter(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const Text('WORKSPACE')),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (context, state) =>
            Text('DASHBOARD_${state.uri.queryParameters['tab']}'),
      ),
      customerBookingDetailRoute,
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(_FakeDashboardNotifier.new),
        customerBookingsProvider.overrideWith((ref) async => const [_booking]),
        customerApprovalsProvider.overrideWith(
          (ref) async => const <CustomerApprovalSummaryResponse>[],
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}
