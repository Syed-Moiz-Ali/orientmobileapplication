import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

abstract interface class AuthRepository {
  List<RoleConfig> getRoleConfigs();

  Future<Result<UserRole>> authenticate({
    required UserRole role,
    required String username,
    required String password,
  });
}
