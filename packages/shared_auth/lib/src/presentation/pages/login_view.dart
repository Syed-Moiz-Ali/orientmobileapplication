import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/auth_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_notice.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';
import 'package:shared_core/shared_core.dart';

enum _SignInMode { password, code }

/// Shared sign-in experience for all four Orient applications.
///
/// The same screen is configured per app through [appName], [appPurpose] and
/// [intendedUsers]; customer builds additionally enable [allowRegistration].
/// Business logic lives in [LoginNotifier] and is never duplicated here - this
/// widget only decides how the authentication task is presented.
class LoginView extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onForgotPassword;
  final bool allowRegistration;
  final String appName;
  final String appPurpose;
  final String intendedUsers;

  const LoginView({
    super.key,
    required this.onLoginSuccess,
    this.onForgotPassword,
    this.allowRegistration = false,
    this.appName = 'Orient Workshop',
    this.appPurpose =
        'Manage workshop bookings, job cards, approvals, and service updates.',
    this.intendedUsers = 'Workshop users',
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
    final registering = state.isRegistering;
    final codeMode = !registering && _mode == _SignInMode.code;

    final String title;
    final String subtitle;
    if (registering) {
      title = 'Create your account';
      subtitle = 'Set up your account in under a minute.';
    } else if (codeMode) {
      title = 'Security code';
      subtitle = state.otpSent
          ? 'Enter the 6-digit code we sent you.'
          : 'Get a one-time code on your email or mobile.';
    } else {
      title = 'Welcome back';
      subtitle = 'Sign in with your email or mobile number.';
    }

    return AuthShell(
      appName: widget.appName,
      appPurpose: widget.appPurpose,
      intendedUsers: widget.intendedUsers,
      title: title,
      subtitle: subtitle,
      child: AnimatedSwitcher(
        duration: AppMotion.standard,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        child: registering
            ? _RegisterForm(
                key: const ValueKey('register'),
                state: state,
                notifier: notifier,
                identifierCtrl: _identifierCtrl,
                passwordCtrl: _passwordCtrl,
                nameCtrl: _nameCtrl,
                onSubmit: () => _submitPassword(state, notifier),
                onIdentifierChanged: () => _syncIdentifier(notifier),
              )
            : codeMode
            ? _CodeForm(
                key: const ValueKey('code'),
                state: state,
                notifier: notifier,
                identifierCtrl: _identifierCtrl,
                onUsePassword: () =>
                    _changeMode(_SignInMode.password, notifier),
                onSendCode: () => _sendCode(notifier),
              )
            : _SignInPasswordForm(
                key: const ValueKey('password'),
                state: state,
                notifier: notifier,
                identifierCtrl: _identifierCtrl,
                passwordCtrl: _passwordCtrl,
                allowRegistration: widget.allowRegistration,
                onForgotPassword: widget.onForgotPassword,
                onUseCode: () => _changeMode(_SignInMode.code, notifier),
                onSubmit: () => _submitPassword(state, notifier),
                onIdentifierChanged: () => _syncIdentifier(notifier),
              ),
      ),
    );
  }
}

class _SignInPasswordForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final TextEditingController passwordCtrl;
  final bool allowRegistration;
  final VoidCallback? onForgotPassword;
  final VoidCallback onUseCode;
  final VoidCallback onSubmit;
  final VoidCallback onIdentifierChanged;

  const _SignInPasswordForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.passwordCtrl,
    required this.allowRegistration,
    required this.onForgotPassword,
    required this.onUseCode,
    required this.onSubmit,
    required this.onIdentifierChanged,
  });

  @override
  Widget build(BuildContext context) {
    final busy = state.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNoticeSlot(message: state.error),
        AuthTextField(
          controller: identifierCtrl,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          enabled: !busy,
          onChanged: (_) => onIdentifierChanged(),
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthTextField(
          controller: passwordCtrl,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          enabled: !busy,
          onChanged: notifier.setPassword,
          onSubmitted: (_) => onSubmit(),
        ),
        if (onForgotPassword != null) ...[
          const SizedBox(height: AppDimensions.s4),
          Align(
            alignment: Alignment.centerRight,
            child: AuthLinkButton(
              label: 'Forgot password?',
              onPressed: busy ? null : onForgotPassword,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.s20),
        AuthPrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s12),
        Center(
          child: AuthLinkButton(
            label: 'Use one-time code instead',
            icon: Icons.password_rounded,
            onPressed: busy ? null : onUseCode,
          ),
        ),
        if (allowRegistration) ...[
          const SizedBox(height: AppDimensions.s8),
          Center(
            child: AuthLinkButton(
              label: 'New customer? Create an account',
              onPressed: busy ? null : notifier.toggleRegister,
            ),
          ),
        ],
      ],
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onIdentifierChanged;

  const _RegisterForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.onSubmit,
    required this.onIdentifierChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = state.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNoticeSlot(message: state.error),
        AuthTextField(
          controller: nameCtrl,
          label: 'Full name',
          hint: 'Your full name',
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          enabled: !busy,
          onChanged: notifier.setName,
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthTextField(
          controller: identifierCtrl,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          enabled: !busy,
          onChanged: (_) => onIdentifierChanged(),
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthTextField(
          controller: passwordCtrl,
          label: 'Create a password',
          hint: 'At least 6 characters',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !busy,
          labelTrailing: Text(
            'Min. 6 characters',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          onChanged: notifier.setPassword,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppDimensions.s24),
        AuthPrimaryButton(
          label: 'Create account',
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s8),
        Center(
          child: AuthLinkButton(
            label: 'Already have an account? Sign in',
            onPressed: busy ? null : notifier.toggleRegister,
          ),
        ),
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
    final busy = state.isLoading;

    if (state.otpSent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthNotice(
            icon: email ? Icons.mark_email_read_outlined : Icons.sms_outlined,
            text: 'Code sent to ${email ? state.email : state.phone}.',
          ),
          const SizedBox(height: AppDimensions.s20),
          AuthOtpField(
            onChanged: notifier.setOtp,
            errorText: state.error,
            enabled: !busy,
            onSubmitted: (_) =>
                email ? notifier.verifyEmailOtp() : notifier.verifySmsOtp(),
          ),
          const SizedBox(height: AppDimensions.s24),
          AuthPrimaryButton(
            label: 'Verify code',
            icon: Icons.verified_rounded,
            isLoading: state.isLoading,
            onPressed: () =>
                email ? notifier.verifyEmailOtp() : notifier.verifySmsOtp(),
          ),
          const SizedBox(height: AppDimensions.s8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s4,
            children: [
              AuthLinkButton(
                label: 'Change email or mobile',
                onPressed: busy ? null : notifier.reset,
              ),
              AuthLinkButton(
                label: state.resendCooldown > 0
                    ? 'Resend in ${state.resendCooldown}s'
                    : 'Resend code',
                subtle: true,
                onPressed: state.resendCooldown > 0 || busy ? null : onSendCode,
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNoticeSlot(message: state.error),
        AuthTextField(
          controller: identifierCtrl,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.username],
          enabled: !busy,
          onSubmitted: (_) => onSendCode(),
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthPrimaryButton(
          label: 'Send code',
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSendCode,
        ),
        const SizedBox(height: AppDimensions.s12),
        Center(
          child: AuthLinkButton(
            label: 'Use password instead',
            icon: Icons.lock_outline_rounded,
            onPressed: busy ? null : onUsePassword,
          ),
        ),
      ],
    );
  }
}
