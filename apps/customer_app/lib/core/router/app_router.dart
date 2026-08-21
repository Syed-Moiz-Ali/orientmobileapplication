import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/add_vehicle_view.dart';
import 'package:customer_app/features/customer/presentation/customer_book_service_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_success_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_help_view.dart';
import 'package:customer_app/features/customer/presentation/customer_dashboard_view.dart';
import 'package:customer_app/features/customer/presentation/customer_feedback_view.dart';
import 'package:customer_app/features/customer/presentation/customer_invoice_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/customer_service_status_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
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
  static const String customerNotifications = '/notifications';
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
        AuthLoading() =>
          matched == AppRoutes.startup ? null : AppRoutes.startup,
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
        builder: (context, state) => ForgotPasswordView(
          onBackToLogin: () => context.go(AppRoutes.login),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        name: AppRoutes.customerDashboard,
        builder: (context, state) {
          final requestedTab =
              int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return CustomerDashboardView(initialTab: requestedTab.clamp(0, 4));
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
        path: AppRoutes.customerServiceStatus,
        name: AppRoutes.customerServiceStatus,
        builder: (context, state) => const CustomerServiceStatusView(),
      ),
      GoRoute(
        path: AppRoutes.customerNotifications,
        name: AppRoutes.customerNotifications,
        builder: (context, state) => const CustomerNotificationsView(),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        name: AppRoutes.customerAddVehicle,
        builder: (context, state) => const AddVehicleView(),
      ),
      GoRoute(
        path: '/edit-vehicle/:id',
        name: 'customerEditVehicle',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AddVehicleView(vehicleId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        name: AppRoutes.customerBookingDetail,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is CustomerBookingEntity) {
            return CustomerBookingDetailView(booking: extra);
          }

          if (extra is Map<String, dynamic>) {
            return CustomerBookingDetailView(
              booking: CustomerBookingEntity.fromJson(extra),
            );
          }

          return const _RouteErrorPage(
            title: 'Booking detail unavailable',
            message: 'Select a booking again from My Bookings.',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownDetail,
        name: AppRoutes.customerBreakdownDetail,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is! Map<String, dynamic>) {
            return const _RouteErrorPage(
              title: 'Breakdown detail unavailable',
              message: 'Select a request again from Breakdown Help.',
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
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Text(
          'No route found for ${state.matchedLocation}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
});

class _RouteErrorPage extends StatelessWidget {
  final String title;
  final String message;

  const _RouteErrorPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.customerDashboard),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
