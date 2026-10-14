import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/src/user_role.dart';

/// Per-role entry configuration for the shared sign-in experience.
///
/// Phase 01.2 hardening: all hex literals are migrated to the frozen
/// [AppColors] authorities — no bespoke `Color(0x…)` values. The primary
/// action color stays the single `#215FE6` authority via [AppTheme]; per-role
/// marks use the semantic tokens below (identity only, never a competing
/// primary).
class RoleConfig {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color buttonColor;
  final String buttonLabel;
  final List<String> features;

  const RoleConfig({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    required this.buttonColor,
    required this.buttonLabel,
    this.features = const [],
  });

  static const List<RoleConfig> configs = [
    RoleConfig(
      role: UserRole.owner,
      title: 'Owner Portal',
      subtitle: 'All Branches',
      icon: Icons.manage_accounts_rounded,
      iconBackgroundColor: AppColors.primary,
      buttonColor: AppColors.primary,
      buttonLabel: 'Continue as Owner',
      features: [
        'View KPIs and performance',
        'Monitor financials',
        'Manage approvals',
      ],
    ),
    RoleConfig(
      role: UserRole.advisor,
      title: 'Advisor Login',
      subtitle: 'Service Advisor Portal',
      icon: Icons.assignment_rounded,
      iconBackgroundColor: AppColors.surfaceStrong,
      buttonColor: AppColors.primary,
      buttonLabel: 'Login as Advisor',
      features: [
        'Create job cards',
        'Perform inspections',
        'Share via print/email',
      ],
    ),
    RoleConfig(
      role: UserRole.technician,
      title: 'Technician Login',
      subtitle: 'Auto Garage ERP System',
      icon: Icons.build_rounded,
      iconBackgroundColor: AppColors.success,
      buttonColor: AppColors.primary,
      buttonLabel: 'Login as Technician',
      features: ['Mark attendance', 'View assigned jobs', 'Update task status'],
    ),
    RoleConfig(
      role: UserRole.customer,
      title: 'Customer Portal',
      subtitle: 'Access your vehicles and service history',
      icon: Icons.directions_car_rounded,
      iconBackgroundColor: AppColors.purpleAccent,
      buttonColor: AppColors.primary,
      buttonLabel: 'Login as Customer',
      features: ['Book appointments', 'Approve estimates', 'Track status'],
    ),
    RoleConfig(
      role: UserRole.supervisor,
      title: 'Supervisor Portal',
      subtitle: 'Manage technicians and job assignments',
      icon: Icons.manage_accounts_rounded,
      iconBackgroundColor: AppColors.info,
      buttonColor: AppColors.primary,
      buttonLabel: 'Login as Supervisor',
      features: ['Manage vehicles', 'Book appointments', 'Approve estimates'],
    ),
    RoleConfig(
      role: UserRole.crmDashboard,
      title: 'CRM Dashboard',
      subtitle: 'Dashboard',
      icon: Icons.bar_chart_rounded,
      iconBackgroundColor: AppColors.info,
      buttonColor: AppColors.primary,
      buttonLabel: 'Login as CRM Dashboard',
      features: ['Manage vehicles', 'Book appointments', 'Approve estimates'],
    ),
  ];
}
