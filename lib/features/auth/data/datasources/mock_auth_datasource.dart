import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

class MockAuthDatasource implements AuthDatasource {
  @override
  Future<Result<AuthResult>> authenticate({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (username.trim().isEmpty || password.trim().isEmpty) {
      return Failure(
        const ValidationException('Please enter username and password.'),
      );
    }

    return Success(AuthResult(role: UserRole.owner, token: 'mock-jwt-token'));
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async {
    return Failure(const NetworkException('Mock datasource does not support token refresh'));
  }
}
