import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/auth_error_mapper.dart';
import 'package:shared_auth/src/presentation/widgets/auth_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_password_strength.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';
import 'package:shared_core/shared_core.dart';

enum ForgotMethod { phone, email }

/// Recovery is a single view with three intent-level stages. The backend
/// issues and consumes the recovery code in one `reset-password` call, so the
/// code and the new password are collected together rather than inventing a
/// local "verify" gate that the API cannot honour.
///
/// Composition (rebuilt): 2-step indicator (Verify account → New password) →
/// identify → code-sent with resend timer → reset with the shared strength
/// slot → warm success with a single CTA.
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
  int _resendCooldown = 0;
  int _cooldownGeneration = 0;

  @override
  void dispose() {
    _cooldownGeneration++;
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
        // Code-sent confirmation: success snackbar, no banner. Values in the
        // controllers are preserved for the reset step.
        showAppSnackBar(
          context,
          message: t.forgotCodeSent(_maskedDestination),
          tone: AppSnackBarTone.success,
        );
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
    setState(() => _resendCooldown = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || generation != _cooldownGeneration) return false;
      if (_resendCooldown <= 1) {
        setState(() => _resendCooldown = 0);
        return false;
      }
      setState(() => _resendCooldown--);
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
    final (title, subtitle) = switch (_stage) {
      _RecoveryStage.identifier => (t.forgotTitle, t.forgotSubtitle),
      _RecoveryStage.reset => (t.forgotResetTitle, t.forgotResetSubtitle),
      _RecoveryStage.done => (t.forgotDoneTitle, t.forgotDoneSubtitle),
    };

    return AuthShell(
      appName: widget.appName,
      appPurpose: widget.appPurpose,
      intendedUsers: widget.intendedUsers,
      securityNotice: widget.securityNotice,
      top: _stage == _RecoveryStage.done
          ? null
          : _RecoveryProgress(
              step: _stage == _RecoveryStage.reset ? 2 : 1,
              onBackToLogin: widget.onBackToLogin,
            ),
      title: title,
      subtitle: subtitle,
      child: AnimatedSwitcher(
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
        child: switch (_stage) {
          _RecoveryStage.identifier => _IdentifierStep(
            key: const ValueKey('identifier'),
            controller: _identifierCtrl,
            error: _identifierError,
            isLoading: _isLoading,
            focusNode: _identifierFocus,
            onChanged: _onIdentifierChanged,
            onSubmit: _sendOtp,
          ),
          _RecoveryStage.reset => _ResetStep(
            key: const ValueKey('reset'),
            passwordCtrl: _passwordCtrl,
            password: _password,
            codeError: _codeError,
            passwordError: _passwordError,
            isLoading: _isLoading,
            resendCooldown: _resendCooldown,
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
            onSubmit: _resetPassword,
            onEditIdentifier: _editIdentifier,
            onResend: _sendOtp,
          ),
          _RecoveryStage.done => _RecoverySuccess(
            key: const ValueKey('done'),
            onBackToLogin: widget.onBackToLogin,
          ),
        },
      ),
    );
  }
}

/// Step progress plus the always-available route back to sign in. Placed in the
/// shell's `top` slot so back navigation is consistent with the system back
/// gesture, which also leaves recovery for sign in.
class _RecoveryProgress extends StatelessWidget {
  final int step;
  final VoidCallback onBackToLogin;

  const _RecoveryProgress({required this.step, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AuthLinkButton(
            label: t.forgotSignIn,
            icon: Icons.arrow_back_rounded,
            onPressed: onBackToLogin,
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        AppStepProgress(
          currentStep: step - 1,
          steps: [
            AppProgressStep(
              label: t.authRecoveryStepIdentify,
              icon: Icons.alternate_email_rounded,
            ),
            AppProgressStep(
              label: t.authRecoveryStepReset,
              icon: Icons.lock_reset_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _IdentifierStep extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final bool isLoading;
  final FocusNode? focusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _IdentifierStep({
    super.key,
    required this.controller,
    required this.error,
    required this.isLoading,
    this.focusNode,
    required this.onChanged,
    required this.onSubmit,
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
                  AuthTextField(
                    controller: controller,
                    label: t.loginFieldIdentifier,
                    hint: t.loginFieldIdentifierHint,
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.username],
                    textDirection: TextDirection.ltr,
                    enabled: !isLoading,
                    errorText: error,
                    focusNode: focusNode,
                    onChanged: (_) => onChanged(),
                    onSubmitted: (_) => onSubmit(),
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
          const SizedBox(height: AppDimensions.s24),
          AuthPrimaryButton(
            label: t.forgotActionSendRecoveryCode,
            busyLabel: t.authActionSending,
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            onPressed: onSubmit,
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

class _ResetStep extends StatelessWidget {
  final TextEditingController passwordCtrl;
  final String password;
  final String? codeError;
  final String? passwordError;
  final bool isLoading;
  final int resendCooldown;
  final FocusNode? passwordFocus;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onEditIdentifier;
  final VoidCallback onResend;

  const _ResetStep({
    super.key,
    required this.passwordCtrl,
    required this.password,
    required this.codeError,
    required this.passwordError,
    required this.isLoading,
    required this.resendCooldown,
    this.passwordFocus,
    required this.onOtpChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
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
          AuthOtpField(
            label: t.forgotFieldRecoveryCode,
            onChanged: onOtpChanged,
            errorText: codeError,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppDimensions.s20),
          AuthTextField(
            controller: passwordCtrl,
            label: t.forgotFieldNewPassword,
            hint: t.forgotFieldNewPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            enabled: !isLoading,
            errorText: passwordError,
            focusNode: passwordFocus,
            belowField: AuthPasswordStrength(password: password),
            onChanged: onPasswordChanged,
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: AppDimensions.s24),
          AuthPrimaryButton(
            label: t.forgotActionUpdatePassword,
            busyLabel: t.authActionUpdating,
            icon: Icons.check_rounded,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: AppDimensions.s8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s4,
            children: [
              AuthLinkButton(
                label: t.loginActionChangeIdentifier,
                onPressed: isLoading ? null : onEditIdentifier,
              ),
              AuthResendAction(
                cooldownSeconds: resendCooldown,
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

class _RecoverySuccess extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const _RecoverySuccess({super.key, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    final success = context.semanticColors.success.base;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 32, color: success),
          ),
        ),
        const SizedBox(height: AppDimensions.s24),
        AuthPrimaryButton(
          label: t.forgotBackToSignIn,
          icon: Icons.login_rounded,
          onPressed: onBackToLogin,
        ),
      ],
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
