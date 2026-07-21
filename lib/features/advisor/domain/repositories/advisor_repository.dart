import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';

abstract class AdvisorRepository {
  Future<Result<AdvisorStatsEntity>> getStats();
  Future<Result<List<JobCardEntity>>> getRecentJobCards();
  Future<Result<List<PendingApprovalEntity>>> getPendingApprovals();
  Future<Result<List<FollowupReminderEntity>>> getFollowupReminders();
  String get advisorName;
  String get advisorId;
  String get branch;
  String get shift;
}
