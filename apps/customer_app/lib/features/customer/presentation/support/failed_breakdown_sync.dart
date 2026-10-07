import 'package:customer_app/core/local/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

/// Failed roadside requests, read from the sync engine's own failed store.
///
/// This is recovery state, not history: the backend exposes no way to read a
/// breakdown back, so the only durable trace of a request the workshop never
/// received is the operation the sync engine refused to discard.
abstract interface class FailedBreakdownSync {
  /// The failed roadside creates, oldest first. Empty when there is nothing to
  /// recover.
  List<SyncOperation> failedBreakdowns();

  /// Replays the failed operations through the existing retry mechanism.
  /// Returns true when nothing is left to recover.
  Future<bool> retry();

  /// Deletes exactly these failed requests, and any copy still waiting to be
  /// sent, so the customer can discard a request that cannot be delivered.
  Future<void> remove();
}

class StoreFailedBreakdownSync implements FailedBreakdownSync {
  final Ref _ref;

  StoreFailedBreakdownSync(this._ref);

  /// The failed box is the authoritative state; a read that cannot be answered
  /// is treated as "nothing to recover" rather than breaking the form.
  @override
  List<SyncOperation> failedBreakdowns() {
    try {
      final operations = Hive.box<SyncOperation>(
        'sync_failed',
      ).values.where(_isFailedBreakdownCreate).toList();
      operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return operations;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> retry() async {
    try {
      await _ref.read(syncEngineProvider).retryFailed();
    } catch (_) {
      // A retry that cannot run leaves the request exactly where it was.
    }
    return failedBreakdowns().isEmpty;
  }

  @override
  Future<void> remove() async {
    final ids = failedBreakdowns().map((operation) => operation.id).toSet();
    if (ids.isEmpty) return;
    await _deleteById('sync_failed', ids);
    // A request can also still be waiting in the send queue; removing it must
    // not leave a copy behind that would arrive later.
    await _deleteById('sync_queue', ids);
  }

  Future<void> _deleteById(String boxName, Set<String> ids) async {
    try {
      final box = Hive.box<SyncOperation>(boxName);
      for (final id in ids) {
        if (box.containsKey(id)) await box.delete(id);
      }
    } catch (_) {}
  }

  static bool _isFailedBreakdownCreate(SyncOperation operation) =>
      operation.entityType == 'breakdown' &&
      operation.changeType == ChangeType.create;
}

/// The recovery seam. A test replaces this with a fake so no Hive box is needed.
final failedBreakdownSyncProvider = Provider<FailedBreakdownSync>(
  (ref) => StoreFailedBreakdownSync(ref),
);
