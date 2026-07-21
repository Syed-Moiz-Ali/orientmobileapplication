import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

class RoleConfig extends Equatable {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color buttonColor;
  final String buttonLabel;
  final List<String> features;
  final bool showRequestPassword;
  final bool showCreateAccount;
  final String? demoUsername;
  final String? demoPassword;
  final String usernamePlaceholder;

  const RoleConfig({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    required this.buttonColor,
    required this.buttonLabel,
    this.features = const [],
    this.showRequestPassword = false,
    this.showCreateAccount = false,
    this.demoUsername,
    this.demoPassword,
    this.usernamePlaceholder = 'Enter your username',
  });

  @override
  List<Object?> get props => [
    role,
    title,
    subtitle,
    icon,
    iconBackgroundColor,
    buttonColor,
    buttonLabel,
    features,
    showRequestPassword,
    showCreateAccount,
    demoUsername,
    demoPassword,
    usernamePlaceholder,
  ];

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
      showRequestPassword: true,
      showCreateAccount: true,
      usernamePlaceholder: 'Enter your login ID',
    ),
    RoleConfig(
      role: UserRole.advisor,
      title: 'Advisor Login',
      subtitle: 'Service Advisor Portal',
      icon: Icons.assignment_rounded,
      iconBackgroundColor: AppColors.navy,
      buttonColor: AppColors.navy,
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
      buttonColor: AppColors.success,
      buttonLabel: 'Login as Technician',
      features: ['Mark attendance', 'View assigned jobs', 'Update task status'],
    ),
    RoleConfig(
      role: UserRole.customer,
      title: 'Customer Portal',
      subtitle: 'Access your vehicles and service history',
      icon: Icons.directions_car_rounded,
      iconBackgroundColor: AppColors.info,
      buttonColor: AppColors.info,
      buttonLabel: 'Login as Customer',
      features: ['Book appointments', 'Approve estimates', 'Track status'],
      showRequestPassword: true,
      showCreateAccount: true,
      usernamePlaceholder: 'Enter your login ID',
    ),
    RoleConfig(
      role: UserRole.supervisor,
      title: 'Supervisor Portal',
      subtitle: 'Manage technicians and job assignments',
      icon: Icons.manage_accounts_rounded,
      iconBackgroundColor: AppColors.accent,
      buttonColor: AppColors.accent,
      buttonLabel: 'Login as Supervisor',
      features: ['Manage vehicles', 'Book appointments', 'Approve estimates'],
    ),
    RoleConfig(
      role: UserRole.crmDashboard,
      title: 'CRM Dashboard',
      subtitle: 'Dashboard',
      icon: Icons.bar_chart_rounded,
      iconBackgroundColor: AppColors.accent,
      buttonColor: AppColors.accent,
      buttonLabel: 'Login as CRM Dashboard',
      features: ['Manage vehicles', 'Book appointments', 'Approve estimates'],
    ),
  ];
}
