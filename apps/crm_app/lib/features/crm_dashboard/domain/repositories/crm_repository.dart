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
}
