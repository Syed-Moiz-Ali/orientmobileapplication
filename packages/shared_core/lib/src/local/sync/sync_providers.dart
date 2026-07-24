import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/src/local/sync/sync_operation.dart';
import 'package:shared_core/src/local/sync/sync_queue.dart';

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(Hive.box<SyncOperation>('sync_queue'));
});
