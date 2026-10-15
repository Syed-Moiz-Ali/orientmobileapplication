import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/l10n/gen/shared_auth_localizations.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/widgets/auth_error_mapper.dart';
import 'package:shared_core/src/errors/result.dart';
import 'package:shared_core/src/localization/locale_provider.dart';
import 'package:shared_models/shared_models.dart';

enum AuthMethod { sms, email, password }

enum PasswordIdentifier { email, phone }

class LoginState {
  final bool isLoading;
  final String? error;

  /// Display-only family of the last backend failure (401 vs offline vs 500
  /// vs field validation). Validation thresholds and payloads are untouched —
  /// this only preserves the distinction a bare message string would erase so
  /// the view can pick the specific surface (inline field, snackbar + retry,
  /// offline treatment). Cleared alongside [error] by plain `copyWith()`.
  final AuthFailureKind? failureKind;
  final String phone;
  final String email;
  final String password;
  final String name;
  final String otp;
  final bool otpSent;
  final bool isRegistering;
  final int resendCooldown;
  final AuthMethod method;
  final PasswordIdentifier identifier;
  final String countryCode;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.failureKind,
    this.phone = '',
    this.email = '',
    this.password = '',
    this.name = '',
    this.otp = '',
    this.otpSent = false,
    this.isRegistering = false,
    this.resendCooldown = 0,
    this.method = AuthMethod.sms,
    this.identifier = PasswordIdentifier.email,
    this.countryCode = '+971',
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    AuthFailureKind? failureKind,
    String? phone,
    String? email,
    String? password,
    String? name,
    String? otp,
    bool? otpSent,
    bool? isRegistering,
    int? resendCooldown,
    AuthMethod? method,
    PasswordIdentifier? identifier,
    String? countryCode,
  }) => LoginState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    failureKind: failureKind,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    password: password ?? this.password,
    name: name ?? this.name,
    otp: otp ?? this.otp,
    otpSent: otpSent ?? this.otpSent,
    isRegistering: isRegistering ?? this.isRegistering,
    resendCooldown: resendCooldown ?? this.resendCooldown,
    method: method ?? this.method,
    identifier: identifier ?? this.identifier,
    countryCode: countryCode ?? this.countryCode,
  );
}

class LoginNotifier extends Notifier<LoginState> {
  Timer? _cooldownTimer;

  @override
  LoginState build() {
    ref.onDispose(cancelCooldown);
    return const LoginState();
  }

  /// Localized validation copy for the active locale (Phase 02). Resolved from
  /// the shared locale provider because notifiers run outside the widget tree.
  SharedAuthLocalizations get _t =>
      SharedAuthL10n.forLocale(ref.read(localeProvider));

  void cancelCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  void setMethod(AuthMethod m) {
    cancelCooldown();
    state = LoginState(method: m);
  }

  void setPasswordIdentifier(PasswordIdentifier value) {
    state = state.copyWith(
      identifier: value,
      email: value == PasswordIdentifier.email ? state.email : '',
      phone: value == PasswordIdentifier.phone ? state.phone : '',
    );
  }

  void setCountryCode(String code) => state = state.copyWith(countryCode: code);

  void setPhone(String v) {
    final c = v.replaceAll(RegExp(r'[^\d]'), '');
    if (c.length <= 10) state = state.copyWith(phone: c);
  }

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
  void setName(String v) => state = state.copyWith(name: v);
  void setOtp(String v) {
    final c = v.replaceAll(RegExp(r'[^\d]'), '');
    if (c.length <= 6) state = state.copyWith(otp: c);
  }

  void toggleRegister() =>
      state = state.copyWith(isRegistering: !state.isRegistering);

  String _fullPhone(String p) {
    // Phase 01.2: canonical phone normalization lives in the shared
    // [PhoneNumber] value object — no duplicated regex munging here.
    return PhoneNumber.normalizeLoose(p, countryCode: state.countryCode);
  }

  Future<void> _completeAuth() async {
    state = state.copyWith(isLoading: false, otpSent: false);
  }

  Future<void> sendSmsOtp() async {
    final p = state.phone.replaceAll(RegExp(r'[^\d]'), '');
    if (p.isEmpty || p.length < 8) {
      state = state.copyWith(error: _t.validationEnterValidPhone);
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(sendOtpProvider)(_fullPhone(state.phone));
    if (r case Success()) {
      state = state.copyWith(isLoading: false, otpSent: true);
      _startCooldown();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureKind: authFailureKindOf(error),
      );
    }
  }

