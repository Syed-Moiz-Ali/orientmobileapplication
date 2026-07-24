import 'package:customer_app/features/customer/data/datasources/customer_mock_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerMockDataSource dataSource;

  CustomerRepositoryImpl({CustomerMockDataSource? dataSource})
      : dataSource = dataSource ?? CustomerMockDataSource();

  @override
  CustomerEntity getCustomerProfile() => dataSource.getCustomerProfile();

  @override
  List<CustomerVehicleEntity> getVehicles() => dataSource.getVehicles();

  @override
  List<CustomerBookingEntity> getBookings() => dataSource.getBookings();

  @override
  List<CustomerNotificationEntity> getNotifications() =>
      dataSource.getNotifications();

  @override
  CustomerServiceEntity getActiveService() => dataSource.getActiveService();
}
