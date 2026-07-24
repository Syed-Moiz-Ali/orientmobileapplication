import 'package:shared_models/src/user_role.dart';

class AuthResult {
  final UserRole role;
  final String token;
  final String? refreshToken;

  const AuthResult({required this.role, required this.token, this.refreshToken});
}
