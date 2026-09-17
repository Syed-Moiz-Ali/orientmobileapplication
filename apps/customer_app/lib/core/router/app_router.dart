import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/add_vehicle_view.dart';
import 'package:customer_app/features/customer/presentation/customer_book_service_view.dart';
import 'package:customer_app/features/customer/presentation/customer_approvals_page.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_booking_success_view.dart';

import 'package:customer_app/features/customer/presentation/customer_breakdown_help_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_result_view.dart';
import 'package:customer_app/features/customer/presentation/customer_dashboard_view.dart';
import 'package:customer_app/features/customer/presentation/customer_feedback_view.dart';
import 'package:customer_app/features/customer/presentation/customer_invoice_detail_view.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/customer_service_status_page.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
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

  /// Where a submitted roadside request is confirmed. It carries the result
  /// of the request the customer just made, because there is no endpoint that
  /// can read a breakdown back, and never pretends to be a tracking page.
  static const String customerBreakdownResult = '/customer_breakdown_result';
  static const String forgotPassword = '/forgot-password';
  static const String customerAddVehicle = '/add-vehicle';
  static String customerEditVehicle(String id) => '/edit-vehicle/$id';
  static const String customerBookingSuccess = '/booking-success';
  static const String customerInvoiceDetail = '/invoice-detail';
  static const String customerFeedback = '/feedback';
  static const String customerNotifications = '/notifications';

  /// Canonical contextual Service Status route.
  ///
  /// Status is not a permanent workspace destination: it is the detailed view
  /// of one active workshop job, opened from Home, Bookings, notifications or a
  /// deep link.
  static const String customerServiceStatus = '/customer_service_status';

  /// Pre-migration Status path, kept resolving for existing bookmarks.
  static const String customerServiceStatusLegacy =
      '/customer_service_status_view';

  /// Canonical contextual Approvals route.
  ///
  /// Approvals is not a permanent workspace destination: the backend only
  /// exposes *pending* estimate decisions (no approval history), and Home,
  /// Bookings and Booking Details already surface each decision with an exact
  /// deep link. The page lists what needs a decision — and the settled invoices
  /// that have no other entry point — while `?estimateId=` opens that one
  /// estimate directly.
  static const String customerApprovals = '/customer_approvals';

  /// Canonical workspace location for a primary destination.
  static String tabLocation(CustomerDestination destination) =>
      '$customerDashboard?tab=${destination.name}';

  /// Canonical Customer Bookings location.
  static String get bookingsLocation =>
      tabLocation(CustomerDestination.bookings);

  /// Canonical Book Service location, optionally preselecting one vehicle.
  ///
  /// The vehicle id travels as an explicit query parameter, so a
  /// vehicle-specific entry point (the Vehicles tab) hands the chosen car to
  /// the flow without overloading unrelated route extras.
  static String customerBookServiceLocation({String vehicleId = ''}) {
    final id = vehicleId.trim();
    if (id.isEmpty) return customerBookService;
    return '$customerBookService?vehicleId=${Uri.encodeQueryComponent(id)}';
  }

  /// Canonical Customer Approvals location.
  ///
  /// With an estimate id this opens that estimate's decision detail; without
  /// one it opens the approvals overview. Both remain valid deep links.
  static String approvalsLocation({String estimateId = ''}) {
    final id = estimateId.trim();
    if (id.isEmpty) return customerApprovals;
    return '$customerApprovals?estimateId=${Uri.encodeQueryComponent(id)}';
  }
}

final _routerRefreshNotifier = ValueNotifier<int>(0);

/// Canonical contextual Service Status route.
///
/// Renders the already-redesigned tracking experience as a pushed page — no
/// duplicate implementation, no bottom-navigation destination.
final GoRoute customerServiceStatusRoute = GoRoute(
  path: AppRoutes.customerServiceStatus,
  name: AppRoutes.customerServiceStatus,
  builder: (context, state) => const CustomerServiceStatusPage(),
);

/// Compatibility route for the pre-migration `/customer_service_status_view`
/// path.
///
/// That path must keep resolving so existing bookmarks and deep links do not
/// 404, but it now points at the canonical contextual Service Status route
/// instead of the removed duplicate implementation.
final GoRoute customerServiceStatusCompatRoute = GoRoute(
  path: AppRoutes.customerServiceStatusLegacy,
  name: AppRoutes.customerServiceStatusLegacy,
  redirect: (context, state) => AppRoutes.customerServiceStatus,
);

