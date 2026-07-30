import 'package:shared_core/shared_core.dart';

class CustomerRemoteDataSource {
  final ApiClient _client;
  CustomerRemoteDataSource(this._client);

  Future<CustomerProfileResponse> getProfile() async {
    final result = await _client.get<CustomerProfileResponse>(
      ApiEndpoints.customerProfile,
      fromJson: (d) => CustomerProfileResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const CustomerProfileResponse());
  }

  Future<List<VehicleResponse>> getVehicles() async {
    final result = await _client.get<List<dynamic>>(ApiEndpoints.customerVehicles, fromJson: (d) => d as List<dynamic>);
    return result.when(
      success: (list) => list.map((e) => VehicleResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<VehicleResponse> addVehicle(Map<String, dynamic> data) async {
    final result = await _client.post<VehicleResponse>(
      ApiEndpoints.customerVehicles,
      data: data,
      fromJson: (d) => VehicleResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const VehicleResponse());
  }

  Future<VehicleResponse> updateVehicle(String id, Map<String, dynamic> data) async {
    final result = await _client.put<VehicleResponse>(
      ApiEndpoints.customerVehicle(id),
      data: data,
      fromJson: (d) => VehicleResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const VehicleResponse());
  }

  Future<void> deleteVehicle(String id) async {
    await _client.delete(ApiEndpoints.customerVehicle(id));
  }

  Future<List<BookingResponse>> getBookings() async {
    final result = await _client.get<List<dynamic>>(ApiEndpoints.customerBookings, fromJson: (d) => d as List<dynamic>);
    return result.when(
      success: (list) => list.map((e) => BookingResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<IdResponse> createBooking(Map<String, dynamic> data) async {
    final result = await _client.post<IdResponse>(
      ApiEndpoints.createBooking,
      data: data,
      fromJson: (d) => IdResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const IdResponse());
  }

  Future<ActiveServiceResponse> getActiveService() async {
    final result = await _client.get<ActiveServiceResponse>(
      ApiEndpoints.customerServicesActive,
      fromJson: (d) => ActiveServiceResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const ActiveServiceResponse());
  }

  Future<List<ServiceTypeResponse>> getServiceTypes() async {
    final result = await _client.get<List<dynamic>>(ApiEndpoints.serviceTypes, fromJson: (d) => d as List<dynamic>);
    return result.when(
      success: (list) => list.map((e) => ServiceTypeResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<IdResponse> createBreakdown(Map<String, dynamic> data) async {
    final result = await _client.post<IdResponse>(
      ApiEndpoints.customerBreakdowns,
      data: data,
      fromJson: (d) => IdResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const IdResponse());
  }

  Future<List<NotificationResponse>> getNotifications() async {
    final result = await _client.get<List<dynamic>>(
      ApiEndpoints.customerNotifications,
      fromJson: (d) => d as List<dynamic>,
    );
    return result.when(
      success: (list) => list.map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<void> markNotificationRead(String id) async {
    await _client.put(ApiEndpoints.notificationRead(id));
  }

  Future<void> markAllNotificationsRead() async {
    await _client.put(ApiEndpoints.notificationReadAll);
  }
}
