import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_error_mapper.dart';
import 'package:shared_auth/src/presentation/widgets/auth_otp_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_password_strength.dart';
import 'package:shared_auth/src/presentation/widgets/auth_resend_action.dart';
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
    this.appPurpose = 'Manage workshop bookings, job cards, approvals, and service updates.',
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
  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _nameFocus = FocusNode();
  _SignInMode _mode = _SignInMode.password;

  String? _identifierError;
  String? _passwordError;
  String? _nameError;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
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
    } else if (!_isEmail(value) && value.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      error = t.validationEnterValidPhone;
    }
    setState(() {
      _identifierError = error;
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
    });
    return error != null;
  }

  bool _validateNameField() {
    final t = SharedAuthL10n.of(context);
    final value = _nameCtrl.text.trim();
    final error = value.isEmpty ? t.validationEnterName : null;
    setState(() {
      _nameError = error;
    });
    return error != null;
  }

  /// Hides any visible form-error snackbar. Called on every edit so a stale
  /// backend failure never lingers next to a corrected field.
  void _dismissSnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Shows a form-level failure as a snackbar with a retry action when the
  /// mapping marks it retryable (offline, 401, 500, 404). Field-mapped
  /// failures never reach here — they render inline on their field.
  void _showErrorSnack(AuthErrorDisplay display, VoidCallback onRetry) {
    showAppSnackBar(
      context,
      message: display.message,
      tone: AppSnackBarTone.danger,
      actionLabel: display.retryable
          ? SharedAuthL10n.of(context).authActionRetry
          : null,
      onAction: display.retryable ? onRetry : null,
      duration: const Duration(seconds: 5),
    );
  }

  /// Moves keyboard focus to the first relevant field after a failure, in
  /// visual order. The OTP cells own their focus (autofocus keeps entry
  /// there), so code failures rely on the OTP live region instead.
  void _focusFor(AuthErrorField field, {required bool includeName}) {
    final node = switch (field) {
      AuthErrorField.identifier => _identifierFocus,
      AuthErrorField.password => _passwordFocus,
      AuthErrorField.name => includeName ? _nameFocus : _identifierFocus,
      AuthErrorField.code || AuthErrorField.none => null,
    };
    if (node != null) node.requestFocus();
  }

  void _focusFirstLocalError({required bool includeName}) {
    if (includeName && _nameError != null) {
      _nameFocus.requestFocus();
      return;
    }
    if (_identifierError != null) {
      _identifierFocus.requestFocus();
      return;
    }
    if (_passwordError != null) _passwordFocus.requestFocus();
  }

  /// Surfaces a backend failure from [LoginState]: field-mapped failures land
  /// inline on their field, form-level failures land in a snackbar with
  /// retry. Values in the controllers are preserved — nothing is cleared.
  /// [otpInline] is true only for the verify step, where code-mapped copy
  /// renders on the OTP field in build; anywhere else it falls back to the
  /// snackbar so nothing reaches nowhere.
  void _surfaceApiError(
    LoginState s, {
    required VoidCallback onRetry,
    bool otpInline = false,
  }) {
    if (!mounted || s.error == null) return;
    final display = mapAuthFailure(
      kind: s.failureKind ?? AuthFailureKind.validation,
      message: s.error!,
      t: SharedAuthL10n.of(context),
    );
    switch (display.field) {
      case AuthErrorField.identifier:
        setState(() => _identifierError = display.message);
      case AuthErrorField.password:
        setState(() => _passwordError = display.message);
      case AuthErrorField.name:
        setState(() => _nameError = display.message);
      case AuthErrorField.code:
        if (!otpInline) _showErrorSnack(display, onRetry);
        // The OTP step reads the mapped copy in build (same grammar, no
        // duplicate text) — nothing to set here.
        break;
      case AuthErrorField.none:
        _showErrorSnack(display, onRetry);
    }
    _focusFor(display.focusField, includeName: s.isRegistering);
  }

  Future<void> _sendCode(LoginNotifier notifier) async {
    // Double-submit guard: the busy CTA is already disabled, this covers the
    // race between the tap and the first frame.
    if (ref.read(loginProvider).isLoading) return;
    if (_validateIdentifier()) {
      _focusFor(AuthErrorField.identifier, includeName: false);
      return;
    }
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
    _surfaceApiError(ref.read(loginProvider), onRetry: () => _sendCode(notifier));
  }

  /// Guarded OTP verification: blocks double-submits; code-mapped failures
  /// (expired vs incorrect distinct copy) render on the OTP field in build,
  /// everything else goes to the snackbar with retry.
  Future<void> _verifyCode(LoginNotifier notifier, bool email) async {
    if (ref.read(loginProvider).isLoading) return;
    if (email) {
      await notifier.verifyEmailOtp();
    } else {
      await notifier.verifySmsOtp();
    }
    _surfaceApiError(
      ref.read(loginProvider),
      onRetry: () => _verifyCode(notifier, email),
      otpInline: true,
    );
  }

  Future<void> _submitPassword(LoginState state, LoginNotifier notifier) async {
    if (ref.read(loginProvider).isLoading) return;
    var invalid = _validateIdentifier();
    invalid = _validatePasswordField(isCreate: state.isRegistering) || invalid;
    if (state.isRegistering) invalid = _validateNameField() || invalid;
    if (invalid) {
      _focusFirstLocalError(includeName: state.isRegistering);
      return;
    }
    _syncIdentifier(notifier);
    if (state.isRegistering) {
      await notifier.register();
    } else {
      await notifier.loginWithPassword();
    }
    _surfaceApiError(
      ref.read(loginProvider),
      onRetry: () => _submitPassword(ref.read(loginProvider), notifier),
    );
  }

  void _changeMode(_SignInMode mode, LoginNotifier notifier) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _identifierError = null;
      _passwordError = null;
      _nameError = null;
    });
    _dismissSnack();
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
      subtitle = state.otpSent ? t.loginOtpSentSubtitle : t.loginSecurityCodeSubtitle;
    } else {
      title = t.loginWelcomeTitle;
      subtitle = t.loginWelcomeSubtitle;
    }

    // One-time-code confirmation is an in-flow success banner rendered by
    // the code form below (phase-2 F-4): it sits above the resend row in the
    // scrollable column, so it can never overlay the countdown the way the
    // previous floating snackbar did. It shows exactly while otpSent holds
    // (once per send, again after the next send) and announces through the
    // banner's live region. Form-level API failures still surface as
    // snackbars with a retry action via _surfaceApiError.

    // Mapped OTP copy: expired vs incorrect codes get distinct text on the
    // OTP field itself (same grammar, no duplicate snackbar). Anything the
    // mapper routes elsewhere is snackbar-surfaced at submit time.
    final AuthErrorDisplay? otpDisplay = state.error == null
        ? null
        : mapAuthFailure(
            kind: state.failureKind ?? AuthFailureKind.validation,
            message: state.error!,
            t: t,
          );
    final String? otpError = otpDisplay?.field == AuthErrorField.code
        ? otpDisplay!.message
        : null;

    // Form-level leftovers from a backend failure that mapped to no field
    // are snackbar-only now (shown at submit time); inline vars here only
    // carry local validation or field-mapped API copy.
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
              // C9 method switch: the shared sunken-track segmented control
              // (surface chip + selected Semantics) replaces the bespoke
              // sliding-thumb switcher from before.
              AppSegmentedControl<_SignInMode>(
                options: [
                  AppSegmentedOption(
                    value: _SignInMode.password,
                    label: t.authMethodPassword,
                    icon: Icons.lock_outline_rounded,
                  ),
                  AppSegmentedOption(
                    value: _SignInMode.code,
                    label: t.authMethodCode,
                    icon: Icons.sms_outlined,
                  ),
                ],
                selected: _mode,
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
              children: [...previousChildren, if (currentChild != null) currentChild],
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
                    identifierFocus: _identifierFocus,
                    passwordFocus: _passwordFocus,
                    nameFocus: _nameFocus,
                    onIdentifierChanged: (v) {
                      _dismissSnack();
                      setState(() {
                        _identifierError = null;
                      });
                      _syncIdentifier(notifier);
                    },
                    onPasswordChanged: (v) {
                      _dismissSnack();
                      notifier.setPassword(v);
                      setState(() {
                        _passwordError = null;
                      });
                    },
                    onNameChanged: (v) {
                      _dismissSnack();
                      notifier.setName(v);
                      setState(() {
                        _nameError = null;
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
                    otpError: otpError,
                    identifierFocus: _identifierFocus,
                    onIdentifierChanged: (_) {
                      _dismissSnack();
                      setState(() {
                        _identifierError = null;
                      });
                    },
                    onOtpChanged: (v) {
                      _dismissSnack();
                      notifier.setOtp(v);
                    },
                    onCountryChanged: notifier.setCountryCode,
                    onSendCode: () => _sendCode(notifier),
                    onVerifyCode: () => _verifyCode(
                      notifier,
                      state.method == AuthMethod.email,
                    ),
                  )
                : _SignInPasswordForm(
                    key: const ValueKey('password'),
                    state: state,
                    notifier: notifier,
                    identifierCtrl: _identifierCtrl,
                    passwordCtrl: _passwordCtrl,
                    identifierError: _identifierError,
                    passwordError: _passwordError,
                    identifierFocus: _identifierFocus,
                    passwordFocus: _passwordFocus,
                    allowRegistration: widget.allowRegistration,
                    onForgotPassword: widget.onForgotPassword,
                    onSubmit: () => _submitPassword(state, notifier),
                    onIdentifierChanged: (v) {
                      _dismissSnack();
                      setState(() {
                        _identifierError = null;
                      });
                      _syncIdentifier(notifier);
                    },
                    onPasswordChanged: (v) {
                      _dismissSnack();
                      notifier.setPassword(v);
                      setState(() {
                        _passwordError = null;
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

/// Identifier row: searchable country prefix + the email/mobile field.
///
/// The prefix shows only for phone-like entry (LTR-locked dial code with
/// search); email entry hides it so `+971` never sits beside an inbox. The
/// notifier country code stays in sync through [onCountryChanged].
/// Phone-like entry additionally shows the per-country digit hint
/// (`loginPhoneFormatHint`) so the expected format is visible before submit.
/// Both branches render [AppInputField] (label above, 52 CTA rhythm, live
/// error region); the identifier value + caret stay LTR-locked via
/// `forceLtr` so mixed Arabic/Latin entry stays legible in RTL layouts.
class _IdentifierRow extends StatelessWidget {
  final TextEditingController controller;
  final LoginState state;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
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
    this.focusNode,
    this.onSubmitted,
  });

  bool _looksLikeEmail(String value) => value.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final phoneLike = !_looksLikeEmail(value.text.trim());
        if (!phoneLike) {
          return AppInputField(
            label: t.loginFieldIdentifier,
            hint: t.loginFieldIdentifierHint,
            controller: controller,
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            forceLtr: true,
            enabled: enabled,
            error: errorText,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          );
        }
        final theme = Theme.of(context);
        // Blank run in the field's own label style + the field's own label
        // gap, so the prefix stays aligned with the input at any text scale.
        final labelStyle = theme.textTheme.labelMedium;
        final country = phoneCountryFor(state.countryCode);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\u00A0', style: labelStyle),
                    const SizedBox(height: AppSpacing.labelValueGap),
                    AuthCountryCodeButton(value: state.countryCode, enabled: enabled, onChanged: onCountryChanged),
                  ],
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
              child: AppInputField(
                label: t.loginFieldIdentifier,
                hint: t.loginFieldIdentifierHint,
                controller: controller,
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                forceLtr: true,
                enabled: enabled,
                error: errorText,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              t.loginPhoneFormatHint(country.expectedLength, country.code),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
  final FocusNode? identifierFocus;
  final FocusNode? passwordFocus;
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
    this.identifierFocus,
    this.passwordFocus,
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
          _IdentifierRow(
            controller: identifierCtrl,
            state: state,
            errorText: identifierError,
            enabled: !busy,
            focusNode: identifierFocus,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
          ),
          const SizedBox(height: AppDimensions.s16),
          AppInputField(
            label: t.loginFieldPassword,
            hint: t.loginFieldPasswordHint,
            controller: passwordCtrl,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            passwordToggle: true,
            showPasswordTooltip: t.authShowPassword,
            hidePasswordTooltip: t.authHidePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            enabled: !busy,
            error: passwordError,
            focusNode: passwordFocus,
            onChanged: onPasswordChanged,
            onSubmitted: (_) => onSubmit(),
          ),
          if (onForgotPassword != null) ...[
            const SizedBox(height: AppDimensions.s4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              // UnconstrainedBox: AppTextButton's Container carries an
              // alignment and would otherwise expand to the column width
              // (centering the label); the link hugs its content at the
              // field end, as before.
              child: UnconstrainedBox(
                alignment: AlignmentDirectional.center,
                child: AppTextButton(
                    label: t.loginActionForgotPassword,
                    onPressed: busy ? null : onForgotPassword),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s24),
          AppPillButton.primary(
            label: t.loginActionContinue,
            busyLabel: t.authActionSigningIn,
            icon: Icons.arrow_forward_rounded,
            isLoading: state.isLoading,
            onPressed: onSubmit,
          ),
          if (allowRegistration) ...[
            const SizedBox(height: AppDimensions.s12),
            Center(
              child: AppTextButton(label: t.loginNewCustomer, onPressed: busy ? null : notifier.toggleRegister),
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
  final FocusNode? identifierFocus;
  final FocusNode? passwordFocus;
  final FocusNode? nameFocus;
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
    this.identifierFocus,
    this.passwordFocus,
    this.nameFocus,
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
          AppInputField(
            label: t.loginFieldFullName,
            hint: t.loginFieldFullNameHint,
            controller: nameCtrl,
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            enabled: !busy,
            error: nameError,
            focusNode: nameFocus,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: AppDimensions.s16),
          _IdentifierRow(
            controller: identifierCtrl,
            state: state,
            errorText: identifierError,
            enabled: !busy,
            focusNode: identifierFocus,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
          ),
          const SizedBox(height: AppDimensions.s16),
          AppInputField(
            label: t.loginFieldCreatePassword,
            hint: t.loginFieldCreatePasswordHint,
            controller: passwordCtrl,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            passwordToggle: true,
            showPasswordTooltip: t.authShowPassword,
            hidePasswordTooltip: t.authHidePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            enabled: !busy,
            error: passwordError,
            focusNode: passwordFocus,
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
          AppPillButton.primary(
            label: t.loginActionCreateAccount,
            busyLabel: t.authActionCreating,
            icon: Icons.arrow_forward_rounded,
            isLoading: state.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: AppDimensions.s8),
          Center(
            child: AppTextButton(label: t.loginAlreadyHaveAccount, onPressed: busy ? null : notifier.toggleRegister),
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
  final String? otpError;
  final FocusNode? identifierFocus;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onSendCode;
  final VoidCallback onVerifyCode;

  const _CodeForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.identifierCtrl,
    required this.identifierError,
    required this.otpError,
    this.identifierFocus,
    required this.onIdentifierChanged,
    required this.onOtpChanged,
    required this.onCountryChanged,
    required this.onSendCode,
    required this.onVerifyCode,
  });

  @override
  Widget build(BuildContext context) {
    final busy = state.isLoading;
    final t = SharedAuthL10n.of(context);

    if (state.otpSent) {
      final target = state.method == AuthMethod.email
          ? state.email
          : '${state.countryCode} ${state.phone}';
      return AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // In-flow sent confirmation (F-4): above the OTP field, so the
            // resend row below the CTA never sits under an overlay.
            AppBanner(
              kind: AppBannerKind.success,
              message: t.loginCodeSent(target),
            ),
            const SizedBox(height: AppDimensions.s20),
            AuthOtpField(
              onChanged: onOtpChanged,
              errorText: otpError,
              enabled: !busy,
              onSubmitted: (_) => onVerifyCode(),
            ),
            const SizedBox(height: AppDimensions.s24),
            AppPillButton.primary(
              label: t.loginActionVerifyCode,
              busyLabel: t.authActionVerifying,
              icon: Icons.verified_rounded,
              isLoading: state.isLoading,
              onPressed: onVerifyCode,
            ),
            const SizedBox(height: AppDimensions.s8),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppDimensions.s8,
              runSpacing: AppDimensions.s4,
              children: [
                AppTextButton(label: t.loginActionChangeIdentifier, onPressed: busy ? null : notifier.reset),
                AuthResendAction(cooldownSeconds: state.resendCooldown, busy: busy, onResend: onSendCode),
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
          _IdentifierRow(
            controller: identifierCtrl,
            state: state,
            errorText: identifierError,
            enabled: !busy,
            focusNode: identifierFocus,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
            onSubmitted: (_) => onSendCode(),
          ),
          const SizedBox(height: AppDimensions.s24),
          AppPillButton.primary(
            label: t.loginActionSendCode,
            busyLabel: t.authActionSending,
            icon: Icons.arrow_forward_rounded,
            isLoading: state.isLoading,
            onPressed: onSendCode,
          ),
        ],
      ),
    );
  }
}
