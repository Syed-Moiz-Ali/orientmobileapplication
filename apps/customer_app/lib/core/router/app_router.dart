import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:customer_app/features/customer/presentation/customer_dashboard_view.dart';
import 'package:customer_app/features/customer/presentation/customer_book_service_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_help_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_detail_view.dart';
import 'package:customer_app/features/customer/presentation/add_vehicle_view.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class AppRoutes {
  AppRoutes._();

  static const String startup = '/';
  static const String login = '/login';
  static const String customerDashboard = '/customer_dashboard_view';
  static const String customerBookService = '/customer_book_service_view';
  static const String customerBreakdownHelp = '/customer_breakdown_help_view';
  static const String customerBookingDetail = '/customer_booking_detail';
  static const String customerBreakdownDetail = '/customer_breakdown_detail';
  static const String forgotPassword = '/forgot-password';
  static const String customerAddVehicle = '/add-vehicle';
  static String customerEditVehicle(String id) => '/edit-vehicle/$id';
}

final _routerRefreshNotifier = ValueNotifier<int>(0);

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.listen<AuthState>(authNotifierProvider, (_, __) {
    _routerRefreshNotifier.value++;
  });

  return GoRouter(
    refreshListenable: _routerRefreshNotifier,
    initialLocation: AppRoutes.startup,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final matched = state.matchedLocation;

      return switch (authState) {
        AuthUnauthenticated() =>
          matched == AppRoutes.login || matched == AppRoutes.forgotPassword
              ? null
              : AppRoutes.login,
        AuthLoading() =>
          matched == AppRoutes.startup ? null : AppRoutes.startup,
        AuthError() =>
          matched == AppRoutes.login || matched == AppRoutes.forgotPassword
              ? null
              : AppRoutes.login,
        AuthAuthenticated() =>
          matched == AppRoutes.login || matched == AppRoutes.startup
              ? AppRoutes.customerDashboard
              : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const AuthLoadingView(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => LoginView(
          onLoginSuccess: () => context.go(AppRoutes.customerDashboard),
          onForgotPassword: () => context.push(AppRoutes.forgotPassword),
          allowRegistration: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) =>
            ForgotPasswordView(onBackToLogin: () => context.pop()),
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
        path: AppRoutes.customerAddVehicle,
        name: AppRoutes.customerAddVehicle,
        builder: (context, state) => const AddVehicleView(),
      ),
      GoRoute(
        path: '/edit-vehicle/:id',
        name: 'edit-vehicle',
        builder: (context, state) =>
            AddVehicleView(vehicleId: state.pathParameters['id']),
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
