import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_core/src/local/sync/sync_handler.dart';
import 'package:shared_core/src/local/sync/sync_operation.dart';
import 'package:shared_core/src/local/sync/sync_queue.dart';
import 'package:shared_core/src/local/sync/sync_status.dart';
import 'package:shared_core/src/local/exceptions/sync_exceptions.dart';

class SyncEngine {
  final SyncQueue _queue;
  final Box _failedBox;
  final Map<String, SyncHandler> _handlers = {};
  final Connectivity _connectivity;
  final Logger _logger;
  StreamSubscription? _connectivitySub;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _disposed = false;

  final List<void Function(SyncStatus)> _listeners = [];

  SyncEngine({
    required SyncQueue queue,
    required Box failedBox,
    Connectivity? connectivity,
    Logger? logger,
  }) : _queue = queue,
       _failedBox = failedBox,
       _connectivity = connectivity ?? Connectivity(),
       _logger = logger ?? Logger() {
    _initConnectivity();
  }

  void _initConnectivity() {
    unawaited(_checkInitialConnectivity());
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      if (_disposed) return;
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        // FIX (audit P0): retry the failed box on reconnect too, not just the
        // active queue — previously failed ops were never retried at all.
        if (_queue.length > 0) unawaited(syncAll());
        if (_failedBox.length > 0) unawaited(retryFailed());
      }
      _isOnline = online;
    });
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (_disposed) return;
      _isOnline = results.any((result) => result != ConnectivityResult.none);
      if (_isOnline) {
        if (_queue.length > 0) await syncAll();
        if (_failedBox.length > 0) await retryFailed();
      }
    } catch (error, stackTrace) {
      _logger.w(
        'Initial connectivity check failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Re-attempts every operation in the failed box (previously never retried).
  Future<void> retryFailed() async {
    if (_disposed || _status == SyncStatus.syncing) return;
    final ids = [
      for (final op in _failedBox.values.whereType<SyncOperation>()) op.id,
    ];
    if (ids.isEmpty) return;

    _notify(SyncStatus.syncing);
    for (final id in ids) {
      // Re-read: an earlier retry in this pass can already have removed it.
      final op = _failedBox.get(id);
      if (op == null) continue;
      try {
        final result = await _executeOperation(op);
        if (result) {
          await _failedBox.delete(op.id);
        }
      } on ConflictException {
        await _failedBox.delete(op.id); // server already has the state
      } catch (e, st) {
        _logger.e(
          'Retry failed for operation ${op.id} (${op.entityType})',
          error: e,
          stackTrace: st,
        );
        op.retryCount++;
        // A failed mutation represents user data. Never discard it merely
        // because the server was unavailable or rejected an older payload;
        // keeping it allows a corrected app build to replay the same job.
        await _failedBox.put(op.id, op);
      }
    }
    _notify(SyncStatus.idle);
  }

  /// Re-attempts ONE failed operation by its stable id.
  ///
  /// The operation keeps its identity and payload, so the request carries the
  /// same idempotency key and cannot duplicate a mutation. Unrelated failed
  /// operations are never touched. Returns true when the workshop accepted it
  /// (the operation is then removed from the failed store).
  Future<bool> retryFailedOperation(String id) async {
    if (_disposed || _status == SyncStatus.syncing) return false;
    final op = _failedBox.get(id);
    if (op == null) return false;

    _notify(SyncStatus.syncing);
    var accepted = false;
    try {
      accepted = await _executeOperation(op);
      if (accepted) {
        await _failedBox.delete(op.id);
      } else {
        final current = _failedBox.get(op.id) ?? op;
        current.retryCount++;
        await _failedBox.put(current.id, current);
      }
    } on ConflictException {
      // The server already holds the intended state.
      await _failedBox.delete(op.id);
      accepted = true;
    } catch (e, st) {
      _logger.e(
        'Retry failed for operation ${op.id} (${op.entityType})',
        error: e,
        stackTrace: st,
      );
      final current = _failedBox.get(op.id) ?? op;
      current.retryCount++;
      await _failedBox.put(current.id, current);
    }
    _notify(accepted ? SyncStatus.success : SyncStatus.failure);
    return accepted;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _listeners.clear();
  }

  void registerHandler(SyncHandler handler) {
    _handlers[handler.entityType] = handler;
  }

  void addListener(void Function(SyncStatus) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(SyncStatus) listener) {
    _listeners.remove(listener);
  }

  void _notify(SyncStatus status) {
    _status = status;
    for (final listener in _listeners) {
      listener(status);
    }
  }

  Future<void> syncAll() async {
    if (_disposed || _status == SyncStatus.syncing) return;

    _notify(SyncStatus.syncing);
    final ids = [for (final op in _queue.peekAll()) op.id];

    if (ids.isEmpty) {
      _notify(SyncStatus.success);
      return;
    }

    bool hasFailure = false;
    bool hasConflict = false;

    // The pass runs in the order of the initial scan, but each operation is
    // re-read from the queue immediately before it executes: an earlier
    // operation can rewrite a later one's payload mid-pass (a vehicle
    // registration rewrites the queued booking that references its temporary
    // id), and executing the stale snapshot would send the old id.
    for (final id in ids) {
      final op = _queue.getById(id);
      if (op == null) continue; // removed or replaced mid-pass
      try {
        final result = await _executeOperation(op);
        if (result) {
          await _queue.remove(op.id);
        } else {
          // FIX (audit P0): a handler returning false (e.g. HTTP 500) never
          // incremented retryCount → the op was replayed on EVERY connectivity
          // toggle with no backoff, forever. Treat false like a failure.
          op.retryCount++;
          if (op.retryCount >= 3) {
            await _moveToFailed(op);
            await _queue.remove(op.id);
          } else {
            await _queue.updateRetry(op);
          }
          hasFailure = true;
        }
      } on ConflictException {
        hasConflict = true;
        await _moveToFailed(op);
        await _queue.remove(op.id);
      } catch (e, st) {
        _logger.e(
          'Sync failed for operation ${op.id} (${op.entityType})',
          error: e,
          stackTrace: st,
        );
        op.retryCount++;
        if (op.retryCount >= 3) {
          await _moveToFailed(op);
          await _queue.remove(op.id);
        } else {
          await _queue.updateRetry(op);
        }
        hasFailure = true;
      }
    }

    if (hasConflict) {
      _notify(SyncStatus.conflict);
    } else if (hasFailure) {
      _notify(SyncStatus.failure);
    } else {
      _notify(SyncStatus.success);
    }
  }

  Future<bool> _executeOperation(SyncOperation op) async {
    final handler = _handlers[op.entityType];
    if (handler == null) {
      throw MissingSyncHandlerException(op.entityType);
    }
    return handler.execute(op);
  }

  Future<void> _moveToFailed(SyncOperation op) async {
    await _failedBox.put(
      op.id,
      SyncOperation(
        id: op.id,
        entityType: op.entityType,
        entityId: op.entityId,
        changeType: op.changeType,
        payload: op.payload,
        timestamp: op.timestamp,
        retryCount: op.retryCount,
      ),
    );
  }
}
