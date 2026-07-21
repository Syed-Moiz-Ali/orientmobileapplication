import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';

class HiveRegistry {
  static bool _initialized = false;

  static Future<void> initHive() async {
    if (_initialized) return;

    await Hive.initFlutter();

    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(ChangeTypeAdapter());

    await Hive.openBox<dynamic>('inspections');
    await Hive.openBox<dynamic>('repair_orders');
    await Hive.openBox<dynamic>('technician_jobs');
    await Hive.openBox<dynamic>('supervisor_assignments');
    await Hive.openBox<dynamic>('customer_bookings');
    await Hive.openBox<SyncOperation>('sync_queue');
    await Hive.openBox<SyncOperation>('sync_failed');

    _initialized = true;

    if (kDebugMode) {
      final inspections = Hive.box<dynamic>('inspections').length;
      final repairOrders = Hive.box<dynamic>('repair_orders').length;
      final techJobs = Hive.box<dynamic>('technician_jobs').length;
      final assignments = Hive.box<dynamic>('supervisor_assignments').length;
      final bookings = Hive.box<dynamic>('customer_bookings').length;
      final queue = Hive.box<SyncOperation>('sync_queue').length;
      final failed = Hive.box<SyncOperation>('sync_failed').length;
      debugPrint('Hive initialized: inspections=$inspections, repairOrders=$repairOrders, '
          'technicianJobs=$techJobs, assignments=$assignments, bookings=$bookings, '
          'queue=$queue, failed=$failed');
    }
  }
}
