import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';
import 'package:staff_app/features/common/presentation/simple_pages.dart';
import 'package:staff_app/features/common/presentation/staff_attendance_screen.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_job_detail_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
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
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

import '../../features/advisor/domain/entities/job_card_entity.dart';

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
  static const String technicianJobDetail = '/technician/job-detail';
  static const String scanVehicle = '/scan-vehicle';
  static const String vehicleCustomer = '/vehicle-customer';
  static const String advisorCheckIn = '/advisor/check-in';
  static const String advisorJobDetail = '/advisor/job-detail';
  static const String inspectionPreview = '/inspection-preview';
  static const String inspectionSheet = '/inspection-sheet';
  static const String chooseInspection = '/choose-inspection';
  static const String repairOrder = '/repair-order';
  static const String repairOrderPreview = '/repair-order-preview';
  static const String profile = '/profile';
  static const String shiftDetails = '/shift-details';
  static const String settings = '/settings';
  static const String attendance = '/attendance';
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
          matched == AppRoutes.login || matched == AppRoutes.supervisorLogin;
      // Password recovery is the one auth-adjacent flow a signed-in staff
      // member may legitimately open from Profile ("Reset password"), so it
      // must stay reachable while authenticated instead of being redirected
      // back to the dashboard.
      final isPasswordRecoveryRoute = matched == AppRoutes.forgotPassword;
      final isPublicRoute = isAuthRoute || isPasswordRecoveryRoute;

      return switch (authState) {
        AuthUnauthenticated() => isPublicRoute ? null : AppRoutes.login,
        AuthLoading() =>
          matched == AppRoutes.startup ? null : AppRoutes.startup,
        AuthError() => isPublicRoute ? null : AppRoutes.login,
        AuthAuthenticated(:final role) when !_isStaffRole(role) =>
          isPublicRoute ? null : AppRoutes.login,
        AuthAuthenticated(:final role) =>
          isAuthRoute ||
                  matched == AppRoutes.startup ||
                  !_isRouteAllowedForRole(role, matched)
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
        builder: (context, state) {
          final t = StaffLocalizations.of(context);
          return LoginView(
            appName: t?.loginAppName ?? 'Orient Staff App',
            intendedUsers:
                t?.loginIntendedUsers ??
                'For advisors, technicians, and supervisors',
            appPurpose:
                t?.loginAppPurpose ??
                'Confirm bookings, check in vehicles, run inspections, assign repair work, update tasks, and complete QC.',
            securityNotice: t?.authSecurityNotice,
            onLoginSuccess: () {
              final authState = ref.read(authNotifierProvider);
              if (authState is AuthAuthenticated) {
                context.go(AppRoutes.dashboardForRole(authState.role));
              }
            },
            onForgotPassword: () => context.push(AppRoutes.forgotPassword),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        builder: (context, state) {
          final t = StaffLocalizations.of(context);
          return ForgotPasswordView(
            onBackToLogin: () => context.pop(),
            appName: t?.loginAppName ?? 'Orient Staff App',
            intendedUsers:
                t?.loginIntendedUsers ??
                'For advisors, technicians, and supervisors',
            appPurpose:
                t?.loginAppPurpose ??
                'Confirm bookings, check in vehicles, run inspections, assign repair work, update tasks, and complete QC.',
            securityNotice: t?.authSecurityNotice,
          );
        },
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
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteAssignTitle,
            subtitle: t.svRouteAssignSubtitle,
            child: const SupervisorAssignSheet(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorJobs,
        name: AppRoutes.supervisorJobs,
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteJobsTitle,
            subtitle: t.svRouteJobsSubtitle,
            child: SupervisorJobsTab(onOpenAssign: () {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorQueue,
        name: AppRoutes.supervisorQueue,
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteQueueTitle,
            subtitle: t.svRouteQueueSubtitle,
            child: SupervisorQueueTab(onOpenReview: () {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorReview,
        name: AppRoutes.supervisorReview,
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteReviewTitle,
            subtitle: t.svRouteReviewSubtitle,
            child: const SupervisorReviewTab(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorStaff,
        name: AppRoutes.supervisorStaff,
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteStaffTitle,
            subtitle: t.svRouteStaffSubtitle,
            child: const SupervisorStaffTab(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorSchedule,
        name: AppRoutes.supervisorSchedule,
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteScheduleTitle,
            subtitle: t.svRouteScheduleSubtitle,
            child: SupervisorScheduleTab(onOpenQueue: () {}),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.supervisorReports,
        name: AppRoutes.supervisorReports,
        builder: (context, state) {
          final t = StaffLocalizations.of(context)!;
          return SupervisorSubPageWrapper(
            title: t.svRouteReportsTitle,
            subtitle: t.svRouteReportsSubtitle,
            child: const SupervisorReportsTab(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.technicianDashboard,
        name: AppRoutes.technicianDashboard,
        builder: (context, state) => const TechnicianDashboardView(),
      ),
      GoRoute(
        path: AppRoutes.technicianJobDetail,
        name: AppRoutes.technicianJobDetail,
        builder: (context, state) {
          final job = state.extra;
          return job is TechnicianJobEntity
              ? JobDetailSheet(job: job)
              : const TechnicianDashboardView();
        },
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
        path: AppRoutes.advisorCheckIn,
        name: AppRoutes.advisorCheckIn,
        builder: (context, state) {
          final extra = _mapExtra(state.extra);
          return AdvisorVehicleCheckinView(
            bookingId: extra?['bookingId']?.toString() ?? '',
            customerName: extra?['customerName']?.toString() ?? '',
            vehicleInfo: extra?['vehicleInfo']?.toString() ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.advisorJobDetail,
        name: AppRoutes.advisorJobDetail,
        builder: (context, state) {
          final extra = state.extra;
          return extra is JobCardEntity
              ? AdvisorJobDetailView(jc: extra)
              : const AdvisorHomeView();
        },
      ),
      GoRoute(
        path: AppRoutes.chooseInspection,
        name: AppRoutes.chooseInspection,
        builder: (context, state) => ChooseInspectionView(
          jobId: _mapExtra(state.extra)?['jobId'] as String? ?? '',
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
        builder: (context, state) {
          final extra = _mapExtra(state.extra);
          return RepairOrderView(
            onBack: extra?['onBack'] as VoidCallback? ?? (() => context.pop()),
            fromInspection: extra?['fromInspection'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.repairOrderPreview,
        name: AppRoutes.repairOrderPreview,
        builder: (context, state) =>
            RepairOrderPreviewView(onBack: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        name: AppRoutes.attendance,
        builder: (context, state) => const StaffAttendanceScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) {
          final extra = state.extra;
          final authState = ref.read(authNotifierProvider);
          final me = authState is AuthAuthenticated ? authState.profile : null;
          final fallbackRole = authState is AuthAuthenticated
              ? _displayRole(authState.role)
              : '';
          final passed = extra is ProfileData ? extra : null;
          return StaffProfileScreen(
            data: ProfileData(
              name: _firstNonEmpty([passed?.name, me?.name, 'Staff Member']),
              id: _firstNonEmpty([
                passed?.id,
                me?.empId,
                me?.staffId?.toString(),
              ]),
              role: _firstNonEmpty([
                passed?.role,
                me?.designation,
                me?.role,
                fallbackRole,
              ]),
              branch: _firstNonEmpty([passed?.branch, me?.branchName]),
              shift: _firstNonEmpty([passed?.shift, me?.shift]),
              email: _firstNonEmpty([passed?.email, me?.email]),
              phone: _firstNonEmpty([passed?.phone, me?.phone]),
              avatarInitials: _firstNonEmpty([
                passed?.avatarInitials,
                me?.avatarInitials,
                me?.initials,
              ]),
            ),
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

bool _isRouteAllowedForRole(UserRole role, String location) {
  const commonRoutes = {
    AppRoutes.profile,
    AppRoutes.shiftDetails,
    AppRoutes.settings,
    AppRoutes.attendance,
    // Reachable from Profile's "Reset password"; it is a real, OTP-verified
    // backend flow that also revokes refresh tokens server-side.
    AppRoutes.forgotPassword,
  };
  if (commonRoutes.contains(location)) return true;

  return switch (role) {
    UserRole.supervisor =>
      location == AppRoutes.supervisorDashboard ||
          location.startsWith('/supervisor/'),
    UserRole.advisor =>
      location == AppRoutes.advisorDashboard ||
          location == AppRoutes.scanVehicle ||
          location == AppRoutes.vehicleCustomer ||
          location == AppRoutes.advisorCheckIn ||
          location == AppRoutes.advisorJobDetail ||
          location == AppRoutes.inspectionPreview ||
          location == AppRoutes.inspectionSheet ||
          location == AppRoutes.chooseInspection ||
          location == AppRoutes.repairOrder ||
          location == AppRoutes.repairOrderPreview,
    UserRole.technician =>
      location == AppRoutes.technicianDashboard ||
          location == AppRoutes.technicianJobDetail,
    _ => false,
  };
}

Map<String, dynamic>? _mapExtra(Object? extra) {
  return extra is Map<String, dynamic> ? extra : null;
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _displayRole(UserRole role) {
  return switch (role) {
    UserRole.advisor => 'Service Advisor',
    UserRole.technician => 'Technician',
    UserRole.supervisor => 'Supervisor',
    _ => 'Staff',
  };
}

/// Pushed supervisor sub-page chrome (Phase 11): shared [WorkspaceAppBar] plus a
/// wayfinding breadcrumb trail above the surface, replacing the bespoke `AppBar`.
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
    final t = StaffLocalizations.of(context);
    final root = t?.svBreadcrumbConsole ?? 'Supervisor console';
    return Scaffold(
      appBar: WorkspaceAppBar(
        title: title,
        subtitle: subtitle,
        showBack: true,
        onBack: () => context.pop(),
        frosted: !context.isCompact,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s20,
              AppDimensions.s12,
              AppDimensions.s20,
              AppDimensions.s4,
            ),
            child: AppBreadcrumbs(
              items: [
                AppBreadcrumbItem(
                  label: root,
                  onTap: () => context.pop(),
                ),
                AppBreadcrumbItem.current(title),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
