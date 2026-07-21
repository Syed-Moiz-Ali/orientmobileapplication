enum UserRole {
  owner,
  advisor,
  technician,
  customer,
  supervisor,
  crmDashboard;

  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Owner Dashboard';
      case UserRole.advisor:
        return 'Service Advisor';
      case UserRole.technician:
        return 'Technician Portal';
      case UserRole.customer:
        return 'Customer Portal';
      case UserRole.supervisor:
        return 'Supervisor Portal';
      case UserRole.crmDashboard:
        return 'CRM Dashboard';
    }
  }
}
