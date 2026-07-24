import 'package:flutter/material.dart';
import 'package:shared_models/src/user_role.dart';

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
      iconBackgroundColor: Color(0xFF2563EB),
      buttonColor: Color(0xFF2563EB),
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
      iconBackgroundColor: Color(0xFF0F1D3A),
      buttonColor: Color(0xFF0F1D3A),
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
      iconBackgroundColor: Color(0xFF16A34A),
      buttonColor: Color(0xFF16A34A),
      buttonLabel: 'Login as Technician',
      features: ['Mark attendance', 'View assigned jobs', 'Update task status'],
    ),
    RoleConfig(
      role: UserRole.customer,
      title: 'Customer Portal',
      subtitle: 'Access your vehicles and service history',
      icon: Icons.directions_car_rounded,
      iconBackgroundColor: Color(0xFF7C3AED),
      buttonColor: Color(0xFF7C3AED),
      buttonLabel: 'Login as Customer',
      features: ['Book appointments', 'Approve estimates', 'Track status'],
    ),
    RoleConfig(
      role: UserRole.supervisor,
      title: 'Supervisor Portal',
      subtitle: 'Manage technicians and job assignments',
      icon: Icons.manage_accounts_rounded,
      iconBackgroundColor: Color(0xFF1B9AAA),
      buttonColor: Color(0xFF1B9AAA),
      buttonLabel: 'Login as Supervisor',
      features: ['Manage vehicles', 'Book appointments', 'Approve estimates'],
    ),
    RoleConfig(
      role: UserRole.crmDashboard,
      title: 'CRM Dashboard',
      subtitle: 'Dashboard',
      icon: Icons.bar_chart_rounded,
      iconBackgroundColor: Color(0xFF1B9AAA),
      buttonColor: Color(0xFF1B9AAA),
      buttonLabel: 'Login as CRM Dashboard',
      features: ['Manage vehicles', 'Book appointments', 'Approve estimates'],
    ),
  ];
}
