import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_auth/src/domain/entities/role_config.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';
import 'package:shared_core/src/errors/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<Result<void>> sendOtp(String phone) {
    return _datasource.sendOtp(phone);
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) {
    return _datasource.verifyOtp(phone, otp);
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) {
    return _datasource.refreshToken(refreshToken);
  }

  @override
  Future<Result<void>> logout() async {
    return const Success(null);
  }

  @override
  List<RoleConfig> getRoleConfigs() => RoleConfig.configs;
}
