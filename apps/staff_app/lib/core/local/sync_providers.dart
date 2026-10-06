import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Entity types the sync engine can receive. Every type must have a handler
/// registered below, otherwise ops would be dropped.
const kSyncEntityTypes = [
  'inspection',
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

/// Restores sync work for advisor intakes that are still local-only. Older
/// app versions could exhaust their retry count and remove the operation while
/// leaving the intake safely stored in Hive.
Future<void> recoverUnsyncedAdvisorIntakes() async {
  final queue = Hive.box<SyncOperation>('sync_queue');
  final failed = Hive.box<SyncOperation>('sync_failed');
  final inspections = Hive.box<dynamic>('inspections');
  final pendingEntityIds = <String>{
    ...queue.values.map((operation) => operation.entityId),
    ...failed.values.map((operation) => operation.entityId),
  };

  for (final entry in inspections.toMap().entries) {
    final raw = entry.value;
    if (raw is! Map || raw['type']?.toString() != 'vehicle_customer') {
      continue;
    }
    final payload = Map<String, dynamic>.from(raw);
    final entityId = (payload['id'] ?? entry.key).toString();
    final serverReference =
        (payload['jobCardRef'] ?? payload['serverJobCardId'] ?? '')
            .toString()
            .trim();
    if (entityId.isEmpty ||
        serverReference.isNotEmpty ||
        pendingEntityIds.contains(entityId)) {
      continue;
    }

    final operation = SyncOperation(
      id: entityId,
      entityType: 'vehicle_customer',
      entityId: entityId,
      changeType: ChangeType.create,
      payload: payload,
      timestamp:
          DateTime.tryParse(
            payload['createdAt']?.toString() ?? '',
          )?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
    );
    await queue.put(operation.id, operation);
    pendingEntityIds.add(entityId);
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final dio = ref.read(dioClientProvider);
  _discardDeprecatedJobCompleteOps();
  final engine = SyncEngine(
    queue: ref.watch(syncQueueProvider),
    failedBox: Hive.box<SyncOperation>('sync_failed'),
  );
  for (final type in kSyncEntityTypes) {
    engine.registerHandler(DioSyncHandler(type, dio));
  }
  ref.onDispose(engine.dispose);
  return engine;
});

void _discardDeprecatedJobCompleteOps() {
  for (final boxName in const ['sync_queue', 'sync_failed']) {
    final box = Hive.box<SyncOperation>(boxName);
    final staleKeys = box.keys.where((key) {
      final op = box.get(key);
      if (op == null) return false;
      return op.entityType == 'job_complete' ||
          (op.entityType == 'technician_job' &&
              op.payload['status'] == 'completed');
    }).toList();
    for (final key in staleKeys) {
      unawaited(box.delete(key));
    }
  }
}

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
    await client.uploadMedia(
      upload.recordId,
      upload.filePath,
      itemId: upload.itemId,
      type: upload.type,
      module: upload.module,
    );
  });
}
