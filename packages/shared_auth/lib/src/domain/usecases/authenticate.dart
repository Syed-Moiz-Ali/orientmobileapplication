import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';
import 'package:shared_core/src/errors/result.dart';

class SendOtp {
  final AuthRepository _r;
  SendOtp(this._r);
  Future<Result<void>> call(String phone) => _r.sendOtp(phone);
}

class VerifyOtp {
  final AuthRepository _r;
  VerifyOtp(this._r);
  Future<Result<AuthResult>> call(String phone, String otp) =>
      _r.verifyOtp(phone, otp);
}

class SendEmailOtp {
  final AuthRepository _r;
  SendEmailOtp(this._r);
  Future<Result<void>> call(String email) => _r.sendEmailOtp(email);
}

class VerifyEmailOtp {
  final AuthRepository _r;
  VerifyEmailOtp(this._r);
  Future<Result<AuthResult>> call(String email, String otp) =>
      _r.verifyEmailOtp(email, otp);
}

class RegisterUser {
  final AuthRepository _r;
  RegisterUser(this._r);
  Future<Result<AuthResult>> call(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) => _r.register(name, email, phone, password, role);
}

class LoginWithPassword {
  final AuthRepository _r;
  LoginWithPassword(this._r);
  Future<Result<AuthResult>> call(
    String email,
    String phone,
    String password,
  ) => _r.loginWithPassword(email, phone, password);
}

class ForgotPassword {
  final AuthRepository _r;
  ForgotPassword(this._r);
  Future<Result<void>> call(String type, String phone, String email) =>
      _r.forgotPassword(type, phone, email);
}

class ResetPassword {
  final AuthRepository _r;
  ResetPassword(this._r);
  Future<Result<void>> call(
    String type,
    String phone,
    String email,
    String otp,
    String password,
  ) => _r.resetPassword(type, phone, email, otp, password);
}
