import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_background.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/auth_header.dart';
import 'package:shared_auth/src/presentation/widgets/otp_input_field.dart';
import 'package:shared_auth/src/presentation/widgets/phone_input_field.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

class LoginView extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginView({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final brand = ref.watch(brandConfigProvider);

    return Scaffold(
      body: AuthBackground(
        brand: brand,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: loginState.otpSent
                    ? _OtpView(
                        key: const ValueKey('otp'),
                        brand: brand,
                        phone: loginState.phone,
                        error: loginState.error,
                        isLoading: loginState.isLoading,
                        resendCooldown: loginState.resendCooldown,
                        onResend: () =>
                            ref.read(loginProvider.notifier).resendOtp(),
                        onChangePhone: () =>
                            ref.read(loginProvider.notifier).resetPhone(),
                        onOtpChanged: (v) =>
                            ref.read(loginProvider.notifier).setOtp(v),
                        onVerify: () async {
                          await ref.read(loginProvider.notifier).verifyOtp();
                          final authState = ref.read(authNotifierProvider);
                          if (authState is AuthAuthenticated) {
                            widget.onLoginSuccess();
                          }
                        },
                      )
                    : _PhoneView(
                        key: const ValueKey('phone'),
                        brand: brand,
                        phone: loginState.phone,
                        error: loginState.error,
                        isLoading: loginState.isLoading,
                        onPhoneChanged: (v) =>
                            ref.read(loginProvider.notifier).setPhone(v),
                        onSendOtp: () =>
                            ref.read(loginProvider.notifier).sendOtp(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Minimal Phone View ───────────────────────────────────────────────────

class _PhoneView extends StatelessWidget {
  final BrandConfig brand;
  final String phone;
  final String? error;
  final bool isLoading;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onSendOtp;

  const _PhoneView({
    super.key,
    required this.brand,
    required this.phone,
    required this.error,
    required this.isLoading,
    required this.onPhoneChanged,
    required this.onSendOtp,
  });

  @override
  Widget build(BuildContext context) {
    final isPhoneValid = phone.length >= 8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          brand: brand,
          title: 'Sign in to ${brand.appName}',
          subtitle: 'Enter your mobile number to receive a verification code.',
        ),
        const SizedBox(height: 32),
        PhoneInputField(
          brand: brand,
          error: error,
          onChanged: onPhoneChanged,
          onSubmitted: onSendOtp,
        ),
        const SizedBox(height: 24),
        AuthButton(
          text: 'Continue',
          isLoading: isLoading,
          onPressed: isPhoneValid ? onSendOtp : null,
          brand: brand,
        ),
        const SizedBox(height: 32),
        const Center(
          child: SecurityBadge(),
        ),
      ],
    );
  }
}

// ─── Minimal OTP View ──────────────────────────────────────────────────────

class _OtpView extends StatelessWidget {
  final BrandConfig brand;
  final String phone;
  final String? error;
  final bool isLoading;
  final int resendCooldown;
  final VoidCallback onResend;
  final VoidCallback onChangePhone;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onVerify;

  const _OtpView({
    super.key,
    required this.brand,
    required this.phone,
    required this.error,
    required this.isLoading,
    required this.resendCooldown,
    required this.onResend,
    required this.onChangePhone,
    required this.onOtpChanged,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          brand: brand,
          title: 'Check your phone',
          subtitle: 'Enter the 6-digit passcode sent to your mobile number.',
          customIcon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 32),
        OtpInputField(
          brand: brand,
          phone: phone,
          error: error,
          isLoading: isLoading,
          resendCooldown: resendCooldown,
          onResend: onResend,
          onChangePhone: onChangePhone,
          onOtpChanged: onOtpChanged,
          onVerify: onVerify,
        ),
        const SizedBox(height: 24),
        AuthButton(
          text: 'Verify & sign in',
          isLoading: isLoading,
          onPressed: onVerify,
          brand: brand,
        ),
        const SizedBox(height: 32),
        const Center(
          child: SecurityBadge(),
        ),
      ],
    );
  }
}
