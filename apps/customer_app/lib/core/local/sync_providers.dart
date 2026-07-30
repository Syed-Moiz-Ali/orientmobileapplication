import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/src/network/dio_client_provider.dart';
import 'package:shared_core/shared_core.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dio = ref.read(dioClientProvider);
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    failedBox: Hive.box<dynamic>('customer_cache'),
  );
  engine.registerHandler(DioSyncHandler('booking', dio));
  engine.registerHandler(DioSyncHandler('breakdown', dio));
  engine.syncAll();
  return engine;
});
