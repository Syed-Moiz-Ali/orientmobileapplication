import 'package:shared_core/shared_core.dart';

class AdvisorRemoteDataSource {
  final ApiClient _client;
  AdvisorRemoteDataSource(this._client);

  Future<AdvisorStatsResponse> getStats() async => (await _client.get<AdvisorStatsResponse>(
    ApiEndpoints.advisorStats,fromJson: (d) => AdvisorStatsResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const AdvisorStatsResponse());

  Future<PageResponse<JobCardResponse>> getJobCards({int page = 1, int size = 20}) async => (await _client.get<Map<String, dynamic>>(
    ApiEndpoints.advisorJobCards,queryParams: {'page': '$page', 'size': '$size'},
    fromJson: (d) => d as Map<String, dynamic>)).when(
    success: (m) => PageResponse.fromJson(m, (j) => JobCardResponse.fromJson(j)),
    failure: (_) => const PageResponse());

  Future<JobCardDetailResponse> getJobCard(String id) async => (await _client.get<JobCardDetailResponse>(
    ApiEndpoints.advisorJobCard(id),fromJson: (d) => JobCardDetailResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const JobCardDetailResponse());

  Future<void> updateJobCardStatus(String id, String status) async {
    await _client.put(ApiEndpoints.advisorJobCardStatus(id), data: {'status': status});
  }

  Future<void> assignTechnician(String id, String technician) async {
    await _client.put(ApiEndpoints.advisorJobCardTechnician(id), data: {'technician': technician});
  }

  Future<InspectionResponse> createInspection(Map<String, dynamic> data) async => (await _client.post<InspectionResponse>(
    ApiEndpoints.inspections,data: data,fromJson: (d) => InspectionResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const InspectionResponse());

  Future<InspectionDraftResponse> getDraft(String id) async => (await _client.get<InspectionDraftResponse>(
    ApiEndpoints.inspectionDraft(id),fromJson: (d) => InspectionDraftResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const InspectionDraftResponse());

  Future<void> saveDraft(String id, Map<String, dynamic> data) async {
    await _client.put(ApiEndpoints.inspectionDraft(id), data: data);
  }

  Future<void> deleteDraft(String id) async {
    await _client.delete(ApiEndpoints.inspectionDraft(id));
  }

  Future<List<PendingApprovalResponse>> getPendingApprovals() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.advisorApprovalsPending,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => PendingApprovalResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<void> processApproval(String estimateId, String action, double amount, String customerName) async {
    await _client.post(ApiEndpoints.advisorApproval(estimateId),
      data: {'action': action, 'customerName': customerName, 'amount': amount});
  }

  Future<List<ReminderResponse>> getReminders() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.advisorReminders,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => ReminderResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<ReminderResponse> createReminder(Map<String, dynamic> data) async => (await _client.post<ReminderResponse>(
    ApiEndpoints.advisorReminders,data: data,fromJson: (d) => ReminderResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const ReminderResponse());

  Future<void> deleteReminder(String id) async {
    await _client.delete(ApiEndpoints.advisorReminder(id));
  }

  Future<RepairOrderResponse> createRepairOrder(Map<String, dynamic> data) async => (await _client.post<RepairOrderResponse>(
    ApiEndpoints.repairOrders,data: data,fromJson: (d) => RepairOrderResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const RepairOrderResponse());

  Future<ReportResponse> getReports(String range) async => (await _client.get<ReportResponse>(
    ApiEndpoints.advisorReports,queryParams: {'range': range},fromJson: (d) => ReportResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const ReportResponse());

  Future<List<CustomerSearchResponse>> searchCustomers(String q) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.customerSearch,queryParams: {'q': q},fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => CustomerSearchResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<VehicleSearchResponse>> searchVehicles(String q) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.vehicleSearch,queryParams: {'q': q},fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => VehicleSearchResponse.fromJson(e)).toList(), failure: (_) => []);
}
