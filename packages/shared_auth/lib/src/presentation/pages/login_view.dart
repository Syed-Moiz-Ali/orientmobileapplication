import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_state.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_auth/src/presentation/widgets/auth_error_mapper.dart';
import 'package:shared_auth/src/presentation/widgets/auth_otp_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_password_strength.dart';
import 'package:shared_auth/src/presentation/widgets/auth_step_brand.dart';
import 'package:shared_auth/src/presentation/widgets/auth_step_resend.dart';
import 'package:shared_auth/src/presentation/widgets/phone_country.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

/// View-level steps of the sign-in step flow. UI state only — every
/// transition maps onto existing [LoginNotifier] calls; no logic change.
///
/// * [identifier] ("Log in or sign up"): identifier field only. Continue
///   advances with NO API call (local validation + setter sync only).
/// * [password] ("Welcome back", password-first for all apps): password field
///   + Continue → [LoginNotifier.loginWithPassword].
/// * [code] ("Confirm your number"): token-styled Pinput, masked destination,
///   resend link + countdown, Back. Reached by sending a code; Verify (plus
///   auto-verify on complete) → verify methods.
/// * [registerName]/[registerContact]/[registerPassword] (R1/R2/R3,
///   customer only): one field group per step; final CTA → single
///   [LoginNotifier.register] with all fields.
enum _LoginStep {
  identifier,
  password,
  code,
  registerName,
  registerContact,
  registerPassword,
}

