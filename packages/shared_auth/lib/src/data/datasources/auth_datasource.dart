import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_core/src/errors/result.dart';

abstract class AuthDatasource {
  Future<Result<void>> sendOtp(String phone);
  Future<Result<AuthResult>> verifyOtp(String phone, String otp);
  Future<Result<void>> sendEmailOtp(String email);
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp);
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  );
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  );
  Future<Result<AuthResult>> refreshToken(String refreshToken);
  Future<Result<void>> logout();
  Future<Result<void>> forgotPassword(String type, String phone, String email);
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  );
}
