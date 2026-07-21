import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/advisor/data/datasources/advisor_mock_datasource.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/repositories/advisor_repository.dart';

class AdvisorRepositoryImpl implements AdvisorRepository {
  final AdvisorMockDataSource _dataSource;

  AdvisorRepositoryImpl(this._dataSource);

  @override
  Future<Result<AdvisorStatsEntity>> getStats() async {
    try {
      final stats = await _dataSource.fetchStats();
      return Success(stats);
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<List<JobCardEntity>>> getRecentJobCards() async {
    try {
      final cards = await _dataSource.fetchRecentJobCards();
      return Success(cards);
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<List<PendingApprovalEntity>>> getPendingApprovals() async {
    try {
      final approvals = await _dataSource.fetchPendingApprovals();
      return Success(approvals);
    } catch (e) {
      return Failure(UnknownException(e.toString()));
    }
  }

  @override
  Future<Result<List<FollowupReminderEntity>>> getFollowupReminders() async {
    try {
      final reminders = await _dataSource.fetchFollowupReminders();
      return Success(reminders);
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
