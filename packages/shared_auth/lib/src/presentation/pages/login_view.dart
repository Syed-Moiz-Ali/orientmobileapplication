import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/auth_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_notice.dart';
import 'package:shared_auth/src/presentation/widgets/auth_password_strength.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';
import 'package:shared_auth/src/presentation/widgets/phone_country.dart';
import 'package:shared_core/shared_core.dart';

enum _SignInMode { password, code }

/// Shared sign-in experience for all four Orient applications.
///
/// The same screen is configured per app through [appName], [appPurpose] and
/// [intendedUsers]; customer builds additionally enable [allowRegistration].
/// Business logic lives in [LoginNotifier] and is never duplicated here - this
/// widget only decides how the authentication task is presented.
///
/// Composition (rebuilt, Archetype 1): brand lockup → app context → title →
/// segmented password/code switcher → identifier/password fields with
/// field-level errors (LTR-locked) → primary CTA with distinct busy/disabled
/// states → secondary link → security notice. Registration is a progressive
/// disclosure of the same column, never a separate route.
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

  String? _identifierError;
  String? _passwordError;
  String? _nameError;

  /// Local validation summary announced as a live region alongside the
  /// field-level errors. Backend failures continue to arrive via
  /// `LoginState.error`; this covers only the pre-network checks so an empty
  /// submit is announced to screen readers the same moment the fields flag.
  String? _formError;

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

  /// Dual-identifier checks shared by password and code paths. Returns true
  /// when the field error was set (caller must stop); validation copy reuses
  /// the frozen login/forgot keys — no new strings.
  bool _validateIdentifier() {
    final t = SharedAuthL10n.of(context);
    final value = _identifierCtrl.text.trim();
    String? error;
    if (value.isEmpty) {
      error = t.validationEnterIdentifier;
    } else if (_isEmail(value) && !value.contains('@')) {
      error = t.validationEnterValidEmail;
    } else if (!_isEmail(value) &&
        value.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      error = t.validationEnterValidPhone;
    }
    setState(() {
      _identifierError = error;
      if (error != null) _formError ??= error;
    });
    return error != null;
  }

  bool _validatePasswordField({required bool isCreate}) {
    final t = SharedAuthL10n.of(context);
    final value = _passwordCtrl.text;
    String? error;
    if (value.isEmpty) {
      error = t.validationEnterPassword;
    } else if (isCreate && value.length < 6) {
      error = t.validationPassword6Chars;
    }
    setState(() {
      _passwordError = error;
      if (error != null) _formError ??= error;
    });
    return error != null;
  }

  bool _validateNameField() {
    final t = SharedAuthL10n.of(context);
    final value = _nameCtrl.text.trim();
    final error = value.isEmpty ? t.validationEnterName : null;
    setState(() {
      _nameError = error;
      if (error != null) _formError ??= error;
    });
    return error != null;
  }

  Future<void> _sendCode(LoginNotifier notifier) async {
    if (_validateIdentifier()) return;
    setState(() => _formError = null);
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
    var invalid = _validateIdentifier();
    invalid = _validatePasswordField(isCreate: state.isRegistering) || invalid;
    if (state.isRegistering) invalid = _validateNameField() || invalid;
    if (invalid) return;
    setState(() => _formError = null);
    _syncIdentifier(notifier);
    if (state.isRegistering) {
      await notifier.register();
    } else {
      await notifier.loginWithPassword();
    }
  }

  void _changeMode(_SignInMode mode, LoginNotifier notifier) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _identifierError = null;
      _passwordError = null;
      _nameError = null;
      _formError = null;
    });
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
                    identifierError: _identifierError,
                    passwordError: _passwordError,
                    nameError: _nameError,
                    banner: _formError ?? state.error,
                    onIdentifierChanged: (v) {
                      setState(() {
                        _identifierError = null;
                        _formError = null;
                      });
                      _syncIdentifier(notifier);
                    },
                    onPasswordChanged: (v) {
                      notifier.setPassword(v);
                      setState(() {
                        _passwordError = null;
                        _formError = null;
                      });
                    },
                    onNameChanged: (v) {
                      notifier.setName(v);
                      setState(() {
                        _nameError = null;
                        _formError = null;
                      });
                    },
                    onCountryChanged: notifier.setCountryCode,
                    onSubmit: () => _submitPassword(state, notifier),
                  )
                : codeMode
                ? _CodeForm(
                    key: const ValueKey('code'),
                    state: state,
                    notifier: notifier,
                    identifierCtrl: _identifierCtrl,
                    identifierError: _identifierError,
                    banner: _formError ?? state.error,
                    onIdentifierChanged: (_) => setState(() {
                      _identifierError = null;
                      _formError = null;
                    }),
                    onCountryChanged: notifier.setCountryCode,
                    onSendCode: () => _sendCode(notifier),
                  )
                : _SignInPasswordForm(
                    key: const ValueKey('password'),
                    state: state,
                    notifier: notifier,
                    identifierCtrl: _identifierCtrl,
                    passwordCtrl: _passwordCtrl,
                    identifierError: _identifierError,
                    passwordError: _passwordError,
                    banner: _formError ?? state.error,
                    allowRegistration: widget.allowRegistration,
                    onForgotPassword: widget.onForgotPassword,
                    onSubmit: () => _submitPassword(state, notifier),
                    onIdentifierChanged: (v) {
                      setState(() {
                        _identifierError = null;
                        _formError = null;
                      });
                      _syncIdentifier(notifier);
                    },
                    onPasswordChanged: (v) {
                      notifier.setPassword(v);
                      setState(() {
                        _passwordError = null;
                        _formError = null;
                      });
                    },
                    onCountryChanged: notifier.setCountryCode,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Two-option segmented control for the password / one-time-code sign-in
/// methods. Preserves the exact [AuthMethod] transitions owned by
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
              constraints: const BoxConstraints(minHeight: 48),
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

/// Identifier row: searchable country prefix + the email/mobile field.
///
/// The prefix shows only for phone-like entry (LTR-locked dial code with
/// search); email entry hides it so `+971` never sits beside an inbox. The
/// notifier country code stays in sync through [onCountryChanged].
class _IdentifierRow extends StatelessWidget {
  final TextEditingController controller;
  final LoginState state;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String>? onSubmitted;

  const _IdentifierRow({
    required this.controller,
    required this.state,
    required this.errorText,
    required this.enabled,
    required this.onChanged,
    required this.onCountryChanged,
    this.onSubmitted,
  });

  bool _looksLikeEmail(String value) =>
      value.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final phoneLike = !_looksLikeEmail(value.text.trim());
        if (!phoneLike) {
          return AuthTextField(
            controller: controller,
            label: t.loginFieldIdentifier,
            hint: t.loginFieldIdentifierHint,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            textDirection: TextDirection.ltr,
            enabled: enabled,
            errorText: errorText,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          );
        }
        final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.3,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mirrors the field's own label row (same style + gap) with a
            // blank run so the 48px prefix stays aligned with the input at
            // any text scale — no pixel guesses.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\u00A0', style: labelStyle),
                const SizedBox(height: AppDimensions.s8),
                AuthCountryCodeButton(
                  value: state.countryCode,
                  enabled: enabled,
                  onChanged: onCountryChanged,
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: AuthTextField(
                controller: controller,
                label: t.loginFieldIdentifier,
                hint: t.loginFieldIdentifierHint,
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                textDirection: TextDirection.ltr,
                enabled: enabled,
                errorText: errorText,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SignInPasswordForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final TextEditingController passwordCtrl;
  final String? identifierError;
  final String? passwordError;
  final String? banner;
  final bool allowRegistration;
  final VoidCallback? onForgotPassword;
  final VoidCallback onSubmit;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onCountryChanged;

  const _SignInPasswordForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.passwordCtrl,
    required this.identifierError,
    required this.passwordError,
    required this.banner,
    required this.allowRegistration,
    required this.onForgotPassword,
    required this.onSubmit,
    required this.onIdentifierChanged,
    required this.onPasswordChanged,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final busy = state.isLoading;
    final t = SharedAuthL10n.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthNoticeSlot(message: banner),
          _IdentifierRow(
            controller: identifierCtrl,
            state: state,
            errorText: identifierError,
            enabled: !busy,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
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
            errorText: passwordError,
            onChanged: onPasswordChanged,
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
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController nameCtrl;
  final String? identifierError;
  final String? passwordError;
  final String? nameError;
  final String? banner;
  final VoidCallback onSubmit;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onCountryChanged;

  const _RegisterForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
    required this.identifierError,
    required this.passwordError,
    required this.nameError,
    required this.banner,
    required this.onSubmit,
    required this.onIdentifierChanged,
    required this.onPasswordChanged,
    required this.onNameChanged,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = state.isLoading;
    final t = SharedAuthL10n.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthNoticeSlot(message: banner),
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
            errorText: nameError,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: AppDimensions.s16),
          _IdentifierRow(
            controller: identifierCtrl,
            state: state,
            errorText: identifierError,
            enabled: !busy,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
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
            errorText: passwordError,
            belowField: AuthPasswordStrength(password: state.password),
            labelTrailing: Text(
              t.loginMinCharacters,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: onPasswordChanged,
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
      ),
    );
  }
}

class _CodeForm extends StatelessWidget {
  final LoginState state;
  final LoginNotifier notifier;
  final TextEditingController identifierCtrl;
  final String? identifierError;
  final String? banner;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onSendCode;

  const _CodeForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.identifierError,
    required this.banner,
    required this.onIdentifierChanged,
    required this.onCountryChanged,
    required this.onSendCode,
  });

  @override
  Widget build(BuildContext context) {
    final email = state.method == AuthMethod.email;
    final busy = state.isLoading;
    final t = SharedAuthL10n.of(context);

    if (state.otpSent) {
      return AutofillGroup(
        child: Column(
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
        ),
      );
    }

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthNoticeSlot(message: banner),
          _IdentifierRow(
            controller: identifierCtrl,
            state: state,
            errorText: identifierError,
            enabled: !busy,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
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
      ),
    );
  }
}
