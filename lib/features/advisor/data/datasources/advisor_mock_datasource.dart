import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';

class AdvisorMockDataSource {
  const AdvisorMockDataSource();

  Future<AdvisorStatsEntity> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const AdvisorStatsEntity(
      newJobCardsToday: 12,
      inspectionsToday: 8,
      pendingApprovals: 5,
      vehiclesWaiting: 3,
      readyForDelivery: 7,
      totalOpenJobCards: 23,
    );
  }

  Future<List<JobCardEntity>> fetchRecentJobCards() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      JobCardEntity(
        id: 'JC-2024-089',
        customerName: 'Ahmed Hassan',
        vehicleInfo: 'Toyota Camry • D-12345',
        time: '09:15 AM',
        status: JobCardStatus.inProgress,
      ),
      JobCardEntity(
        id: 'JC-2024-088',
        customerName: 'Fatima Ali',
        vehicleInfo: 'Honda Accord • D-67890',
        time: '08:45 AM',
        status: JobCardStatus.pendingApproval,
      ),
      JobCardEntity(
        id: 'JC-2024-087',
        customerName: 'Khalid Rashid',
        vehicleInfo: 'Nissan Patrol • D-11223',
        time: '08:00 AM',
        status: JobCardStatus.qualityCheck,
      ),
    ];
  }

  Future<List<PendingApprovalEntity>> fetchPendingApprovals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      PendingApprovalEntity(
        estimateId: 'EST-2024-089',
        customerName: 'Ahmed Hassan',
        vehicleId: 'D-12345',
        amount: 1250,
        timeAgo: '10 mins ago',
      ),
      PendingApprovalEntity(
        estimateId: 'EST-2024-088',
        customerName: 'Sara Mohammed',
        vehicleId: 'D-44321',
        amount: 875,
        timeAgo: '25 mins ago',
      ),
    ];
  }

  Future<List<FollowupReminderEntity>> fetchFollowupReminders() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      FollowupReminderEntity(
        customerName: 'Ahmed Hassan',
        vehicleId: 'D-12345',
        task: 'Follow up on estimate approval',
        dueDate: 'Due: Today, 2:00 PM',
        priority: ReminderPriority.high,
      ),
      FollowupReminderEntity(
        customerName: 'Mariam Salem',
        vehicleId: 'D-44556',
        task: 'Notify when parts arrive',
        dueDate: 'Due: Tomorrow, 10:00 AM',
        priority: ReminderPriority.medium,
      ),
      FollowupReminderEntity(
        customerName: 'Omar Khalid',
        vehicleId: 'D-99001',
        task: 'Schedule next service',
        dueDate: 'Due: Apr 10, 2024',
        priority: ReminderPriority.low,
      ),
    ];
  }

  String get advisorName => 'Ali Rahman';
  String get advisorId => 'ADV001';
  String get branch => 'Main Branch - Dubai';
  String get shift => 'Morning (8:00 AM - 5:00 PM)';
}
