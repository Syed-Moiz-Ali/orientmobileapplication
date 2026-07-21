import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';
import 'package:orientmobileapplication/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockAuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  List<RoleConfig> getRoleConfigs() => RoleConfig.configs;

  @override
  Future<Result<UserRole>> authenticate({
    required UserRole role,
    required String username,
    required String password,
  }) {
    return _datasource.authenticate(
      role: role,
      username: username,
      password: password,
    );
  }
}
