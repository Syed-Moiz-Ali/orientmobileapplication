import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final VoidCallback? onForgotPassword;
  const LoginView({super.key, required this.onLoginSuccess, this.onForgotPassword});
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(loginProvider);
    final brand = ref.watch(brandConfigProvider);
    final notifier = ref.read(loginProvider.notifier);

    return Scaffold(
      body: AuthBackground(
        brand: brand,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MethodTabs(method: s.method, onChanged: notifier.setMethod),
                  const SizedBox(height: 24),
                  if (s.method == AuthMethod.sms) _SmsView(s, brand, notifier),
                  if (s.method == AuthMethod.email) _EmailView(s, brand, notifier, _emailCtrl),
                  if (s.method == AuthMethod.password) _PasswordView(s, brand, notifier, _emailCtrl, _passCtrl, _nameCtrl, widget.onForgotPassword),
                  const SizedBox(height: 24),
                  const Center(child: SecurityBadge()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodTabs extends StatelessWidget {
  final AuthMethod method;
  final ValueChanged<AuthMethod> onChanged;
  const _MethodTabs({required this.method, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _tab('SMS', AuthMethod.sms, Icons.phone_android_rounded),
          _tab('Email', AuthMethod.email, Icons.email_outlined),
          _tab('Password', AuthMethod.password, Icons.lock_outline_rounded),
        ],
      ),
    );
  }

  Widget _tab(String label, AuthMethod m, IconData icon) {
    final selected = method == m;
    final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? (isDark ? const Color(0xFF1F2937) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? null : (isDark ? Colors.white54 : Colors.grey)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(
                fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? null : (isDark ? Colors.white54 : Colors.grey),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmsView extends StatelessWidget {
  final LoginState s; final BrandConfig brand; final LoginNotifier n;
  const _SmsView(this.s, this.brand, this.n);

  @override
  Widget build(BuildContext context) {
    if (s.otpSent) {
      return Column(children: [
        AuthHeader(brand: brand, title: 'Check your phone', subtitle: 'Enter the 6-digit code sent via SMS.', customIcon: Icons.lock_outline_rounded),
        const SizedBox(height: 24),
        OtpInputField(brand: brand, phone: s.phone, error: s.error, isLoading: s.isLoading,
          resendCooldown: s.resendCooldown, onResend: () => n.sendSmsOtp(),
          onChangePhone: n.reset, onOtpChanged: n.setOtp, onVerify: n.verifySmsOtp),
        const SizedBox(height: 16),
        AuthButton(text: 'Verify & sign in', isLoading: s.isLoading, onPressed: n.verifySmsOtp, brand: brand),
      ]);
    }
    return Column(children: [
      AuthHeader(brand: brand, title: 'Sign in to ${brand.appName}', subtitle: 'Enter your mobile number to receive a code via SMS.'),
      const SizedBox(height: 24),
      PhoneInputField(brand: brand, error: s.error, onChanged: n.setPhone, onSubmitted: n.sendSmsOtp),
      const SizedBox(height: 16),
      AuthButton(text: 'Send OTP', isLoading: s.isLoading, onPressed: s.phone.length>=8 ? n.sendSmsOtp : null, brand: brand),
    ]);
  }
}

class _EmailView extends StatelessWidget {
  final LoginState s; final BrandConfig brand; final LoginNotifier n; final TextEditingController c;
  const _EmailView(this.s, this.brand, this.n, this.c);

  @override
  Widget build(BuildContext context) {
    if (s.otpSent) {
      return Column(children: [
        AuthHeader(brand: brand, title: 'Check your email', subtitle: 'Enter the 6-digit code sent to your email.', customIcon: Icons.lock_outline_rounded),
        const SizedBox(height: 24),
        OtpInputField(brand: brand, phone: s.email, error: s.error, isLoading: s.isLoading,
          resendCooldown: s.resendCooldown, onResend: () => n.sendEmailOtp(),
          onChangePhone: n.reset, onOtpChanged: n.setOtp, onVerify: n.verifyEmailOtp),
        const SizedBox(height: 16),
        AuthButton(text: 'Verify & sign in', isLoading: s.isLoading, onPressed: n.verifyEmailOtp, brand: brand),
      ]);
    }
    return Column(children: [
      AuthHeader(brand: brand, title: 'Sign in to ${brand.appName}', subtitle: 'Enter your email to receive a verification code.'),
      const SizedBox(height: 24),
      _EmailField(controller: c, error: s.error, onChanged: n.setEmail, onSubmitted: n.sendEmailOtp),
      const SizedBox(height: 16),
      AuthButton(text: 'Send OTP', isLoading: s.isLoading, onPressed: s.email.contains('@') ? n.sendEmailOtp : null, brand: brand),
    ]);
  }
}

class _PasswordView extends StatelessWidget {
  final LoginState s; final BrandConfig brand; final LoginNotifier n;
  final TextEditingController eCtrl, pCtrl, nCtrl;
  final VoidCallback? onForgotPassword;
  const _PasswordView(this.s, this.brand, this.n, this.eCtrl, this.pCtrl, this.nCtrl, this.onForgotPassword);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AuthHeader(
        brand: brand,
        title: s.isRegistering ? 'Create Account' : 'Sign in to ${brand.appName}',
        subtitle: s.isRegistering ? 'Create an account with email or phone.' : 'Enter your credentials to sign in.',
      ),
      const SizedBox(height: 24),
      if (s.isRegistering) _TextField(controller: nCtrl, hint: 'Full name', onChanged: n.setName, icon: Icons.person_outline_rounded),
      if (s.isRegistering) const SizedBox(height: 12),
      _TextField(controller: eCtrl, hint: 'Email address', onChanged: n.setEmail, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      if (!s.isRegistering) _PhoneField(onChanged: n.setPhone),
      if (!s.isRegistering) const SizedBox(height: 12),
      _TextField(controller: pCtrl, hint: 'Password', onChanged: n.setPassword, icon: Icons.lock_outline_rounded, obscure: true),
      const SizedBox(height: 8),
      if (s.error != null) Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
      ),
      AuthButton(
        text: s.isRegistering ? 'Create Account' : 'Sign In',
        isLoading: s.isLoading,
        onPressed: () {
          if (s.isRegistering) { n.register(); }
          else { n.loginWithPassword(); }
        },
        brand: brand,
      ),
      const SizedBox(height: 12),
      if (!s.isRegistering) Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: onForgotPassword,
          child: Text('Forgot Password?', style: TextStyle(fontSize: 13, color: brand.accentColor)),
        ),
      ),
      TextButton(
        onPressed: n.toggleRegister,
        child: Text(s.isRegistering ? 'Already have an account? Sign in' : 'Don\'t have an account? Register'),
      ),
    ]);
  }
}

