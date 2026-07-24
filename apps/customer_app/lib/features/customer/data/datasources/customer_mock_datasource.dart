import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

class CustomerMockDataSource {
  CustomerEntity getCustomerProfile() => CustomerEntity.mock;

  List<CustomerVehicleEntity> getVehicles() =>
      List.from(CustomerVehicleEntity.mock);

  List<CustomerBookingEntity> getBookings() =>
      List.from(CustomerBookingEntity.mock);

  List<CustomerNotificationEntity> getNotifications() =>
      CustomerNotificationEntity.mock;

  CustomerServiceEntity getActiveService() => CustomerServiceEntity.mock;
}
