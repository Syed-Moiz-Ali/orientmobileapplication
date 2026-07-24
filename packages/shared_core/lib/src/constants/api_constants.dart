class ApiConstants {
  ApiConstants._();

  static const String inspections = '/inspections';
  static const String jobComplete = '/jobs/complete';
  static const String workAssignments = '/work-assignments';
  static const String bookings = '/bookings';
  static const String repairOrders = '/repair-orders';

  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
