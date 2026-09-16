import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';

/// Service Status is contextual: `/customer_service_status` is the canonical
/// pushed page, and both the pre-migration status path and the old `?tab=1`
/// link resolve to it instead of silently opening a different destination.
void main() {
  group('canonical service status route', () {
    test('is a pushed page, and the legacy path only redirects to it', () {
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

      final canonical = routes
          .where((route) => route.path == AppRoutes.customerServiceStatus)
          .toList();
      expect(canonical, hasLength(1));
      expect(canonical.single, same(customerServiceStatusRoute));
      expect(
        canonical.single.builder,
        isNotNull,
        reason: 'the canonical Status route renders the tracking page',
      );

      final legacy = routes
          .where((route) => route.path == AppRoutes.customerServiceStatusLegacy)
          .toList();
      expect(
        legacy,
        hasLength(1),
        reason: 'the pre-migration path must keep resolving',
      );
      expect(legacy.single, same(customerServiceStatusCompatRoute));
      expect(
        legacy.single.builder,
        isNull,
        reason: 'the removed legacy implementation must not render again',
      );
    });

    testWidgets(
      'renders the canonical tracking experience with a back affordance',
      (tester) async {
        final router = await _pumpRealRouter(tester);

        router.go(AppRoutes.customerServiceStatus);
        await tester.pumpAndSettle();

        expect(find.byType(CustomerServiceStatusTab), findsOneWidget);
        // The top bar owns the title, so it is not repeated in the content.
        expect(find.text('Service status'), findsOneWidget);
        expect(find.text('IN SERVICE'), findsOneWidget);
        expect(find.text('Current stage'), findsOneWidget);
        expect(find.text('Quality Check'), findsOneWidget);
        expect(find.byTooltip('Back'), findsOneWidget);
        expect(
          router.canPop(),
          isFalse,
          reason: 'a contextual deep link must not stack a second location',
        );
      },
    );

    testWidgets('the pre-migration path resolves to the canonical page', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester);

      router.go(AppRoutes.customerServiceStatusLegacy);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.customerServiceStatus,
      );
      expect(find.byType(CustomerServiceStatusTab), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('the old ?tab=1 link opens Service Status, never another tab', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester);

      router.go('${AppRoutes.customerDashboard}?tab=1');
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.customerServiceStatus,
        reason: 'a legacy Status link must not silently open Bookings',
      );
      expect(find.byType(CustomerServiceStatusTab), findsOneWidget);
      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(router.canPop(), isFalse, reason: 'no redirect loop');
    });

    testWidgets('an unauthenticated status deep link still goes to sign in', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester, authenticated: false);

      router.go(AppRoutes.customerServiceStatus);
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.login,
      );
      expect(find.byType(CustomerServiceStatusTab), findsNothing);
    });
  });

  group('contextual service status navigation', () {
    testWidgets('back returns to the workspace', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Text('WORKSPACE')),
          GoRoute(
            path: AppRoutes.customerDashboard,
            builder: (_, __) => const Text('DASHBOARD'),
          ),
          customerServiceStatusRoute,
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _statusOverrides(),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go(AppRoutes.customerDashboard);
      await tester.pumpAndSettle();

      // Reached contextually (pushed), as Home and Bookings do.
      router.push(AppRoutes.customerServiceStatus);
      await tester.pumpAndSettle();
      expect(find.byType(CustomerServiceStatusTab), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.byType(CustomerServiceStatusTab), findsNothing);
    });
  });
}

List<Override> _statusOverrides() {
  return [
    authNotifierProvider.overrideWith(_CustomerAuth.new),
    connectivityStatusProvider.overrideWith((ref) => const Stream.empty()),
    customerDashboardProvider.overrideWith(_FakeDashboardNotifier.new),
    customerBookingsProvider.overrideWith((ref) async => const []),
    customerApprovalsProvider.overrideWith((ref) async => const []),
    customerInvoicesProvider.overrideWith((ref) async => const []),
  ];
}

Future<GoRouter> _pumpRealRouter(
  WidgetTester tester, {
  bool authenticated = true,
}) async {
  late final GoRouter router;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(
          authenticated ? _CustomerAuth.new : _AnonymousAuth.new,
        ),
        connectivityStatusProvider.overrideWith((ref) => const Stream.empty()),
        customerDashboardProvider.overrideWith(_FakeDashboardNotifier.new),
        customerBookingsProvider.overrideWith((ref) async => const []),
        customerApprovalsProvider.overrideWith((ref) async => const []),
        customerInvoicesProvider.overrideWith((ref) async => const []),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          router = ref.watch(appRouterProvider);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  // The workspace opens first and its out-of-scope Vehicles tab still loads
  // hardcoded stock imagery, which the test HTTP client rejects. Only those
  // unrelated failures are tolerated.
  await _ignoreOutOfScopeImageFailures(tester);
  return router;
}

Future<void> _ignoreOutOfScopeImageFailures(WidgetTester tester) async {
  Object? failure;
  while ((failure = tester.takeException()) != null) {
    if (failure is! NetworkImageLoadException) {
      fail('Unexpected error while rendering the workspace: $failure');
    }
  }
}

class _CustomerAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 'test-token');
}

class _AnonymousAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  @override
  CustomerDashboardState build() => CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: const [_vehicle],
    notifications: const [],
    activeService: _liveService,
    profile: const CustomerEntity(
      name: 'Ahmed Al Mansoori',
      firstName: 'Ahmed',
      avatarInitials: 'AM',
      memberId: 'CUS-1042',
    ),
  );

  @override
  Future<void> refresh() async {}
}

const _vehicle = CustomerVehicleEntity(
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
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Land Cruiser',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  currentStage: 'quality_check',
  technicianName: 'Ravi',
  stages: [],
);
