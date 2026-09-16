import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

abstract class CustomerRepository {
  Future<CustomerEntity> getCustomerProfile();
  Future<List<CustomerVehicleEntity>> getVehicles();
  Future<List<CustomerBookingEntity>> getBookings();
  Future<List<CustomerNotificationEntity>> getNotifications();

  /// Persists one read marker. Returns false when the workshop did not accept
  /// it, so the caller never reports a state the server does not hold.
  Future<bool> markNotificationRead(String id);

  /// Persists the read marker for every notification in one bulk call.
  Future<bool> markAllNotificationsRead();

  Future<CustomerServiceEntity> getActiveService();
}
