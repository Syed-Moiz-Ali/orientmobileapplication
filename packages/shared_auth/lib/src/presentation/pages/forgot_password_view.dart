import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/widgets/auth_surface.dart';
import 'package:shared_core/shared_core.dart';

enum ForgotMethod { phone, email }

class ForgotPasswordView extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordView({super.key, required this.onBackToLogin});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  ForgotMethod _method = ForgotMethod.phone;
  String _phone = '';
  String _email = '';
  String _otp = '';
  String _password = '';
  String? _error;
  bool _isLoading = false;
  bool _otpSent = false;
  int _resendCooldown = 0;

  @override
  void dispose() {
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

  Future<void> _sendOtp() async {
    final input = _identifierCtrl.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'Enter your email or phone number.');
      return;
    }

    final email = _looksLikeEmail(input);
    if (email && !input.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (!email && input.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      setState(() => _error = 'Enter a valid phone number.');
      return;
    }

    setState(() {
      _method = email ? ForgotMethod.email : ForgotMethod.phone;
      _email = email ? input : '';
      _phone = email ? '' : input.replaceAll(RegExp(r'[^0-9]'), '');
      _isLoading = true;
      _error = null;
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
          _otpSent = true;
        });
        _startCooldown();
      },
      failure: (error) => setState(() {
        _isLoading = false;
        _error = error.message;
      }),
    );
  }

  Future<void> _resetPassword() async {
    if (_otp.length != 6) {
      setState(() => _error = 'Enter the 6 digit code.');
      return;
    }
    if (_password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    final email = _method == ForgotMethod.email;
    setState(() {
      _isLoading = true;
      _error = null;
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
      success: (_) => widget.onBackToLogin(),
      failure: (error) => setState(() {
        _isLoading = false;
        _error = error.message;
      }),
    );
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
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
      _otpSent = false;
      _otp = '';
      _password = '';
      _passwordCtrl.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: _otpSent ? 'New password' : 'Recover access',
      subtitle: _otpSent
          ? 'Enter the code and choose a new password.'
          : 'Use your registered email or mobile number.',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(_otpSent),
          child: _otpSent
              ? _ResetStep(
                  identifier: _method == ForgotMethod.email
                      ? _email
                      : '+971 $_phone',
                  passwordCtrl: _passwordCtrl,
                  error: _error,
                  isLoading: _isLoading,
                  resendCooldown: _resendCooldown,
                  onOtpChanged: (value) => setState(() {
                    _otp = value;
                    _error = null;
                  }),
                  onPasswordChanged: (value) => setState(() {
                    _password = value;
                    _error = null;
                  }),
                  onSubmit: _resetPassword,
                  onEditIdentifier: _editIdentifier,
                  onResend: _sendOtp,
                  onBackToLogin: widget.onBackToLogin,
                )
              : _RequestStep(
                  identifierCtrl: _identifierCtrl,
                  error: _error,
                  isLoading: _isLoading,
                  onChanged: () => setState(() => _error = null),
                  onSubmit: _sendOtp,
                  onBackToLogin: widget.onBackToLogin,
                ),
        ),
      ),
    );
  }
}

class _RequestStep extends StatelessWidget {
  final TextEditingController identifierCtrl;
  final String? error;
  final bool isLoading;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const _RequestStep({
    required this.identifierCtrl,
    required this.error,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: identifierCtrl,
          label: 'Email or mobile number',
          hint: 'name@company.com or 501234567',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          errorText: error,
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthPrimaryButton(
          label: 'Send code',
          icon: Icons.arrow_forward_rounded,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s12),
        AuthLinkButton(
          label: 'Back to sign in',
          onPressed: onBackToLogin,
        ),
      ],
    );
  }
}

class _ResetStep extends StatelessWidget {
  final String identifier;
  final TextEditingController passwordCtrl;
  final String? error;
  final bool isLoading;
  final int resendCooldown;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onEditIdentifier;
  final VoidCallback onResend;
  final VoidCallback onBackToLogin;

  const _ResetStep({
    required this.identifier,
    required this.passwordCtrl,
    required this.error,
    required this.isLoading,
    required this.resendCooldown,
    required this.onOtpChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onEditIdentifier,
    required this.onResend,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          identifier,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthOtpField(
          onChanged: onOtpChanged,
          errorText: error,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppDimensions.s16),
        AuthTextField(
          controller: passwordCtrl,
          label: 'New password',
          hint: 'At least 6 characters',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          errorText: error,
          onChanged: onPasswordChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppDimensions.s20),
        AuthPrimaryButton(
          label: 'Reset password',
          icon: Icons.check_rounded,
          isLoading: isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppDimensions.s12),
        Wrap(
          spacing: AppDimensions.s12,
          runSpacing: AppDimensions.s4,
          children: [
            AuthLinkButton(
              label: 'Edit email or phone',
              onPressed: onEditIdentifier,
            ),
            AuthLinkButton(
              label: resendCooldown > 0
                  ? 'Resend in ${resendCooldown}s'
                  : 'Resend code',
              onPressed: resendCooldown > 0 ? () {} : onResend,
            ),
            AuthLinkButton(
              label: 'Back to sign in',
              onPressed: onBackToLogin,
            ),
          ],
        ),
      ],
    );
  }
}
