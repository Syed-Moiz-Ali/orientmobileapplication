import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/features/common/presentation/simple_pages.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/scan_vehicle_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/choose_inspection_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_sheet_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_preview_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/repair_order_view.dart';
import 'package:staff_app/features/supervisor/presentation/supervisor_dashboard_view.dart';
import 'package:staff_app/features/supervisor/presentation/supervisor_login_view.dart';
import 'package:staff_app/features/technician/presentation/technician_dashboard_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String startup = '/';
  static const String login = '/login';
  static const String supervisorLogin = '/supervisor-login';
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
  static const String forgotPassword = '/forgot-password';

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
        AuthAuthenticated(:final role) =>
          matched == AppRoutes.login || matched == AppRoutes.startup
              ? AppRoutes.dashboardForRole(role)
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
          onLoginSuccess: () {
            final authState = ref.read(authNotifierProvider);
            if (authState is AuthAuthenticated) {
              context.go(AppRoutes.dashboardForRole(authState.role));
            }
          },
          onForgotPassword: () => context.push(AppRoutes.forgotPassword),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) =>
            ForgotPasswordView(onBackToLogin: () => context.pop()),
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
      GoRoute(
        path: AppRoutes.scanVehicle,
        name: AppRoutes.scanVehicle,
        builder: (context, state) => const ScanVehicleView(),
      ),
      GoRoute(
        path: AppRoutes.vehicleCustomer,
        name: AppRoutes.vehicleCustomer,
        builder: (context, state) => const VehicleCustomerView(),
      ),
      GoRoute(
        path: AppRoutes.chooseInspection,
        name: AppRoutes.chooseInspection,
        builder: (context, state) => ChooseInspectionView(
          onSelect: () => context.pop(),
          onSkip: () => context.pop(),
          onBack: () => context.pop(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inspectionSheet,
        name: AppRoutes.inspectionSheet,
        builder: (context, state) {
          final callbacks = state.extra as InspectionCallbacks?;
          return InspectionSheetView(
            callbacks:
                callbacks ??
                InspectionCallbacks(
                  onBack: () => context.pop(),
                  onSaveDraft: () => context.pop(),
                  onPreview: () => context.push(AppRoutes.inspectionPreview),
                ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inspectionPreview,
        name: AppRoutes.inspectionPreview,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return InspectionPreviewView(
            onBack: extra?['onBack'] as VoidCallback? ?? (() => context.pop()),
            jobId: extra?['jobId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.repairOrder,
        name: AppRoutes.repairOrder,
        builder: (context, state) =>
            RepairOrderView(onBack: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.repairOrderPreview,
        name: AppRoutes.repairOrderPreview,
        builder: (context, state) =>
            RepairOrderPreviewView(onBack: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) {
          final extra = state.extra;
          return ProfilePage(
            data: extra is ProfileData
                ? extra
                : ProfileData(name: '', id: '', role: '', branch: ''),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shiftDetails,
        name: AppRoutes.shiftDetails,
        builder: (context, state) =>
            ShiftDetailsPage(data: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        builder: (context, state) =>
            SettingsPage(data: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: AppRoutes.supervisorLogin,
        name: AppRoutes.supervisorLogin,
        builder: (context, state) => const SupervisorLoginView(),
      ),
    ],
  );
});
