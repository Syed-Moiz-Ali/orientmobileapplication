import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';
import 'package:shared_core/shared_core.dart';

enum _SignInMode { password, code }

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
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  _SignInMode _mode = _SignInMode.password;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _listenToAuth(AuthState? previous, AuthState next) {
    if (next is AuthAuthenticated && previous is! AuthAuthenticated) {
      widget.onLoginSuccess();
    }
  }

  bool _isEmail(String value) {
    return value.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  void _syncIdentifier(LoginNotifier notifier) {
    final value = _identifierCtrl.text.trim();
    if (_isEmail(value)) {
      notifier.setPasswordIdentifier(PasswordIdentifier.email);
      notifier.setEmail(value);
    } else {
      notifier.setPasswordIdentifier(PasswordIdentifier.phone);
      notifier.setPhone(value);
    }
  }

  Future<void> _sendCode(LoginNotifier notifier) async {
    final value = _identifierCtrl.text.trim();
    if (_isEmail(value)) {
      notifier.setMethod(AuthMethod.email);
      notifier.setEmail(value);
      await notifier.sendEmailOtp();
    } else {
      notifier.setMethod(AuthMethod.sms);
      notifier.setPhone(value);
      await notifier.sendSmsOtp();
    }
  }

  Future<void> _submitPassword(LoginState state, LoginNotifier notifier) async {
    _syncIdentifier(notifier);
    if (state.isRegistering) {
      await notifier.register();
    } else {
      await notifier.loginWithPassword();
    }
  }

  void _changeMode(_SignInMode mode, LoginNotifier notifier) {
    setState(() => _mode = mode);
    notifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, _listenToAuth);

    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    return AuthShell(
      title: state.isRegistering
          ? 'Create account'
          : _mode == _SignInMode.code
          ? 'Security code'
          : 'Welcome back',
      subtitle: state.isRegistering
          ? 'Use the details registered with your workshop.'
          : _mode == _SignInMode.code
          ? 'Get a one-time code on your email or mobile.'
          : 'Sign in with your email or mobile number.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: AppMotion.standard,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: _mode == _SignInMode.password
                ? _PasswordForm(
                    key: const ValueKey('password'),
                    state: state,
                    notifier: notifier,
                    identifierCtrl: _identifierCtrl,
                    passwordCtrl: _passwordCtrl,
                    nameCtrl: _nameCtrl,
                    allowRegistration: widget.allowRegistration,
                    onForgotPassword: widget.onForgotPassword,
                    onUseCode: () => _changeMode(_SignInMode.code, notifier),
                    onSubmit: () => _submitPassword(state, notifier),
                    onIdentifierChanged: () => _syncIdentifier(notifier),
                  )
                : _CodeForm(
                    key: const ValueKey('code'),
                    state: state,
                    notifier: notifier,
                    identifierCtrl: _identifierCtrl,
                    onUsePassword: () =>
                        _changeMode(_SignInMode.password, notifier),
                    onSendCode: () => _sendCode(notifier),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PasswordForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final bool allowRegistration;
  final VoidCallback? onForgotPassword;
  final VoidCallback onUseCode;
  final VoidCallback onSubmit;
  final VoidCallback onIdentifierChanged;

  const _PasswordForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.allowRegistration,
    required this.onForgotPassword,
    required this.onUseCode,
    required this.onSubmit,
    required this.onIdentifierChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.error case final error?) ...[
          _InlineNotice(
            icon: Icons.error_outline_rounded,
            text: error,
            isError: true,
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        if (state.isRegistering) ...[
          AuthTextField(
            controller: nameCtrl,
            label: 'Full name',
            hint: 'Your name',
            icon: Icons.person_outline_rounded,
            onChanged: notifier.setName,
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        AuthTextField(
          controller: identifierCtrl,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => onIdentifierChanged(),
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthTextField(
          controller: passwordCtrl,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          onChanged: notifier.setPassword,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppDimensions.s10),
        if (!state.isRegistering && onForgotPassword != null)
          Row(
            children: [
              const Spacer(),
              AuthLinkButton(
                label: 'Forgot password?',
                onPressed: onForgotPassword,
              ),
            ],
          ),
        const SizedBox(height: AppDimensions.s16),
        AuthPrimaryButton(
          label: state.isRegistering ? 'Create account' : 'Continue',
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s16),
        Center(
          child: AuthLinkButton(
            label: 'Use one-time code instead',
            onPressed: onUseCode,
          ),
        ),
        if (allowRegistration) ...[
          const SizedBox(height: AppDimensions.s16),
          Center(
            child: AuthLinkButton(
              label: state.isRegistering
                  ? 'Already have an account? Sign in'
                  : 'New customer? Create an account',
              onPressed: notifier.toggleRegister,
            ),
          ),
        ],
      ],
    );
  }
}

class _CodeForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final VoidCallback onUsePassword;
  final VoidCallback onSendCode;

  const _CodeForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.onUsePassword,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    final email = state.method == AuthMethod.email;

    if (state.otpSent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InlineNotice(
            icon: Icons.mark_email_read_outlined,
            text: 'Code sent to ${email ? state.email : state.phone}.',
          ),
          const SizedBox(height: AppDimensions.s16),
          AuthOtpField(
            onChanged: notifier.setOtp,
            errorText: state.error,
            onSubmitted: (_) =>
                email ? notifier.verifyEmailOtp() : notifier.verifySmsOtp(),
          ),
          const SizedBox(height: AppDimensions.s20),
          AuthPrimaryButton(
            label: 'Verify code',
            icon: Icons.verified_rounded,
            isLoading: state.isLoading,
            onPressed: () =>
                email ? notifier.verifyEmailOtp() : notifier.verifySmsOtp(),
          ),
          const SizedBox(height: AppDimensions.s12),
          Wrap(
            spacing: AppDimensions.s12,
            runSpacing: AppDimensions.s4,
            children: [
              AuthLinkButton(
                label: 'Change email or mobile',
                onPressed: notifier.reset,
              ),
              AuthLinkButton(
                label: state.resendCooldown > 0
                    ? 'Resend in ${state.resendCooldown}s'
                    : 'Resend code',
                onPressed: state.resendCooldown > 0 ? null : onSendCode,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: identifierCtrl,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          errorText: state.error,
          onSubmitted: (_) => onSendCode(),
        ),
        const SizedBox(height: AppDimensions.s8),
        Text(
          'No password needed.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.s24),
        AuthPrimaryButton(
          label: 'Send code',
          icon: Icons.sms_outlined,
          isLoading: state.isLoading,
          onPressed: onSendCode,
        ),
        const SizedBox(height: AppDimensions.s16),
        Center(
          child: AuthLinkButton(
            label: 'Use password instead',
            onPressed: onUsePassword,
          ),
        ),
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isError;

  const _InlineNotice({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = isError ? colorScheme.error : colorScheme.primary;

    return Semantics(
      liveRegion: isError,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            accent.withValues(alpha: 0.08),
            colorScheme.surface,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: isError ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
