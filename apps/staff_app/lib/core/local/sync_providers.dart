import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Entity types the sync engine can receive. Every type must have a handler
/// registered below, otherwise ops would be dropped.
const kSyncEntityTypes = [
  'inspection',
  'job_complete',
  'work_assignment',
  'booking',
  'repair_order',
  'vehicle_customer',
  'approval',
  'reminder',
  'attendance',
  'technician_job',
  'work_item',
  'attachment',
  'assigned_job',
  'job_card',
  'job_card_technician',
];

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dio = ref.read(dioClientProvider);
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    failedBox: Hive.box<dynamic>('sync_failed'),
  );
  for (final type in kSyncEntityTypes) {
    engine.registerHandler(DioSyncHandler(type, dio));
  }
  ref.onDispose(engine.dispose);
  return engine;
});

/// Queue of media uploads that failed while offline (Hive box 'pending_media').
final pendingMediaQueueProvider = Provider<MediaUploadQueue>((ref) {
  return MediaUploadQueue(Hive.box<dynamic>('pending_media'));
});

/// Retries queued media uploads. Safe to call on connectivity restore.
Future<void> flushPendingMediaUploads(WidgetRef ref) async {
  final queue = ref.read(pendingMediaQueueProvider);
  if (queue.isEmpty) return;
  final dio = ref.read(dioClientProvider);
  final client = MediaClient(dio);
  await queue.retryPending((upload) async {
    await client.uploadMedia(upload.recordId, upload.filePath);
  });
}
