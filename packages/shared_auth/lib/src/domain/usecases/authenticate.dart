import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_auth/src/domain/repositories/auth_repository.dart';
import 'package:shared_core/src/errors/result.dart';

class SendOtp {
  final AuthRepository _repository;

  SendOtp(this._repository);

  Future<Result<void>> call(String phone) {
    return _repository.sendOtp(phone);
  }
}

class VerifyOtp {
  final AuthRepository _repository;

  VerifyOtp(this._repository);

  Future<Result<AuthResult>> call(String phone, String otp) {
    return _repository.verifyOtp(phone, otp);
  }
}
