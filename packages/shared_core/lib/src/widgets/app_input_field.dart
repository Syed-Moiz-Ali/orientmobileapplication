import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Spec-C8 text field, phase-1b name `AppInputField`.
///
/// Named `AppInputField` (not spec `AppTextField`) because the legacy
/// `AppTextField` in `app_text_field.dart` owns that name and is off-limits
/// in phase 1. Rename path: once the legacy field is removed in the polish
/// phase, rename `AppInputField` → `AppTextField` in one codemod.
///
/// ```dart
/// AppInputField(
///   label: 'Email',
///   controller: _email,
///   keyboardType: TextInputType.emailAddress,
///   forceLtr: true,
///   error: _emailError, // icon + text, announced via live region
/// )
/// ```
///
/// - Tokens only (fill surfaceAlt, 1px [AppTokens.inputBorder] resting border
///   at >= 3:1, 1.5px accent focus, 1.5px error border, radius 12).
/// - Label above (labelMedium, textSecondary); helper/error below (error =
///   icon + text, never color alone; errors announced via live region).
/// - Password toggle with Semantics; prefix/suffix 20px icons.
/// - Disabled = 40% opacity; readOnly supported.
/// - `forceLtr`: typed text and caret stay LTR (email/phone/URL/OTP/numbers)
///   while label/hint/error follow the locale. Value text uses physical-left
///   alignment so the caret and glyph order never jump when the surrounding
///   layout mirrors.
/// - Keyboard/IME pass-through: keyboardType, textInputAction, autofillHints,
///   obscureText, inputFormatters, onChanged/onSubmitted/focusNode. No logic
///   inside the widget.
class AppInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool passwordToggle;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool showCounter;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? suffixTooltip;

  /// Lock the *value* (and caret) to LTR inside RTL layouts. Label, hint
  /// and error still follow the locale.
  final bool forceLtr;

  /// Optional slot rendered below the control (e.g. a password-strength
  /// meter). Presentation only; validation copy stays in [error].
  final Widget? belowField;

  /// Optional trailing widget on the label row (e.g. a "Min. 6 characters"
  /// hint). Follows the locale direction.
  final Widget? labelTrailing;

  /// Accessible names for the password visibility toggle. Defaults keep the
  /// previous English copy so existing users see no change; localized
  /// screens pass their own strings.
  final String showPasswordTooltip;
  final String hidePasswordTooltip;

  final TextCapitalization textCapitalization;

  const AppInputField({
    super.key,
    required this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.passwordToggle = false,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffixTooltip,
    this.forceLtr = false,
    this.belowField,
    this.labelTrailing,
    this.showPasswordTooltip = 'Show password',
    this.hidePasswordTooltip = 'Hide password',
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppTokens.of(context);
    final scheme = theme.colorScheme;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    final border = (Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: color, width: width),
        );

    Widget? suffix;
    if (widget.passwordToggle) {
      suffix = AppIconButton(
        icon: _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        onPressed: widget.enabled
            ? () => setState(() => _obscured = !_obscured)
            : null,
        tooltip: _obscured
            ? widget.showPasswordTooltip
            : widget.hidePasswordTooltip,
      );
    } else if (widget.suffixIcon != null) {
      suffix = widget.onSuffixTap == null
          ? DirectionalIcon(widget.suffixIcon!, size: 20, color: scheme.onSurfaceVariant)
      : AppIconButton(
              icon: widget.suffixIcon!,
              onPressed: widget.enabled ? widget.onSuffixTap : null,
              tooltip: widget.suffixTooltip,
              mirrorInRtl:
                  DirectionalIcon.isDirectional(widget.suffixIcon!),
            );
    }

    final field = TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        border: border(tokens.inputBorder, 1),
        enabledBorder: border(tokens.inputBorder, 1),
        focusedBorder: border(scheme.primary, 1.5),
        disabledBorder: border(scheme.outline, 1),
        errorBorder: border(scheme.error, 1.5),
        focusedErrorBorder: border(scheme.error, 1.5),
      prefixIcon: widget.prefixIcon == null
          ? null
          : DirectionalIcon(
              widget.prefixIcon!,
              size: 20,
              color: scheme.onSurfaceVariant,
              mirrorInRtl:
                  DirectionalIcon.isDirectional(widget.prefixIcon!),
            ),
        suffixIcon: suffix == null
            ? null
            : SizedBox(width: 48, height: 48, child: Center(child: suffix)),
        suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        counterText: widget.showCounter ? null : '',
        counterStyle: theme.textTheme.bodySmall,
      ),
      style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      obscureText: _obscured,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      // LTR-locked values keep physical-left alignment so caret and glyph
      // order never jump when the surrounding layout mirrors to RTL.
      textDirection: widget.forceLtr ? TextDirection.ltr : null,
      textAlign: widget.forceLtr ? TextAlign.left : TextAlign.start,
    );

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (widget.labelTrailing != null) widget.labelTrailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.labelValueGap),
          field,
          if (widget.belowField != null) ...[
            const SizedBox(height: AppSpacing.sm),
            widget.belowField!,
          ],
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 16, color: scheme.error),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        widget.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (widget.helper != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                widget.helper!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
