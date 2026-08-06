import 'package:shared_core/shared_core.dart';

class OwnerRemoteDataSource {
  final ApiClient _client;
  OwnerRemoteDataSource(this._client);

  Future<List<KpiCardResponse>> getKpis() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerDashboardKpis,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => KpiCardResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<TrendPointResponse>> getSalesTrend() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerSalesTrend,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => TrendPointResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<TrendPointResponse>> getProfitTrend() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerProfitTrend,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => TrendPointResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<TrendPointResponse>> getExpensesTrend() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerExpensesTrend,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => TrendPointResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<JobCardRegisterResponse>> getJobCardRegister() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerJobCardRegister,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => JobCardRegisterResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<TopSalesCategoryResponse>> getTopSales() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerTopSales,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => TopSalesCategoryResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<DocumentExpiryResponse>> getDocumentExpiry() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerDocumentsExpiry,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => DocumentExpiryResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<JobStatusResponse>> getJobsByStatus(String stage) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerJobsStatus,queryParams: {'stage': stage},fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => JobStatusResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<ApprovalCategoryResponse>> getApprovalCategories() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerApprovalsCategories,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => ApprovalCategoryResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<PendingJobResponse>> getPendingJobs() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerJobsPending,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => PendingJobResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<OwnerJobCardResponse>> getActiveJobs() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerJobsActive,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => OwnerJobCardResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<InvoiceResponse>> getInvoices(String? status) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerInvoices,queryParams: status != null ? {'status': status} : null,
    fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => InvoiceResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<ArSummaryResponse> getArSummary() async => (await _client.get<ArSummaryResponse>(
    ApiEndpoints.ownerArSummary,fromJson: (d) => ArSummaryResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const ArSummaryResponse());

  Future<List<ArRecordResponse>> getArRecords() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerArRecords,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => ArRecordResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<MessageResponse>> getMessages() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerMessages,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => MessageResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<MessageResponse> sendMessage(String recipient, String message) async => (await _client.post<MessageResponse>(
    ApiEndpoints.ownerMessages,data: {'recipient': recipient, 'message': message},
    fromJson: (d) => MessageResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const MessageResponse());

  Future<List<ActivityResponse>> getActivity(int page, int limit) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerActivity,queryParams: {'page': '$page', 'limit': '$limit'},
    fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => ActivityResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<OwnerJobCardResponse>> getOwnerJobCards() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.ownerJobCards,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => OwnerJobCardResponse.fromJson(e)).toList(), failure: (_) => []);

  // FE-FIX (audit P1): owner job-card status updates (Mark as Complete).
  Future<bool> updateJobCardStatus(String id, String status) async {
    final r = await _client.put(
      '${ApiEndpoints.ownerJobCards}/$id/status?status=$status',
    );
    return r is Success;
  }
}
