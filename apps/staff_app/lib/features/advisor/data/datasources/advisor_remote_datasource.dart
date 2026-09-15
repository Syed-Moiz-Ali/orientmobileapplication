import 'package:shared_core/shared_core.dart';

class AdvisorRemoteDataSource {
  final ApiClient _client;
  AdvisorRemoteDataSource(this._client);

  Future<CheckInResult?> checkInVehicleResult(
    String bookingId,
    Map<String, dynamic> data,
  ) async => (await _client.post<CheckInResult>(
    '/advisor/bookings/$bookingId/check-in',
    data: data,
    fromJson: (d) => CheckInResult.fromJson(d),
  )).when(success: (v) => v, failure: (_) => null);

  Future<AdvisorStatsResponse> getStats() async =>
      (await _client.get<AdvisorStatsResponse>(
        ApiEndpoints.advisorStats,
        fromJson: (d) => AdvisorStatsResponse.fromJson(d),
      )).when(success: (v) => v, failure: (_) => const AdvisorStatsResponse());

  Future<PageResponse<JobCardResponse>> getJobCards({
    int page = 1,
    int size = 20,
  }) async {
    final result = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.advisorJobCards,
      queryParams: {'page': '$page', 'size': '$size'},
      fromJson: (data) => data as Map<String, dynamic>,
    );
    final data = result.unwrapOrThrow();
    return PageResponse.fromJson(data, JobCardResponse.fromJson);
  }

  Future<JobCardDetailResponse> getJobCard(String id) async {
    final result = await _client.get<JobCardDetailResponse>(
      ApiEndpoints.advisorJobCard(id),
      fromJson: (d) => JobCardDetailResponse.fromJson(d),
    );
    final detail = result.when(
      success: (value) => value,
      failure: (_) => const JobCardDetailResponse(),
    );
    if (detail.id.isNotEmpty && detail.dbId > 0) return detail;

    final page = await getJobCards(page: 1, size: 50);
    final matches = page.content.where((job) => job.id == id).toList();
    if (matches.isEmpty) return detail;
    final match = matches.first;
    return JobCardDetailResponse(
      id: match.id,
      dbId: match.dbId,
      customerName: match.customerName,
      vehicleInfo: match.vehicleInfo,
      time: match.time,
      createdDate: match.createdDate,
      lastUpdated: match.lastUpdated,
      status: match.status,
      technician: match.technician,
      odometer: match.odometer,
      fuelLevel: match.fuelLevel,
    );
  }

  Future<void> updateJobCardStatus(String id, String status) async {
    await _client.put(
      ApiEndpoints.advisorJobCardStatus(id),
      data: {'status': status},
    );
  }

  Future<void> assignTechnician(String id, String technician) async {
    await _client.put(
      ApiEndpoints.advisorJobCardTechnician(id),
      data: {'technician': technician},
    );
  }

  Future<InspectionResponse> createInspection(Map<String, dynamic> data) async {
    final result = await _client.post<InspectionResponse>(
      ApiEndpoints.inspections,
      data: data,
      fromJson: (d) => InspectionResponse.fromJson(d),
    );
    return result.unwrapOrThrow();
  }

  Future<InspectionDraftResponse> getDraft(String id) async =>
      (await _client.get<InspectionDraftResponse>(
        ApiEndpoints.inspectionDraft(id),
        fromJson: (d) => InspectionDraftResponse.fromJson(d),
      )).when(
        success: (v) => v,
        failure: (_) => const InspectionDraftResponse(),
      );

  Future<void> saveDraft(String id, Map<String, dynamic> data) async {
    await _client.put(ApiEndpoints.inspectionDraft(id), data: data);
  }

  Future<void> deleteDraft(String id) async {
    await _client.delete(ApiEndpoints.inspectionDraft(id));
  }

  Future<List<PendingApprovalResponse>> getPendingApprovals() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.advisorApprovalsPending,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => PendingApprovalResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<void> processApproval(
    String estimateId,
    String action,
    double amount,
    String customerName,
  ) async {
    await _client.post(
      ApiEndpoints.advisorApproval(estimateId),
      data: {'action': action, 'customerName': customerName, 'amount': amount},
    );
  }

  Future<List<ReminderResponse>> getReminders() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.advisorReminders,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => ReminderResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<ReminderResponse> createReminder(Map<String, dynamic> data) async =>
      (await _client.post<ReminderResponse>(
        ApiEndpoints.advisorReminders,
        data: data,
        fromJson: (d) => ReminderResponse.fromJson(d),
      )).when(success: (v) => v, failure: (_) => const ReminderResponse());

  Future<void> deleteReminder(String id) async {
    await _client.delete(ApiEndpoints.advisorReminder(id));
  }

  Future<RepairOrderResponse> createRepairOrder(
    Map<String, dynamic> data,
  ) async => (await _client.post<RepairOrderResponse>(
    ApiEndpoints.repairOrders,
    data: data,
    fromJson: (d) => RepairOrderResponse.fromJson(d),
  )).when(success: (v) => v, failure: (_) => const RepairOrderResponse());

  Future<RepairOrderResponse> createRepairOrderStrict(
    Map<String, dynamic> data,
  ) async => (await _client.post<RepairOrderResponse>(
    ApiEndpoints.repairOrders,
    data: data,
    fromJson: (d) => RepairOrderResponse.fromJson(d),
  )).unwrapOrThrow();

  Future<ReportResponse> getReports(String range) async =>
      (await _client.get<ReportResponse>(
        ApiEndpoints.advisorReports,
        queryParams: {'range': range},
        fromJson: (d) => ReportResponse.fromJson(d),
      )).when(success: (v) => v, failure: (_) => const ReportResponse());

  Future<List<CustomerSearchResponse>> searchCustomers(String q) async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.customerSearch,
        queryParams: {'q': q},
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => CustomerSearchResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<VehicleSearchResponse>> searchVehicles(String q) async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.vehicleSearch,
        queryParams: {'q': q},
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => VehicleSearchResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  // ---------- Seamless flows ----------

  Future<List<AdvisorBookingResponse>> getAssignedBookings() async {
    final result = await _client.get<List<dynamic>>(
      ApiEndpoints.advisorBookings,
      fromJson: (data) => data as List<dynamic>,
    );
    return result
        .unwrapOrThrow()
        .map(
          (item) => AdvisorBookingResponse.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<WorkItemResponse>> getWorkItems(String jobCardRef) async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.advisorWorkItems(jobCardRef),
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => WorkItemResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<bool> assignWorkItem(int taskId, String empId) async {
    final r = await _client.put(
      ApiEndpoints.advisorWorkItemAssign(taskId),
      data: {'empId': empId},
    );
    return r is Success;
  }

  Future<List<AdvisorTechnicianResponse>> getTechnicians() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.advisorTechnicians,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => AdvisorTechnicianResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<StaffNotificationResponse>> getStaffNotifications() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.staffNotifications,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => StaffNotificationResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<bool> markStaffNotificationRead(String id) async {
    final r = await _client.put(ApiEndpoints.staffNotificationRead(id));
    return r is Success;
  }

  Future<bool> assignTasks(String jobCardRef, Map<String, dynamic> data) async {
    final r = await _client.post(
      '/advisor/job-cards/$jobCardRef/tasks',
      data: data,
    );
    return r is Success;
  }

  Future<bool> checkInVehicle(
    String bookingId,
    Map<String, dynamic> data,
  ) async => await checkInVehicleResult(bookingId, data) != null;

  Future<bool> deliverVehicle(
    String jobCardRef,
    Map<String, dynamic> data,
  ) async {
    final r = await _client.post(
      '/advisor/job-cards/$jobCardRef/deliver',
      data: data,
    );
    return r is Success;
  }
}

class CheckInResult {
  final int jobCardId;
  final String jobCardRef;

  const CheckInResult({required this.jobCardId, required this.jobCardRef});

  factory CheckInResult.fromJson(Map<String, dynamic> json) => CheckInResult(
    jobCardId: (json['jobCardId'] as num?)?.toInt() ?? 0,
    jobCardRef: json['jobCardRef']?.toString() ?? '',
  );
}
