import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/pages/profile_view.dart';
import 'package:orientmobileapplication/core/pages/settings_view.dart';
import 'package:orientmobileapplication/core/pages/shift_details_view.dart';
import 'package:orientmobileapplication/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/choose_inspection_view.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/presentation/pages/login_view.dart';
import 'package:orientmobileapplication/features/auth/presentation/pages/role_selection_view.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/crm_dashboard_view.dart';
import 'package:orientmobileapplication/features/customer/presentation/customer_dashboard_view.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/dashboard_view.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/pages/accounts_receivable_view.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/pages/document_expiry_view.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/pages/job_status_view.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/pages/pending_approvals_view.dart';
import 'package:orientmobileapplication/features/job_cards/presentation/pages/job_card_detail_view.dart';
import 'package:orientmobileapplication/features/supervisor/presentation/supervisor_dashboard_view.dart';
// New Imports for GoRouter migration
import 'package:orientmobileapplication/features/advisor/vehicle_customer/vehicle_customer_view.dart';
import 'package:orientmobileapplication/features/advisor/scan_vehicle_view.dart';
import 'package:orientmobileapplication/features/customer/presentation/customer_book_service_view.dart';
import 'package:orientmobileapplication/core/router/inspection_callbacks.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/repair_order_view.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/inspection_sheet_view.dart';
import 'package:orientmobileapplication/features/advisor/inspection_pages/inspection_preview_view.dart';
import 'package:orientmobileapplication/features/technician/presentation/technician_dashboard_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String roleSelection = '/role_selection_view';
  static const String ownerDashboard = '/owner-dashboard';
  static const String advisorDashboard = '/advisor_home_view';
  static const String customerPortal = '/customer_dashboard_view';
  static const String login = '/login/:role';
  static const String jobCardDetail = '/job_card_detail_view';
  static const String accountsReceivable = '/accounts_receivable_view';
  static const String pendingApprovals = '/pending_approvals_view';
  static const String documentExpiry = '/document_expiry_view';
  static const String chooseInspection = '/choose_inspection_view';
  static const String technicianDashboard = '/technician-dashboard';
  static const String supervisorDashboard = '/supervisor_dashboard_view';
  static const String jobStatus = '/job_status_view';
  static const String crmDashboard = '/crm_dashboard_view';

  // New Route Path Constants
  static const String vehicleCustomer = '/vehicle_customer_view';
  static const String scanVehicle = '/scan_vehicle_view';
  static const String customerBookService = '/customer_book_service_view';
  static const String repairOrder = '/repair_order_view';
  static const String inspectionSheet = '/inspection_sheet_view';
  static const String inspectionPreview = '/inspection_preview_view';
  static const String repairOrderPreview = '/repair_order_preview_view';
  static const String profile = '/profile_view';
  static const String shiftDetails = '/shift_details_view';
  static const String settings = '/settings_view';

  static UserRole roleFromPath(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.owner,
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.roleSelection,
  routes: [
    GoRoute(
      path: AppRoutes.roleSelection,
      name: AppRoutes.roleSelection,
      builder: (context, state) => const RoleSelectionView(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.login,
      builder: (context, state) {
        final role = AppRoutes.roleFromPath(state.pathParameters['role']!);
        return LoginView(role: role);
      },
    ),
    GoRoute(
      path: AppRoutes.ownerDashboard,
      name: AppRoutes.ownerDashboard,
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: AppRoutes.advisorDashboard,
      name: AppRoutes.advisorDashboard,
      builder: (context, state) => const AdvisorHomeView(),
    ),
    GoRoute(
      path: AppRoutes.customerPortal,
      name: AppRoutes.customerPortal,
      builder: (context, state) => const CustomerDashboardView(),
    ),
    GoRoute(
      path: AppRoutes.jobCardDetail,
      name: AppRoutes.jobCardDetail,
      builder: (context, state) => const JobCardDetailView(),
    ),
    GoRoute(
      path: AppRoutes.accountsReceivable,
      name: AppRoutes.accountsReceivable,
      builder: (context, state) => const AccountsReceivableView(),
    ),
    GoRoute(
      path: AppRoutes.pendingApprovals,
      name: AppRoutes.pendingApprovals,
      builder: (context, state) => const PendingApprovalsView(),
    ),
    GoRoute(
      path: AppRoutes.documentExpiry,
      name: AppRoutes.documentExpiry,
      builder: (context, state) => const DocumentExpiryView(),
    ),
    GoRoute(
      path: AppRoutes.chooseInspection,
      name: AppRoutes.chooseInspection,
      builder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final onBack = extra?['onBack'] as VoidCallback? ?? () => context.pop();
        final onSkip = extra?['onSkip'] as VoidCallback? ?? () {};
        final onSelect = extra?['onSelect'] as VoidCallback? ?? () {};
        return ChooseInspectionView(
          onBack: onBack,
          onSkip: onSkip,
          onSelect: onSelect,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.technicianDashboard,
      name: AppRoutes.technicianDashboard,
      builder: (context, state) => const TechnicianDashboardView(),
    ),
    GoRoute(
      path: AppRoutes.supervisorDashboard,
      name: AppRoutes.supervisorDashboard,
      builder: (context, state) => const SupervisorDashboardView(),
    ),
    GoRoute(
      path: AppRoutes.jobStatus,
      name: AppRoutes.jobStatus,
      builder: (context, state) => const JobStatusView(),
    ),
    GoRoute(
      path: AppRoutes.crmDashboard,
      name: AppRoutes.crmDashboard,
      builder: (context, state) => const CrmDashboardView(),
    ),

    // New Registered Routes
    GoRoute(
      path: AppRoutes.vehicleCustomer,
      name: AppRoutes.vehicleCustomer,
      builder: (context, state) => const VehicleCustomerView(),
    ),
    GoRoute(
      path: AppRoutes.scanVehicle,
      name: AppRoutes.scanVehicle,
      builder: (context, state) => const ScanVehicleView(),
    ),
    GoRoute(
      path: AppRoutes.customerBookService,
      name: AppRoutes.customerBookService,
      builder: (context, state) => const CustomerBookServiceView(),
    ),
    GoRoute(
      path: AppRoutes.repairOrder,
      name: AppRoutes.repairOrder,
      builder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final onBack = extra?['onBack'] as VoidCallback? ?? () => context.pop();
        final fromInspection = extra?['fromInspection'] as bool? ?? false;
        return RepairOrderView(
          onBack: onBack,
          fromInspection: fromInspection,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.inspectionSheet,
      name: AppRoutes.inspectionSheet,
      builder: (context, state) {
        final callbacks = state.extra as InspectionCallbacks? ??
            InspectionCallbacks(
              onBack: () => context.pop(),
              onSaveDraft: () {},
              onPreview: () {},
            );
        return InspectionSheetView(callbacks: callbacks);
      },
    ),
    GoRoute(
      path: AppRoutes.inspectionPreview,
      name: AppRoutes.inspectionPreview,
      builder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final onBack = extra?['onBack'] as VoidCallback? ?? () => context.pop();
        final jobId = extra?['jobId'] as String? ?? '';
        return InspectionPreviewView(onBack: onBack, jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.repairOrderPreview,
      name: AppRoutes.repairOrderPreview,
      builder: (context, state) {
        final Map<String, dynamic>? extra = state.extra as Map<String, dynamic>?;
        final onBack = extra?['onBack'] as VoidCallback? ?? () => context.pop();
        return RepairOrderPreviewView(
          onBack: onBack,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: AppRoutes.profile,
      builder: (context, state) {
        final profile = state.extra as ProfileData?;
        return ProfileView(
          profile: profile ?? ProfileData(name: '', id: '', role: '', branch: ''),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.shiftDetails,
      name: AppRoutes.shiftDetails,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ShiftDetailsView(
          employeeName: extra?['name'] as String? ?? '',
          employeeId: extra?['id'] as String? ?? '',
          currentShift: extra?['shift'] as String? ?? '',
          shiftStart: extra?['start'] as String? ?? '8:00 AM',
          shiftEnd: extra?['end'] as String? ?? '5:00 PM',
          branch: extra?['branch'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: AppRoutes.settings,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return SettingsView(
          appVersion: extra?['version'] as String? ?? '1.0.0',
        );
      },
    ),
  ],
);
