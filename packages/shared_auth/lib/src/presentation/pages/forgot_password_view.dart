import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/presentation/providers/auth_providers.dart';
import 'package:shared_auth/src/presentation/widgets/auth_background.dart';
import 'package:shared_auth/src/presentation/widgets/auth_button.dart';
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

  final TextEditingController _unifiedCtrl = TextEditingController();
  late final TextEditingController _passCtrl;

  @override
  void initState() {
    super.initState();
    _passCtrl = TextEditingController(text: _password);
  }

  @override
  void dispose() {
    _unifiedCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  void _setOtp(String v) {
    final c = v.replaceAll(RegExp(r'[^\d]'), '');
    if (c.length <= 6) {
      setState(() {
        _otp = c;
        _error = null;
      });
    }
  }

  void _setPassword(String v) {
    setState(() {
      _password = v;
      _error = null;
    });
  }

  String _fullPhone(String p) {
    final c = p.replaceAll(RegExp(r'[^\d]'), '');
    if (c.startsWith('971')) return c;
    return '971${c.startsWith('0') ? c.substring(1) : c}';
  }

  Future<void> _sendOtp() async {
    final input = _unifiedCtrl.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'Enter your email or phone');
      return;
    }

    // Smart detection
    final isEmail = input.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(input);
    setState(() {
      _method = isEmail ? ForgotMethod.email : ForgotMethod.phone;
      if (isEmail) {
        _email = input;
        if (!_email.contains('@')) _error = 'Enter a valid email';
      } else {
        _phone = input.replaceAll(RegExp(r'[^\d]'), '');
        if (_phone.length < 8) _error = 'Enter a valid phone number';
      }
    });

    if (_error != null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final r = await ref.read(forgotPasswordProvider)(
      _method == ForgotMethod.phone ? 'sms' : 'email',
      _method == ForgotMethod.phone ? _fullPhone(_phone) : '',
      _method == ForgotMethod.email ? _email : '',
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
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    if (_password.length < 6) {
      setState(() => _error = 'Password must be 6+ characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final r = await ref.read(resetPasswordProvider)(
      _method == ForgotMethod.phone ? 'sms' : 'email',
      _method == ForgotMethod.phone ? _fullPhone(_phone) : '',
      _method == ForgotMethod.email ? _email : '',
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
      _passCtrl.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandConfigProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AuthBackground(
        brand: brand,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_otpSent),
                  child: _otpSent ? _buildResetStep(brand, theme) : _buildSendStep(brand, theme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendStep(BrandConfig brand, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(brand.icon, color: theme.colorScheme.primary, size: 40),
        const SizedBox(height: 32),
        Text(
          'Reset password',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email or phone number to receive a recovery code.',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 56),
        _PremiumTextField(
          controller: _unifiedCtrl,
          hint: 'Email or phone',
          keyboardType: TextInputType.emailAddress,
          error: _error,
          onChanged: (_) => _clearError(),
          onSubmitted: (_) => _sendOtp(),
        ),
        const SizedBox(height: 40),
        AuthButton(text: 'Send Code', isLoading: _isLoading, onPressed: _sendOtp, brand: brand),
        const SizedBox(height: 32),
        _ActionLink(text: 'Back to login', onTap: widget.onBackToLogin),
      ],
    );
  }

  Widget _buildResetStep(BrandConfig brand, ThemeData theme) {
    final identifier = _method == ForgotMethod.phone ? '971 $_phone' : _email;
    final isEmail = _method == ForgotMethod.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check ${isEmail ? 'inbox' : 'messages'}.',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              identifier,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _editIdentifier,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Edit',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        _MinimalOtpRow(onChanged: _setOtp),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _resendCooldown > 0 ? null : _sendOtp,
          behavior: HitTestBehavior.opaque,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.titleSmall!.copyWith(
              color: _resendCooldown > 0
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                  : theme.colorScheme.primary,
              fontWeight: _resendCooldown > 0 ? FontWeight.w500 : FontWeight.w600,
            ),
            child: Text(_resendCooldown > 0 ? 'Resend code in ${_resendCooldown}s' : 'Didn\'t receive a code? Resend'),
          ),
        ),
        const SizedBox(height: 48),
        _PremiumTextField(
          controller: _passCtrl,
          hint: 'New password',
          obscure: true,
          onChanged: _setPassword,
          error: _error,
        ),
        const SizedBox(height: 40),
        AuthButton(text: 'Reset Password', isLoading: _isLoading, onPressed: _resetPassword, brand: brand),
        const SizedBox(height: 32),
        _ActionLink(text: 'Back to login', onTap: widget.onBackToLogin),
      ],
    );
  }
}

class _MinimalOtpRow extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _MinimalOtpRow({required this.onChanged});

  @override
  State<_MinimalOtpRow> createState() => _MinimalOtpRowState();
}

class _MinimalOtpRowState extends State<_MinimalOtpRow> {
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
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final focused = _focusNodes[i].hasFocus;
        final filled = _controllers[i].text.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 56,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: focused
                    ? theme.colorScheme.primary
                    : (filled
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                width: focused ? 2.5 : 1.5,
              ),
            ),
          ),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: theme.colorScheme.primary,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
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

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? error;

  const _PremiumTextField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.obscure = false,
    this.keyboardType,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: theme.colorScheme.onSurface,
          ),
          cursorColor: theme.colorScheme.primary,
          cursorHeight: 24,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              fontWeight: FontWeight.w400,
              letterSpacing: -0.3,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), width: 1.0),
            ),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0)),
            isDense: true,
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: error != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ActionLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;

  const _ActionLink({required this.text, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
