import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dio = ref.read(dioClientProvider);
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    failedBox: Hive.box<dynamic>('sync_failed'),
  );
  engine.registerHandler(DioSyncHandler('booking', dio));
  engine.registerHandler(DioSyncHandler('breakdown', dio));
  engine.registerHandler(DioSyncHandler('vehicle_customer', dio));
  // FIX (audit P0): offline vehicle create/update/delete used entityType
  // 'vehicle', which had NO registered handler — ops were silently dropped.
  engine.registerHandler(DioSyncHandler('vehicle', dio));
  ref.onDispose(engine.dispose);
  return engine;
});
