import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final brand = ref.watch(brandConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: loginState.otpSent
                ? _OtpView(
                    key: const ValueKey('otp'),
                    brand: brand,
                    phone: loginState.phone,
                    error: loginState.error,
                    isLoading: loginState.isLoading,
                    resendCooldown: loginState.resendCooldown,
                    onResend: () => ref.read(loginProvider.notifier).resendOtp(),
                    onChangePhone: () => ref.read(loginProvider.notifier).resetPhone(),
                    onOtpChanged: (v) => ref.read(loginProvider.notifier).setOtp(v),
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
                    error: loginState.error,
                    isLoading: loginState.isLoading,
                    onPhoneChanged: (v) => ref.read(loginProvider.notifier).setPhone(v),
                    onSendOtp: () => ref.read(loginProvider.notifier).sendOtp(),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Phone View ──────────────────────────────────────────────────────────

class _PhoneView extends StatelessWidget {
  final BrandConfig brand;
  final String? error;
  final bool isLoading;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onSendOtp;

  const _PhoneView({
    super.key,
    required this.brand,
    required this.error,
    required this.isLoading,
    required this.onPhoneChanged,
    required this.onSendOtp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: brand.iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(brand.icon, color: brand.iconColor, size: 28),
        ),
        const SizedBox(height: 28),
        Text(
          brand.appName,
          style: AppTextStyles.orbitronDisplayMedium(color: AppColors.textPrimary),
        ),
        if (brand.tagline != null) ...[
          const SizedBox(height: 6),
          Text(
            brand.tagline!,
            style: AppTextStyles.rajdhaniBody(color: AppColors.text4),
          ),
        ],
        const SizedBox(height: 64),
        Text(
          'Phone Number',
          style: AppTextStyles.rajdhaniLabel(color: AppColors.text3),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onPhoneChanged,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: AppTextStyles.rajdhaniInput(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '+91  9876543210',
            hintStyle: TextStyle(color: AppColors.text4.withValues(alpha: 0.5), fontSize: 16, letterSpacing: 1),
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: brand.iconColor, width: 1.5),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                const SizedBox(width: 6),
                Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
            ),
          ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: brand.buttonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadowColor: brand.buttonColor.withValues(alpha: 0.3),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Send OTP',
                    style: AppTextStyles.rajdhaniButton(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'By continuing, you agree to our Terms of Service',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.text4.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─── OTP View ─────────────────────────────────────────────────────────────

class _OtpView extends StatefulWidget {
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
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      widget.onOtpChanged(_controllers.map((c) => c.text).join());
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: widget.brand.iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_outline_rounded, color: widget.brand.iconColor, size: 28),
        ),
        const SizedBox(height: 28),
        Text(
          widget.brand.appName,
          style: AppTextStyles.orbitronDisplayMedium(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Code sent to +91 ${widget.phone}',
          style: AppTextStyles.rajdhaniBody(color: AppColors.text4),
        ),
        const SizedBox(height: 56),
        Text(
          'Enter Code',
          style: AppTextStyles.rajdhaniLabel(color: AppColors.text3),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            return SizedBox(
              width: 46,
              height: 54,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.monoMetric(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isFocused ? widget.brand.iconColor : AppColors.border.withValues(alpha: 0.8),
                      width: isFocused ? 1.5 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.brand.iconColor, width: 1.5),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _onDigitChanged(index, value),
              ),
            );
          }),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                const SizedBox(width: 6),
                Text(widget.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
            ),
          ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.brand.buttonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Verify & Login',
                    style: AppTextStyles.rajdhaniButton(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: widget.resendCooldown > 0 ? null : widget.onResend,
              child: Text(
                widget.resendCooldown > 0
                    ? 'Resend in ${widget.resendCooldown}s'
                    : 'Resend code',
                style: AppTextStyles.rajdhaniLabel(
                  color: widget.resendCooldown > 0
                      ? AppColors.text4
                      : widget.brand.iconColor,
                ),
              ),
            ),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.borderMd,
              ),
            ),
            GestureDetector(
              onTap: widget.onChangePhone,
              child: Text(
                'Change number',
                style: AppTextStyles.rajdhaniLabel(color: AppColors.text3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
