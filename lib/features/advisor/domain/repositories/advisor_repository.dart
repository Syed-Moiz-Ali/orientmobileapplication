import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';

abstract class AdvisorRepository {
  Result<AdvisorStatsEntity> getStats();
  Result<List<JobCardEntity>> getRecentJobCards();
  Result<List<PendingApprovalEntity>> getPendingApprovals();
  Result<List<FollowupReminderEntity>> getFollowupReminders();
  String get advisorName;
  String get advisorId;
  String get branch;
  String get shift;
}
