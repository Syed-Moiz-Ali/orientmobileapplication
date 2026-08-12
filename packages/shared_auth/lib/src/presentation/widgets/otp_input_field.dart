import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

class OtpInputField extends StatefulWidget {
  final Color accentColor;
  final String phone;

  /// Display label for the verification target (e.g. '+971 50 123 4567').
  /// When null the widget falls back to showing the raw [phone] value.
  final String? identifierLabel;
  final String? error;
  final bool isLoading;
  final int resendCooldown;
  final VoidCallback onResend;
  final VoidCallback onChangePhone;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onVerify;

  const OtpInputField({
    super.key,
    required this.phone,
    this.accentColor = AppColors.primary,
    this.identifierLabel,
    required this.error,
    required this.isLoading,
    required this.resendCooldown,
    required this.onResend,
    required this.onChangePhone,
    required this.onOtpChanged,
    required this.onVerify,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {});
        }
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes[0].canRequestFocus) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^\d]'), '');
      for (int i = 0; i < 6; i++) {
        if (i < digits.length) {
          _controllers[i].text = digits[i];
        } else {
          _controllers[i].clear();
        }
      }
      final currentOtp = _controllers.map((c) => c.text).join();
      widget.onOtpChanged(currentOtp);
      if (digits.length >= 6) {
        _focusNodes[5].requestFocus();
        widget.onVerify();
      } else {
        _focusNodes[digits.length.clamp(0, 5)].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    final currentOtp = _controllers.map((c) => c.text).join();
    widget.onOtpChanged(currentOtp);

    if (currentOtp.length == 6) {
      widget.onVerify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = widget.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.identifierLabel ?? widget.phone,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onChangePhone,
              child: Text(
                'Edit',
                style: TextStyle(
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.text3,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final isFilled = _controllers[index].text.isNotEmpty;

            return Container(
              width: 44,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF161E2E)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.error != null
                      ? AppColors.danger
                      : (isFocused
                            ? accentColor
                            : (isFilled
                                  ? accentColor.withValues(alpha: 0.5)
                                  : (isDark
                                        ? const Color(0xFF26334D)
                                        : const Color(0xFFE2E8F0)))),
                  width: isFocused ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _onDigitChanged(index, value),
              ),
            );
          }),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.error!,
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: widget.resendCooldown > 0 ? null : widget.onResend,
          child: Text(
            widget.resendCooldown > 0
                ? 'Resend code in ${widget.resendCooldown}s'
                : 'Didn\'t receive a code? Resend code',
            style: TextStyle(
              color: widget.resendCooldown > 0
                  ? (isDark ? Colors.white38 : AppColors.text4)
                  : accentColor,
              fontSize: 14,
              fontWeight: widget.resendCooldown > 0
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