/// Shared sign-in experience for all four Orient applications.
///
/// The same screen is configured per app through [appName], [appPurpose] and
/// [intendedUsers]; customer builds additionally enable [allowRegistration].
/// Business logic lives in [LoginNotifier] and is never duplicated here - this
/// widget only decides how the authentication task is presented.
///
/// Composition (C16 step flow): one question per step in [AppStepScaffold]
/// (thin progress, back arrow, headlineLarge question, supporting line,
/// input, sticky full-width CTA), `AppOrDivider` + `AppAltAuthRow` on Step 1
/// for alternative paths, muted trust line under the Step 1 CTAs. Password is
/// the default second step for ALL apps; the code path is the secondary
/// alternative. Registration is its own 3-step flow behind
/// "New here? Create account".
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

  _LoginStep _step = _LoginStep.identifier;

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
  /// snackbar so nothing reaches nowhere. Returns the mapping (null when
  /// there was nothing to surface) so submit paths can route a field-mapped
  /// failure back to the step that owns its field.
  AuthErrorDisplay? _surfaceApiError(
    LoginState s, {
    required VoidCallback onRetry,
    bool otpInline = false,
  }) {
    if (!mounted || s.error == null) return null;
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
    return display;
  }

  // -------------------------------------------------------------------------
  // Step transitions (view-level UI state only).
  //
  // Step 1 / R1 / R2 Continue handlers perform LOCAL validation (+ setter
  // sync) and advance with ZERO API calls. The notifier's send/verify/login/
  // register methods are called only from the password step, the code step,
  // and the final register step.
  // -------------------------------------------------------------------------

  /// Step 1 Continue: local identifier validation only, then setter sync and
  /// advance to the password step. Fires ZERO API calls by construction.
  void _continueFromIdentifier(LoginNotifier notifier) {
    if (ref.read(loginProvider).isLoading) return;
    if (_validateIdentifier()) {
      _focusFor(AuthErrorField.identifier, includeName: false);
      return;
    }
    _syncIdentifier(notifier);
    _dismissSnack();
    setState(() {
      _step = _LoginStep.password;
      _passwordError = null;
    });
  }

  /// R1 Continue: local name validation only, no API call.
  void _continueFromName() {
    if (ref.read(loginProvider).isLoading) return;
    if (_validateNameField()) {
      _nameFocus.requestFocus();
      return;
    }
    _dismissSnack();
    setState(() => _step = _LoginStep.registerContact);
  }

  /// R2 Continue: local identifier validation + setter sync, no API call.
  void _continueFromContact(LoginNotifier notifier) {
    if (ref.read(loginProvider).isLoading) return;
    if (_validateIdentifier()) {
      _focusFor(AuthErrorField.identifier, includeName: true);
      return;
    }
    _syncIdentifier(notifier);
    _dismissSnack();
    setState(() => _step = _LoginStep.registerPassword);
  }

  void _enterRegister(LoginNotifier notifier) {
    if (ref.read(loginProvider).isLoading) return;
    if (!ref.read(loginProvider).isRegistering) {
      notifier.toggleRegister();
    }
    _dismissSnack();
    setState(() {
      _step = _LoginStep.registerName;
      _identifierError = null;
      _passwordError = null;
      _nameError = null;
    });
  }

  void _exitRegisterToIdentifier(LoginNotifier notifier) {
    if (ref.read(loginProvider).isRegistering) {
      notifier.toggleRegister();
    }
    _dismissSnack();
    setState(() {
      _step = _LoginStep.identifier;
      _identifierError = null;
      _passwordError = null;
      _nameError = null;
    });
  }

  /// View-level back: step change only. Controllers + notifier values are
  /// preserved — nothing is cleared or re-fetched.
  void _goBack(LoginNotifier notifier) {
    _dismissSnack();
    setState(() {
      switch (_step) {
        case _LoginStep.identifier:
          break;
        case _LoginStep.password:
          _step = _LoginStep.identifier;
          _passwordError = null;
        case _LoginStep.code:
          _step = _LoginStep.password;
        case _LoginStep.registerName:
          _exitRegisterToIdentifier(notifier);
          return;
        case _LoginStep.registerContact:
          _step = _LoginStep.registerName;
          _identifierError = null;
        case _LoginStep.registerPassword:
          _step = _LoginStep.registerContact;
          _passwordError = null;
      }
    });
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
    if (!mounted) return;
    final s = ref.read(loginProvider);
    if (s.otpSent) {
      _dismissSnack();
      setState(() => _step = _LoginStep.code);
    }
    _surfaceApiError(s, onRetry: () => _sendCode(notifier));
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
    if (!mounted) return;
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
    if (!mounted) return;
    final display = _surfaceApiError(
      ref.read(loginProvider),
      onRetry: () => _submitPassword(ref.read(loginProvider), notifier),
    );
    // A field-mapped failure belongs to the step that owns its field. The
    // password step and R3 carry no identifier/name fields, so route there —
    // view state only, controllers + notifier values preserved — instead of
    // letting the copy reach nowhere. Everything else stays put.
    if (display != null && mounted) {
      final _LoginStep? target = switch (display.field) {
        AuthErrorField.identifier when _step == _LoginStep.password =>
          _LoginStep.identifier,
        AuthErrorField.identifier when _step == _LoginStep.registerPassword =>
          _LoginStep.registerContact,
        AuthErrorField.name when _step == _LoginStep.registerPassword =>
          _LoginStep.registerName,
        _ => null,
      };
      if (target != null) {
        final includeName = ref.read(loginProvider).isRegistering;
        setState(() => _step = target);
        // The target field mounts on the next frame; move focus then so the
        // re-routed error takes keyboard + screen-reader focus like any
        // field-mapped failure.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _focusFor(display.focusField, includeName: includeName);
        });
      }
    }
  }

  String _maskedTarget({
    required bool isEmail,
    required String email,
    required String phone,
    required String countryCode,
  }) {
    if (isEmail) {
      final at = email.indexOf('@');
      if (at <= 0) return email;
      final local = email.substring(0, at);
      final visible = local.length <= 2
          ? local.substring(0, 1)
          : local.substring(0, 2);
      return '$visible\u2022\u2022\u2022\u2022${email.substring(at)}';
    }
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 5) return '$countryCode $digits';
    return '$countryCode \u2022\u2022\u2022 \u2022\u2022\u2022 ${digits.substring(digits.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, _listenToAuth);

    // Selective watches: every slice the step needs EXCEPT the resend
    // cooldown. The countdown ticks rebuild [LoginResendRow] alone (it
    // selects resendCooldown itself) — never this whole step.
    final notifier = ref.read(loginProvider.notifier);
    final isLoading = ref.watch(loginProvider.select((s) => s.isLoading));
    final error = ref.watch(loginProvider.select((s) => s.error));
    final failureKind = ref.watch(loginProvider.select((s) => s.failureKind));
    final method = ref.watch(loginProvider.select((s) => s.method));
    final countryCode = ref.watch(
      loginProvider.select((s) => s.countryCode),
    );
    final passwordValue = ref.watch(
      loginProvider.select((s) => s.password),
    );
    final isRegistering = ref.watch(
      loginProvider.select((s) => s.isRegistering),
    );
    final t = SharedAuthL10n.of(context);

    // Mapped OTP copy: expired vs incorrect codes get distinct text on the
    // OTP field itself (same grammar, no duplicate snackbar).
    final AuthErrorDisplay? otpDisplay = error == null
        ? null
        : mapAuthFailure(
            kind: failureKind ?? AuthFailureKind.validation,
            message: error,
            t: t,
          );
    final String? otpError = otpDisplay?.field == AuthErrorField.code
        ? otpDisplay!.message
        : null;

    final identifierValue = _identifierCtrl.text.trim();

    final (title, subtitle, ctaLabel, busyLabel, step, total, onCta, onBack) =
        switch (_step) {
      _LoginStep.identifier => (
        t.loginStepIdentifierTitle,
        t.loginStepIdentifierSubtitle,
        t.loginActionContinue,
        t.authActionSending,
        1,
        2,
        () => _continueFromIdentifier(notifier),
        null as VoidCallback?,
      ),
      _LoginStep.password => (
        t.loginStepPasswordTitle,
        t.loginStepPasswordSubtitle(
          identifierValue.isEmpty ? t.loginFieldIdentifier : identifierValue,
        ),
        t.loginActionContinue,
        t.authActionSigningIn,
        2,
        2,
        () => _submitPassword(ref.read(loginProvider), notifier),
        () => _goBack(notifier),
      ),
      _LoginStep.code => (
        t.loginStepCodeTitle,
        t.loginStepCodeSubtitle,
        t.loginActionVerifyCode,
        t.authActionVerifying,
        2,
        2,
        () => _verifyCode(notifier, method == AuthMethod.email),
        () => _goBack(notifier),
      ),
      _LoginStep.registerName => (
        t.loginStepRegisterNameTitle,
        t.loginStepRegisterNameSubtitle,
        t.loginActionContinue,
        t.authActionSending,
        1,
        3,
        _continueFromName,
        () => _goBack(notifier),
      ),
      _LoginStep.registerContact => (
        t.loginStepRegisterContactTitle,
        t.loginStepRegisterContactSubtitle,
        t.loginActionContinue,
        t.authActionSending,
        2,
        3,
        () => _continueFromContact(notifier),
        () => _goBack(notifier),
      ),
      _LoginStep.registerPassword => (
        t.loginStepRegisterPasswordTitle,
        t.loginStepRegisterPasswordSubtitle,
        t.loginActionCreateAccount,
        t.authActionCreating,
        3,
        3,
        () => _submitPassword(ref.read(loginProvider), notifier),
        () => _goBack(notifier),
      ),
    };

    final content = switch (_step) {
      _LoginStep.identifier => _IdentifierStepContent(
        identifierCtrl: _identifierCtrl,
        countryCode: countryCode,
        identifierError: _identifierError,
        enabled: !isLoading,
        identifierFocus: _identifierFocus,
        allowRegistration: widget.allowRegistration && isRegistering == false,
        onIdentifierChanged: (v) {
          _dismissSnack();
          setState(() => _identifierError = null);
          _syncIdentifier(notifier);
        },
        onCountryChanged: notifier.setCountryCode,
        onSubmitted: () => _continueFromIdentifier(notifier),
        onUseCode: () => _sendCode(notifier),
        onCreateAccount: () => _enterRegister(notifier),
        securityNotice: widget.securityNotice,
      ),
      _LoginStep.password => _PasswordStepContent(
        identifierRecap: identifierValue,
        passwordCtrl: _passwordCtrl,
        passwordError: _passwordError,
        enabled: !isLoading,
        passwordFocus: _passwordFocus,
        onForgotPassword: widget.onForgotPassword,
        onPasswordChanged: (v) {
          _dismissSnack();
          notifier.setPassword(v);
          setState(() => _passwordError = null);
        },
        onSubmitted: () =>
            _submitPassword(ref.read(loginProvider), notifier),
        onUseCode: () => _sendCode(notifier),
      ),
      _LoginStep.code => _CodeStepContent(
        isEmail: method == AuthMethod.email,
        maskedTarget: _maskedTarget(
          isEmail: method == AuthMethod.email,
          email: identifierValue,
          phone: identifierValue,
          countryCode: countryCode,
        ),
        otpError: otpError,
        enabled: !isLoading,
        busy: isLoading,
        onOtpChanged: (v) {
          _dismissSnack();
          notifier.setOtp(v);
        },
        onOtpSubmitted: (_) =>
            _verifyCode(notifier, method == AuthMethod.email),
        onResend: () => _sendCode(notifier),
        onUsePassword: () => setState(() => _step = _LoginStep.password),
      ),
      _LoginStep.registerName => _RegisterNameContent(
        nameCtrl: _nameCtrl,
        nameError: _nameError,
        enabled: !isLoading,
        nameFocus: _nameFocus,
        onNameChanged: (v) {
          _dismissSnack();
          notifier.setName(v);
          setState(() => _nameError = null);
        },
        onSubmitted: _continueFromName,
      ),
      _LoginStep.registerContact => _RegisterContactContent(
        identifierCtrl: _identifierCtrl,
        countryCode: countryCode,
        identifierError: _identifierError,
        enabled: !isLoading,
        identifierFocus: _identifierFocus,
        onIdentifierChanged: (v) {
          _dismissSnack();
          setState(() => _identifierError = null);
          _syncIdentifier(notifier);
        },
        onCountryChanged: notifier.setCountryCode,
        onSubmitted: () => _continueFromContact(notifier),
      ),
      _LoginStep.registerPassword => _RegisterPasswordContent(
        passwordCtrl: _passwordCtrl,
        passwordValue: passwordValue,
        passwordError: _passwordError,
        enabled: !isLoading,
        passwordFocus: _passwordFocus,
        onPasswordChanged: (v) {
          _dismissSnack();
          notifier.setPassword(v);
          setState(() => _passwordError = null);
        },
        onSubmitted: () =>
            _submitPassword(ref.read(loginProvider), notifier),
      ),
    };

    // Centered 480 column for every width; the brand panel appears ONLY on
    // split widths beside the step column.
    final Widget stepShell = AppStepScaffold(
      step: step,
      totalSteps: total,
      backLabel: t.loginStepBack,
      onBack: onBack,
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      busyLabel: busyLabel,
      onCta: onCta,
      isLoading: isLoading,
      progressSemanticLabel: t.loginStepProgress(step, total),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: content,
        ),
      ),
    );

    return AppAdaptiveBuilder(
      builder: (context, adaptive) {
        final split = adaptive.isExpanded || adaptive.isLarge;
        if (!split) return stepShell;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: AuthStepBrandPanel(
                    appName: widget.appName,
                    appPurpose: widget.appPurpose,
                    intendedUsers: widget.intendedUsers,
                    securityNotice: widget.securityNotice,
                  ),
                ),
                Expanded(flex: 6, child: stepShell),
              ],
            ),
          ),
        );
      },
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
  final String countryCode;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String>? onSubmitted;

  const _IdentifierRow({
    required this.controller,
    required this.countryCode,
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
        final country = phoneCountryFor(countryCode);
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
                    AuthCountryCodeButton(value: countryCode, enabled: enabled, onChanged: onCountryChanged),
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

/// Step 1 content: identifier field + sticky-CTA-adjacent alternative paths
/// (code row, register row) + muted trust line.
class _IdentifierStepContent extends StatelessWidget {
  final TextEditingController identifierCtrl;
  final String countryCode;
  final String? identifierError;
  final bool enabled;
  final FocusNode? identifierFocus;
  final bool allowRegistration;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onUseCode;
  final VoidCallback onCreateAccount;
  final String? securityNotice;

  const _IdentifierStepContent({
    required this.identifierCtrl,
    required this.countryCode,
    required this.identifierError,
    required this.enabled,
    required this.identifierFocus,
    required this.allowRegistration,
    required this.onIdentifierChanged,
    required this.onCountryChanged,
    required this.onSubmitted,
    required this.onUseCode,
    required this.onCreateAccount,
    required this.securityNotice,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentifierRow(
            controller: identifierCtrl,
            countryCode: countryCode,
            errorText: identifierError,
            enabled: enabled,
            focusNode: identifierFocus,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
          const SizedBox(height: AppDimensions.s20),
          AppOrDivider(label: t.loginStepOr),
          const SizedBox(height: AppDimensions.s12),
          AppAltAuthRow(
            label: t.loginStepUseCodeInstead,
            icon: Icons.sms_outlined,
            onTap: enabled ? onUseCode : null,
          ),
          if (allowRegistration) ...[
            const SizedBox(height: AppDimensions.s8),
            AppAltAuthRow(
              label: t.loginStepCreateAccountRow,
              icon: Icons.person_add_alt_rounded,
              onTap: enabled ? onCreateAccount : null,
            ),
          ],
          const SizedBox(height: AppDimensions.s20),
          SecurityBadge(text: securityNotice),
        ],
      ),
    );
  }
}

class _PasswordStepContent extends StatelessWidget {
  final String identifierRecap;
  final TextEditingController passwordCtrl;
  final String? passwordError;
  final bool enabled;
  final FocusNode? passwordFocus;
  final VoidCallback? onForgotPassword;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onUseCode;

  const _PasswordStepContent({
    required this.identifierRecap,
    required this.passwordCtrl,
    required this.passwordError,
    required this.enabled,
    required this.passwordFocus,
    required this.onForgotPassword,
    required this.onPasswordChanged,
    required this.onSubmitted,
    required this.onUseCode,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            enabled: enabled,
            error: passwordError,
            focusNode: passwordFocus,
            onChanged: onPasswordChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
          if (onForgotPassword != null) ...[
            const SizedBox(height: AppDimensions.s4),
            // End-aligned quiet link. A bounded Row (not UnconstrainedBox)
            // keeps the button inside the column at 320 px / 1.3x, and the
            // Flexible lets long translations wrap instead of overflowing.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: AppTextButton(
                    label: t.loginActionForgotPassword,
                    onPressed: enabled ? onForgotPassword : null,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.s12),
          AppAltAuthRow(
            label: t.loginStepUseCodeInstead,
            icon: Icons.sms_outlined,
            onTap: enabled ? onUseCode : null,
          ),
        ],
      ),
    );
  }
}

