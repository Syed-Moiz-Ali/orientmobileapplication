import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';

class AdvisorMockDataSource {
  final Box<Map<String, dynamic>>? hiveBox;

  const AdvisorMockDataSource({this.hiveBox});

  AdvisorStatsEntity fetchStats() {
    final allData = hiveBox?.values.toList() ?? [];
    final approvals = allData
        .where((m) => m['action'] == 'approved' || m['action'] == 'rejected')
        .length;
    final vehicleCustomers = allData
        .where((m) => m['type'] == 'vehicle_customer')
        .length;
    return AdvisorStatsEntity(
      newJobCardsToday: vehicleCustomers,
      inspectionsToday: vehicleCustomers,
      pendingApprovals: approvals,
      vehiclesWaiting: vehicleCustomers,
      readyForDelivery: (allData.length * 0.3).round(),
      totalOpenJobCards: allData.length,
    );
  }

  List<JobCardEntity> fetchRecentJobCards() {
    final allData = hiveBox?.values.toList() ?? [];
    final jobs = allData
        .where((m) => m['type'] == 'vehicle_customer')
        .map(
          (m) => JobCardEntity(
            id: m['vin'] as String? ?? '',
            customerName: m['customerName'] as String? ?? '',
            vehicleInfo: '${m['make'] ?? ''} ${m['model'] ?? ''}',
            time: DateTime.now().toString().substring(11, 16),
            status: JobCardStatus.inProgress,
          ),
        )
        .toList();
    if (jobs.isEmpty) {
      return const [
        JobCardEntity(
          id: 'JC-2024-089',
          customerName: 'Ahmed Hassan',
          vehicleInfo: 'Toyota Camry',
          time: '09:15 AM',
          status: JobCardStatus.inProgress,
        ),
        JobCardEntity(
          id: 'JC-2024-088',
          customerName: 'Fatima Ali',
          vehicleInfo: 'Honda Accord',
          time: '08:45 AM',
          status: JobCardStatus.pendingApproval,
        ),
        JobCardEntity(
          id: 'JC-2024-087',
          customerName: 'Khalid Rashid',
          vehicleInfo: 'Nissan Patrol',
          time: '08:00 AM',
          status: JobCardStatus.qualityCheck,
        ),
      ];
    }
    return jobs;
  }

  List<PendingApprovalEntity> fetchPendingApprovals() {
    final allData = hiveBox?.values.toList() ?? [];
    final approvals = allData
        .where(
          (m) =>
              m['estimateId'] != null &&
              (m['action'] == 'approved' || m['action'] == 'rejected'),
        )
        .map(
          (m) => PendingApprovalEntity(
            estimateId: m['estimateId'] as String? ?? '',
            customerName: m['customerName'] as String? ?? '',
            vehicleId: '',
            amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
          ),
        )
        .toList();
    if (approvals.isEmpty) {
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
    return approvals;
  }

  List<FollowupReminderEntity> fetchFollowupReminders() {
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

