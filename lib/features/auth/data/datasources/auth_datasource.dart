import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';

abstract interface class AuthDatasource {
  Future<Result<AuthResult>> authenticate({
    required String username,
    required String password,
  });

  Future<Result<AuthResult>> refreshToken(String refreshToken);
}
