import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/auth_field.dart';
import 'package:shared_auth/src/presentation/widgets/auth_notice.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';
import 'package:shared_core/shared_core.dart';

enum ForgotMethod { phone, email }

/// Recovery is a single view with three intent-level stages. The backend
/// issues and consumes the recovery code in one `reset-password` call, so the
/// code and the new password are collected together rather than inventing a
/// local "verify" gate that the API cannot honour.
enum _RecoveryStage { identifier, reset, done }

class ForgotPasswordView extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;
  final String appName;
  final String appPurpose;
  final String intendedUsers;

  const ForgotPasswordView({
    super.key,
    required this.onBackToLogin,
    this.appName = 'Orient Workshop',
    this.appPurpose =
        'Manage workshop bookings, job cards, approvals, and service updates.',
    this.intendedUsers = 'Workshop users',
  });

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  ForgotMethod _method = ForgotMethod.phone;
  _RecoveryStage _stage = _RecoveryStage.identifier;

  String _phone = '';
  String _email = '';
  String _otp = '';
  String _password = '';

  String? _identifierError;
  String? _codeError;
  String? _passwordError;
  String? _bannerError;

  bool _isLoading = false;
  int _resendCooldown = 0;
  int _cooldownGeneration = 0;

  @override
  void dispose() {
    _cooldownGeneration++;
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
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
    _bannerError = null;
  }

  void _onIdentifierChanged() {
    setState(() {
      _identifierError = null;
      _bannerError = null;
    });
  }

  Future<void> _sendOtp() async {
    final input = _identifierCtrl.text.trim();
    final email = _looksLikeEmail(input);

    String? fieldError;
    if (input.isEmpty) {
      fieldError = 'Enter your email or mobile number.';
    } else if (email && !input.contains('@')) {
      fieldError = 'Enter a valid email address.';
    } else if (!email && input.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      fieldError = 'Enter a valid mobile number.';
    }

    if (fieldError != null) {
      setState(() {
        _identifierError = fieldError;
        _bannerError = null;
      });
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
      },
      failure: (error) => setState(() {
        _isLoading = false;
        _bannerError = _friendlyError(error);
      }),
    );
  }

  Future<void> _resetPassword() async {
    String? codeError;
    String? passwordError;
    if (_otp.length != 6) {
      codeError = 'Enter the 6-digit recovery code.';
    }
    if (_password.length < 6) {
      passwordError = 'Use at least 6 characters.';
    }

    if (codeError != null || passwordError != null) {
      setState(() {
        _codeError = codeError;
        _passwordError = passwordError;
        _bannerError = null;
      });
      return;
    }

    final email = _method == ForgotMethod.email;
    setState(() {
      _isLoading = true;
      _bannerError = null;
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
      failure: (error) => setState(() {
        _isLoading = false;
        _bannerError = _friendlyError(error);
      }),
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
    final (title, subtitle) = switch (_stage) {
      _RecoveryStage.identifier => (
        'Forgot your password?',
        'Enter the email address or mobile number linked to your account and '
            'we will send you a recovery code.',
      ),
      _RecoveryStage.reset => (
        'Choose a new password',
        'Enter the code and set a new password.',
      ),
      _RecoveryStage.done => (
        'Password updated',
        'Sign in with your new password to continue.',
      ),
    };

    return AuthShell(
      appName: widget.appName,
      appPurpose: widget.appPurpose,
      intendedUsers: widget.intendedUsers,
      top: _stage == _RecoveryStage.done
          ? null
          : _RecoveryProgress(
              step: _stage == _RecoveryStage.reset ? 2 : 1,
              onBackToLogin: widget.onBackToLogin,
            ),
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
        child: switch (_stage) {
          _RecoveryStage.identifier => _IdentifierStep(
            key: const ValueKey('identifier'),
            controller: _identifierCtrl,
            error: _identifierError,
            bannerError: _bannerError,
            isLoading: _isLoading,
            onChanged: _onIdentifierChanged,
            onSubmit: _sendOtp,
          ),
          _RecoveryStage.reset => _ResetStep(
            key: const ValueKey('reset'),
            maskedDestination: _maskedDestination,
            passwordCtrl: _passwordCtrl,
            password: _password,
            codeError: _codeError,
            passwordError: _passwordError,
            bannerError: _bannerError,
            isLoading: _isLoading,
            resendCooldown: _resendCooldown,
            onOtpChanged: (value) => setState(() {
              _otp = value;
              _codeError = null;
              _bannerError = null;
            }),
            onPasswordChanged: (value) => setState(() {
              _password = value;
              _passwordError = null;
              _bannerError = null;
            }),
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

/// Step counter plus the always-available route back to sign in. Placed in the
/// shell's `top` slot so back navigation is consistent with the system back
/// gesture, which also leaves recovery for sign in.
class _RecoveryProgress extends StatelessWidget {
  final int step;
  final VoidCallback onBackToLogin;

  const _RecoveryProgress({required this.step, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AuthLinkButton(
                  label: 'Sign in',
                  icon: Icons.arrow_back_rounded,
                  onPressed: onBackToLogin,
                ),
              ),
            ),
            Text(
              'Step $step of 2',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.rPill),
          child: LinearProgressIndicator(
            value: step / 2,
            minHeight: 4,
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _IdentifierStep extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final String? bannerError;
  final bool isLoading;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _IdentifierStep({
    super.key,
    required this.controller,
    required this.error,
    required this.bannerError,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNoticeSlot(message: bannerError),
        AuthTextField(
          controller: controller,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.username],
          enabled: !isLoading,
          errorText: error,
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppDimensions.s24),
        AuthPrimaryButton(
          label: 'Send recovery code',
          icon: Icons.arrow_forward_rounded,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s20),
        Text(
          'Can\u2019t access this email or mobile number? Contact your workshop '
          'support team.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ResetStep extends StatelessWidget {
  final String maskedDestination;
  final TextEditingController passwordCtrl;
  final String password;
  final String? codeError;
  final String? passwordError;
  final String? bannerError;
  final bool isLoading;
  final int resendCooldown;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onEditIdentifier;
  final VoidCallback onResend;

  const _ResetStep({
    super.key,
    required this.maskedDestination,
    required this.passwordCtrl,
    required this.password,
    required this.codeError,
    required this.passwordError,
    required this.bannerError,
    required this.isLoading,
    required this.resendCooldown,
    required this.onOtpChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onEditIdentifier,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final resendAvailable = resendCooldown == 0 && !isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNotice(
          icon: Icons.lock_reset_rounded,
          text: 'Recovery code sent to $maskedDestination.',
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthNoticeSlot(message: bannerError),
        AuthOtpField(
          label: 'Recovery code',
          onChanged: onOtpChanged,
          errorText: codeError,
          enabled: !isLoading,
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthTextField(
          controller: passwordCtrl,
          label: 'New password',
          hint: 'Enter a new password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !isLoading,
          errorText: passwordError,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        if (passwordError == null) ...[
          const SizedBox(height: AppDimensions.s8),
          _PasswordRequirement(password: password),
        ],
        const SizedBox(height: AppDimensions.s24),
        AuthPrimaryButton(
          label: 'Update password',
          icon: Icons.check_rounded,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimensions.s8,
          runSpacing: AppDimensions.s4,
          children: [
            AuthLinkButton(
              label: 'Change email or mobile',
              onPressed: isLoading ? null : onEditIdentifier,
            ),
            AuthLinkButton(
              label: resendCooldown > 0
                  ? 'Resend in ${resendCooldown}s'
                  : 'Resend code',
              subtle: true,
              onPressed: resendAvailable ? onResend : null,
            ),
          ],
        ),
      ],
    );
  }
}

/// Restrained live confirmation of the only enforced password rule.
class _PasswordRequirement extends StatelessWidget {
  final String password;

  const _PasswordRequirement({required this.password});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final met = password.length >= 6;
    final color = met ? colors.tertiary : colors.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: AppDimensions.iconSm,
          color: color,
        ),
        const SizedBox(width: AppDimensions.s6),
        Flexible(
          child: Text(
            'At least 6 characters',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecoverySuccess extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const _RecoverySuccess({super.key, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.tertiary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 32, color: colors.tertiary),
          ),
        ),
        const SizedBox(height: AppDimensions.s24),
        AuthPrimaryButton(
          label: 'Back to sign in',
          icon: Icons.login_rounded,
          onPressed: onBackToLogin,
        ),
      ],
    );
  }
}

final _technicalMessage = RegExp(
  r'dio|socket|connection (refused|reset|closed)|failed host lookup|timeout'
  r'|xmlhttprequest|handshake|os error',
  caseSensitive: false,
);

/// Keeps backend validation messages (they are user facing) while replacing
/// transport-level noise with calm, actionable copy.
String _friendlyError(AppException error) {
  final raw = error.message.trim();
  if (error is NetworkException || _technicalMessage.hasMatch(raw)) {
    return 'We couldn\u2019t reach Orient. Check your connection and try again.';
  }
  if (error is UnknownException) {
    return 'Something went wrong on our side. Please try again.';
  }
  if (raw.isEmpty) return 'Something went wrong. Please try again.';
  return raw;
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
