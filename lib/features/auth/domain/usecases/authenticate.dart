import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/repositories/auth_repository.dart';

class Authenticate {
  final AuthRepository _repository;

  Authenticate(this._repository);

  Future<Result<AuthResult>> call({
    required String username,
    required String password,
  }) {
    return _repository.authenticate(
      username: username,
      password: password,
    );
  }
}
