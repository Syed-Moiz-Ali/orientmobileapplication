import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/repositories/local_repository.dart';

class GenericLocalDataSource implements LocalRepository<void> {
  final Box<dynamic> _box;

  GenericLocalDataSource(this._box);

  @override
  Future<void> save(String id, Map<String, dynamic> data) async {
    await _box.put(id, data);
  }

  @override
  Future<Map<String, dynamic>?> get(String id) async {
    final val = _box.get(id);
    if (val is Map) return Map<String, dynamic>.from(val);
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    return _box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
