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
import 'package:customer_app/features/customer/presentation/customer_booking_success_view.dart';
import 'package:customer_app/features/customer/presentation/customer_invoice_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_feedback_view.dart';
import 'package:customer_app/features/customer/presentation/customer_service_status_view.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:shared_core/shared_core.dart';

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
  static const String customerBookingSuccess = '/booking-success';
  static const String customerInvoiceDetail = '/invoice-detail';
  static const String customerFeedback = '/feedback';
  static const String customerServiceStatus = '/customer_service_status_view';
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

      final isAuthRoute =
          matched == AppRoutes.login || matched == AppRoutes.forgotPassword;

      return switch (authState) {
        AuthUnauthenticated() => isAuthRoute ? null : AppRoutes.login,
        AuthLoading() => matched == AppRoutes.startup ? null : AppRoutes.startup,
        AuthError() => isAuthRoute ? null : AppRoutes.login,
        AuthAuthenticated(:final role) when role != UserRole.customer =>
          isAuthRoute ? null : AppRoutes.login,
        AuthAuthenticated() =>
          matched == AppRoutes.login || matched == AppRoutes.startup
              ? AppRoutes.customerDashboard
              : null,
      };
    },
    routes: [
      GoRoute(path: AppRoutes.startup, builder: (context, state) => const AuthLoadingView()),
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
        builder: (context, state) => ForgotPasswordView(onBackToLogin: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        name: AppRoutes.customerDashboard,
        // FIX (audit P0/P1): 'Track Booking' pushes extra {'tab': 1} which was
        // silently ignored — the user landed on Home. Pass it through.
        builder: (context, state) {
          final extra = state.extra;
          int initialTab = 0;
          if (extra is Map<String, dynamic> && extra['tab'] is int) {
            initialTab = extra['tab'] as int;
          }
          return CustomerDashboardView(initialTab: initialTab);
        },
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
        builder: (context, state) => AddVehicleView(vehicleId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        name: AppRoutes.customerBookingDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! CustomerBookingEntity) {
            return const _RouteErrorPage(
              title: 'Booking unavailable',
              message: 'Open this booking again from My Bookings.',
            );
          }
          final booking = extra;
          return CustomerBookingDetailView(booking: booking);
        },
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownDetail,
        name: AppRoutes.customerBreakdownDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic>) {
            return const _RouteErrorPage(
              title: 'Breakdown unavailable',
              message: 'Open this request again from Service Status.',
            );
          }
          final breakdown = extra;
          return CustomerBreakdownDetailView(breakdown: breakdown);
        },
      ),
      GoRoute(
        path: AppRoutes.customerBookingSuccess,
        name: AppRoutes.customerBookingSuccess,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic> ||
              extra['service'] is! String ||
              extra['date'] is! String ||
              extra['time'] is! String) {
            return const _RouteErrorPage(
              title: 'Booking result unavailable',
              message: 'Check My Bookings for the latest appointment status.',
            );
          }
          final args = extra;
          return CustomerBookingSuccessView(
            bookingRef: args['ref'] as String?,
            service: args['service'] as String,
            date: args['date'] as String,
            time: args['time'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerInvoiceDetail,
        name: AppRoutes.customerInvoiceDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! InvoiceResponse) {
            return const _RouteErrorPage(
              title: 'Invoice unavailable',
              message: 'Open this invoice again from Estimates & Invoices.',
            );
          }
          final invoice = extra;
          return CustomerInvoiceDetailView(invoice: invoice);
        },
      ),
      GoRoute(
        path: AppRoutes.customerFeedback,
        name: AppRoutes.customerFeedback,
        builder: (context, state) => const CustomerFeedbackView(),
      ),
      GoRoute(
        path: AppRoutes.customerServiceStatus,
        name: AppRoutes.customerServiceStatus,
        builder: (context, state) => const CustomerServiceStatusView(),
      ),
    ],
  );
});

class _RouteErrorPage extends StatelessWidget {
  final String title;
  final String message;

  const _RouteErrorPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.customerDashboard),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s20),
          child: EmptyState(
            title: title,
            message: message,
            icon: Icons.link_off_rounded,
            actionLabel: 'Go to Dashboard',
            onAction: () => context.go(AppRoutes.customerDashboard),
          ),
        ),
      ),
    );
  }
}
