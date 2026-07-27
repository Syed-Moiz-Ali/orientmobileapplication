import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_core/src/errors/result.dart';
import 'package:shared_core/src/local/helpers/environment_config.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final String phone;
  final String otp;
  final bool otpSent;
  final int resendCooldown;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.phone = '',
    this.otp = '',
    this.otpSent = false,
    this.resendCooldown = 0,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    String? phone,
    String? otp,
    bool? otpSent,
    int? resendCooldown,
  }) =>
      LoginState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        phone: phone ?? this.phone,
        otp: otp ?? this.otp,
        otpSent: otpSent ?? this.otpSent,
        resendCooldown: resendCooldown ?? this.resendCooldown,
      );
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  String? _validatePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return 'Phone number is required';
    if (!EnvironmentConfig.useMocks) {
      if (cleaned.length != 10) return 'Phone number must be exactly 10 digits';
      if (!cleaned.startsWith(RegExp(r'[5-9]'))) {
        return 'Phone number must start with 5, 6, 7, 8, or 9';
      }
    }
    return null;
  }

  String? _validateOtp(String otp) {
    final cleaned = otp.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return 'OTP is required';
    if (cleaned.length != 6) return 'OTP must be exactly 6 digits';
    return null;
  }

  void setPhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length <= 10) {
      state = state.copyWith(phone: cleaned);
    }
  }

  void setOtp(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length <= 6) {
      state = state.copyWith(otp: cleaned);
    }
  }

  Future<void> sendOtp() async {
    final phoneError = _validatePhone(state.phone);
    if (phoneError != null) {
      state = state.copyWith(error: phoneError);
      return;
    }

    state = state.copyWith(isLoading: true);

    final sendOtp = ref.read(sendOtpProvider);
    final result = await sendOtp(state.phone);

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false, otpSent: true);
        _startResendCooldown();
      case Failure(error: final error):
        state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  void _startResendCooldown() {
    state = state.copyWith(resendCooldown: 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!state.otpSent || state.resendCooldown <= 1) {
        state = state.copyWith(resendCooldown: 0);
        return false;
      }
      state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      return true;
    });
  }

  Future<void> resendOtp() async {
    if (state.resendCooldown > 0) return;
    await sendOtp();
  }

  Future<void> verifyOtp() async {
    final otpError = _validateOtp(state.otp);
    if (otpError != null) {
      state = state.copyWith(error: otpError);
      return;
    }

    state = state.copyWith(isLoading: true);

    final verifyOtp = ref.read(verifyOtpProvider);
    final result = await verifyOtp(state.phone, state.otp);

    switch (result) {
      case Success(data: final auth):
        await ref.read(authNotifierProvider.notifier).authenticate(
              auth.role,
              auth.token,
              refreshToken: auth.refreshToken,
            );
      case Failure(error: final error):
        state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  void resetPhone() {
    state = const LoginState();
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
