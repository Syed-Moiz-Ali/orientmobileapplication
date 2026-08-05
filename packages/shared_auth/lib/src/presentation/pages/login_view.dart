import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_background.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/otp_input_field.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

class LoginView extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onForgotPassword;
  final bool allowRegistration;

  const LoginView({super.key, required this.onLoginSuccess, this.onForgotPassword, this.allowRegistration = false});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _unifiedCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _unifiedCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _listenToAuth(AuthState? previous, AuthState next) {
    if (next is AuthAuthenticated && previous is! AuthAuthenticated) {
      widget.onLoginSuccess();
    }
  }

  void _handleSmartSubmit(LoginNotifier notifier) {
    final input = _unifiedCtrl.text.trim();
    if (input.isEmpty) return;

    final isEmail = input.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(input);

    if (isEmail) {
      notifier.setMethod(AuthMethod.email);
      notifier.setEmail(input);
      notifier.sendEmailOtp();
    } else {
      notifier.setMethod(AuthMethod.sms);
      notifier.setPhone(input);
      notifier.sendSmsOtp();
    }
  }

  void _switchToOtp(LoginNotifier notifier) {
    final input = _unifiedCtrl.text.trim();
    final isEmail = input.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(input);
    notifier.setMethod(isEmail ? AuthMethod.email : AuthMethod.sms);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, _listenToAuth);
    final s = ref.watch(loginProvider);
    final brand = ref.watch(brandConfigProvider);
    final notifier = ref.read(loginProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AuthBackground(
        brand: brand,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 48, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BrandIntro(brand: brand),
                      const SizedBox(height: 56),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topLeft,
                            children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey('${s.method}_${s.otpSent}'),
                          child: _buildDynamicFlow(s, brand, notifier),
                        ),
                      ),
                      const SizedBox(height: 64),
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

  Widget _buildDynamicFlow(LoginState s, BrandConfig brand, LoginNotifier notifier) {
    if (s.otpSent) {
      final isEmail = s.method == AuthMethod.email;
      return _OtpVerificationView(
        brand: brand,
        state: s,
        notifier: notifier,
        identifier: isEmail ? s.email : '${s.countryCode} ${s.phone}',
        isEmail: isEmail,
        onBack: () => _switchToOtp(notifier),
      );
    }

    if (s.method == AuthMethod.password) {
      return _PasswordView(
        s: s,
        brand: brand,
        n: notifier,
        unifiedCtrl: _unifiedCtrl,
        passCtrl: _passCtrl,
        nameCtrl: _nameCtrl,
        onForgotPassword: widget.onForgotPassword,
        allowRegistration: widget.allowRegistration,
        onSwitchToOtp: () => _switchToOtp(notifier),
      );
    }

    return _UnifiedInputView(
      brand: brand,
      state: s,
      controller: _unifiedCtrl,
      onContinue: () => _handleSmartSubmit(notifier),
      onSwitchToPassword: () => notifier.setMethod(AuthMethod.password),
    );
  }
}

