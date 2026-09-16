import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

/// Persistent identity map for vehicles that were created before the workshop
/// knew about them.
///
/// A vehicle created offline carries a temporary local id. When its queued
/// create finally reaches the workshop, the server assigns the real id — and
/// everything local that referenced the temporary id (the cached vehicle, any
/// queued booking for that car, any booking already cached) is rewritten here,
/// so the temporary id can never reach the API afterwards.
///
/// The map lives in Hive, so the relationship survives an app restart.
abstract final class VehicleIdentityStore {
  VehicleIdentityStore._();

  static const String _mapKey = 'vehicle_identity_map';
  static const String _pendingKey = 'vehicle_pending_ids';
  static const String _cacheBox = 'customer_cache';

  /// Records that a vehicle exists only on this device, so no server request may
  /// name it until its create has completed.
  static Future<void> markPending(String localId) async {
    final id = localId.trim();
    if (id.isEmpty) return;
    try {
      final box = Hive.box<dynamic>(_cacheBox);
      final pending = _pending().toSet()..add(id);
      await box.put(_pendingKey, pending.toList());
    } catch (_) {}
  }

  /// True while this id is a vehicle the workshop has not accepted yet.
  ///
  /// Persisted, so the answer survives an app restart and does not depend on the
  /// queued operation still being present (it is removed on success and moved to
  /// the failed queue after repeated failures).
  static bool isPending(String localId) => _pending().contains(localId.trim());

  /// True when this vehicle's registration exhausted its retries.
  ///
  /// Read from the sync engine's own failed queue (the operation keeps its id,
  /// so a retry reuses the same idempotency key). This is real sync state, not a
  /// guess based on how long the vehicle has been pending.
  static bool hasFailedCreate(String localId) {
    final id = localId.trim();
    if (id.isEmpty) return false;
    try {
      final box = Hive.box<SyncOperation>('sync_failed');
      return box.values.any(
        (operation) =>
            operation.entityType == 'vehicle' &&
            operation.entityId == id &&
            operation.changeType == ChangeType.create,
      );
    } catch (_) {
      return false;
    }
  }

  /// Removes every local trace of a vehicle that never reached the workshop:
  /// the pending marker, the failed operation, and any cached record.
  static Future<void> forget(String localId) async {
    final id = localId.trim();
    if (id.isEmpty) return;
    await _clearPending(id);
    try {
      final failed = Hive.box<SyncOperation>('sync_failed');
      for (final operation
          in failed.values
              .where((operation) => operation.entityId == id)
              .toList()) {
        await failed.delete(operation.id);
      }
    } catch (_) {}
    try {
      final box = Hive.box<dynamic>(_cacheBox);
      final map = Map<String, String>.from(_read())..remove(id);
      await box.put(_mapKey, map);
    } catch (_) {}
  }

  static List<String> _pending() {
    try {
      final raw = Hive.box<dynamic>(_cacheBox).get(_pendingKey);
      if (raw is List) return raw.map((id) => id.toString()).toList();
    } catch (_) {}
    return const [];
  }

  /// Clears the pending marker for a vehicle that is no longer awaiting the
  /// workshop (its create completed, or it was deleted before syncing).
  static Future<void> clearPending(String localId) => _clearPending(localId);

  static Future<void> _clearPending(String localId) async {
    try {
      final box = Hive.box<dynamic>(_cacheBox);
      final pending = _pending().where((id) => id != localId.trim()).toList();
      await box.put(_pendingKey, pending);
    } catch (_) {}
  }

  static Map<String, String> _read() {
    try {
      final box = Hive.box<dynamic>(_cacheBox);
      final raw = box.get(_mapKey);
      if (raw is Map) {
        return raw.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
    } catch (_) {
      // No local storage available: nothing is mapped.
    }
    return const {};
  }

  /// The server id for a temporary local id, when the create has completed.
  static String? serverIdFor(String localId) {
    final id = _read()[localId.trim()];
    return id == null || id.isEmpty ? null : id;
  }

  /// Resolves an id to the persisted server id when it is a reconciled
  /// temporary id, and returns it unchanged otherwise.
  static String resolve(String id) => serverIdFor(id) ?? id;

  static Future<void> record(String tempId, String serverId) async {
    if (tempId.trim().isEmpty || serverId.trim().isEmpty) return;
    try {
      final box = Hive.box<dynamic>(_cacheBox);
      final map = Map<String, String>.from(_read());
      map[tempId.trim()] = serverId.trim();
      await box.put(_mapKey, map);
    } catch (_) {
      // The mapping is best-effort; the write path still succeeds.
    }
  }
}

/// Rewrites every local reference to a temporary vehicle id into the server id.
///
/// Called once the workshop has assigned the real id. It touches only local
/// data: the cached vehicle, cached bookings that named the temporary vehicle,
/// and queued operations whose payload carries that id (so a booking queued
/// offline for a brand-new vehicle replays against the persisted vehicle).
Future<void> reconcileVehicleIdentity({
  required String tempId,
  required String serverId,
  required SyncQueue queue,
}) async {
  final local = tempId.trim();
  final remote = serverId.trim();
  if (local.isEmpty || remote.isEmpty) return;

  await VehicleIdentityStore.record(local, remote);
  await VehicleIdentityStore._clearPending(local);

  Box<dynamic>? box;
  try {
    box = Hive.box<dynamic>(VehicleIdentityStore._cacheBox);
  } catch (_) {
    box = null;
  }

  if (box != null) {
    try {
      final cached = box.get('cached_vehicles');
      if (cached is List) {
        await box.put('cached_vehicles', [
          for (final entry in cached)
            if (entry is Map && entry['id'].toString() == local)
              {...Map<String, dynamic>.from(entry), 'id': remote}
            else
              entry,
        ]);
      }
    } catch (_) {}

    try {
      final bookings = box.get('cached_bookings');
      if (bookings is List) {
        await box.put('cached_bookings', [
          for (final entry in bookings)
            if (entry is Map && entry['vehicleId'].toString() == local)
              {...Map<String, dynamic>.from(entry), 'vehicleId': remote}
            else
              entry,
        ]);
      }
    } catch (_) {}
  }

  // Queued operations for other entities (a booking made offline for this car)
  // still name the temporary vehicle. Rewrite them before they replay.
  try {
    for (final operation in queue.peekAll().toList()) {
      if (operation.changeType == ChangeType.delete) continue;
      final payload = operation.payload;
      if (payload['vehicleId']?.toString() != local) continue;
      await queue.enqueue(
        SyncOperation(
          id: operation.id,
          entityType: operation.entityType,
          entityId: operation.entityId,
          changeType: operation.changeType,
          payload: {...payload, 'vehicleId': remote},
          timestamp: operation.timestamp,
          retryCount: operation.retryCount,
        ),
      );
    }
  } catch (_) {
    // A queue that cannot be rewritten must not fail the reconciliation.
  }
}
