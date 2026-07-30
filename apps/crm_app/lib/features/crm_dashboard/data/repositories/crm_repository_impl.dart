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
}