class _CodeStepContent extends StatelessWidget {
  final bool isEmail;
  final String maskedTarget;
  final String? otpError;
  final bool enabled;
  final bool busy;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onOtpSubmitted;
  final VoidCallback onResend;
  final VoidCallback onUsePassword;

  const _CodeStepContent({
    required this.isEmail,
    required this.maskedTarget,
    required this.otpError,
    required this.enabled,
    required this.busy,
    required this.onOtpChanged,
    required this.onOtpSubmitted,
    required this.onResend,
    required this.onUsePassword,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // In-flow sent confirmation: the masked destination line arrives as
          // a success banner above the OTP field (never an overlay), so it
          // can never cover the resend row below the CTA.
          AppBanner(
            kind: AppBannerKind.success,
            message: t.loginStepCodeDestination(maskedTarget),
          ),
          const SizedBox(height: AppDimensions.s20),
          AuthOtpField(
            onChanged: onOtpChanged,
            errorText: otpError,
            enabled: enabled,
            onSubmitted: onOtpSubmitted,
          ),
          const SizedBox(height: AppDimensions.s12),
          Center(
            child: LoginResendRow(busy: busy, onResend: onResend),
          ),
          const SizedBox(height: AppDimensions.s8),
          AppAltAuthRow(
            label: t.loginStepUsePasswordInstead,
            icon: Icons.lock_outline_rounded,
            onTap: enabled ? onUsePassword : null,
          ),
        ],
      ),
    );
  }
}

