import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_auth/src/domain/entities/role_config.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';
import 'package:shared_core/src/errors/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<Result<void>> sendOtp(String phone) => _ds.sendOtp(phone);
  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) =>
      _ds.verifyOtp(phone, otp);
  @override
  Future<Result<void>> sendEmailOtp(String email) => _ds.sendEmailOtp(email);
  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) =>
      _ds.verifyEmailOtp(email, otp);
  @override
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) => _ds.register(name, email, phone, password, role);
  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) => _ds.loginWithPassword(email, phone, password);
  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) =>
      _ds.refreshToken(refreshToken);
  @override
  Future<Result<void>> logout() => _ds.logout();
  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) => _ds.forgotPassword(type, phone, email);
  @override
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  ) => _ds.resetPassword(type, phone, email, otp, newPassword);
  @override
  List<RoleConfig> getRoleConfigs() => RoleConfig.configs;
}
