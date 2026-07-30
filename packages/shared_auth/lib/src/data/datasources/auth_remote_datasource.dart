import 'package:shared_auth/src/data/datasources/auth_datasource.dart';
import 'package:shared_auth/src/domain/entities/auth_result.dart';
import 'package:shared_core/src/constants/api_constants.dart';
import 'package:shared_core/src/errors/result.dart';
import 'package:shared_core/src/models/auth_models.dart';
import 'package:shared_core/src/network/api_client.dart';
import 'package:shared_models/src/user_role.dart';

class AuthRemoteDatasource implements AuthDatasource {
  final ApiClient _client;
  AuthRemoteDatasource(this._client);

  @override
  Future<Result<void>> sendOtp(String phone) async {
    return _client.post(ApiEndpoints.sendOtp, data: {'type': 'sms', 'phone': phone});
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async {
    final r = await _client.post<TokenResponse>(ApiEndpoints.verifyOtp,
      data: {'type': 'sms', 'phone': phone, 'otp': otp},
      fromJson: (d) => TokenResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => Success(_toAuth(v)), failure: (e) => Failure(e));
  }

  @override
  Future<Result<void>> sendEmailOtp(String email) async {
    return _client.post(ApiEndpoints.sendOtp, data: {'type': 'email', 'email': email});
  }

  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) async {
    final r = await _client.post<TokenResponse>(ApiEndpoints.verifyOtp,
      data: {'type': 'email', 'email': email, 'otp': otp},
      fromJson: (d) => TokenResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => Success(_toAuth(v)), failure: (e) => Failure(e));
  }

  @override
  Future<Result<AuthResult>> register(String name, String email, String phone, String password, String role) async {
    final data = <String, dynamic>{'name': name, 'password': password, 'role': role};
    if (email.isNotEmpty) data['email'] = email;
    if (phone.isNotEmpty) data['phone'] = phone;
    final r = await _client.post<TokenResponse>(ApiEndpoints.register,
      data: data, fromJson: (d) => TokenResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => Success(_toAuth(v)), failure: (e) => Failure(e));
  }

  @override
  Future<Result<AuthResult>> loginWithPassword(String email, String phone, String password) async {
    final data = <String, dynamic>{'password': password};
    if (email.isNotEmpty) data['email'] = email;
    if (phone.isNotEmpty) data['phone'] = phone;
    final r = await _client.post<TokenResponse>(ApiEndpoints.login,
      data: data, fromJson: (d) => TokenResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => Success(_toAuth(v)), failure: (e) => Failure(e));
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async {
    final r = await _client.post<TokenResponse>(ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
      fromJson: (d) => TokenResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => Success(_toAuth(v)), failure: (e) => Failure(e));
  }

  @override
  Future<Result<void>> logout() async => _client.post(ApiEndpoints.logout);

  @override
  Future<Result<void>> forgotPassword(String type, String phone, String email) async {
    final d = <String, dynamic>{'type': type};
    if (phone.isNotEmpty) d['phone'] = phone;
    if (email.isNotEmpty) d['email'] = email;
    return _client.post(ApiEndpoints.forgotPassword, data: d);
  }

  @override
  Future<Result<void>> resetPassword(String type, String phone, String email, String otp, String newPassword) async {
    return _client.post(ApiEndpoints.resetPassword, data: {
      'type': type, 'otp': otp, 'newPassword': newPassword,
      if (phone.isNotEmpty) 'phone': phone,
      if (email.isNotEmpty) 'email': email,
    });
  }

  AuthResult _toAuth(TokenResponse r) => AuthResult(role: _parse(r.role), token: r.token, refreshToken: r.refreshToken);

  UserRole _parse(String role) {
    try { return UserRole.values.byName(role); } catch (_) { return UserRole.customer; }
  }
}
