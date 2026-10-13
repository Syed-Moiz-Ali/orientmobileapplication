import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
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
  final String? securityNotice;

  const LoginView({
    super.key,
    required this.onLoginSuccess,
    this.onForgotPassword,
    this.allowRegistration = false,
    this.appName = 'Orient Workshop',
    this.appPurpose =
        'Manage workshop bookings, job cards, approvals, and service updates.',
    this.intendedUsers = 'Workshop users',
    this.securityNotice,
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
    if (_mode == mode) return;
    setState(() => _mode = mode);
    notifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, _listenToAuth);

    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    final t = SharedAuthL10n.of(context);
    final registering = state.isRegistering;
    final codeMode = !registering && _mode == _SignInMode.code;

    final String title;
    final String subtitle;
    if (registering) {
      title = t.loginRegisterTitle;
      subtitle = t.loginRegisterSubtitle;
    } else if (codeMode) {
      title = t.loginSecurityCodeTitle;
      subtitle = state.otpSent
          ? t.loginOtpSentSubtitle
          : t.loginSecurityCodeSubtitle;
    } else {
      title = t.loginWelcomeTitle;
      subtitle = t.loginWelcomeSubtitle;
    }

    return AuthShell(
      appName: widget.appName,
      appPurpose: widget.appPurpose,
      intendedUsers: widget.intendedUsers,
      securityNotice: widget.securityNotice,
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!registering) ...[
            _MethodSwitcher(
              mode: _mode,
              passwordLabel: t.authMethodPassword,
              codeLabel: t.authMethodCode,
              onChanged: (mode) => _changeMode(mode, notifier),
            ),
            const SizedBox(height: AppDimensions.s20),
          ],
          AnimatedSwitcher(
            duration: AppMotion.resolve(context, AppMotion.standard),
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
                    onSubmit: () => _submitPassword(state, notifier),
                    onIdentifierChanged: () => _syncIdentifier(notifier),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Two-option segmented control for the password / one-time-code sign-in
/// methods (spec §7). Preserves the exact [AuthMethod] transitions owned by
/// [LoginNotifier]; it only chooses which method the form presents.
class _MethodSwitcher extends StatelessWidget {
  final _SignInMode mode;
  final String passwordLabel;
  final String codeLabel;
  final ValueChanged<_SignInMode> onChanged;

  const _MethodSwitcher({
    required this.mode,
    required this.passwordLabel,
    required this.codeLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          _tab(
            context,
            passwordLabel,
            mode == _SignInMode.password,
            () => onChanged(_SignInMode.password),
          ),
          _tab(
            context,
            codeLabel,
            mode == _SignInMode.code,
            () => onChanged(_SignInMode.code),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: AnimatedContainer(
              duration: AppMotion.resolve(context, AppMotion.fast),
              curve: AppMotion.enter,
              constraints: const BoxConstraints(minHeight: 40),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s8,
                vertical: AppDimensions.s10,
              ),
              decoration: BoxDecoration(
                color: selected ? colors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(
                  color: selected ? colors.outlineVariant : Colors.transparent,
                ),
                boxShadow: selected ? AppDimensions.shadowSurface : null,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? colors.onSurface : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
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
    required this.onSubmit,
    required this.onIdentifierChanged,
  });

  @override
  Widget build(BuildContext context) {
    final busy = state.isLoading;
    final t = SharedAuthL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNoticeSlot(message: state.error),
        AuthTextField(
          controller: identifierCtrl,
          label: t.loginFieldIdentifier,
          hint: t.loginFieldIdentifierHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          textDirection: TextDirection.ltr,
          enabled: !busy,
          onChanged: (_) => onIdentifierChanged(),
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthTextField(
          controller: passwordCtrl,
          label: t.loginFieldPassword,
          hint: t.loginFieldPasswordHint,
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
            alignment: AlignmentDirectional.centerEnd,
            child: AuthLinkButton(
              label: t.loginActionForgotPassword,
              onPressed: busy ? null : onForgotPassword,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.s20),
        AuthPrimaryButton(
          label: t.loginActionContinue,
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSubmit,
        ),
        if (allowRegistration) ...[
          const SizedBox(height: AppDimensions.s12),
          Center(
            child: AuthLinkButton(
              label: t.loginNewCustomer,
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
    final t = SharedAuthL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNoticeSlot(message: state.error),
        AuthTextField(
          controller: nameCtrl,
          label: t.loginFieldFullName,
          hint: t.loginFieldFullNameHint,
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
          label: t.loginFieldIdentifier,
          hint: t.loginFieldIdentifierHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          textDirection: TextDirection.ltr,
          enabled: !busy,
          onChanged: (_) => onIdentifierChanged(),
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthTextField(
          controller: passwordCtrl,
          label: t.loginFieldCreatePassword,
          hint: t.loginFieldCreatePasswordHint,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !busy,
          labelTrailing: Text(
            t.loginMinCharacters,
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
          label: t.loginActionCreateAccount,
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s8),
        Center(
          child: AuthLinkButton(
            label: t.loginAlreadyHaveAccount,
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
  final VoidCallback onSendCode;

  const _CodeForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    final email = state.method == AuthMethod.email;
    final busy = state.isLoading;
    final t = SharedAuthL10n.of(context);

    if (state.otpSent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthNotice(
            icon: email ? Icons.mark_email_read_outlined : Icons.sms_outlined,
            text: t.loginCodeSent(email ? state.email : state.phone),
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
            label: t.loginActionVerifyCode,
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
                label: t.loginActionChangeIdentifier,
                onPressed: busy ? null : notifier.reset,
              ),
              AuthLinkButton(
                label: state.resendCooldown > 0
                    ? t.loginActionResendIn(state.resendCooldown)
                    : t.loginActionResendCode,
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
          label: t.loginFieldIdentifier,
          hint: t.loginFieldIdentifierHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.username],
          textDirection: TextDirection.ltr,
          enabled: !busy,
          onSubmitted: (_) => onSendCode(),
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthPrimaryButton(
          label: t.loginActionSendCode,
          icon: Icons.arrow_forward_rounded,
          isLoading: state.isLoading,
          onPressed: onSendCode,
        ),
      ],
    );
  }
}
