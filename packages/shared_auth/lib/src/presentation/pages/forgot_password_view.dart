import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/widgets/auth_background.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
import 'package:shared_auth/src/presentation/widgets/auth_header.dart';
import 'package:shared_auth/src/presentation/widgets/phone_input_field.dart';
import 'package:shared_core/shared_core.dart';

enum ForgotMethod { phone, email }

class ForgotPasswordView extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;
  const ForgotPasswordView({super.key, required this.onBackToLogin});
  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  ForgotMethod _method = ForgotMethod.phone;
  String _phone = '';
  String _email = '';
  String _otp = '';
  String _password = '';
  String? _error;
  bool _isLoading = false;
  bool _otpSent = false;
  int _resendCooldown = 0;

  void _setPhone(String v) {
    final c = v.replaceAll(RegExp(r'[^\d]'), '');
    if (c.length <= 10)
      setState(() {
        _phone = c;
        _error = null;
      });
  }

  void _setEmail(String v) => setState(() {
    _email = v;
    _error = null;
  });
  void _setOtp(String v) {
    final c = v.replaceAll(RegExp(r'[^\d]'), '');
    if (c.length <= 6)
      setState(() {
        _otp = c;
        _error = null;
      });
  }

  void _setPassword(String v) => setState(() {
    _password = v;
    _error = null;
  });

  String _fullPhone(String p) {
    final c = p.replaceAll(RegExp(r'[^\d]'), '');
    if (c.startsWith('971')) return c;
    return '971${c.startsWith('0') ? c.substring(1) : c}';
  }

  Future<void> _sendOtp() async {
    if (_method == ForgotMethod.phone) {
      final p = _phone.replaceAll(RegExp(r'[^\d]'), '');
      if (p.isEmpty || p.length < 8) {
        setState(() {
          _error = 'Enter a valid phone number';
        });
        return;
      }
    } else {
      if (_email.isEmpty || !_email.contains('@')) {
        setState(() {
          _error = 'Enter a valid email';
        });
        return;
      }
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final r = await ref.read(forgotPasswordProvider)(
      _method == ForgotMethod.phone ? 'sms' : 'email',
      _method == ForgotMethod.phone ? _fullPhone(_phone) : '',
      _method == ForgotMethod.email ? _email.trim() : '',
    );
    if (!mounted) return;
    r.when(
      success: (_) => setState(() {
        _isLoading = false;
        _otpSent = true;
        _startCooldown();
      }),
      failure: (e) => setState(() {
        _isLoading = false;
        _error = e.message;
      }),
    );
  }

  Future<void> _resetPassword() async {
    final o = _otp.replaceAll(RegExp(r'[^\d]'), '');
    if (o.length != 6) {
      setState(() {
        _error = 'Enter 6-digit OTP';
      });
      return;
    }
    if (_password.length < 6) {
      setState(() {
        _error = 'Password must be 6+ characters';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final r = await ref.read(resetPasswordProvider)(
      _method == ForgotMethod.phone ? 'sms' : 'email',
      _method == ForgotMethod.phone ? _fullPhone(_phone) : '',
      _method == ForgotMethod.email ? _email.trim() : '',
      _otp,
      _password,
    );
    if (!mounted) return;
    r.when(
      success: (_) => widget.onBackToLogin(),
      failure: (e) => setState(() {
        _isLoading = false;
        _error = e.message;
      }),
    );
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 30;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_resendCooldown <= 1) {
        setState(() {
          _resendCooldown = 0;
        });
        return false;
      }
      setState(() {
        _resendCooldown--;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandConfigProvider);
    return Scaffold(
      body: AuthBackground(
        brand: brand,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _otpSent
                    ? _buildResetStep(brand)
                    : _buildSendStep(brand),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSendStep(BrandConfig brand) {
    return [
      AuthHeader(
        brand: brand,
        title: 'Reset Password',
        subtitle: 'Choose how to receive the reset code.',
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          _methodChip(ForgotMethod.phone, 'Phone', Icons.phone_android_rounded),
          const SizedBox(width: 12),
          _methodChip(ForgotMethod.email, 'Email', Icons.email_outlined),
        ],
      ),
      const SizedBox(height: 24),
      if (_method == ForgotMethod.phone)
        PhoneInputField(
          brand: brand,
          error: _error,
          onChanged: _setPhone,
          onSubmitted: _sendOtp,
        )
      else
        _EmailField(
          controller: TextEditingController.fromValue(
            TextEditingValue(text: _email),
          ),
          error: _error,
          onChanged: _setEmail,
          onSubmitted: _sendOtp,
        ),
      const SizedBox(height: 16),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _error!,
            style: const TextStyle(color: AppColors.danger, fontSize: 13),
          ),
        ),
      AuthButton(
        text: 'Send OTP',
        isLoading: _isLoading,
        onPressed: _sendOtp,
        brand: brand,
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: widget.onBackToLogin,
        child: const Text('Back to login'),
      ),
    ];
  }

  List<Widget> _buildResetStep(BrandConfig brand) {
    final id = _method == ForgotMethod.phone ? '971 $_phone' : _email;
    return [
      AuthHeader(
        brand: brand,
        title: 'Reset Password',
        subtitle: 'Enter the OTP and your new password.',
        customIcon: Icons.lock_outline_rounded,
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Text(
            id,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() {
              _otpSent = false;
              _otp = '';
              _password = '';
              _error = null;
            }),
            child: Text(
              'Edit',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : AppColors.text3,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _OtpRow(onChanged: _setOtp),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _resendCooldown > 0 ? null : _sendOtp,
        child: Text(
          _resendCooldown > 0
              ? 'Resend code in ${_resendCooldown}s'
              : 'Didn\'t receive a code? Resend code',
          style: TextStyle(
            fontSize: 14,
            color: _resendCooldown > 0 ? AppColors.text4 : brand.accentColor,
            fontWeight: _resendCooldown > 0 ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 20),
      _PasswordField(
        controller: TextEditingController.fromValue(
          TextEditingValue(text: _password),
        ),
        onChanged: _setPassword,
      ),
      const SizedBox(height: 16),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            _error!,
            style: const TextStyle(color: AppColors.danger, fontSize: 13),
          ),
        ),
      AuthButton(
        text: 'Reset Password',
        isLoading: _isLoading,
        onPressed: _resetPassword,
        brand: brand,
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: widget.onBackToLogin,
        child: const Text('Back to login'),
      ),
    ];
  }

  Widget _methodChip(ForgotMethod m, String label, IconData icon) {
    final selected = _method == m;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? const Color(0xFF1F2937) : Colors.white)
                : (isDark ? const Color(0xFF161E2E) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFFE2E8F0) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? null
                    : (isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpRow extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _OtpRow({required this.onChanged});
  @override
  State<_OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<_OtpRow> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^\d]'), '');
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final otp = _controllers.map((c) => c.text).join();
      widget.onChanged(otp);
      _focusNodes[digits.length.clamp(0, 5)].requestFocus();
      return;
    }
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final focused = _focusNodes[i].hasFocus;
        return Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161E2E) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: focused || filled
                  ? const Color(0xFFE2E8F0)
                  : (isDark
                        ? const Color(0xFF26334D)
                        : const Color(0xFFE2E8F0)),
              width: focused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }
}

Widget _EmailField({
  required TextEditingController controller,
  String? error,
  ValueChanged<String>? onChanged,
  VoidCallback? onSubmitted,
}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        const SizedBox(width: 14),
        const Icon(Icons.email_outlined, size: 20, color: AppColors.text4),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'email@example.com',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.text4, fontSize: 14),
            ),
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted?.call(),
          ),
        ),
      ],
    ),
  );
}

Widget _PasswordField({
  required TextEditingController controller,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    height: 52,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        const SizedBox(width: 14),
        const Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: AppColors.text4,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'New password',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.text4, fontSize: 14),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}
