import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:customer_app/features/customer/presentation/customer_dashboard_view.dart';
import 'package:customer_app/features/customer/presentation/customer_book_service_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_help_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_detail_view.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String customerDashboard = '/customer_dashboard_view';
  static const String customerBookService = '/customer_book_service_view';
  static const String customerBreakdownHelp = '/customer_breakdown_help_view';
  static const String customerBookingDetail = '/customer_booking_detail';
  static const String customerBreakdownDetail = '/customer_breakdown_detail';
}

final _routerRefreshNotifier = ValueNotifier<void>(null);

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.listen<AuthState>(authNotifierProvider, (_, __) {
    _routerRefreshNotifier.value = null;
  });

  return GoRouter(
    refreshListenable: _routerRefreshNotifier,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final matched = state.matchedLocation;

      return switch (authState) {
        AuthUnauthenticated() =>
          matched == AppRoutes.login ? null : AppRoutes.login,
        AuthLoading() => null,
        AuthError() =>
          matched == AppRoutes.login ? null : AppRoutes.login,
        AuthAuthenticated() =>
          matched == AppRoutes.login ? AppRoutes.customerDashboard : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => LoginView(
          onLoginSuccess: () => context.go(AppRoutes.customerDashboard),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        name: AppRoutes.customerDashboard,
        builder: (context, state) => const CustomerDashboardView(),
      ),
      GoRoute(
        path: AppRoutes.customerBookService,
        name: AppRoutes.customerBookService,
        builder: (context, state) => const CustomerBookServiceView(),
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownHelp,
        name: AppRoutes.customerBreakdownHelp,
        builder: (context, state) => const CustomerBreakdownHelpView(),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        name: AppRoutes.customerBookingDetail,
        builder: (context, state) {
          final booking = state.extra as CustomerBookingEntity;
          return CustomerBookingDetailView(booking: booking);
        },
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownDetail,
        name: AppRoutes.customerBreakdownDetail,
        builder: (context, state) {
          final breakdown = state.extra as Map<String, dynamic>;
          return CustomerBreakdownDetailView(breakdown: breakdown);
        },
      ),
    ],
  );
});
