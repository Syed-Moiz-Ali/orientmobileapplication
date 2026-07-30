import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';

class GetCustomerServices {
  final CustomerRepository repository;

  GetCustomerServices(this.repository);

  Future<CustomerServiceEntity> getActiveService() => repository.getActiveService();
  Future<List<CustomerBookingEntity>> getBookings() => repository.getBookings();
}