  Future<void> verifySmsOtp() async {
    final o = state.otp.replaceAll(RegExp(r'[^\d]'), '');
    if (o.length != 6) {
      state = state.copyWith(error: _t.validationEnter6Otp);
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(verifyOtpProvider)(
      _fullPhone(state.phone),
      state.otp,
    );
    if (r case Success(data: final a)) {
      await ref
          .read(authNotifierProvider.notifier)
          .authenticate(a.role, a.token, refreshToken: a.refreshToken);
      await _completeAuth();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureKind: authFailureKindOf(error),
      );
    }
  }

  Future<void> sendEmailOtp() async {
    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(error: _t.validationEnterValidEmail);
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(sendEmailOtpProvider)(state.email.trim());
    if (r case Success()) {
      state = state.copyWith(isLoading: false, otpSent: true);
      _startCooldown();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureKind: authFailureKindOf(error),
      );
    }
  }

  Future<void> verifyEmailOtp() async {
    final o = state.otp.replaceAll(RegExp(r'[^\d]'), '');
    if (o.length != 6) {
      state = state.copyWith(error: _t.validationEnter6Otp);
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(verifyEmailOtpProvider)(
      state.email.trim(),
      state.otp,
    );
    if (r case Success(data: final a)) {
      await ref
          .read(authNotifierProvider.notifier)
          .authenticate(a.role, a.token, refreshToken: a.refreshToken);
      await _completeAuth();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureKind: authFailureKindOf(error),
      );
    }
  }

  Future<void> loginWithPassword() async {
    if (state.password.isEmpty) {
      state = state.copyWith(error: _t.validationEnterPassword);
      return;
    }
    if (state.identifier == PasswordIdentifier.email &&
        (state.email.isEmpty || !state.email.contains('@'))) {
      state = state.copyWith(error: _t.validationEnterValidEmail);
      return;
    }
    if (state.identifier == PasswordIdentifier.phone &&
        state.phone.length < 8) {
      state = state.copyWith(error: _t.validationEnterValidPhone);
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(loginWithPasswordProvider)(
      state.identifier == PasswordIdentifier.email ? state.email.trim() : '',
      state.identifier == PasswordIdentifier.phone
          ? _fullPhone(state.phone)
          : '',
      state.password,
    );
    if (r case Success(data: final a)) {
      await ref
          .read(authNotifierProvider.notifier)
          .authenticate(a.role, a.token, refreshToken: a.refreshToken);
      await _completeAuth();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureKind: authFailureKindOf(error),
      );
    }
  }

  Future<void> register() async {
    if (state.name.isEmpty) {
      state = state.copyWith(error: _t.validationEnterName);
      return;
    }
    if (state.password.length < 6) {
      state = state.copyWith(error: _t.validationPassword6Chars);
      return;
    }
    if (state.identifier == PasswordIdentifier.email &&
        (state.email.isEmpty || !state.email.contains('@'))) {
      state = state.copyWith(error: _t.validationEnterValidEmail);
      return;
    }
    if (state.identifier == PasswordIdentifier.phone &&
        state.phone.length < 8) {
      state = state.copyWith(error: _t.validationEnterValidPhone);
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(registerUserProvider)(
      state.name,
      state.identifier == PasswordIdentifier.email ? state.email.trim() : '',
      state.identifier == PasswordIdentifier.phone
          ? _fullPhone(state.phone)
          : '',
      state.password,
      'customer',
    );
    if (r case Success(data: final a)) {
      await ref
          .read(authNotifierProvider.notifier)
          .authenticate(a.role, a.token, refreshToken: a.refreshToken);
      await _completeAuth();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
        failureKind: authFailureKindOf(error),
      );
    }
  }

  void reset() {
    cancelCooldown();
    state = const LoginState();
  }

  void _startCooldown() {
    cancelCooldown();
    state = state.copyWith(resendCooldown: 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.otpSent || state.resendCooldown <= 1) {
        timer.cancel();
        _cooldownTimer = null;
        // Preserve any surfaced failure — the countdown must never wipe the
        // visible error out from under the user.
        state = state.copyWith(
          resendCooldown: 0,
          error: state.error,
          failureKind: state.failureKind,
        );
        return;
      }
      state = state.copyWith(
        resendCooldown: state.resendCooldown - 1,
        error: state.error,
        failureKind: state.failureKind,
      );
    });
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
