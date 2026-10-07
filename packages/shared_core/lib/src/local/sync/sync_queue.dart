import 'package:hive/hive.dart';
import 'package:shared_core/src/local/sync/sync_operation.dart';

class SyncQueue {
  final Box<SyncOperation> _box;

  SyncQueue(this._box);

  Future<void> enqueue(SyncOperation operation) async {
    await _box.put(operation.id, operation);
  }

  List<SyncOperation> peekAll() {
    return _box.values.toList();
  }

  /// The current authoritative copy of one queued operation.
  ///
  /// The sync engine processes a pass in the order of its initial scan but
  /// re-reads each operation by id before executing it, because an earlier
  /// operation can rewrite a later one's payload during the same pass.
  SyncOperation? getById(String id) => _box.get(id);

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> updateRetry(SyncOperation operation) async {
    await _box.put(operation.id, operation);
  }

  int get length => _box.length;

  Future<void> clear() async {
    await _box.clear();
  }
}
