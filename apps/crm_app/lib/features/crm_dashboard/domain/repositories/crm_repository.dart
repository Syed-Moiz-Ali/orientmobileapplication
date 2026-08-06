import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

abstract class CrmRepository {
  List<CrmKpiEntity> get kpis;
  List<CrmChannelEntity> get channels;
  List<CrmTrendPoint> get conversionTrend;
  List<SalespersonPerf> get salespersonPerf;
  List<ResponseTimeBucket> get responseTimeBuckets;
  List<LeadSourceSlice> get leadSources;
  List<CrmKeyMetric> get keyMetrics;
  List<IntegrationEntity> get integrations;
  List<SalesTeamMember> get salesTeam;
  List<ConversationEntity> get conversations;
  List<CrmLeadEntity> getLeads();
  List<CrmTaskEntity> getTasks();
  Future<void> refreshLeads();
  Future<void> refreshTasks();
  Future<CrmTaskEntity> createTask(Map<String, dynamic> data);
  Future<CrmTaskEntity> updateTask(String id, Map<String, dynamic> data);
  Future<void> deleteTask(String id);
  Future<CrmLeadEntity> createLead(Map<String, dynamic> data);
  Future<CrmLeadEntity> updateLead(String id, Map<String, dynamic> data);
  Future<void> deleteLead(String id);
  Future<IntegrationEntity> connectIntegration(String name, Map<String, String> credentials);
  Future<IntegrationEntity> disconnectIntegration(String name);
  Future<IntegrationEntity> syncIntegration(String name);
  Future<List<TeamMemberEntity>> getTeamMembers();
  Future<List<LeadActivityEntity>> getLeadActivities(String id);
  Future<LeadStatsEntity> getLeadStats();
  Future<List<FollowUpEntity>> getFollowUps();
  Future<List<ActivityFeedEntity>> getActivityFeed();
  // FE-FIX (audit): refresh() was a fake; the dashboard reloads through this.
  Future<void> loadAll();
}
