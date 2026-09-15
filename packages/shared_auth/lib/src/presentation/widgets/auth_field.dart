import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_core/shared_core.dart';

/// Auth-scoped text field used across the shared authentication surfaces.
///
/// The label is rendered above the control instead of floating inside it so
/// hierarchy stays readable at large text scales and focus / error states are
/// communicated once, consistently. The control intentionally keeps a calm
/// default border and only spends cobalt on the label and border while focused
/// or invalid.
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
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final accent = hasError
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
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
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
          cursorColor: colors.primary,
          cursorRadius: const Radius.circular(AppDimensions.r2),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: widget.enabled ? colors.onSurface : colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            errorMaxLines: 2,
            filled: true,
            fillColor: widget.enabled
                ? colors.surface
                : colors.surfaceContainerLow,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s14,
              vertical: AppDimensions.s16,
            ),
            prefixIcon: Icon(widget.icon, size: AppDimensions.iconMd),
            prefixIconColor: accent,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: widget.enabled
                        ? () => setState(() => _hidden = !_hidden)
                        : null,
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: AppDimensions.iconMd,
                    ),
                    color: colors.onSurfaceVariant,
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                  )
                : null,
            border: outline(colors.outlineVariant),
            enabledBorder: outline(colors.outlineVariant),
            disabledBorder: outline(
              colors.outlineVariant.withValues(alpha: 0.6),
            ),
            focusedBorder: outline(colors.primary, 1.6),
            errorBorder: outline(colors.error, 1.2),
            focusedErrorBorder: outline(colors.error, 1.6),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }
}

/// Six-digit verification code input used by the one-time-code and password
/// recovery flows.
class AuthOtpField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;
  final String label;
  final bool autofocus;

  const AuthOtpField({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.label = 'Verification code',
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
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

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
          color: widget.enabled
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = ((constraints.maxWidth - 40) / 6)
                .clamp(42.0, 54.0)
                .toDouble();
            final defaultTheme = pinTheme(
              width: fieldWidth,
              borderColor: colorScheme.outlineVariant,
              fillColor: colorScheme.surface,
            );

            return Pinput(
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
                borderWidth: 1.8,
              ),
              submittedPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.primary.withValues(alpha: 0.5),
                fillColor: colorScheme.surfaceContainerLow,
              ),
              disabledPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.outlineVariant.withValues(alpha: 0.6),
                fillColor: colorScheme.surfaceContainerLow,
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
            );
          },
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimensions.s8),
          Semantics(
            liveRegion: true,
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
