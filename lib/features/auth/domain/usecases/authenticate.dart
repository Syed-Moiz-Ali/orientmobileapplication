import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/domain/repositories/auth_repository.dart';

class Authenticate {
  final AuthRepository _repository;

  Authenticate(this._repository);

  Future<Result<UserRole>> call({
    required UserRole role,
    required String username,
    required String password,
  }) {
    return _repository.authenticate(
      role: role,
      username: username,
      password: password,
    );
  }
}
