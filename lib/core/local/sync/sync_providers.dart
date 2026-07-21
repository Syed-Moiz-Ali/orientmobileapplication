import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/sync/dio_sync_handler.dart';
import 'package:orientmobileapplication/core/local/sync/sync_engine.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';
import 'package:orientmobileapplication/core/local/sync/sync_queue.dart';
import 'package:orientmobileapplication/core/network/dio_client.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(Hive.box<SyncOperation>('sync_queue'));
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dio = ref.read(dioClientProvider);
  final engine = SyncEngine(
    queue: ref.read(syncQueueProvider),
    failedBox: Hive.box<SyncOperation>('sync_failed'),
    connectivity: Connectivity(),
  );

  engine.registerHandler(DioSyncHandler('inspection', dio));
  engine.registerHandler(DioSyncHandler('job_complete', dio));
  engine.registerHandler(DioSyncHandler('work_assignment', dio));
  engine.registerHandler(DioSyncHandler('booking', dio));
  engine.registerHandler(DioSyncHandler('repair_order', dio));
  engine.registerHandler(DioSyncHandler('technician_job', dio));
  engine.registerHandler(DioSyncHandler('technician_attendance', dio));
  engine.registerHandler(DioSyncHandler('assigned_job', dio));

  return engine;
});
