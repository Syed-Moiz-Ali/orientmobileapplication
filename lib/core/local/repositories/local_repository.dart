abstract class LocalRepository<T> {
  Future<void> save(String id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String id);
  Future<List<Map<String, dynamic>>> getAll();
  Future<void> delete(String id);
  Future<void> clear();
}
