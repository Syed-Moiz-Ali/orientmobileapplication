import 'package:shared_core/shared_core.dart';

class CrmRemoteDataSource {
  final ApiClient _client;
  CrmRemoteDataSource(this._client);

  Future<List<CrmKpiResponse>> getKpis() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmKpis,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => CrmKpiResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<ChannelResponse>> getChannels() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmChannels,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => ChannelResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<ConversionTrendResponse>> getConversionTrend() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmConversionTrend,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => ConversionTrendResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<SalespersonPerfResponse>> getSalespersonPerformance() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmSalespersonPerf,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => SalespersonPerfResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<ResponseTimeResponse>> getResponseTimes() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmResponseTimes,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => ResponseTimeResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<LeadSourceResponse>> getLeadSources() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmLeadSources,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => LeadSourceResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<KeyMetricResponse> getKeyMetrics() async {
    final r = await _client.get<KeyMetricResponse>(ApiEndpoints.crmKeyMetrics,
      fromJson: (d) => KeyMetricResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const KeyMetricResponse());
  }

  Future<List<IntegrationResponse>> getIntegrations() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmIntegrations,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => IntegrationResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<SalesTeamResponse>> getSalesTeam() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmSalesTeam,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => SalesTeamResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<ConversationResponse>> getConversations() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmConversations,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => ConversationResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<LeadResponse>> getLeads({String? status, String? source}) async {
    final p = <String, dynamic>{};
    if (status != null) p['status'] = status;
    if (source != null) p['source'] = source;
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmLeads,
      queryParams: p, fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => LeadResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<CrmTaskResponse>> getTasks() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmTasks,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => CrmTaskResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<void> updateTask(String id, bool isDone) async {
    await _client.put(ApiEndpoints.crmTaskById(id), data: {'isDone': isDone});
  }
}
