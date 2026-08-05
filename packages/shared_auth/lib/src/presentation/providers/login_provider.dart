import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_core/src/errors/result.dart';

enum AuthMethod { sms, email, password }

enum PasswordIdentifier { email, phone }

class LoginState {
  final bool isLoading;
  final String? error;
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
    final c = p.replaceAll(RegExp(r'[^\d]'), '');
    final cc = state.countryCode.replaceAll(RegExp(r'[^\d]'), '');
    if (c.startsWith(cc)) return c;
    final z = c.startsWith('0') ? c.substring(1) : c;
    return '$cc$z';
  }

  Future<void> _completeAuth() async {
    state = state.copyWith(isLoading: false, otpSent: false);
  }

  Future<void> sendSmsOtp() async {
    final p = state.phone.replaceAll(RegExp(r'[^\d]'), '');
    if (p.isEmpty || p.length < 8) {
      state = state.copyWith(error: 'Enter a valid phone number');
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(sendOtpProvider)(_fullPhone(state.phone));
    if (r case Success()) {
      state = state.copyWith(isLoading: false, otpSent: true);
      _startCooldown();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<void> verifySmsOtp() async {
    final o = state.otp.replaceAll(RegExp(r'[^\d]'), '');
    if (o.length != 6) {
      state = state.copyWith(error: 'Enter 6-digit OTP');
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
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<void> sendEmailOtp() async {
    if (state.email.isEmpty || !state.email.contains('@')) {
      state = state.copyWith(error: 'Enter a valid email');
      return;
    }
    state = state.copyWith(isLoading: true);
    final r = await ref.read(sendEmailOtpProvider)(state.email.trim());
    if (r case Success()) {
      state = state.copyWith(isLoading: false, otpSent: true);
      _startCooldown();
    } else if (r case Failure(:final error)) {
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<void> verifyEmailOtp() async {
    final o = state.otp.replaceAll(RegExp(r'[^\d]'), '');
    if (o.length != 6) {
      state = state.copyWith(error: 'Enter 6-digit OTP');
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
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<void> loginWithPassword() async {
    if (state.password.isEmpty) {
      state = state.copyWith(error: 'Enter your password');
      return;
    }
    if (state.identifier == PasswordIdentifier.email &&
        (state.email.isEmpty || !state.email.contains('@'))) {
      state = state.copyWith(error: 'Enter a valid email');
      return;
    }
    if (state.identifier == PasswordIdentifier.phone &&
        state.phone.length < 8) {
      state = state.copyWith(error: 'Enter a valid phone number');
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
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<void> register() async {
    if (state.name.isEmpty) {
      state = state.copyWith(error: 'Enter your name');
      return;
    }
    if (state.password.length < 6) {
      state = state.copyWith(error: 'Password must be 6+ chars');
      return;
    }
    if (state.identifier == PasswordIdentifier.email &&
        (state.email.isEmpty || !state.email.contains('@'))) {
      state = state.copyWith(error: 'Enter a valid email');
      return;
    }
    if (state.identifier == PasswordIdentifier.phone &&
        state.phone.length < 8) {
      state = state.copyWith(error: 'Enter a valid phone number');
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
      state = state.copyWith(isLoading: false, error: error.message);
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
        state = state.copyWith(resendCooldown: 0);
        return;
      }
      state = state.copyWith(resendCooldown: state.resendCooldown - 1);
    });
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
