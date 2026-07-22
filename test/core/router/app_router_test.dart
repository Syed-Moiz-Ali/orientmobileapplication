import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

void main() {
  group('AppRoutes.dashboardForRole', () {
    test('returns ownerDashboard for owner', () {
      expect(AppRoutes.dashboardForRole(UserRole.owner),
          AppRoutes.ownerDashboard);
    });
    test('returns advisorDashboard for advisor', () {
      expect(AppRoutes.dashboardForRole(UserRole.advisor),
          AppRoutes.advisorDashboard);
    });
    test('returns technicianDashboard for technician', () {
      expect(AppRoutes.dashboardForRole(UserRole.technician),
          AppRoutes.technicianDashboard);
    });
    test('returns supervisorDashboard for supervisor', () {
      expect(AppRoutes.dashboardForRole(UserRole.supervisor),
          AppRoutes.supervisorDashboard);
    });
    test('returns customerPortal for customer', () {
      expect(AppRoutes.dashboardForRole(UserRole.customer),
          AppRoutes.customerPortal);
    });
    test('returns crmDashboard for crmDashboard', () {
      expect(AppRoutes.dashboardForRole(UserRole.crmDashboard),
          AppRoutes.crmDashboard);
    });
  });

  group('AppRoutes.roleFromPath', () {
    test('parses owner from path', () {
      expect(AppRoutes.roleFromPath('owner'), UserRole.owner);
    });
    test('parses advisor from path', () {
      expect(AppRoutes.roleFromPath('advisor'), UserRole.advisor);
    });
    test('parses technician from path', () {
      expect(AppRoutes.roleFromPath('technician'), UserRole.technician);
    });
    test('defaults to owner for unknown path', () {
      expect(AppRoutes.roleFromPath('unknown'), UserRole.owner);
    });
  });

  group('AppRoutes.isPublicRoute', () {
    test('returns true for roleSelection', () {
      expect(AppRoutes.isPublicRoute(AppRoutes.roleSelection), isTrue);
    });
    test('returns true for login paths', () {
      expect(AppRoutes.isPublicRoute('/login/owner'), isTrue);
      expect(AppRoutes.isPublicRoute('/login/advisor'), isTrue);
    });
    test('returns true for forgot-password', () {
      expect(AppRoutes.isPublicRoute('/forgot-password'), isTrue);
      expect(AppRoutes.isPublicRoute('/forgot-password/owner'), isTrue);
    });
    test('returns false for dashboard paths', () {
      expect(AppRoutes.isPublicRoute(AppRoutes.ownerDashboard), isFalse);
      expect(AppRoutes.isPublicRoute(AppRoutes.advisorDashboard), isFalse);
    });
  });

  group('AppRoutes.hasPermission', () {
    test('owner can access every route', () {
      for (final route in AppRoutes.routePermissions.keys) {
        expect(AppRoutes.hasPermission(UserRole.owner, route), isTrue);
      }
      expect(AppRoutes.hasPermission(UserRole.owner, '/unlisted-route'), isTrue);
    });

    test('advisor can access advisor routes', () {
      expect(AppRoutes.hasPermission(UserRole.advisor, AppRoutes.advisorDashboard),
          isTrue);
      expect(AppRoutes.hasPermission(UserRole.advisor, AppRoutes.chooseInspection),
          isTrue);
      expect(AppRoutes.hasPermission(UserRole.advisor, AppRoutes.jobStatus), isTrue);
    });

    test('advisor cannot access supervisor-only routes', () {
      expect(
          AppRoutes.hasPermission(UserRole.advisor, AppRoutes.supervisorDashboard),
          isFalse);
    });

    test('technician can access own dashboard', () {
      expect(
          AppRoutes.hasPermission(
              UserRole.technician, AppRoutes.technicianDashboard),
          isTrue);
    });

    test('technician cannot access advisor routes', () {
      expect(
          AppRoutes.hasPermission(UserRole.technician, AppRoutes.advisorDashboard),
          isFalse);
    });

    test('supervisor has access to pendingApprovals', () {
      expect(
          AppRoutes.hasPermission(
              UserRole.supervisor, AppRoutes.pendingApprovals),
          isTrue);
    });

    test('customer can access customerPortal and customerBookService', () {
      expect(
          AppRoutes.hasPermission(UserRole.customer, AppRoutes.customerPortal),
          isTrue);
      expect(
          AppRoutes.hasPermission(
              UserRole.customer, AppRoutes.customerBookService),
          isTrue);
    });

    test('unlisted routes are accessible by any role', () {
      expect(
          AppRoutes.hasPermission(UserRole.advisor, '/profile_view'), isTrue);
      expect(
          AppRoutes.hasPermission(UserRole.technician, '/settings_view'), isTrue);
    });

    test('crmDashboard role can access crmDashboard', () {
      expect(
          AppRoutes.hasPermission(
              UserRole.crmDashboard, AppRoutes.crmDashboard),
          isTrue);
    });
  });
}
