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
  /// P1 (audit): sessions validated offline keep working indefinitely after
  /// revocation. A hard cap: beyond this TTL, a non-401 (offline/5xx) failure
  /// no longer extends the session — the user must re-authenticate.
  static const Duration _sessionTtl = Duration(minutes: 30);
  static const String _validatedAtKey = 'validated_at';

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
    final role = _tryRoleFromName(roleName);
    if (role == null) {
      // FIX (audit P0): an unknown/renamed role must fail closed — it
      // previously defaulted to OWNER (privilege escalation on corrupt data).
      await storage.clearAll();
      state = const AuthUnauthenticated();
      return;
    }
    state = AuthAuthenticated(role: role, token: token);
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
      final role = _tryRoleFromName(data.role.isNotEmpty ? data.role : roleName ?? '');
      if (role == null) {
        await storage.clearAll();
        state = const AuthUnauthenticated();
        return false;
      }
      await storage.setMetadata(_validatedAtKey, DateTime.now().millisecondsSinceEpoch.toString());
      state = AuthAuthenticated(role: role, token: token, profile: data);
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
          final role = _tryRoleFromName(me.role);
          if (role == null) {
            state = const AuthUnauthenticated();
            return false;
          }
          state = AuthAuthenticated(role: role, token: retryToken, profile: me);
          return true;
        },
        failure: (_) {
          state = const AuthUnauthenticated();
          return false;
        },
      );
    }
    // Network failure / offline: proceed with the locally stored session ONLY
    // within the freshness TTL — a revoked user must not stay in forever.
    final validatedAt = await storage.getMetadata(_validatedAtKey);
    final fresh = validatedAt != null &&
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(int.tryParse(validatedAt) ?? 0)) <
            _sessionTtl;
    final role = _tryRoleFromName(roleName ?? '');
    if (!fresh || role == null) {
      state = const AuthUnauthenticated();
      return false;
    }
    state = AuthAuthenticated(role: role, token: token);
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
        // FIX (audit QA BUG-023): never call the full logout() here — the
        // logout API call would 401 (token expired) and the auth interceptor
        // would re-enter this failure path, deadlocking on the single-flight
        // refresh future. Clear local state directly instead.
        try {
          await storage.clearAll();
        } catch (_) {
          // Storage failure must not keep the user logged in.
        }
        state = const AuthUnauthenticated();
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
    // FIX (audit QA BUG-023): the in-memory session MUST always be dropped.
    // flutter_secure_storage.deleteAll() can throw on some devices (e.g.
    // Android Keystore unavailable) — if it did, state stayed authenticated
    // and logout appeared to do nothing (user could not log out).
    try {
      await ref.read(tokenStorageProvider).clearAll();
    } catch (_) {
      // Storage failure must not keep the user logged in — the router only
      // reads the AuthState, so clearing it is sufficient to force logout.
    }
    state = const AuthUnauthenticated();
  }

  /// FIX (audit P0): unknown role strings fail closed (null) instead of
  /// silently escalating to OWNER.
  UserRole? _tryRoleFromName(String roleName) {
    for (final r in UserRole.values) {
      if (r.name == roleName) return r;
    }
    return null;
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