/// Canonical contextual Approvals route.
///
/// Approvals is a pushed page, not a workspace destination. `?estimateId=` opens
/// that estimate's decision directly (from Home, a Bookings row or Booking
/// Details); without it the page shows what still needs a decision.
final GoRoute customerApprovalsRoute = GoRoute(
  path: AppRoutes.customerApprovals,
  name: AppRoutes.customerApprovals,
  builder: (context, state) => CustomerApprovalsPage(
    estimateId: state.uri.queryParameters['estimateId'] ?? '',
  ),
);

/// Canonical Booking Details route.
///
/// The detailed single-booking surface receives the booking it must represent
/// through route `extra` (an entity, or a map parsed into one). Anything
/// missing or unusable recovers to the named Bookings destination instead of
/// rendering an empty screen or crashing.
final GoRoute customerBookingDetailRoute = GoRoute(
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

    return _RouteErrorPage(
      title: 'Booking detail unavailable',
      message:
          "We couldn't find this booking. Open My Bookings to pick "
          'an appointment again.',
      actionLabel: 'Return to bookings',
      actionLocation: AppRoutes.bookingsLocation,
    );
  },
);

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
          appName: 'Orient Customer App',
          intendedUsers: 'For vehicle owners and service customers',
          appPurpose:
              'Book service, track your vehicle, review estimates, approve repairs, and view invoices.',
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
          appName: 'Orient Customer App',
          intendedUsers: 'For vehicle owners and service customers',
          appPurpose:
              'Book service, track your vehicle, review estimates, approve repairs, and view invoices.',
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        name: AppRoutes.customerDashboard,
        // Migration: `?tab=1` selected Status and `?tab=3` selected Approvals
        // before both became contextual. Each is redirected to its canonical
        // route — carrying any `estimateId` along — rather than silently opening
        // whichever destination now sits at that index.
        redirect: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          if (CustomerDestination.isStatusTabValue(tab)) {
            return AppRoutes.customerServiceStatus;
          }
          if (CustomerDestination.isApprovalsTabValue(tab)) {
            return AppRoutes.approvalsLocation(
              estimateId: state.uri.queryParameters['estimateId'] ?? '',
            );
          }
          return null;
        },
        builder: (context, state) {
          final destination =
              CustomerDestination.fromTabValue(
                state.uri.queryParameters['tab'],
              ) ??
              CustomerDestination.home;
          return CustomerDashboardView(initialDestination: destination);
        },
      ),
      customerServiceStatusRoute,
      customerApprovalsRoute,
      GoRoute(
        path: AppRoutes.customerBookService,
        name: AppRoutes.customerBookService,
        builder: (context, state) => CustomerBookServiceView(
          vehicleId: state.uri.queryParameters['vehicleId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownHelp,
        name: AppRoutes.customerBreakdownHelp,
        builder: (context, state) => const CustomerBreakdownHelpView(),
      ),
      customerServiceStatusCompatRoute,
      customerBookingDetailRoute,
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
        path: AppRoutes.customerBreakdownResult,
        name: AppRoutes.customerBreakdownResult,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is! Map<String, dynamic>) {
            return const _RouteErrorPage(
              title: 'Request unavailable',
              message: 'Open Roadside assistance to send a new request.',
              actionLabel: 'Roadside assistance',
              actionLocation: AppRoutes.customerBreakdownHelp,
            );
          }

          return CustomerBreakdownResultView(result: extra);
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
            bookingRef: args['ref'] as String? ?? '',
            bookingId: args['id'] as String? ?? '',
            service: args['service'] as String,
            date: args['date'] as String,
            time: args['time'] as String,
            vehicle: args['vehicle'] as String? ?? '',
            plate: args['plate'] as String? ?? '',
            queuedOffline: args['queued'] as bool? ?? false,
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

  /// Where the recovery action sends the customer. Defaults to the Home
  /// destination so pre-existing callers keep their behaviour.
  final String actionLabel;
  final String actionLocation;

  const _RouteErrorPage({
    required this.title,
    required this.message,
    this.actionLabel = 'Return to Home',
    this.actionLocation = AppRoutes.customerDashboard,
  });

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
                onPressed: () => context.go(actionLocation),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
