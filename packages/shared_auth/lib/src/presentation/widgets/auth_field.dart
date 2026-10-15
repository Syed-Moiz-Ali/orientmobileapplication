import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Auth-scoped text field used across the shared authentication surfaces.
///
/// The label renders above the control (never floating) so hierarchy stays
/// readable at 1.3x text scale; focus and error spend cobalt/error ink once,
/// on both the label and the border. Validation copy arrives via [errorText]
/// and is associated with the control through the input decoration, so screen
/// readers announce it with the field.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final String? errorText;
  final Widget? labelTrailing;

  /// Optional slot rendered below the control (Phase 01.2) — e.g. an
  /// [AuthPasswordStrength] meter on create-password fields. Presentation
  /// only; validation copy stays in [errorText].
  final Widget? belowField;

  /// Forces a fixed text direction for the control content. Identifier fields
  /// (email, mobile, username) set this to [TextDirection.ltr] so mixed
  /// Arabic/Latin entry stays legible inside RTL layouts.
  final TextDirection? textDirection;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.errorText,
    this.labelTrailing,
    this.belowField,
    this.textDirection,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden;
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText;
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _hidden = widget.obscureText;
    }
  }

  void _handleFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final disabled = context.semanticColors;
    final t = SharedAuthL10n.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final accent = !widget.enabled
        ? disabled.disabledInk
        : hasError
        ? colors.error
        : _focused
        ? colors.primary
        : colors.onSurfaceVariant;

    OutlineInputBorder outline(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: theme.textTheme.labelMedium?.copyWith(color: accent, fontWeight: FontWeight.w700, height: 1.3),
              ),
            ),
            if (widget.labelTrailing != null) widget.labelTrailing!,
          ],
        ),
        const SizedBox(height: AppDimensions.s8),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          autocorrect: false,
          obscureText: _hidden,
          textDirection: widget.textDirection,
          cursorColor: colors.primary,
          cursorRadius: const Radius.circular(AppDimensions.r2),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: widget.enabled ? colors.onSurface : disabled.disabledInk,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            errorMaxLines: 2,
            filled: true,
            // Recessed fill at rest, lifting to the surface on focus so the
            // field feels responsive; disabled uses the semantic pair.
            fillColor: !widget.enabled
                ? disabled.disabledFill
                : _focused && !hasError
                ? colors.surface
                : colors.surfaceContainerLow,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.s14, vertical: AppDimensions.s16),
            prefixIcon: Icon(widget.icon, size: AppDimensions.iconMd),
            prefixIconColor: accent,
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: widget.enabled ? () => setState(() => _hidden = !_hidden) : null,
                    icon: Icon(
                      _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: AppDimensions.iconMd,
                    ),
                    color: colors.onSurfaceVariant,
                    // Labeled visibility toggle: tooltip doubles as the
                    // accessible name, announced distinctly per state.
                    tooltip: _hidden ? t.authShowPassword : t.authHidePassword,
                  )
                : null,
            border: outline(colors.outline),
            enabledBorder: outline(colors.outline),
            disabledBorder: outline(disabled.disabledBorder),
            // 2px primary focus ring; errors keep the 1.2/1.5 error ramp so
            // focus and invalid never share one treatment.
            focusedBorder: outline(colors.primary, 2),
            errorBorder: outline(colors.error, 1.2),
            focusedErrorBorder: outline(colors.error, 1.5),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(color: colors.error, fontWeight: FontWeight.w600),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
        if (widget.belowField != null) ...[const SizedBox(height: AppDimensions.s8), widget.belowField!],
      ],
    );
  }
}

/// Six-digit verification code input used by the one-time-code and password
/// recovery flows.
///
/// Grouped and labelled: the whole block exposes one [Semantics] node carrying
/// the field label plus the error (when present), while the error line itself
/// is a live region. Digits stay LTR-locked and numeric-only so Arabic-layout
/// entry cannot produce mirrored or non-digit codes.
class AuthOtpField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;

  /// Label. When null it resolves to the localized "Verification code".
  final String? label;
  final bool autofocus;

  const AuthOtpField({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.label,
    this.autofocus = true,
  });

  @override
  State<AuthOtpField> createState() => _AuthOtpFieldState();
}

class _AuthOtpFieldState extends State<AuthOtpField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = SharedAuthL10n.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final resolvedLabel = widget.label ?? t.loginFieldVerificationCode;

    PinTheme pinTheme({
      required double width,
      required Color borderColor,
      required Color fillColor,
      double borderWidth = 1,
    }) {
      return PinTheme(
        width: width,
        height: 56,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          color: widget.enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
      );
    }

    return Semantics(
      container: true,
      label: resolvedLabel,
      value: hasError ? widget.errorText : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resolvedLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          LayoutBuilder(
            builder: (context, constraints) {
              final fieldWidth = ((constraints.maxWidth - 40) / 6).clamp(42.0, 54.0).toDouble();
              final defaultTheme = pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.outlineVariant,
                fillColor: colorScheme.surfaceContainerLow,
              );

              return Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _controller,
                  length: 6,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: pinTheme(
                    width: fieldWidth,
                    borderColor: colorScheme.primary,
                    fillColor: colorScheme.surface,
                    borderWidth: 2,
                  ),
                  submittedPinTheme: pinTheme(
                    width: fieldWidth,
                    borderColor: colorScheme.primary.withValues(alpha: 0.5),
                    fillColor: colorScheme.surfaceContainerLow,
                  ),
                  disabledPinTheme: pinTheme(
                    width: fieldWidth,
                    borderColor: context.semanticColors.disabledBorder,
                    fillColor: context.semanticColors.disabledFill,
                  ),
                  errorPinTheme: pinTheme(
                    width: fieldWidth,
                    borderColor: colorScheme.error,
                    fillColor: colorScheme.errorContainer.withValues(alpha: 0.2),
                    borderWidth: 1.5,
                  ),
                  forceErrorState: hasError,
                  onChanged: widget.onChanged,
                  onCompleted: widget.onSubmitted,
                ),
              );
            },
          ),
          if (hasError) ...[
            const SizedBox(height: AppDimensions.s8),
            Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
