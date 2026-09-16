import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

/// The Customer workspace has exactly five permanent destinations, and Service
/// Status is deliberately not one of them.
void main() {
  group('Customer workspace destinations', () {
    test('are the five permanent destinations, in order', () {
      expect(
        CustomerDestination.values
            .map((destination) => destination.name)
            .toList(),
        const ['home', 'bookings', 'vehicles', 'profile'],
      );
      expect(
        CustomerDestination.navItems.map((item) => item.label).toList(),
        const ['Home', 'Bookings', 'Vehicles', 'Profile'],
      );
      expect(
        CustomerDestination.navItems.map((item) => item.label),
        isNot(contains('Status')),
        reason: 'Status is contextual, not a permanent destination',
      );
    });

    testWidgets('fit the bottom navigation without a More slot', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              items: CustomerDestination.navItems,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final destination in CustomerDestination.values) {
        expect(
          find.text(destination.label),
          findsOneWidget,
          reason: '${destination.label} must be directly reachable',
        );
      }
      expect(
        find.text('More'),
        findsNothing,
        reason: 'five destinations must not trigger the overflow slot',
      );
    });

    test('legacy numeric ?tab= values keep their original meaning', () {
      // Pre-migration order: 0 Home, 1 Status, 2 Bookings, 3 Approvals,
      // 4 Vehicles, 5 Profile.
      expect(CustomerDestination.resolveTabValue('0'), 'home');
      expect(CustomerDestination.resolveTabValue('2'), 'bookings');
      // Tab 3 was Approvals; it now resolves to the contextual Approvals page,
      // never to whichever destination happens to sit at that index.
      expect(
        CustomerDestination.resolveTabValue('3'),
        CustomerDestination.approvalsTabValue,
      );
      expect(CustomerDestination.isApprovalsTabValue('3'), isTrue);
      expect(CustomerDestination.isApprovalsTabValue('approvals'), isTrue);
      expect(CustomerDestination.fromTabValue('3'), isNull);
      expect(CustomerDestination.resolveTabValue('4'), 'vehicles');
      expect(CustomerDestination.resolveTabValue('5'), 'profile');

      // The old Status index must never resolve to a destination.
      expect(CustomerDestination.isStatusTabValue('1'), isTrue);
      expect(CustomerDestination.fromTabValue('1'), isNull);

      expect(
        CustomerDestination.fromTabValue('2'),
        CustomerDestination.bookings,
      );
      expect(
        CustomerDestination.fromTabValue('4'),
        CustomerDestination.vehicles,
      );
    });

    test('named ?tab= values resolve to their destination', () {
      for (final destination in CustomerDestination.values) {
        expect(CustomerDestination.fromTabValue(destination.name), destination);
      }
      // Unknown or missing values fall back to Home rather than misrouting.
      expect(CustomerDestination.fromTabValue(null), CustomerDestination.home);
      expect(CustomerDestination.fromTabValue(''), CustomerDestination.home);
      expect(
        CustomerDestination.fromTabValue('nonsense'),
        CustomerDestination.home,
      );
    });

    test('workspace locations use names instead of shifted indices', () {
      expect(
        AppRoutes.tabLocation(CustomerDestination.bookings),
        '${AppRoutes.customerDashboard}?tab=bookings',
      );
      expect(
        AppRoutes.bookingsLocation,
        '${AppRoutes.customerDashboard}?tab=bookings',
      );
      // Approvals is contextual: its own route, not a dashboard tab.
      expect(AppRoutes.approvalsLocation(), AppRoutes.customerApprovals);
      expect(
        AppRoutes.approvalsLocation(estimateId: 'EST-9001'),
        '${AppRoutes.customerApprovals}?estimateId=EST-9001',
      );
      final encoded = AppRoutes.approvalsLocation(estimateId: 'EST 9001');
      expect(encoded, contains('estimateId='));
      expect(
        encoded,
        isNot(contains(' ')),
        reason: 'the estimate id is query-encoded',
      );
    });
  });

  group('Customer workspace pages', () {
    testWidgets('map one-to-one onto the four destinations', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(_CustomerAuth.new),
            connectivityStatusProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
            customerDashboardProvider.overrideWith(_EmptyDashboardNotifier.new),
            customerBookingsProvider.overrideWith((ref) async => const []),
            customerApprovalsProvider.overrideWith((ref) async => const []),
            customerInvoicesProvider.overrideWith((ref) async => const []),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            home: const CustomerScaffold(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.children, hasLength(CustomerDestination.values.length));
      expect(
        stack.children[CustomerDestination.home.index],
        isA<CustomerHomeTab>(),
      );
      expect(
        stack.children[CustomerDestination.bookings.index],
        isA<CustomerBookingsTab>(),
      );
      expect(
        stack.children[CustomerDestination.vehicles.index],
        isA<CustomerVehiclesTab>(),
      );
      expect(
        stack.children[CustomerDestination.profile.index],
        isA<CustomerProfileTab>(),
      );
      // No hidden Status page kept around to preserve old index numbers.
      expect(stack.children.whereType<CustomerHomeTab>(), hasLength(1));
    });
  });
}

class _CustomerAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 'test-token');
}

/// Empty, offline-free workspace state so the shell test never touches the
/// network (and never renders the out-of-scope stock vehicle imagery).
class _EmptyDashboardNotifier extends CustomerDashboardNotifier {
  @override
  CustomerDashboardState build() => const CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: [],
    notifications: [],
    profile: CustomerEntity(
      name: 'Ahmed Al Mansoori',
      firstName: 'Ahmed',
      avatarInitials: 'AM',
      memberId: 'CUS-1042',
    ),
  );

  @override
  Future<void> refresh() async {}
}
