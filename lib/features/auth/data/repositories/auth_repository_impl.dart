import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/role_config.dart';
import 'package:orientmobileapplication/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  List<RoleConfig> getRoleConfigs() => RoleConfig.configs;

  @override
  Future<Result<AuthResult>> authenticate({
    required String username,
    required String password,
  }) {
    return _datasource.authenticate(
      username: username,
      password: password,
    );
  }
}
