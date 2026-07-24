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
