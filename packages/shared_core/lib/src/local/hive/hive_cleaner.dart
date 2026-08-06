import 'package:hive/hive.dart';
import 'package:shared_core/src/local/sync/sync_operation.dart';

class HiveCleaner {
  static Future<void> clearAll() async {
    await Hive.box<dynamic>('inspections').clear();
    await Hive.box<dynamic>('repair_orders').clear();
    await Hive.box<dynamic>('technician_jobs').clear();
    await Hive.box<dynamic>('supervisor_assignments').clear();
    await Hive.box<dynamic>('customer_bookings').clear();
    await Hive.box<dynamic>('customer_breakdowns').clear();
    // FIX (audit P0): customer PII cache and ID counters survived logout.
    await Hive.box<dynamic>('customer_cache').clear();
    await Hive.box<dynamic>('owner_messages').clear();
    await Hive.box<dynamic>('owner_activity').clear();
    await Hive.box<dynamic>('pending_media').clear();
    await Hive.box<SyncOperation>('sync_queue').clear();
    await Hive.box<SyncOperation>('sync_failed').clear();
    await Hive.box<int>('id_counters').clear();
  }

  static bool hasPendingSync() {
    final queue = Hive.box<SyncOperation>('sync_queue');
    final failed = Hive.box<SyncOperation>('sync_failed');
    return queue.isNotEmpty || failed.isNotEmpty;
  }
}
