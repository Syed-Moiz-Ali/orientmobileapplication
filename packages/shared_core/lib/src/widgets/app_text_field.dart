import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
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
  final int maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  /// When provided, renders a localized reveal/hide password toggle as the
  /// suffix icon (the parent owns the obscured state).
  final VoidCallback? onToggleObscure;

  /// Identifier variant (Phase 02): forces LTR content direction and Latin
  /// keyboard hints regardless of the UI locale for VIN/plate/phone/SKU/email
  /// values, while the surrounding label/hint still localize.
  final bool isIdentifier;

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
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.label,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.onSubmitted,
    this.onTap,
    this.onToggleObscure,
    this.isIdentifier = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Identifier values (VIN, plate, phone, SKU, email) always render and type
    // left-to-right with Latin glyphs, even inside an Arabic/RTL form.
    final textDirection = isIdentifier ? TextDirection.ltr : null;
    final resolvedTextAlign = isIdentifier ? TextAlign.left : null;

    final effectiveSuffix =
        suffixIcon ??
        (onToggleObscure != null
            ? IconButton(
                tooltip: obscureText
                    ? SharedCoreL10n.of(context).commonShowPassword
                    : SharedCoreL10n.of(context).commonHidePassword,
                onPressed: onToggleObscure,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: AppDimensions.iconMd,
                ),
              )
            : null);

    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      obscureText: obscureText,
      onChanged: onChanged,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onSubmitted: onSubmitted,
      textDirection: textDirection,
      textAlign: resolvedTextAlign ?? TextAlign.start,
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
        suffixIcon: effectiveSuffix,
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