class _RegisterNameContent extends StatelessWidget {
  final TextEditingController nameCtrl;
  final String? nameError;
  final bool enabled;
  final FocusNode? nameFocus;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onSubmitted;

  const _RegisterNameContent({
    required this.nameCtrl,
    required this.nameError,
    required this.enabled,
    required this.nameFocus,
    required this.onNameChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
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
            enabled: enabled,
            error: nameError,
            focusNode: nameFocus,
            onChanged: onNameChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
        ],
      ),
    );
  }
}

class _RegisterContactContent extends StatelessWidget {
  final TextEditingController identifierCtrl;
  final String countryCode;
  final String? identifierError;
  final bool enabled;
  final FocusNode? identifierFocus;
  final ValueChanged<String> onIdentifierChanged;
  final ValueChanged<String> onCountryChanged;
  final VoidCallback onSubmitted;

  const _RegisterContactContent({
    required this.identifierCtrl,
    required this.countryCode,
    required this.identifierError,
    required this.enabled,
    required this.identifierFocus,
    required this.onIdentifierChanged,
    required this.onCountryChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentifierRow(
            controller: identifierCtrl,
            countryCode: countryCode,
            errorText: identifierError,
            enabled: enabled,
            focusNode: identifierFocus,
            onChanged: onIdentifierChanged,
            onCountryChanged: onCountryChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
        ],
      ),
    );
  }
}

class _RegisterPasswordContent extends StatelessWidget {
  final TextEditingController passwordCtrl;
  final String passwordValue;
  final String? passwordError;
  final bool enabled;
  final FocusNode? passwordFocus;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmitted;

  const _RegisterPasswordContent({
    required this.passwordCtrl,
    required this.passwordValue,
    required this.passwordError,
    required this.enabled,
    required this.passwordFocus,
    required this.onPasswordChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SharedAuthL10n.of(context);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            enabled: enabled,
            error: passwordError,
            focusNode: passwordFocus,
            belowField: AuthPasswordStrength(password: passwordValue),
            labelTrailing: Text(
              t.loginMinCharacters,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: onPasswordChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
        ],
      ),
    );
  }
}
