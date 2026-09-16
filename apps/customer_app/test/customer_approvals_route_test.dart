import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_approvals_page.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_scaffold.dart';

/// Approvals became contextual: `/customer_approvals` is the canonical pushed
/// page, and every pre-migration link (including `?tab=3`) resolves to it
/// instead of silently opening whichever destination now sits at that index.
void main() {
  group('canonical approvals route', () {
    test('is a pushed page, not a workspace destination', () {
      final container = ProviderContainer(
        overrides: [authNotifierProvider.overrideWith(_CustomerAuth.new)],
      );
      addTearDown(container.dispose);

      expect(
        CustomerDestination.values.map((d) => d.name),
        isNot(contains('approvals')),
      );

      final routes = container
          .read(appRouterProvider)
          .configuration
          .routes
          .whereType<GoRoute>()
          .toList();

      final canonical = routes
          .where((route) => route.path == AppRoutes.customerApprovals)
          .toList();
      expect(canonical, hasLength(1));
      expect(canonical.single, same(customerApprovalsRoute));
      expect(
        canonical.single.builder,
        isNotNull,
        reason: 'the approvals page renders from the canonical route',
      );
    });

    testWidgets('renders the approvals overview with a back affordance', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester);

      router.go(AppRoutes.customerApprovals);
      await tester.pumpAndSettle();
      await _ignoreOutOfScopeImageFailures(tester);

      expect(find.byType(CustomerApprovalsPage), findsOneWidget);
      expect(find.text('Approvals & billing'), findsOneWidget);
      expect(find.text('Needs your decision'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('a targeted link opens that estimate', (tester) async {
      final router = await _pumpRealRouter(tester);

      router.go(AppRoutes.approvalsLocation(estimateId: 'EST-9001'));
      await tester.pumpAndSettle();
      await _ignoreOutOfScopeImageFailures(tester);

      expect(find.byType(CustomerApprovalsPage), findsOneWidget);
      expect(find.text('Estimate'), findsOneWidget);
    });

    testWidgets('the pre-migration ?tab=3 opens Approvals, never Vehicles', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester);

      router.go('${AppRoutes.customerDashboard}?tab=3');
      await tester.pumpAndSettle();
      await _ignoreOutOfScopeImageFailures(tester);

      final uri = router.routerDelegate.currentConfiguration.uri;
      expect(uri.path, AppRoutes.customerApprovals);
      expect(find.byType(CustomerApprovalsPage), findsOneWidget);
      // The workspace is not underneath: the legacy link cannot have opened
      // another destination such as Vehicles.
      expect(find.byType(CustomerScaffold), findsNothing);
    });

    testWidgets('the pre-migration ?tab=3 keeps its estimate id', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester);

      router.go('${AppRoutes.customerDashboard}?tab=3&estimateId=EST-9001');
      await tester.pumpAndSettle();
      await _ignoreOutOfScopeImageFailures(tester);

      final uri = router.routerDelegate.currentConfiguration.uri;
      expect(uri.path, AppRoutes.customerApprovals);
      expect(uri.queryParameters['estimateId'], 'EST-9001');
    });

    testWidgets('the named approvals tab value migrates too', (tester) async {
      final router = await _pumpRealRouter(tester);

      router.go('${AppRoutes.customerDashboard}?tab=approvals');
      await tester.pumpAndSettle();
      await _ignoreOutOfScopeImageFailures(tester);

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.customerApprovals,
      );
    });

    testWidgets('the other legacy indices keep their original meaning', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester);

      for (final legacy in const <String, String>{
        '0': 'home',
        '2': 'bookings',
        '4': 'vehicles',
        '5': 'profile',
      }.entries) {
        router.go('${AppRoutes.customerDashboard}?tab=${legacy.key}');
        await tester.pumpAndSettle();
        await _ignoreOutOfScopeImageFailures(tester);

        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          AppRoutes.customerDashboard,
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(CustomerScaffold)),
        );
        expect(
          container.read(customerDashboardProvider).selectedIndex,
          CustomerDestination.values.byName(legacy.value).index,
          reason: 'legacy tab ${legacy.key} must still open ${legacy.value}',
        );
      }
    });

    testWidgets('an unauthenticated approvals deep link goes to sign in', (
      tester,
    ) async {
      final router = await _pumpRealRouter(tester, authenticated: false);

      router.go(AppRoutes.approvalsLocation(estimateId: 'EST-9001'));
      await tester.pumpAndSettle();

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.login,
      );
      expect(find.byType(CustomerApprovalsPage), findsNothing);
    });
  });
}

List<Override> _overrides({bool authenticated = true}) {
  return [
    authNotifierProvider.overrideWith(
      authenticated ? _CustomerAuth.new : _AnonymousAuth.new,
    ),
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
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  late final GoRouter router;
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(authenticated: authenticated),
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
  // The workspace's out-of-scope Vehicles tab still loads hardcoded stock
  // imagery, which the test HTTP client rejects. Only those are tolerated.
  await _ignoreOutOfScopeImageFailures(tester);
  return router;
}

/// The workspace's Vehicles tab is not part of this phase: it still loads
/// hardcoded stock imagery (which the test HTTP client rejects) and overflows at
/// phone sizes. Both are pre-existing and out of scope, so only those failures
/// are tolerated while these route tests navigate the real workspace.
Future<void> _ignoreOutOfScopeImageFailures(WidgetTester tester) async {
  Object? failure;
  while ((failure = tester.takeException()) != null) {
    final tolerated =
        failure is NetworkImageLoadException ||
        failure.toString().contains('A RenderFlex overflowed');
    if (!tolerated) {
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
    vehicles: const [
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
    notifications: const [],
  );

  @override
  Future<void> refresh() async {}
}
