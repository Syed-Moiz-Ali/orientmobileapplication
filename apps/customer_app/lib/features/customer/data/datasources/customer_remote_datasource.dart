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
    final result = await _client.get<List<dynamic>>(
      ApiEndpoints.customerVehicles,
      fromJson: (d) {
        final raw = (d is Map && d.containsKey('data')) ? d['data'] : d;
        return (raw as List<dynamic>?) ?? [];
      },
    );
    return result.when(
      success: (list) => list.map((e) => VehicleResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<VehicleResponse> addVehicle(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)..remove('id');
    final result = await _client.post<VehicleResponse>(
      ApiEndpoints.customerVehicles,
      data: payload,
      fromJson: (d) {
        final raw = (d is Map && d.containsKey('data')) ? d['data'] : d;
        return VehicleResponse.fromJson(raw as Map<String, dynamic>);
      },
    );
    return result.when(success: (r) => r, failure: (_) => const VehicleResponse());
  }

  Future<VehicleResponse> updateVehicle(String id, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)..remove('id');
    final result = await _client.put<VehicleResponse>(
      ApiEndpoints.customerVehicle(id),
      data: payload,
      fromJson: (d) {
        final raw = (d is Map && d.containsKey('data')) ? d['data'] : d;
        return VehicleResponse.fromJson(raw as Map<String, dynamic>);
      },
    );
    return result.when(success: (r) => r, failure: (_) => const VehicleResponse());
  }

  Future<void> deleteVehicle(String id) async {
    await _client.delete(ApiEndpoints.customerVehicle(id));
  }

  // FE-FIX: the backend's PUT /customers/bookings/{id}/status supports
  // "cancelled" with ownership checks — the frontend never used it.
  Future<bool> cancelBooking(int bookingId) async {
    final r = await _client.put<dynamic>(
      '${ApiEndpoints.customerBookings}/$bookingId/status?status=cancelled',
    );
    return r is Success;
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

  // FE-FLOW (seamless-flow integration): real slot availability per date.
  Future<List<String>> getAvailability(String date) async {
    final result = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.bookingsAvailability(date),
      fromJson: (d) => d as Map<String, dynamic>,
    );
    return result.when(
      success: (data) => List<String>.from(data['availableSlots'] as List? ?? const []),
      failure: (_) => const [],
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

  // ---------- Seamless flows: estimate approvals & invoices ----------

  Future<List<CustomerApprovalSummaryResponse>> getPendingApprovals() async {
    final result = await _client.get<List<dynamic>>(
      ApiEndpoints.customerApprovalsPending,
      fromJson: (d) => d as List<dynamic>,
    );
    return result.when(
      success: (list) => list.map((e) => CustomerApprovalSummaryResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<CustomerApprovalDetailResponse> getApprovalDetail(String estimateId) async {
    final result = await _client.get<CustomerApprovalDetailResponse>(
      ApiEndpoints.customerApproval(estimateId),
      fromJson: (d) => CustomerApprovalDetailResponse.fromJson(d as Map<String, dynamic>),
    );
    return result.when(success: (r) => r, failure: (_) => const CustomerApprovalDetailResponse());
  }

  Future<bool> processApproval(String estimateId, String action) async {
    final result = await _client.put(
      ApiEndpoints.customerApproval(estimateId),
      data: {'action': action},
    );
    return result is Success;
  }

  Future<List<InvoiceResponse>> getInvoices() async {
    final result = await _client.get<List<dynamic>>(
      ApiEndpoints.customerInvoices,
      fromJson: (d) => d as List<dynamic>,
    );
    return result.when(
      success: (list) => list.map((e) => InvoiceResponse.fromJson(e as Map<String, dynamic>)).toList(),
      failure: (_) => [],
    );
  }

  Future<bool> submitFeedback(Map<String, dynamic> data) async {
    final result = await _client.post(
      ApiEndpoints.feedback,
      data: data,
    );
    return result is Success;
  }
}
