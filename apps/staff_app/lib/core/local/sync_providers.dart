import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    failedBox: Hive.box<dynamic>('inspections'),
  );
  engine.registerHandler(MockSyncHandler('inspection'));
  engine.registerHandler(MockSyncHandler('vehicle_customer'));
  engine.registerHandler(MockSyncHandler('repair_order'));
  engine.registerHandler(MockSyncHandler('attachment'));
  engine.registerHandler(MockSyncHandler('reminder'));
  return engine;
});
