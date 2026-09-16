import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/local/vehicle_sync_handler.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dio = ref.read(dioClientProvider);
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    failedBox: Hive.box<SyncOperation>('sync_failed'),
  );
  engine.registerHandler(DioSyncHandler('booking', dio));
  engine.registerHandler(DioSyncHandler('breakdown', dio));
  engine.registerHandler(DioSyncHandler('vehicle_customer', dio));
  // FIX (audit P0): offline vehicle create/update/delete used entityType
  // 'vehicle', which had NO registered handler — ops were silently dropped.
  // Vehicles reconcile their temporary local id with the server id, which the
  // shared handler cannot do because it discards mutation responses.
  engine.registerHandler(VehicleSyncHandler(dio, ref.watch(syncQueueProvider)));
  Future.microtask(engine.syncAll);
  ref.onDispose(engine.dispose);
  return engine;
});
