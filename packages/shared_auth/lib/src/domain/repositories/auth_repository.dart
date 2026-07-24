import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_auth/src/domain/entities/role_config.dart';
import 'package:shared_core/src/errors/result.dart';

abstract class AuthRepository {
  Future<Result<void>> sendOtp(String phone);
  Future<Result<AuthResult>> verifyOtp(String phone, String otp);
  Future<Result<AuthResult>> refreshToken(String refreshToken);
  Future<Result<void>> logout();
  List<RoleConfig> getRoleConfigs();
}
