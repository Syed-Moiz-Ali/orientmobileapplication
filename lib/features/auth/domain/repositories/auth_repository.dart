import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';

abstract interface class AuthRepository {
  List<RoleConfig> getRoleConfigs();

  Future<Result<AuthResult>> authenticate({
    required String username,
    required String password,
  });
}
