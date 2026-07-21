import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/repositories/local_repository.dart';

class AdvisorLocalDataSource implements LocalRepository<void> {
  final Box<dynamic> _box;

  AdvisorLocalDataSource(this._box);

  String get _draftKey => 'current_draft';

  Future<void> saveDraft(Map<String, dynamic> data) async {
    await _box.put(_draftKey, data);
  }

  Map<String, dynamic>? getDraft() {
    final val = _box.get(_draftKey);
    return val is Map ? Map<String, dynamic>.from(val) : null;
  }

  Future<Map<String, dynamic>?> getDraftAsync() async {
    final val = _box.get(_draftKey);
    return val is Map ? Map<String, dynamic>.from(val) : null;
  }

  Future<void> deleteDraft() async {
    await _box.delete(_draftKey);
  }

  Future<void> saveInspection(String id, Map<String, dynamic> data) async {
    await _box.put('inspection_$id', data);
  }

  Future<Map<String, dynamic>?> getInspection(String id) async {
    final val = _box.get('inspection_$id');
    return val is Map ? Map<String, dynamic>.from(val) : null;
  }

  @override
  Future<void> save(String id, Map<String, dynamic> data) async {
    await _box.put(id, data);
  }

  @override
  Future<Map<String, dynamic>?> get(String id) async {
    final val = _box.get(id);
    return val is Map ? Map<String, dynamic>.from(val) : null;
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
