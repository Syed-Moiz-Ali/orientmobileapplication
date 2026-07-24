import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_core/src/errors/result.dart';
import 'package:shared_models/src/user_role.dart';

class MockAuthDatasource implements AuthDatasource {
  @override
  Future<Result<void>> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));

    if (phone.length < 10) {
      return Failure(ValidationException('Invalid phone number'));
    }
    return const Success(null);
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));

    if (otp != '123456') {
      return Failure(ValidationException('Invalid OTP'));
    }

    final role = _inferRole(phone);
    return Success(AuthResult(
      role: role,
      token: 'mock_token_${role.name}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
    ));
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Success(AuthResult(
      role: UserRole.owner,
      token: 'refreshed_mock_token',
      refreshToken: 'refreshed_mock_refresh',
    ));
  }

  UserRole _inferRole(String phone) {
    final last4 = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (last4.length < 4) return UserRole.advisor;

    final suffix = last4.substring(last4.length - 4);
    switch (suffix) {
      case '0001':
        return UserRole.owner;
      case '0002':
        return UserRole.advisor;
      case '0003':
        return UserRole.technician;
      case '0004':
        return UserRole.customer;
      case '0005':
        return UserRole.supervisor;
      case '0006':
        return UserRole.crmDashboard;
      default:
        return UserRole.advisor;
    }
  }
}