Widget _EmailField({required TextEditingController controller, String? error, ValueChanged<String>? onChanged, VoidCallback? onSubmitted}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(children: [
      const SizedBox(width: 14),
      const Icon(Icons.email_outlined, size: 20, color: AppColors.text4),
      const SizedBox(width: 10),
      Expanded(child: TextField(
        controller: controller, keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'email@example.com', border: InputBorder.none,
          hintStyle: TextStyle(color: AppColors.text4, fontSize: 14),
        ),
        onChanged: onChanged, onSubmitted: (_) => onSubmitted?.call(),
      )),
    ]),
  );
}

Widget _PhoneField({ValueChanged<String>? onChanged}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(children: [
      const SizedBox(width: 14),
      const Text('+971', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      Container(width: 1, height: 24, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 10)),
      Expanded(child: TextField(
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 15),
        decoration: const InputDecoration(
          hintText: '50 123 4567', border: InputBorder.none,
          hintStyle: TextStyle(color: AppColors.text4, fontSize: 14),
        ),
        onChanged: onChanged,
      )),
    ]),
  );
}

Widget _TextField({required TextEditingController controller, required String hint, ValueChanged<String>? onChanged,
    IconData? icon, bool obscure = false, TextInputType? keyboardType}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(children: [
      if (icon != null) ...[const SizedBox(width: 14), Icon(icon, size: 20, color: AppColors.text4), const SizedBox(width: 10)],
      Expanded(child: TextField(
        controller: controller, obscureText: obscure, keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(color: AppColors.text4, fontSize: 14)),
        onChanged: onChanged,
      )),
    ]),
  );
}
