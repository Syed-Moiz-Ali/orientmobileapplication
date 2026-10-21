import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/widgets/auth_error_mapper.dart';
import 'package:shared_auth/src/presentation/widgets/auth_otp_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_password_strength.dart';
import 'package:shared_auth/src/presentation/widgets/auth_step_brand.dart';
import 'package:shared_auth/src/presentation/widgets/auth_step_resend.dart';
import 'package:shared_core/shared_core.dart';

enum ForgotMethod { phone, email }

/// Recovery is a single step flow with three intent-level stages. The backend
/// issues and consumes the recovery code in one `reset-password` call, so the
/// code and the new password are collected together rather than inventing a
/// local "verify" gate that the API cannot honour.
///
/// Composition (C16): the same 3 stages recomposed as [AppStepScaffold] steps
/// (thin progress + back arrow + question headline + sticky CTA); code + new
/// password collected together (backend single-call constraint); warm terminal
/// confirmation (C10 exception) → single "Back to sign in" CTA.
enum _RecoveryStage { identifier, reset, done }

class ForgotPasswordView extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;
  final String appName;
  final String appPurpose;
  final String intendedUsers;
  final String? securityNotice;

  const ForgotPasswordView({
    super.key,
    required this.onBackToLogin,
    this.appName = 'Orient Workshop',
    this.appPurpose =
        'Manage workshop bookings, job cards, approvals, and service updates.',
    this.intendedUsers = 'Workshop users',
    this.securityNotice,
  });

  @override
  ConsumerState<ForgotPasswordView> createState() =>
      _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();

  ForgotMethod _method = ForgotMethod.phone;
  _RecoveryStage _stage = _RecoveryStage.identifier;

  String _phone = '';
  String _email = '';
  String _otp = '';
  String _password = '';

  String? _identifierError;
  String? _codeError;
  String? _passwordError;

  bool _isLoading = false;

  /// Resend countdown owned as a notifier (not `setState`): the 1 Hz ticks
  /// update [_cooldown.value] so only [ForgotResendRow]'s
  /// [ValueListenableBuilder] rebuilds — never this whole step.
  final ValueNotifier<int> _cooldown = ValueNotifier<int>(0);
  int _cooldownGeneration = 0;

  @override
  void dispose() {
    _cooldownGeneration++;
    _cooldown.dispose();
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String value) {
    return value.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  String _fullPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('971')) return digits;
    return '971${digits.startsWith('0') ? digits.substring(1) : digits}';
  }

  String get _maskedDestination => _method == ForgotMethod.email
      ? _maskEmail(_email)
      : '+971 ${_maskPhone(_phone)}';

  void _clearErrors() {
    _identifierError = null;
    _codeError = null;
    _passwordError = null;
  }

  /// Hides any visible form-error snackbar so a stale backend failure never
  /// lingers next to a corrected field.
  void _dismissSnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Form-level failures surface as a snackbar with a retry action when the
  /// mapping marks them retryable (offline, 401, 500, 404). Field-mapped
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

  void _onIdentifierChanged() {
    _dismissSnack();
    setState(() {
      _identifierError = null;
    });
  }

  Future<void> _sendOtp() async {
    // Double-submit guard: the busy CTA is already disabled, this covers the
    // race between the tap and the first frame.
    if (_isLoading) return;
    final input = _identifierCtrl.text.trim();
    final email = _looksLikeEmail(input);
    final t = SharedAuthL10n.forLocale(ref.read(localeProvider));

    String? fieldError;
    if (input.isEmpty) {
      fieldError = t.validationEnterIdentifier;
    } else if (email && !input.contains('@')) {
      fieldError = t.validationEnterValidEmailAddress;
    } else if (!email && input.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      fieldError = t.validationEnterValidMobile;
    }

    if (fieldError != null) {
      setState(() {
        _identifierError = fieldError;
      });
      _identifierFocus.requestFocus();
      return;
    }

    setState(() {
      _method = email ? ForgotMethod.email : ForgotMethod.phone;
      _email = email ? input : '';
      _phone = email ? '' : input.replaceAll(RegExp(r'[^0-9]'), '');
      _isLoading = true;
      _clearErrors();
    });

    final result = await ref.read(forgotPasswordProvider)(
      email ? 'email' : 'sms',
      email ? '' : _fullPhone(_phone),
      email ? _email : '',
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() {
          _isLoading = false;
          _stage = _RecoveryStage.reset;
        });
        _startCooldown();
        // Code-sent confirmation is an in-flow success banner at the top of
        // the reset step (phase-2 F-4) — never a floating snackbar, so it
        // can never overlay the resend countdown. Values in the controllers
        // are preserved for the reset step.
      },
      failure: (error) {
        final display = mapAuthError(error, t);
        setState(() {
          _isLoading = false;
          // Field-mapped failures (404 unknown identifier, 409 conflict)
          // render inline; everything else goes to the snackbar with retry.
          _identifierError = display.field == AuthErrorField.identifier
              ? display.message
              : null;
        });
        if (display.field == AuthErrorField.identifier) {
          _identifierFocus.requestFocus();
        } else {
          _showErrorSnack(display, _sendOtp);
        }
      },
    );
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    final t = SharedAuthL10n.forLocale(ref.read(localeProvider));
    String? codeError;
    String? passwordError;
    if (_otp.length != 6) {
      codeError = t.validationEnter6DigitRecovery;
    }
    if (_password.length < 6) {
      passwordError = t.validationUseAtLeast6;
    }

    if (codeError != null || passwordError != null) {
      setState(() {
        _codeError = codeError;
        _passwordError = passwordError;
      });
      // Visual order is code first, then password; the OTP cells keep their
      // own focus, so only a password-only failure moves focus.
      if (codeError == null) _passwordFocus.requestFocus();
      return;
    }

    final email = _method == ForgotMethod.email;
    setState(() {
      _isLoading = true;
      _codeError = null;
      _passwordError = null;
    });

    final result = await ref.read(resetPasswordProvider)(
      email ? 'email' : 'sms',
      email ? '' : _fullPhone(_phone),
      email ? _email : '',
      _otp,
      _password,
    );

    if (!mounted) return;

    result.when(
      success: (_) {
        _cooldownGeneration++;
        _cooldown.value = 0;
        setState(() {
          _isLoading = false;
          _stage = _RecoveryStage.done;
        });
      },
      failure: (error) {
        final display = mapAuthError(error, t);
        setState(() {
          _isLoading = false;
          // Expired vs incorrect codes land on the OTP field with distinct
          // copy; password policy details land on the password field;
          // form-level failures go to the snackbar with retry.
          _codeError = display.field == AuthErrorField.code
              ? display.message
              : null;
          _passwordError = display.field == AuthErrorField.password
              ? display.message
              : null;
        });
        if (display.field == AuthErrorField.password) {
          _passwordFocus.requestFocus();
        } else if (display.field == AuthErrorField.none) {
          _showErrorSnack(display, _resetPassword);
        }
      },
    );
  }

  void _startCooldown() {
    final generation = ++_cooldownGeneration;
    _cooldown.value = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || generation != _cooldownGeneration) return false;
      if (_cooldown.value <= 1) {
        _cooldown.value = 0;
        return false;
      }
      _cooldown.value = _cooldown.value - 1;
      return true;
    });
  }

  void _editIdentifier() {
    _dismissSnack();
    setState(() {
      _stage = _RecoveryStage.identifier;
      _otp = '';
      _password = '';
      _passwordCtrl.clear();
      _clearErrors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    final (title, subtitle, ctaLabel, busyLabel, step, total, onCta, onBack) =
        switch (_stage) {
      _RecoveryStage.identifier => (
        t.forgotTitle,
        t.forgotSubtitle,
        t.forgotActionSendRecoveryCode,
        t.authActionSending,
        1,
        2,
        _sendOtp,
        widget.onBackToLogin,
      ),
      _RecoveryStage.reset => (
        t.forgotResetTitle,
        t.forgotResetSubtitle,
        t.forgotActionUpdatePassword,
        t.authActionUpdating,
        2,
        2,
        _resetPassword,
        _editIdentifier,
      ),
      _RecoveryStage.done => (
        t.forgotDoneTitle,
        t.forgotDoneSubtitle,
        t.forgotBackToSignIn,
        null as String?,
        2,
        2,
        widget.onBackToLogin,
        null as VoidCallback?,
      ),
    };

    final Widget content = switch (_stage) {
      _RecoveryStage.identifier => _ForgotIdentifierContent(
        controller: _identifierCtrl,
        error: _identifierError,
        isLoading: _isLoading,
        focusNode: _identifierFocus,
        onChanged: _onIdentifierChanged,
        onSubmitted: _sendOtp,
      ),
      _RecoveryStage.reset => _ForgotResetContent(
        passwordCtrl: _passwordCtrl,
        password: _password,
        sentMessage: t.forgotCodeSent(_maskedDestination),
        codeError: _codeError,
        passwordError: _passwordError,
        isLoading: _isLoading,
        cooldown: _cooldown,
        passwordFocus: _passwordFocus,
        onOtpChanged: (value) {
          _dismissSnack();
          setState(() {
            _otp = value;
            _codeError = null;
          });
        },
        onPasswordChanged: (value) {
          _dismissSnack();
          setState(() {
            _password = value;
            _passwordError = null;
          });
        },
        onSubmitted: _resetPassword,
        onEditIdentifier: _editIdentifier,
        onResend: _sendOtp,
      ),
      _RecoveryStage.done => const _RecoverySuccessContent(),
    };

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
      isLoading: _isLoading,
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

class _ForgotIdentifierContent extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final bool isLoading;
  final FocusNode? focusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _ForgotIdentifierContent({
    required this.controller,
    required this.error,
    required this.isLoading,
    this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  bool _looksLikeEmail(String value) {
    return value.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    final theme = Theme.of(context);
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final phoneLike = !_looksLikeEmail(value.text.trim());
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppInputField(
                    label: t.loginFieldIdentifier,
                    hint: t.loginFieldIdentifierHint,
                    controller: controller,
                    prefixIcon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.username],
                    forceLtr: true,
                    enabled: !isLoading,
                    error: error,
                    focusNode: focusNode,
                    onChanged: (_) => onChanged(),
                    onSubmitted: (_) => onSubmitted(),
                  ),
                  // Per-country format hint for phone-like entry, mirroring
                  // the sign-in identifier row (UAE default, 9 digits).
                  if (phoneLike) ...[
                    const SizedBox(height: AppDimensions.s6),
                    Text(
                      t.loginPhoneFormatHint(9, '+971'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: AppDimensions.s20),
          Text(
            t.forgotContactSupport,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotResetContent extends StatelessWidget {
  final TextEditingController passwordCtrl;
  final String password;
  final String sentMessage;
  final String? codeError;
  final String? passwordError;
  final bool isLoading;
  final ValueNotifier<int> cooldown;
  final FocusNode? passwordFocus;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onEditIdentifier;
  final VoidCallback onResend;

  const _ForgotResetContent({
    required this.passwordCtrl,
    required this.password,
    required this.sentMessage,
    required this.codeError,
    required this.passwordError,
    required this.isLoading,
    required this.cooldown,
    this.passwordFocus,
    required this.onOtpChanged,
    required this.onPasswordChanged,
    required this.onSubmitted,
    required this.onEditIdentifier,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // In-flow sent confirmation (F-4): pinned above the OTP field with
          // the resend row kept below the CTA, so banner and countdown can
          // never overlap at 360×800. The page stays scrollable.
          AppBanner(
            kind: AppBannerKind.success,
            message: sentMessage,
          ),
          const SizedBox(height: AppDimensions.s20),
          AuthOtpField(
            label: t.forgotFieldRecoveryCode,
            onChanged: onOtpChanged,
            errorText: codeError,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppDimensions.s20),
          AppInputField(
            label: t.forgotFieldNewPassword,
            hint: t.forgotFieldNewPasswordHint,
            controller: passwordCtrl,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            passwordToggle: true,
            showPasswordTooltip: t.authShowPassword,
            hidePasswordTooltip: t.authHidePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            enabled: !isLoading,
            error: passwordError,
            focusNode: passwordFocus,
            belowField: AuthPasswordStrength(password: password),
            onChanged: onPasswordChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
          const SizedBox(height: AppDimensions.s12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s4,
            children: [
              AppTextButton(
                label: t.loginActionChangeIdentifier,
                onPressed: isLoading ? null : onEditIdentifier,
              ),
              ForgotResendRow(
                cooldown: cooldown,
                busy: isLoading,
                onResend: onResend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Terminal confirmation of the recovery flow (kept per the phase-2a
/// decision + DESIGN_SPEC C10 exception: a snackbar plus an immediate
/// redirect would erase the proof of completion).
///
/// Redesigned: a warm layered emblem — soft success halo, solid success disc,
/// white check — announced once as a live region. The subtitle lives ONLY in
/// the step shell (the second body copy under the emblem was deleted — a
/// terminal screen must not repeat its own sentence). The single
/// "Back to sign in" CTA lives in the sticky step bar.
class _RecoverySuccessContent extends StatelessWidget {
  const _RecoverySuccessContent();

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final dark = theme.brightness == Brightness.dark;
    // Same AA-verified pair as AppPillButton.success: deep success disc with
    // the theme on-primary check (5.02 light / 10.24 dark), halo in the
    // semantic success soft.
    final disc = dark ? AppDarkColors.successStrong : AppColors.successStrong;

    return Semantics(
      liveRegion: true,
      label: t.forgotDoneTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: AppDimensions.s64 + AppDimensions.s16,
              height: AppDimensions.s64 + AppDimensions.s16,
              decoration: BoxDecoration(
                color: semantic.success.subtle,
                shape: BoxShape.circle,
                border: Border.all(color: semantic.success.border),
              ),
              child: Center(
                child: Container(
                  width: AppDimensions.s48,
                  height: AppDimensions.s48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: disc,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: AppDimensions.iconXl,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Masks an email using only data the user already supplied on this screen.
String _maskEmail(String email) {
  final at = email.indexOf('@');
  if (at <= 0) return email;
  final local = email.substring(0, at);
  final visible = local.length <= 2
      ? local.substring(0, 1)
      : local.substring(0, 2);
  return '$visible\u2022\u2022\u2022\u2022${email.substring(at)}';
}

/// Masks a local mobile number, keeping a recognisable country code and tail.
String _maskPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 5) return digits;
  return '\u2022\u2022\u2022 \u2022\u2022\u2022 ${digits.substring(digits.length - 3)}';
}
