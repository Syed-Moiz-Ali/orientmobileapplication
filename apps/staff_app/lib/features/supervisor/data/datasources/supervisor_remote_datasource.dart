import 'package:shared_core/shared_core.dart';

class SupervisorRemoteDataSource {
  final ApiClient _client;
  SupervisorRemoteDataSource(this._client);

  Future<List<KpiResponse>> getKpis() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.supervisorKpis,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => KpiResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.supervisorAdvisorJobs,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => AdvisorJobCountResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<JobTypeResponse>> getJobTypes() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.supervisorJobTypes,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => JobTypeResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<RevenueMetricResponse>> getRevenueMetrics() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.supervisorRevenueMetrics,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => RevenueMetricResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<PendingStatusResponse>> getPendingStatuses() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.supervisorPendingStatuses,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => PendingStatusResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<List<String>> getDepartments() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.departments,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => e.toString()).toList(), failure: (_) => []);

  Future<List<String>> getTechnicians() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.technicians,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => e.toString()).toList(), failure: (_) => []);

  Future<List<SupervisorAssignedJob>> getAssignedJobs() async => (await _client.get<List<dynamic>>(
    ApiEndpoints.supervisorAssignedJobs,fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => SupervisorAssignedJob.fromJson(e)).toList(), failure: (_) => []);
}
