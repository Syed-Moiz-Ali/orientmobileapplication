import 'package:dio/dio.dart';
import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_core/src/errors/result.dart';

class AuthRemoteDatasource implements AuthDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  @override
  Future<Result<void>> sendOtp(String phone) async {
    try {
      await _dio.post('/auth/send-otp', data: {'phone': phone});
      return const Success(null);
    } on DioException catch (e) {
      return Failure(NetworkException(e.message ?? 'Failed to send OTP'));
    }
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
      });
      return Success(AuthResult(
        role: _parseRole(response.data['role']),
        token: response.data['token'],
        refreshToken: response.data['refreshToken'],
      ));
    } on DioException catch (e) {
      return Failure(NetworkException(e.message ?? 'OTP verification failed'));
    }
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      return Success(AuthResult(
        role: _parseRole(response.data['role']),
        token: response.data['token'],
        refreshToken: response.data['refreshToken'],
      ));
    } on DioException catch (e) {
      return Failure(NetworkException(e.message ?? 'Token refresh failed'));
    }
  }

  dynamic _parseRole(String role) {
    return role;
  }
}
