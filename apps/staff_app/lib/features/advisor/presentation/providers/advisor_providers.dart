import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_local_datasource.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';

final advisorLocalDataSourceProvider = Provider<AdvisorLocalDataSource>((ref) {
  return AdvisorLocalDataSource(Hive.box<dynamic>('inspections'));
});

final advisorRefreshProvider = StateProvider<int>((ref) => 0);

const _emptyStats = AdvisorStatsEntity(
  newJobCardsToday: 0,
  inspectionsToday: 0,
  pendingApprovals: 0,
  vehiclesWaiting: 0,
  readyForDelivery: 0,
  totalOpenJobCards: 0,
);

/// Loads advisor stats from the backend. Falls back to empty data (never
/// fabricated numbers) when the request fails or the app is offline.
final advisorDashboardProvider = FutureProvider<AdvisorStatsEntity>((ref) async {
  ref.watch(advisorRefreshProvider);
  final remote = ref.read(advisorRemoteDataSourceProvider);
  try {
    final s = await remote.getStats();
    return AdvisorStatsEntity(
      newJobCardsToday: s.newJobCardsToday,
      inspectionsToday: s.inspectionsToday,
      pendingApprovals: s.pendingApprovals,
      vehiclesWaiting: s.vehiclesWaiting,
      readyForDelivery: s.readyForDelivery,
      totalOpenJobCards: s.totalOpenJobCards,
    );
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load advisor stats', error: e, stackTrace: st);
    return _emptyStats;
  }
});

final advisorRecentJobCardsProvider = FutureProvider<List<JobCardEntity>>((ref) async {
  ref.watch(advisorRefreshProvider);
  final remote = ref.read(advisorRemoteDataSourceProvider);
  try {
    final page = await remote.getJobCards(page: 1, size: 50);
    final jobs = page.content;
    final parsed = jobs.map((j) {
      return JobCardEntity(
        id: j.id,
        customerName: j.customerName,
        vehicleInfo: j.vehicleInfo,
        time: j.time,
        createdDate: j.createdDate,
        lastUpdated: j.lastUpdated,
        status: JobCardStatus.values.firstWhere(
          (e) => e.name == j.status,
          orElse: () => JobCardStatus.inProgress,
        ),
        technician: j.technician,
      );
    }).toList();
    return parsed;
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load advisor job cards', error: e, stackTrace: st);
    return const [];
  }
});

final advisorPendingApprovalsProvider = FutureProvider<List<PendingApprovalEntity>>((ref) async {
  ref.watch(advisorRefreshProvider);
  final remote = ref.read(advisorRemoteDataSourceProvider);
  try {
    final approvals = await remote.getPendingApprovals();
    return approvals.map((a) {
      return PendingApprovalEntity(
        estimateId: a.estimateId,
        customerName: a.customerName,
        vehicleId: a.vehicleId,
        amount: a.amount,
        timeAgo: a.timeAgo,
      );
    }).toList();
  } catch (e, st) {
    ref.read(loggerProvider).e('Failed to load pending approvals', error: e, stackTrace: st);
    return const [];
  }
});

class ReminderNotifier extends Notifier<List<FollowupReminderEntity>> {
  @override
  List<FollowupReminderEntity> build() {
    final local = _loadFromHive();
    _loadFromRemote();
    return local;
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

  Future<void> _loadFromRemote() async {
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final reminders = await remote.getReminders();
      if (reminders.isEmpty) return;
      state = reminders.map((r) {
        return FollowupReminderEntity(
          customerName: r.customerName,
          vehicleId: r.vehicleId,
          task: r.task,
          dueDate: r.dueDate,
          priority: ReminderPriority.values.firstWhere(
            (e) => e.name == r.priority,
            orElse: () => ReminderPriority.medium,
          ),
        );
      }).toList();
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to load reminders', error: e, stackTrace: st);
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
    final queue = ref.read(syncQueueProvider);
    await queue.enqueue(
      SyncOperation(
        id: id,
        entityType: 'reminder',
        entityId: id,
        changeType: ChangeType.create,
        payload: {
          'customerName': reminder.customerName,
          'vehicleId': reminder.vehicleId,
          'task': reminder.task,
          'dueDate': reminder.dueDate,
          'priority': reminder.priority.name,
        },
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await ref.read(syncEngineProvider).syncAll();
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

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'A';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
