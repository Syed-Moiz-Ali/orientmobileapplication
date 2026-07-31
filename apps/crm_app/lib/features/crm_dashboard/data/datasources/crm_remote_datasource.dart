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

  Future<CrmTaskResponse> createTask(Map<String, dynamic> data) async {
    final r = await _client.post<CrmTaskResponse>(ApiEndpoints.crmTasks,
      data: data, fromJson: (d) => CrmTaskResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const CrmTaskResponse());
  }

  Future<CrmTaskResponse> updateTaskFull(String id, Map<String, dynamic> data) async {
    final r = await _client.put<CrmTaskResponse>(ApiEndpoints.crmTaskById(id),
      data: data, fromJson: (d) => CrmTaskResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const CrmTaskResponse());
  }

  Future<void> deleteTask(String id) async {
    await _client.delete(ApiEndpoints.crmTaskById(id));
  }

  Future<LeadResponse> createLead(Map<String, dynamic> data) async {
    final r = await _client.post<LeadResponse>(ApiEndpoints.crmLeads,
      data: data, fromJson: (d) => LeadResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const LeadResponse());
  }

  Future<LeadResponse> updateLead(String id, Map<String, dynamic> data) async {
    final r = await _client.put<LeadResponse>(ApiEndpoints.crmLeadById(id),
      data: data, fromJson: (d) => LeadResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const LeadResponse());
  }

  Future<void> deleteLead(String id) async {
    await _client.delete(ApiEndpoints.crmLeadById(id));
  }

  Future<List<TeamMemberResponse>> getTeamMembers() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmTeamMembers,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => TeamMemberResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<LeadActivityResponse>> getLeadActivities(String id) async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmLeadActivities(id),
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => LeadActivityResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<LeadStatsResponse> getLeadStats() async {
    final r = await _client.get<LeadStatsResponse>(ApiEndpoints.crmLeadStats,
      fromJson: (d) => LeadStatsResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const LeadStatsResponse());
  }

  Future<List<FollowUpResponse>> getFollowUps() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmLeadFollowUps,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => FollowUpResponse.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<List<ActivityFeedItem>> getActivityFeed() async {
    final r = await _client.get<List<dynamic>>(ApiEndpoints.crmActivityFeed,
      fromJson: (d) => d as List<dynamic>);
    return r.when(success: (l) => l.map((e) => ActivityFeedItem.fromJson(e)).toList(), failure: (_) => []);
  }

  Future<IntegrationResponse> connectIntegration(String name, Map<String, String> credentials) async {
    final r = await _client.put<IntegrationResponse>(
      ApiEndpoints.crmIntegrationConnect(name),
      data: credentials,
      fromJson: (d) => IntegrationResponse.fromJson(d as Map<String, dynamic>),
    );
    return r.when(success: (v) => v, failure: (_) => const IntegrationResponse());
  }

  Future<IntegrationResponse> disconnectIntegration(String name) async {
    final r = await _client.post<IntegrationResponse>(
      ApiEndpoints.crmIntegrationDisconnect(name),
      fromJson: (d) => IntegrationResponse.fromJson(d as Map<String, dynamic>),
    );
    return r.when(success: (v) => v, failure: (_) => const IntegrationResponse());
  }

  Future<IntegrationResponse> syncIntegration(String name) async {
    final r = await _client.post<IntegrationResponse>(
      ApiEndpoints.crmIntegrationSync(name),
      fromJson: (d) => IntegrationResponse.fromJson(d as Map<String, dynamic>),
    );
    return r.when(success: (v) => v, failure: (_) => const IntegrationResponse());
  }
}
