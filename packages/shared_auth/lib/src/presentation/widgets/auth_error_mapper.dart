import 'package:shared_auth/l10n/gen/shared_auth_localizations.dart';
import 'package:shared_core/src/errors/result.dart';

/// Display-only failure family for a backend authentication failure.
///
/// This never changes validation thresholds, payloads, or retry semantics —
/// it only lets the view pick the specific surface (inline field vs notice
/// slot, retry CTA, offline treatment, session-expired path).
enum AuthFailureKind { validation, unauthorized, offline, server }

/// Maps an [AppException] to its display-only failure family.
AuthFailureKind authFailureKindOf(AppException error) {
  if (error is NetworkException) return AuthFailureKind.offline;
  if (error is UnauthorizedException) return AuthFailureKind.unauthorized;
  if (error is UnknownException) return AuthFailureKind.server;
  return AuthFailureKind.validation;
}

/// Which field an authentication failure belongs to for inline display.
/// [none] means the failure is form-level and belongs in the notice slot.
enum AuthErrorField { identifier, password, name, code, none }

/// Display mapping for one authentication failure: where it surfaces, with
/// what copy, and which follow-up actions apply. Pure presentation logic.
class AuthErrorDisplay {
  /// Inline target. [AuthErrorField.none] renders in the form notice slot.
  final AuthErrorField field;

  /// Fully localized line to show. Never a raw transport string and never a
  /// generic fallback where a specific message exists.
  final String message;

  /// Whether the notice slot should offer its retry CTA. OTP resend owns its
  /// own control, so expired/invalid codes are not retryable here.
  final bool retryable;

  /// 401 carrying session/token expiry copy routes to the Phase 01.2
  /// [AuthSessionExpiredView] path instead of a plain notice.
  final bool sessionExpired;

  /// Transport-level failure: the notice uses the offline treatment.
  final bool offline;

  /// Where keyboard focus moves on failure (first relevant field).
  final AuthErrorField focusField;

  const AuthErrorDisplay({
    required this.field,
    required this.message,
    required this.retryable,
    required this.focusField,
    this.sessionExpired = false,
    this.offline = false,
  });
}

final _technicalMessage = RegExp(
  r'dio|socket|connection (refused|reset|closed)|failed host lookup|timeout'
  r'|xmlhttprequest|handshake|os error|no internet|network is unreachable',
  caseSensitive: false,
);

bool _hasAny(String haystack, List<String> needles) {
  for (final needle in needles) {
    if (haystack.contains(needle)) return true;
  }
  return false;
}

/// Maps a typed backend failure to its display. Backend validation messages
/// are user-facing and pass through on their own field; transport noise is
/// replaced with calm offline copy; empty messages fall back to generic copy.
AuthErrorDisplay mapAuthError(
  AppException error,
  SharedAuthLocalizations t,
) {
  return mapAuthFailure(
    kind: authFailureKindOf(error),
    message: error.message,
    t: t,
  );
}

/// Maps a stored failure (kind + message) to its display. Used by views whose
/// state keeps the message string; the kind preserves the 401/offline/500
/// distinction that a bare string would erase.
AuthErrorDisplay mapAuthFailure({
  required AuthFailureKind kind,
  required String message,
  required SharedAuthLocalizations t,
}) {
  final raw = message.trim();
  final lower = raw.toLowerCase();

  if (kind == AuthFailureKind.offline || _technicalMessage.hasMatch(raw)) {
    return AuthErrorDisplay(
      field: AuthErrorField.none,
      message: t.errorOfflineRetry,
      retryable: true,
      focusField: AuthErrorField.none,
      offline: true,
    );
  }

  if (kind == AuthFailureKind.unauthorized) {
    if (_hasAny(lower, const ['expir', 'session', 'token', 'revok'])) {
      return AuthErrorDisplay(
        field: AuthErrorField.none,
        message: t.authSessionExpiredMessage,
        retryable: true,
        focusField: AuthErrorField.none,
        sessionExpired: true,
      );
    }
    return AuthErrorDisplay(
      field: AuthErrorField.none,
      message: t.errorInvalidCredentials,
      retryable: true,
      focusField: AuthErrorField.password,
    );
  }

  if (kind == AuthFailureKind.server) {
    return AuthErrorDisplay(
      field: AuthErrorField.none,
      message: t.errorServerRetryRef,
      retryable: true,
      focusField: AuthErrorField.none,
    );
  }

  // Validation family (400/404/409/422 + role + field messages).
  if (_hasAny(lower, const ['expir'])) {
    if (_hasAny(lower, const ['otp', 'code', 'token'])) {
      return AuthErrorDisplay(
        field: AuthErrorField.code,
        message: t.errorOtpExpired,
        retryable: false,
        focusField: AuthErrorField.code,
      );
    }
  }
  if (_hasAny(lower, const [
    'invalid',
    'incorrect',
    'wrong',
    'mismatch',
    'not match',
    'does not match',
  ])) {
    if (_hasAny(lower, const ['otp', 'code'])) {
      return AuthErrorDisplay(
        field: AuthErrorField.code,
        message: t.errorOtpInvalid,
        retryable: false,
        focusField: AuthErrorField.code,
      );
    }
  }
  if (_hasAny(lower, const [
    'already',
    'exists',
    'taken',
    'registered',
    'conflict',
    '409',
  ])) {
    return AuthErrorDisplay(
      field: AuthErrorField.identifier,
      message: t.errorAccountExists,
      retryable: false,
      focusField: AuthErrorField.identifier,
    );
  }
  if (_hasAny(lower, const [
    'no account',
    'not found',
    'unknown user',
    'no user',
    '404',
  ])) {
    return AuthErrorDisplay(
      field: AuthErrorField.identifier,
      message: t.errorAccountNotFound,
      retryable: true,
      focusField: AuthErrorField.identifier,
    );
  }
  if (raw.isEmpty) {
    return AuthErrorDisplay(
      field: AuthErrorField.none,
      message: t.errorGeneric,
      retryable: true,
      focusField: AuthErrorField.none,
    );
  }
  if (_hasAny(lower, const ['password'])) {
    return AuthErrorDisplay(
      field: AuthErrorField.password,
      message: raw,
      retryable: true,
      focusField: AuthErrorField.password,
    );
  }
  if (_hasAny(lower, const ['otp', 'verification code', 'recovery code'])) {
    return AuthErrorDisplay(
      field: AuthErrorField.code,
      message: raw,
      retryable: false,
      focusField: AuthErrorField.code,
    );
  }
  if (_hasAny(lower, const ['email', 'phone', 'mobile', 'identifier', 'name@'])) {
    return AuthErrorDisplay(
      field: AuthErrorField.identifier,
      message: raw,
      retryable: true,
      focusField: AuthErrorField.identifier,
    );
  }
  if (_hasAny(lower, const ['name'])) {
    return AuthErrorDisplay(
      field: AuthErrorField.name,
      message: raw,
      retryable: true,
      focusField: AuthErrorField.name,
    );
  }
  return AuthErrorDisplay(
    field: AuthErrorField.none,
    message: raw,
    retryable: true,
    focusField: AuthErrorField.none,
  );
}
