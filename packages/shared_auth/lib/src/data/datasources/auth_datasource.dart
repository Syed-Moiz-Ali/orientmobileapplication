import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_core/src/errors/result.dart';

abstract class AuthDatasource {
  Future<Result<void>> sendOtp(String phone);
  Future<Result<AuthResult>> verifyOtp(String phone, String otp);
  Future<Result<AuthResult>> refreshToken(String refreshToken);
}
