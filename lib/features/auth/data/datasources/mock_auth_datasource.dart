import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

class MockAuthDatasource {
  Future<Result<UserRole>> authenticate({
    required UserRole role,
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (username.trim().isEmpty || password.trim().isEmpty) {
      return Failure(
        const ValidationException('Please enter username and password.'),
      );
    }

    return Success(role);
  }
}
