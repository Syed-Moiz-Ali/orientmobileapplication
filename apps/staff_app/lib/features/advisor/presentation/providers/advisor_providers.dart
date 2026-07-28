import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_local_datasource.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';

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
    return const [];
  }
  final parsed = filtered.map((m) {
    final cd = m['createdDate'] as String? ?? '';
    final id = m['id'] as String? ?? '';
    final vin = m['vin'] as String? ?? '';
    final regNo = m['registrationNumber'] as String? ?? '';
    return JobCardEntity(
      id: id.isNotEmpty ? id : (vin.isNotEmpty ? vin : regNo),
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
      return const [];
    }
    return approvals;
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load pending approvals from Hive', error: e, stackTrace: st);
    return const [];
  }
});

class ReminderNotifier extends Notifier<List<FollowupReminderEntity>> {
  @override
  List<FollowupReminderEntity> build() {
    return _loadFromHive();
  }

  List<FollowupReminderEntity> _loadFromHive() {
    try {
      final box = Hive.box<dynamic>('inspections');
      return box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((m) => m['type'] == 'reminder')
          .map((m) => FollowupReminderEntity(
                customerName: m['customerName'] as String? ?? '',
                vehicleId: m['vehicleId'] as String? ?? '',
                task: m['task'] as String? ?? '',
                dueDate: m['dueDate'] as String? ?? '',
                priority: ReminderPriority.values.firstWhere(
                  (e) => e.name == m['priority'],
                  orElse: () => ReminderPriority.medium,
                ),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addReminder(FollowupReminderEntity reminder) async {
    final local = GenericLocalDataSource(Hive.box<dynamic>('inspections'));
    final id = await IdGenerator.nextId('REM');
    await local.save(id, {
      'id': id,
      'type': 'reminder',
      'customerName': reminder.customerName,
      'vehicleId': reminder.vehicleId,
      'task': reminder.task,
      'dueDate': reminder.dueDate,
      'priority': reminder.priority.name,
    });
    ref.invalidate(advisorRefreshProvider);
    state = _loadFromHive();
  }

  Future<void> dismissReminder(int index) async {
    final box = Hive.box<dynamic>('inspections');
    final reminder = state[index];
    final key = box.keys.firstWhere(
      (k) {
        final v = box.get(k);
        return v is Map && v['type'] == 'reminder' && v['task'] == reminder.task && v['customerName'] == reminder.customerName;
      },
      orElse: () => '',
    );
    if (key != '') {
      await box.delete(key);
    }
    ref.invalidate(advisorRefreshProvider);
    state = _loadFromHive();
  }
}

final advisorFollowupRemindersProvider = NotifierProvider<ReminderNotifier, List<FollowupReminderEntity>>(
  ReminderNotifier.new,
);

final advisorInfoProvider = Provider<AdvisorInfo>((ref) {
  try {
    final box = Hive.box<dynamic>('inspections');
    final profile = box.get('advisor_profile');
    if (profile is Map) {
      return AdvisorInfo(
        name: (profile['name'] ?? 'Advisor').toString(),
        id: (profile['id'] ?? 'ADV001').toString(),
        branch: (profile['branch'] ?? 'Main Branch').toString(),
        shift: (profile['shift'] ?? '').toString(),
      );
    }
  } catch (_) {}
  return const AdvisorInfo(
    name: 'Advisor',
    id: 'ADV001',
    branch: 'Main Branch',
    shift: '',
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

