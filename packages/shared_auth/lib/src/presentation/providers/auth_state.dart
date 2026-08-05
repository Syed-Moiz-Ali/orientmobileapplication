import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_core/src/errors/result.dart';
import 'package:shared_core/src/local/storage/token_storage.dart';
import 'package:shared_core/src/models/auth_models.dart';
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

  /// Server-validated session profile from GET /auth/me (null when offline).
  final MeResponse? profile;

  const AuthAuthenticated({
    required this.role,
    required this.token,
    this.profile,
  });
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
    if (token == null || roleName == null) {
      state = const AuthUnauthenticated();
      return;
    }
    state = const AuthLoading();
    final valid = await validateSession();
    if (!valid && state is! AuthAuthenticated) {
      state = const AuthUnauthenticated();
    }
  }

  /// Server-side session validation used by the splash screen:
  ///  - 200: valid -> authenticated with the authoritative role/profile
  ///  - 401: expired/revoked -> try refresh once, then retry /auth/me
  ///  - network error: offline-tolerant -> keep the local session (field use)
  Future<bool> validateSession() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.getToken();
    if (token == null) {
      state = const AuthUnauthenticated();
      return false;
    }
    final roleName = await storage.getRole();
    final datasource = ref.read(authDatasourceProvider);

    final first = await datasource.getMe();
    if (first case Success(:final data)) {
      state = AuthAuthenticated(
        role: _roleFromName(data.role.isNotEmpty ? data.role : roleName ?? ''),
        token: token,
        profile: data,
      );
      return true;
    }
    final error = (first as Failure).error;
    if (error is UnauthorizedException) {
      final refreshed = await refreshSession();
      if (!refreshed) return false;
      final retryToken = await storage.getToken() ?? token;
      final retry = await datasource.getMe();
      return retry.when(
        success: (me) {
          state = AuthAuthenticated(
            role: _roleFromName(me.role),
            token: retryToken,
            profile: me,
          );
          return true;
        },
        failure: (_) {
          state = const AuthUnauthenticated();
          return false;
        },
      );
    }
    // Network failure / offline: proceed with the locally stored session.
    state = AuthAuthenticated(
      role: _roleFromName(roleName ?? ''),
      token: token,
    );
    return true;
  }

  Future<void> authenticate(
    UserRole role,
    String token, {
    String? refreshToken,
    MeResponse? profile,
  }) async {
    await ref
        .read(tokenStorageProvider)
        .save(token: token, refreshToken: refreshToken, role: role.name);
    state = AuthAuthenticated(role: role, token: token, profile: profile);
  }

  Future<void> updateToken(String token) async {
    await ref.read(tokenStorageProvider).updateToken(token);
    final current = state;
    if (current case AuthAuthenticated(:final role, :final profile)) {
      state = AuthAuthenticated(role: role, token: token, profile: profile);
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
    // Best-effort server-side logout; local clearing must never be blocked
    // by a network failure.
    try {
      await ref.read(authDatasourceProvider).logout();
    } catch (_) {
      // Ignore network errors during logout.
    }
    await ref.read(tokenStorageProvider).clearAll();
    state = const AuthUnauthenticated();
  }

  UserRole _roleFromName(String roleName) {
    return UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.owner,
    );
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
