import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Six-digit verification code input used by the one-time-code and password
/// recovery flows.
///
/// Grouped and labelled: the whole block exposes one [Semantics] node carrying
/// the field label plus the error (when present), while the error line itself
/// is a live region. Digits stay LTR-locked and numeric-only so Arabic-layout
/// entry cannot produce mirrored or non-digit codes.
///
/// Third-party concession (phase-2c): Pinput stays, styled on the shared
/// [AppInputField] border ramp — resting uses the [AppTokens.inputBorder]
/// token (3:1+ on page and card, both themes), focus and error use the same
/// 1.5 px accent/error treatment as [AppInputField]. Kept because no App*
/// OTP cell row exists; the LTR lock, autofocus, digits-only filtering and
/// completion behavior are untouched.
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
    final tokens = AppTokens.of(context);
    final t = SharedAuthL10n.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final resolvedLabel = widget.label ?? t.loginFieldVerificationCode;

    // Same ramp as AppInputField: resting = inputBorder token (AA 3:1+ vs
    // the page and card), focus/error = 1.5 px accent/error. The resting
    // outlineVariant and the 2 px focus ring from before are retired.
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
                borderColor: tokens.inputBorder,
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
                    borderWidth: 1.5,
                  ),
                  submittedPinTheme: pinTheme(
                    width: fieldWidth,
                    borderColor: tokens.inputBorder,
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
                    fillColor: colorScheme.surfaceContainerLow,
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
