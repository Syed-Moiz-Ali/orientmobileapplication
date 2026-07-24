import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/supervisor/presentation/supervisor_dashboard_view.dart';
import 'package:staff_app/features/technician/presentation/technician_dashboard_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String advisorDashboard = '/advisor_home_view';
  static const String supervisorDashboard = '/supervisor_dashboard_view';
  static const String technicianDashboard = '/technician-dashboard';
  static const String scanVehicle = '/scan-vehicle';
  static const String vehicleCustomer = '/vehicle-customer';
  static const String inspectionPreview = '/inspection-preview';
  static const String inspectionSheet = '/inspection-sheet';
  static const String chooseInspection = '/choose-inspection';
  static const String repairOrder = '/repair-order';
  static const String repairOrderPreview = '/repair-order-preview';
  static const String profile = '/profile';
  static const String shiftDetails = '/shift-details';
  static const String settings = '/settings';

  static String dashboardForRole(UserRole role) {
    switch (role) {
      case UserRole.advisor:
        return AppRoutes.advisorDashboard;
      case UserRole.supervisor:
        return AppRoutes.supervisorDashboard;
      case UserRole.technician:
        return AppRoutes.technicianDashboard;
      default:
        return AppRoutes.login;
    }
  }
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
        AuthAuthenticated(:final role) =>
          matched == AppRoutes.login ? AppRoutes.dashboardForRole(role) : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => LoginView(
          onLoginSuccess: () {
            final authState = ref.read(authNotifierProvider);
            if (authState is AuthAuthenticated) {
              context.go(AppRoutes.dashboardForRole(authState.role));
            }
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.advisorDashboard,
        name: AppRoutes.advisorDashboard,
        builder: (context, state) => const AdvisorHomeView(),
      ),
      GoRoute(
        path: AppRoutes.supervisorDashboard,
        name: AppRoutes.supervisorDashboard,
        builder: (context, state) => const SupervisorDashboardView(),
      ),
      GoRoute(
        path: AppRoutes.technicianDashboard,
        name: AppRoutes.technicianDashboard,
        builder: (context, state) => const TechnicianDashboardView(),
      ),
    ],
  );
});
