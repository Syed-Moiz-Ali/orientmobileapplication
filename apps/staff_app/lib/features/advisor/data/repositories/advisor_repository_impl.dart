import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_mock_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/domain/repositories/advisor_repository.dart';

class AdvisorRepositoryImpl implements AdvisorRepository {
  final AdvisorMockDataSource _dataSource;

  AdvisorRepositoryImpl(this._dataSource);

  @override
  Result<AdvisorStatsEntity> getStats() {
    try {
      return Success(_dataSource.fetchStats());
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Result<List<JobCardEntity>> getRecentJobCards() {
    try {
      return Success(_dataSource.fetchRecentJobCards());
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Result<List<PendingApprovalEntity>> getPendingApprovals() {
    try {
      return Success(_dataSource.fetchPendingApprovals());
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Result<List<FollowupReminderEntity>> getFollowupReminders() {
    try {
      return Success(_dataSource.fetchFollowupReminders());
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  String get advisorName => _dataSource.advisorName;

  @override
  String get advisorId => _dataSource.advisorId;

  @override
  String get branch => _dataSource.branch;

  @override
  String get shift => _dataSource.shift;
}

