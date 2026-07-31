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
  final bool allowRegistration;
  const LoginView({
    super.key,
    required this.onLoginSuccess,
    this.onForgotPassword,
    this.allowRegistration = false,
  });
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 18 : 28,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BrandIntro(brand: brand),
                      const SizedBox(height: 22),
                      Container(
                        padding: EdgeInsets.all(compact ? 20 : 28),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xD9162235)
                              : Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE2EAED),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: compact ? 0.06 : 0.09,
                              ),
                              blurRadius: 34,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _MethodTabs(
                              method: s.method,
                              brand: brand,
                              onChanged: notifier.setMethod,
                            ),
                            const SizedBox(height: 26),
                            if (s.method == AuthMethod.sms)
                              _SmsView(s, brand, notifier),
                            if (s.method == AuthMethod.email)
                              _EmailView(s, brand, notifier, _emailCtrl),
                            if (s.method == AuthMethod.password)
                              _PasswordView(
                                s,
                                brand,
                                notifier,
                                _emailCtrl,
                                _passCtrl,
                                _nameCtrl,
                                widget.onForgotPassword,
                                widget.allowRegistration,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Center(child: SecurityBadge()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandIntro extends StatelessWidget {
  final BrandConfig brand;

  const _BrandIntro({required this.brand});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: brand.accentColor,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: brand.accentColor.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(brand.icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand.appName,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            Text(
              brand.tagline ?? 'Secure workspace access',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.text3,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodTabs extends StatelessWidget {
  final AuthMethod method;
  final BrandConfig brand;
  final ValueChanged<AuthMethod> onChanged;
  const _MethodTabs({
    required this.method,
    required this.brand,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1727) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _tab(context, 'SMS OTP', AuthMethod.sms, Icons.phone_android_rounded),
          _tab(context, 'Email OTP', AuthMethod.email, Icons.email_outlined),
          _tab(
            context,
            'Password',
            AuthMethod.password,
            Icons.lock_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String label, AuthMethod m, IconData icon) {
    final selected = method == m;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = brand.accentColor;
    final foregroundColor = selected
        ? Colors.white
        : (isDark ? Colors.white70 : AppColors.text2);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Sign in with $label',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(m),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
              decoration: BoxDecoration(
                color: selected ? selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: selectedColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: foregroundColor),
                  const SizedBox(width: 5),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: foregroundColor,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmsView extends StatelessWidget {
  final LoginState s;
  final BrandConfig brand;
  final LoginNotifier n;
  const _SmsView(this.s, this.brand, this.n);

  @override
  Widget build(BuildContext context) {
    if (s.otpSent) {
      return Column(
        children: [
          AuthHeader(
            brand: brand,
            title: 'Verify your phone',
            subtitle: 'Enter the 6-digit code we sent by SMS.',
            customIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 24),
          OtpInputField(
            brand: brand,
            phone: s.phone,
            error: s.error,
            isLoading: s.isLoading,
            resendCooldown: s.resendCooldown,
            onResend: () => n.sendSmsOtp(),
            onChangePhone: n.reset,
            onOtpChanged: n.setOtp,
            onVerify: n.verifySmsOtp,
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Verify & sign in',
            isLoading: s.isLoading,
            onPressed: n.verifySmsOtp,
            brand: brand,
          ),
        ],
      );
    }
    return Column(
      children: [
        AuthHeader(
          brand: brand,
          title: 'Welcome back',
          subtitle: 'Enter your mobile number to receive a secure code.',
        ),
        const SizedBox(height: 24),
        PhoneInputField(
          brand: brand,
          error: s.error,
          onChanged: n.setPhone,
          onSubmitted: n.sendSmsOtp,
        ),
        const SizedBox(height: 16),
        AuthButton(
          text: 'Send OTP',
          isLoading: s.isLoading,
          onPressed: s.phone.length >= 8 ? n.sendSmsOtp : null,
          brand: brand,
        ),
      ],
    );
  }
}

class _EmailView extends StatelessWidget {
  final LoginState s;
  final BrandConfig brand;
  final LoginNotifier n;
  final TextEditingController c;
  const _EmailView(this.s, this.brand, this.n, this.c);

  @override
  Widget build(BuildContext context) {
    if (s.otpSent) {
      return Column(
        children: [
          AuthHeader(
            brand: brand,
            title: 'Verify your email',
            subtitle: 'Enter the 6-digit code we sent to your inbox.',
            customIcon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 24),
          OtpInputField(
            brand: brand,
            phone: s.email,
            error: s.error,
            isLoading: s.isLoading,
            resendCooldown: s.resendCooldown,
            onResend: () => n.sendEmailOtp(),
            onChangePhone: n.reset,
            onOtpChanged: n.setOtp,
            onVerify: n.verifyEmailOtp,
          ),
          const SizedBox(height: 16),
          AuthButton(
            text: 'Verify & sign in',
            isLoading: s.isLoading,
            onPressed: n.verifyEmailOtp,
            brand: brand,
          ),
        ],
      );
    }
    return Column(
      children: [
        AuthHeader(
          brand: brand,
          title: 'Welcome back',
          subtitle: 'Enter your email to receive a secure code.',
        ),
        const SizedBox(height: 24),
        _EmailField(
          controller: c,
          error: s.error,
          onChanged: n.setEmail,
          onSubmitted: n.sendEmailOtp,
        ),
        const SizedBox(height: 16),
        AuthButton(
          text: 'Send OTP',
          isLoading: s.isLoading,
          onPressed: s.email.contains('@') ? n.sendEmailOtp : null,
          brand: brand,
        ),
      ],
    );
  }
}

class _PasswordView extends StatelessWidget {
  final LoginState s;
  final BrandConfig brand;
  final LoginNotifier n;
  final TextEditingController eCtrl, pCtrl, nCtrl;
  final VoidCallback? onForgotPassword;
  final bool allowRegistration;
  const _PasswordView(
    this.s,
    this.brand,
    this.n,
    this.eCtrl,
    this.pCtrl,
    this.nCtrl,
    this.onForgotPassword,
    this.allowRegistration,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthHeader(
          brand: brand,
          title: s.isRegistering ? 'Create Account' : 'Welcome back',
          subtitle: s.isRegistering
              ? 'Create an account with email or phone.'
              : 'Enter your credentials to sign in.',
        ),
        const SizedBox(height: 24),
        if (s.isRegistering)
          _TextField(
            controller: nCtrl,
            hint: 'Full name',
            onChanged: n.setName,
            icon: Icons.person_outline_rounded,
          ),
        if (s.isRegistering) const SizedBox(height: 12),
        _IdentifierToggle(
          identifier: s.identifier,
          onChanged: n.setPasswordIdentifier,
        ),
        const SizedBox(height: 12),
        if (s.identifier == PasswordIdentifier.email)
          _TextField(
            controller: eCtrl,
            hint: 'Email address',
            onChanged: n.setEmail,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          )
        else
          _PhoneField(onChanged: n.setPhone),
        const SizedBox(height: 12),
        _TextField(
          controller: pCtrl,
          hint: 'Password',
          onChanged: n.setPassword,
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        const SizedBox(height: 8),
        if (s.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              s.error!,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        AuthButton(
          text: s.isRegistering ? 'Create Account' : 'Sign In',
          isLoading: s.isLoading,
          onPressed: () {
            if (s.isRegistering) {
              n.register();
            } else {
              n.loginWithPassword();
            }
          },
          brand: brand,
        ),
        const SizedBox(height: 12),
        if (!s.isRegistering)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 13, color: brand.accentColor),
              ),
            ),
          ),
        if (allowRegistration)
          TextButton(
            onPressed: n.toggleRegister,
            child: Text(
              s.isRegistering
                  ? 'Already have an account? Sign in'
                  : 'Don\'t have an account? Register',
            ),
          ),
      ],
    );
  }
}

class _IdentifierToggle extends StatelessWidget {
  final PasswordIdentifier identifier;
  final ValueChanged<PasswordIdentifier> onChanged;

  const _IdentifierToggle({required this.identifier, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Text(
          'Continue with',
          style: TextStyle(color: AppColors.text3, fontSize: 12),
        ),
        const Spacer(),
        _choice(
          'Email',
          PasswordIdentifier.email,
          Icons.email_outlined,
          accent,
        ),
        const SizedBox(width: 8),
        _choice(
          'Phone',
          PasswordIdentifier.phone,
          Icons.phone_outlined,
          accent,
        ),
      ],
    );
  }

  Widget _choice(
    String label,
    PasswordIdentifier value,
    IconData icon,
    Color accent,
  ) {
    final selected = identifier == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? accent : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? accent : AppColors.text3),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? accent : AppColors.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _EmailField({
  required TextEditingController controller,
  String? error,
  ValueChanged<String>? onChanged,
  VoidCallback? onSubmitted,
}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        const SizedBox(width: 14),
        const Icon(Icons.email_outlined, size: 20, color: AppColors.text4),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'email@example.com',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.text4, fontSize: 14),
            ),
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted?.call(),
          ),
        ),
      ],
    ),
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
    child: Row(
      children: [
        const SizedBox(width: 14),
        const Text(
          '+971',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        Container(
          width: 1,
          height: 24,
          color: const Color(0xFFE2E8F0),
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: '50 123 4567',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.text4, fontSize: 14),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}

Widget _TextField({
  required TextEditingController controller,
  required String hint,
  ValueChanged<String>? onChanged,
  IconData? icon,
  bool obscure = false,
  TextInputType? keyboardType,
}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: AppColors.text4),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: const TextStyle(color: AppColors.text4, fontSize: 14),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}
