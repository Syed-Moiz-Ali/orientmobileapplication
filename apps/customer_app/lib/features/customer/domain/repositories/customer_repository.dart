import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

abstract class CustomerRepository {
  Future<CustomerEntity> getCustomerProfile();
  Future<List<CustomerVehicleEntity>> getVehicles();
  Future<List<CustomerBookingEntity>> getBookings();
  Future<List<CustomerNotificationEntity>> getNotifications();
  Future<CustomerServiceEntity> getActiveService();
}
