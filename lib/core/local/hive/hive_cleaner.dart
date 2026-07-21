import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';

class HiveCleaner {
  static Future<void> clearAll() async {
    await Hive.box<dynamic>('inspections').clear();
    await Hive.box<dynamic>('repair_orders').clear();
    await Hive.box<dynamic>('technician_jobs').clear();
    await Hive.box<dynamic>('supervisor_assignments').clear();
    await Hive.box<dynamic>('customer_bookings').clear();
    await Hive.box<SyncOperation>('sync_queue').clear();
    await Hive.box<SyncOperation>('sync_failed').clear();
  }

  static bool hasPendingSync() {
    final queue = Hive.box<SyncOperation>('sync_queue');
    final failed = Hive.box<SyncOperation>('sync_failed');
    return queue.isNotEmpty || failed.isNotEmpty;
  }
}
