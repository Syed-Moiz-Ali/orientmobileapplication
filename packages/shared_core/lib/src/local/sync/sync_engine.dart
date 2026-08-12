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

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _disposed = false;

  final List<void Function(SyncStatus)> _listeners = [];

  SyncEngine({
    required SyncQueue queue,
    required Box failedBox,
    Connectivity? connectivity,
    Logger? logger,
  })  : _queue = queue,
        _failedBox = failedBox,
        _connectivity = connectivity ?? Connectivity(),
        _logger = logger ?? Logger() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      if (_disposed) return;
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_isOnline) {
        // FIX (audit P0): retry the failed box on reconnect too, not just the
        // active queue — previously failed ops were never retried at all.
        if (_queue.length > 0) syncAll();
        if (_failedBox.length > 0) retryFailed();
      }
      _isOnline = online;
    });
  }

  /// Re-attempts every operation in the failed box (previously never retried).
  Future<void> retryFailed() async {
    if (_disposed || _status == SyncStatus.syncing) return;
    final failed = _failedBox.values
        .whereType<SyncOperation>()
        .toList();
    if (failed.isEmpty) return;

    _notify(SyncStatus.syncing);
    for (final op in failed) {
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
        if (op.retryCount >= 3) {
          await _failedBox.delete(op.id); // give up after 3 retries
        } else {
          await _failedBox.put(op.id, op);
        }
      }
    }
    _notify(SyncStatus.idle);
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
    final operations = _queue.peekAll();

    if (operations.isEmpty) {
      _notify(SyncStatus.success);
      return;
    }

    bool hasFailure = false;
    bool hasConflict = false;

    for (final op in operations) {
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