class _BrandIntro extends StatelessWidget {
  final BrandConfig brand;
  const _BrandIntro({required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(brand.icon, color: theme.colorScheme.primary, size: 40),
        const SizedBox(height: 32),
        Text(
          brand.appName,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          brand.tagline ?? 'Secure workspace access',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _UnifiedInputView extends StatelessWidget {
  final BrandConfig brand;
  final LoginState state;
  final TextEditingController controller;
  final VoidCallback onContinue;
  final VoidCallback onSwitchToPassword;

  const _UnifiedInputView({
    required this.brand,
    required this.state,
    required this.controller,
    required this.onContinue,
    required this.onSwitchToPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PremiumTextField(
          controller: controller,
          hint: 'Email or phone',
          keyboardType: TextInputType.emailAddress,
          error: state.error,
          onSubmitted: (_) => onContinue(),
        ),
        const SizedBox(height: 40),
        AuthButton(text: 'Continue', isLoading: state.isLoading, onPressed: onContinue, brand: brand),
        const SizedBox(height: 24),
        _ActionLink(text: 'Use password instead', onTap: onSwitchToPassword),
      ],
    );
  }
}

class _OtpVerificationView extends StatelessWidget {
  final BrandConfig brand;
  final LoginState state;
  final LoginNotifier notifier;
  final String identifier;
  final bool isEmail;
  final VoidCallback onBack;

  const _OtpVerificationView({
    required this.brand,
    required this.state,
    required this.notifier,
    required this.identifier,
    required this.isEmail,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check ${isEmail ? 'inbox' : 'messages'}.',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        // Removed the duplicate identifier Text widget here
        const SizedBox(height: 40),
        OtpInputField(
          brand: brand,
          phone: identifier,
          identifierLabel: identifier, // Handled completely by your custom widget now
          error: state.error,
          isLoading: state.isLoading,
          resendCooldown: state.resendCooldown,
          onResend: isEmail ? notifier.sendEmailOtp : notifier.sendSmsOtp,
          onChangePhone: notifier.reset,
          onOtpChanged: notifier.setOtp,
          onVerify: isEmail ? notifier.verifyEmailOtp : notifier.verifySmsOtp,
        ),
        const SizedBox(height: 40),
        AuthButton(
          text: 'Verify',
          isLoading: state.isLoading,
          onPressed: isEmail ? notifier.verifyEmailOtp : notifier.verifySmsOtp,
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
  final TextEditingController unifiedCtrl, passCtrl, nameCtrl;
  final VoidCallback? onForgotPassword;
  final bool allowRegistration;
  final VoidCallback onSwitchToOtp;

  const _PasswordView({
    required this.s,
    required this.brand,
    required this.n,
    required this.unifiedCtrl,
    required this.passCtrl,
    required this.nameCtrl,
    required this.onForgotPassword,
    required this.allowRegistration,
    required this.onSwitchToOtp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: s.isRegistering
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _PremiumTextField(controller: nameCtrl, hint: 'Full name', onChanged: n.setName),
                )
              : const SizedBox.shrink(),
        ),
        _PremiumTextField(
          controller: unifiedCtrl,
          hint: 'Email or phone',
          keyboardType: TextInputType.emailAddress,
          onChanged: (val) {
            final isEmail = val.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(val);
            if (isEmail) {
              n.setPasswordIdentifier(PasswordIdentifier.email);
              n.setEmail(val);
            } else {
              n.setPasswordIdentifier(PasswordIdentifier.phone);
              n.setPhone(val);
            }
          },
        ),
        const SizedBox(height: 24),
        _PremiumTextField(
          controller: passCtrl,
          hint: 'Password',
          obscure: true,
          onChanged: n.setPassword,
          error: s.error,
        ),
        const SizedBox(height: 40),
        AuthButton(
          text: s.isRegistering ? 'Create Account' : 'Sign In',
          isLoading: s.isLoading,
          onPressed: () => s.isRegistering ? n.register() : n.loginWithPassword(),
          brand: brand,
        ),
        const SizedBox(height: 32),

        Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ActionLink(text: 'Use magic code', onTap: onSwitchToOtp),
            if (!s.isRegistering && onForgotPassword != null)
              _ActionLink(text: 'Forgot password?', onTap: onForgotPassword!, color: theme.colorScheme.primary),
            if (allowRegistration)
              _ActionLink(
                text: s.isRegistering ? 'Sign in instead' : 'Create account',
                onTap: n.toggleRegister,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? error;

  const _PremiumTextField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.obscure = false,
    this.keyboardType,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: theme.colorScheme.onSurface,
          ),
          cursorColor: theme.colorScheme.primary,
          cursorHeight: 24,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), width: 1.0),
            ),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0)),
            isDense: true,
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ActionLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const _ActionLink({required this.text, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
