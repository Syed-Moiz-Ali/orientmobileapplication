import 'package:dio/dio.dart';
import 'package:orientmobileapplication/core/errors/result.dart';
import 'package:orientmobileapplication/features/auth/data/datasources/auth_datasource.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/auth_result.dart';
import 'package:orientmobileapplication/features/auth/domain/entities/user_role.dart';

class AuthRemoteDatasource implements AuthDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  @override
  Future<Result<AuthResult>> authenticate({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final roleName = data['role'] as String?;
      final role = roleName != null
          ? UserRole.values.firstWhere((r) => r.name == roleName, orElse: () => UserRole.owner)
          : UserRole.owner;

      return Success(AuthResult(role: role, token: token, refreshToken: refreshToken));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Authentication failed';
      return Failure(NetworkException(message));
    } catch (e) {
      return Failure(NetworkException('Authentication failed: $e'));
    }
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final newRefreshToken = data['refreshToken'] as String?;
      final roleName = data['role'] as String?;
      final role = roleName != null
          ? UserRole.values.firstWhere((r) => r.name == roleName, orElse: () => UserRole.owner)
          : UserRole.owner;

      return Success(AuthResult(role: role, token: token, refreshToken: newRefreshToken));
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Token refresh failed';
      return Failure(NetworkException(message));
    } catch (e) {
      return Failure(NetworkException('Token refresh failed: $e'));
    }
  }
}
