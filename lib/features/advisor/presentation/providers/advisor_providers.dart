import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/advisor/data/datasources/advisor_mock_datasource.dart';
import 'package:orientmobileapplication/features/advisor/data/repositories/advisor_repository_impl.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/repositories/advisor_repository.dart';

final advisorRepositoryProvider = Provider<AdvisorRepository>((ref) {
  return AdvisorRepositoryImpl(const AdvisorMockDataSource());
});

final advisorDashboardProvider = FutureProvider<AdvisorStatsEntity>((ref) async {
  final repo = ref.read(advisorRepositoryProvider);
  final result = await repo.getStats();
  return result.when(
    success: (stats) => stats,
    failure: (e) => throw Exception(e.message),
  );
});

final advisorRecentJobCardsProvider =
    FutureProvider<List<JobCardEntity>>((ref) async {
  final repo = ref.read(advisorRepositoryProvider);
  final result = await repo.getRecentJobCards();
  return result.when(
    success: (cards) => cards,
    failure: (e) => throw Exception(e.message),
  );
});

final advisorPendingApprovalsProvider =
    FutureProvider<List<PendingApprovalEntity>>((ref) async {
  final repo = ref.read(advisorRepositoryProvider);
  final result = await repo.getPendingApprovals();
  return result.when(
    success: (approvals) => approvals,
    failure: (e) => throw Exception(e.message),
  );
});

final advisorFollowupRemindersProvider =
    FutureProvider<List<FollowupReminderEntity>>((ref) async {
  final repo = ref.read(advisorRepositoryProvider);
  final result = await repo.getFollowupReminders();
  return result.when(
    success: (reminders) => reminders,
    failure: (e) => throw Exception(e.message),
  );
});

final advisorInfoProvider = Provider<AdvisorInfo>((ref) {
  final repo = ref.read(advisorRepositoryProvider);
  return AdvisorInfo(
    name: repo.advisorName,
    id: repo.advisorId,
    branch: repo.branch,
    shift: repo.shift,
  );
});

class AdvisorInfo {
  final String name;
  final String id;
  final String branch;
  final String shift;
  const AdvisorInfo({
    required this.name,
    required this.id,
    required this.branch,
    required this.shift,
  });
}
