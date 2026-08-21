import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool obscureText;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.obscureText = false,
    this.fillColor,
    this.keyboardType,
    this.maxLength,
    this.textInputAction,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s16,
          vertical: AppDimensions.s14,
        ),
      ),
    );
  }
}
