import 'package:crm_app/features/crm_dashboard/data/datasources/crm_remote_adapter.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/domain/repositories/crm_repository.dart';

class CrmRepositoryImpl implements CrmRepository {
  final CrmDataSource _dataSource;

  CrmRepositoryImpl(this._dataSource);

  @override
  List<CrmKpiEntity> get kpis => _dataSource.kpis;

  @override
  List<CrmChannelEntity> get channels => _dataSource.channels;

  @override
  List<CrmTrendPoint> get conversionTrend => _dataSource.conversionTrend;

  @override
  List<SalespersonPerf> get salespersonPerf => _dataSource.salespersonPerf;

  @override
  List<ResponseTimeBucket> get responseTimeBuckets => _dataSource.responseTimeBuckets;

  @override
  List<LeadSourceSlice> get leadSources => _dataSource.leadSources;

  @override
  List<CrmKeyMetric> get keyMetrics => _dataSource.keyMetrics;

  @override
  List<IntegrationEntity> get integrations => _dataSource.integrations;

  @override
  List<SalesTeamMember> get salesTeam => _dataSource.salesTeam;

  @override
  List<ConversationEntity> get conversations => _dataSource.conversations;

  @override
  List<CrmLeadEntity> getLeads() => _dataSource.getLeads();

  @override
  List<CrmTaskEntity> getTasks() => _dataSource.getTasks();

  @override
  Future<void> refreshLeads() => _dataSource.refreshLeads();

  @override
  Future<void> refreshTasks() => _dataSource.refreshTasks();

  @override
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data) => _dataSource.createTask(data);

  @override
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data) => _dataSource.updateTask(id, data);

  @override
  Future<void> deleteTask(String id) => _dataSource.deleteTask(id);

  @override
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data) => _dataSource.createLead(data);

  @override
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data) => _dataSource.updateLead(id, data);

  @override
  Future<void> deleteLead(String id) => _dataSource.deleteLead(id);

  @override
  Future<List<TeamMemberEntity>> getTeamMembers() => _dataSource.getTeamMembers();

  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String id) => _dataSource.getLeadActivities(id);

  @override
  Future<LeadStatsEntity> getLeadStats() => _dataSource.getLeadStats();

  @override
  Future<List<FollowUpEntity>> getFollowUps() => _dataSource.getFollowUps();

  @override
  Future<List<ActivityFeedEntity>> getActivityFeed() => _dataSource.getActivityFeed();

  @override
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> credentials) =>
      _dataSource.connectIntegration(name, credentials);

  @override
  Future<IntegrationEntity> disconnectIntegration(String name) =>
      _dataSource.disconnectIntegration(name);

  @override
  Future<IntegrationEntity> syncIntegration(String name) =>
      _dataSource.syncIntegration(name);
}
