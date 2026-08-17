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
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/technician/presentation/technician_dashboard_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String startup = '/';
  static const String login = '/login';
  static const String supervisorLogin = '/supervisor-login';
  static const String advisorDashboard = '/advisor_home_view';
  static const String supervisorDashboard = '/supervisor_dashboard_view';
  static const String supervisorAssign = '/supervisor/assign';
  static const String supervisorJobs = '/supervisor/jobs';
  static const String supervisorQueue = '/supervisor/queue';
  static const String supervisorReview = '/supervisor/review';
  static const String supervisorStaff = '/supervisor/staff';
  static const String supervisorSchedule = '/supervisor/schedule';
  static const String supervisorReports = '/supervisor/reports';
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

      final isAuthRoute =
          matched == AppRoutes.login ||
          matched == AppRoutes.supervisorLogin ||
          matched == AppRoutes.forgotPassword;

      return switch (authState) {
        AuthUnauthenticated() => isAuthRoute ? null : AppRoutes.login,
        AuthLoading() =>
          matched == AppRoutes.startup ? null : AppRoutes.startup,
        AuthError() => isAuthRoute ? null : AppRoutes.login,
        AuthAuthenticated(:final role) when !_isStaffRole(role) =>
          isAuthRoute ? null : AppRoutes.login,
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
        path: AppRoutes.supervisorAssign,
        name: AppRoutes.supervisorAssign,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'Task Assignment',
          subtitle: 'Dispatch Tasks to Technicians',
          child: SupervisorAssignSheet(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supervisorJobs,
        name: AppRoutes.supervisorJobs,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'Active Job Cards',
          subtitle: 'Live Workshop Operations',
          child: SupervisorJobsTab(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supervisorQueue,
        name: AppRoutes.supervisorQueue,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'Dispatch Queue',
          subtitle: 'Incoming Bookings & Breakdowns',
          child: SupervisorQueueTab(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supervisorReview,
        name: AppRoutes.supervisorReview,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'QC Verification',
          subtitle: 'Sign-off Completed Repairs',
          child: SupervisorReviewTab(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supervisorStaff,
        name: AppRoutes.supervisorStaff,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'Floor Specialists',
          subtitle: 'Roster & Specialist Availability',
          child: SupervisorStaffTab(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supervisorSchedule,
        name: AppRoutes.supervisorSchedule,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'Bay Schedule',
          subtitle: 'Service Bay Timelines',
          child: SupervisorScheduleTab(),
        ),
      ),
      GoRoute(
        path: AppRoutes.supervisorReports,
        name: AppRoutes.supervisorReports,
        builder: (context, state) => const SupervisorSubPageWrapper(
          title: 'Financial Intelligence',
          subtitle: 'Throughput & Analytics',
          child: SupervisorReportsTab(),
        ),
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
        builder: (context, state) {
          final extra = state.extra;
          return VehicleCustomerView(
            bookingId: extra is Map ? (extra['bookingId'] as String?) : null,
          );
        },
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
          final extra = state.extra;
          final callbacks = extra is InspectionCallbacks ? extra : null;
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
          final extra = _mapExtra(state.extra);
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
            ShiftDetailsPage(data: _mapExtra(state.extra)),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        builder: (context, state) => SettingsPage(data: _mapExtra(state.extra)),
      ),
      GoRoute(
        path: AppRoutes.supervisorLogin,
        name: AppRoutes.supervisorLogin,
        builder: (context, state) => const SupervisorLoginView(),
      ),
    ],
  );
});

bool _isStaffRole(UserRole role) {
  return role == UserRole.advisor ||
      role == UserRole.supervisor ||
      role == UserRole.technician;
}

Map<String, dynamic>? _mapExtra(Object? extra) {
  return extra is Map<String, dynamic> ? extra : null;
}

class SupervisorSubPageWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const SupervisorSubPageWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
