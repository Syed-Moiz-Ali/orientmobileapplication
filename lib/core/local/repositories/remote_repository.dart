import 'package:orientmobileapplication/core/errors/result.dart';

abstract class RemoteRepository<T> {
  Future<Result<T>> create(T entity);
  Future<Result<T>> update(T entity);
  Future<Result<void>> delete(String id);
}
