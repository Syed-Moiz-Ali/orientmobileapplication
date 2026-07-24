import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

abstract class CustomerRepository {
  CustomerEntity getCustomerProfile();
  List<CustomerVehicleEntity> getVehicles();
  List<CustomerBookingEntity> getBookings();
  List<CustomerNotificationEntity> getNotifications();
  CustomerServiceEntity getActiveService();
}
