import 'package:staff_app/features/supervisor/data/datasources/supervisor_mock_datasource.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/domain/repositories/supervisor_repository.dart';

class SupervisorRepositoryImpl implements SupervisorRepository {
  final SupervisorDataSource _dataSource;

  SupervisorRepositoryImpl(this._dataSource);

  @override
  List<SupervisorKpiEntity> get kpis => _dataSource.kpis;

  @override
  List<AdvisorJobEntity> get advisorJobData => _dataSource.advisorJobData;

  @override
  List<JobTypeEntity> get jobTypes => _dataSource.jobTypes;

  @override
  List<RevenueMetricEntity> get revenueMetrics => _dataSource.revenueMetrics;

  @override
  List<PendingStatusEntity> get pendingStatuses => _dataSource.pendingStatuses;

  @override
  List<String> get departments => _dataSource.departments;

  @override
  List<String> get technicians => _dataSource.technicians;

  @override
  List<AssignedJobEntity> get initialJobs => _dataSource.initialJobs;
}
