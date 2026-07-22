import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:orientmobileapplication/core/errors/logger_provider.dart';
import 'package:orientmobileapplication/features/advisor/data/datasources/advisor_local_datasource.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/job_card_entity.dart';
import 'package:orientmobileapplication/features/advisor/domain/entities/pending_approval_entity.dart';

final advisorLocalDataSourceProvider = Provider<AdvisorLocalDataSource>((ref) {
  return AdvisorLocalDataSource(Hive.box<dynamic>('inspections'));
});

final advisorRefreshProvider = StateProvider<int>((ref) => 0);

final advisorDashboardProvider = Provider<AdvisorStatsEntity>((ref) {
  ref.watch(advisorRefreshProvider);
  try {
    final box = Hive.box<dynamic>('inspections');
    final allData = box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
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
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load advisor dashboard stats from Hive', error: e, stackTrace: st);
    return const AdvisorStatsEntity(
      newJobCardsToday: 0,
      inspectionsToday: 0,
      pendingApprovals: 0,
      vehiclesWaiting: 0,
      readyForDelivery: 0,
      totalOpenJobCards: 0,
    );
  }
});

final advisorRecentJobCardsProvider = Provider<List<JobCardEntity>>((ref) {
  ref.watch(advisorRefreshProvider);
  final box = Hive.box<dynamic>('inspections');
  final allData = box.values
      .whereType<Map>()
      .map((m) => Map<String, dynamic>.from(m))
      .toList();
  final filtered = allData
      .where((m) => m['type'] == 'vehicle_customer')
      .toList();
  if (filtered.isEmpty) {
    return const [
      JobCardEntity(
        id: 'JC-2024-089',
        customerName: 'Ahmed Hassan',
        vehicleInfo: 'Toyota Camry',
        time: '09:15 AM',
        createdDate: '12/07/2024 09:15',
        lastUpdated: '12/07/2024 09:15',
        status: JobCardStatus.inProgress,
      ),
      JobCardEntity(
        id: 'JC-2024-088',
        customerName: 'Fatima Ali',
        vehicleInfo: 'Honda Accord',
        time: '08:45 AM',
        createdDate: '12/07/2024 08:45',
        lastUpdated: '12/07/2024 08:45',
        status: JobCardStatus.pendingApproval,
      ),
      JobCardEntity(
        id: 'JC-2024-087',
        customerName: 'Khalid Rashid',
        vehicleInfo: 'Nissan Patrol',
        time: '08:00 AM',
        createdDate: '12/07/2024 08:00',
        lastUpdated: '12/07/2024 08:00',
        status: JobCardStatus.qualityCheck,
      ),
    ];
  }
  final parsed = filtered.map((m) {
    final cd = m['createdDate'] as String? ?? '';
    return JobCardEntity(
      id: m['vin'] as String? ?? '',
      customerName: m['customerName'] as String? ?? '',
      vehicleInfo: '${m['make'] ?? ''} ${m['model'] ?? ''}',
      time: cd.isNotEmpty && cd.length >= 16 ? cd.substring(11, 16) : '',
      createdDate: cd,
      lastUpdated: m['lastUpdated'] as String? ?? cd,
      status: JobCardStatus.values.firstWhere(
        (e) => e.name == m['status'],
        orElse: () => JobCardStatus.inProgress,
      ),
      technician: m['technician'] as String? ?? '',
    );
  }).toList();
  parsed.sort((a, b) {
    final aDate = _parseDate(a.createdDate);
    final bDate = _parseDate(b.createdDate);
    return bDate.compareTo(aDate);
  });
  return parsed;
});

DateTime _parseDate(String dateStr) {
  try {
    final parts = dateStr.split(' ');
    if (parts.length != 2) return DateTime(2000);
    final dateParts = parts[0].split('/');
    if (dateParts.length != 3) return DateTime(2000);
    final timeParts = parts[1].split(':');
    if (timeParts.length != 2) return DateTime(2000);
    return DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[1]),
      int.parse(dateParts[0]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  } catch (e, st) {
    Logger().e('Failed to parse date time from jobCard', error: e, stackTrace: st);
    return DateTime(2000);
  }
}

final advisorPendingApprovalsProvider = Provider<List<PendingApprovalEntity>>((
  ref,
) {
  ref.watch(advisorRefreshProvider);
  try {
    final box = Hive.box<dynamic>('inspections');
    final allData = box.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
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
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load pending approvals from Hive', error: e, stackTrace: st);
    return const [];
  }
});

final advisorFollowupRemindersProvider = Provider<List<FollowupReminderEntity>>(
  (ref) {
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
  },
);

final advisorInfoProvider = Provider<AdvisorInfo>((ref) {
  return const AdvisorInfo(
    name: 'Ali Rahman',
    id: 'ADV001',
    branch: 'Main Branch - Dubai',
    shift: 'Morning (8:00 AM - 5:00 PM)',
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
