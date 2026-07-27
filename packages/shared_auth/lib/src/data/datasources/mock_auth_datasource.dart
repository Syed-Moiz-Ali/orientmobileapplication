import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_core/src/errors/result.dart';
import 'package:shared_models/src/user_role.dart';

class MockAuthDatasource implements AuthDatasource {
  final UserRole? defaultRole;

  MockAuthDatasource({this.defaultRole});

  @override
  Future<Result<void>> sendOtp(String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Success(null);
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));

    if (otp != '123456') {
      return Failure(ValidationException('Invalid OTP'));
    }

    final role = _resolveRole(phone);
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
      role: defaultRole ?? UserRole.advisor,
      token: 'refreshed_mock_token',
      refreshToken: 'refreshed_mock_refresh',
    ));
  }

  UserRole _resolveRole(String phone) {
    if (defaultRole != null) return defaultRole!;

    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = cleaned.length >= 3 ? cleaned.substring(cleaned.length - 3) : cleaned;
    switch (suffix) {
      case '001':
        return UserRole.advisor;
      case '002':
        return UserRole.supervisor;
      case '003':
        return UserRole.technician;
      default:
        return UserRole.advisor;
    }
  }
}
