import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_core/src/local/storage/token_storage.dart';
import 'package:shared_models/src/user_role.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserRole role;
  final String token;

  const AuthAuthenticated({required this.role, required this.token});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthLoading();
  }

  Future<void> _restoreSession() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.getToken();
    final roleName = await storage.getRole();
    if (token != null && roleName != null) {
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleName,
        orElse: () => UserRole.owner,
      );
      state = AuthAuthenticated(role: role, token: token);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> authenticate(
    UserRole role,
    String token, {
    String? refreshToken,
  }) async {
    await ref
        .read(tokenStorageProvider)
        .save(token: token, refreshToken: refreshToken, role: role.name);
    state = AuthAuthenticated(role: role, token: token);
  }

  Future<void> updateToken(String token) async {
    await ref.read(tokenStorageProvider).updateToken(token);
    final current = state;
    if (current case AuthAuthenticated(:final role)) {
      state = AuthAuthenticated(role: role, token: token);
    }
  }

  Future<bool> refreshSession() async {
    final storage = ref.read(tokenStorageProvider);
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null) return false;

    final datasource = ref.read(authDatasourceProvider);
    final result = await datasource.refreshToken(refreshToken);
    return result.when(
      success: (auth) async {
        await storage.save(
          token: auth.token,
          refreshToken: auth.refreshToken,
          role: auth.role.name,
        );
        state = AuthAuthenticated(role: auth.role, token: auth.token);
        return true;
      },
      failure: (_) async {
        await logout();
        return false;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearAll();
    state = const AuthUnauthenticated();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
