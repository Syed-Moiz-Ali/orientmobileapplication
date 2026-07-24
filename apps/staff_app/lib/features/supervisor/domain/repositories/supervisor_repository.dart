import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';

abstract class SupervisorRepository {
  List<SupervisorKpiEntity> get kpis;
  List<AdvisorJobEntity> get advisorJobData;
  List<JobTypeEntity> get jobTypes;
  List<RevenueMetricEntity> get revenueMetrics;
  List<PendingStatusEntity> get pendingStatuses;
  List<String> get departments;
  List<String> get technicians;
  List<AssignedJobEntity> get initialJobs;
}
