import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Primary call-to-action for authentication surfaces.
///
/// Busy and disabled are visually and semantically distinct: busy keeps the
/// active cobalt fill with a spinner (the action is running), genuinely
/// disabled falls back to the neutral fill (the action is unavailable).
/// Minimum 52px height keeps every auth CTA on a 48dp target.
class AuthPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabledTokens = context.semanticColors;
    final disabled = widget.onPressed == null || widget.isLoading;

    // The label follows the button ink explicitly: on-primary while
    // enabled/busy (AA on cobalt in both themes), the semantic disabled ink
    // when genuinely disabled — never a faded primary. Inheriting the theme
    // text color here previously failed contrast, so this mapping is
    // load-bearing.
    final genuinelyDisabled = widget.onPressed == null && !widget.isLoading;
    final labelColor = genuinelyDisabled
        ? disabledTokens.disabledInk
        : colorScheme.onPrimary;

    final Widget button = FilledButton(
      onPressed: disabled ? null : widget.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        // Busy keeps active-strength fill + ink so spinner and label stay AA;
        // genuinely disabled uses the semantic disabled pair.
        disabledBackgroundColor: widget.isLoading
            ? colorScheme.primary
            : disabledTokens.disabledFill,
        disabledForegroundColor: widget.isLoading
            ? colorScheme.onPrimary
            : disabledTokens.disabledInk,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s20,
          vertical: AppDimensions.s14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLoading) ...[
            ExcludeSemantics(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
          ] else if (widget.icon != null) ...[
            DirectionalIcon(
              widget.icon!,
              size: 18,
              color: labelColor,
              mirrorInRtl: DirectionalIcon.isDirectional(widget.icon!),
            ),
            const SizedBox(width: AppDimensions.s8),
          ],
          Flexible(
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );

    // Restrained cobalt lift while actionable; flat while busy/disabled so
    // the elevation itself communicates state.
    final Widget lifted = disabled
        ? SizedBox(width: double.infinity, child: button)
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: SizedBox(width: double.infinity, child: button),
          );

    return Listener(
      onPointerDown: disabled ? null : (_) => _setPressed(true),
      onPointerUp: disabled ? null : (_) => _setPressed(false),
      onPointerCancel: disabled ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: AppMotion.instant,
        curve: AppMotion.standardCurve,
        child: lifted,
      ),
    );
  }
}

/// Secondary text action. [subtle] keeps the action visually quiet so it never
/// competes with the primary call-to-action. 48px minimum keeps the target.
class AuthLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool subtle;

  const AuthLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.subtle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = subtle ? colorScheme.onSurfaceVariant : colorScheme.primary;

    return TextButton(
      onPressed: onPressed,
      // Subtle 8% self-overlay on hover/focus/press (desktop pointer +
      // keyboard focus) so secondary actions feel responsive, never flat.
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: colorScheme.onSurfaceVariant.withValues(
          alpha: 0.6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s8,
          vertical: AppDimensions.s10,
        ),
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ).copyWith(
        overlayColor: WidgetStatePropertyAll(color.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            DirectionalIcon(
              icon!,
              size: 18,
              color: color,
              mirrorInRtl: DirectionalIcon.isDirectional(icon!),
            ),
            const SizedBox(width: AppDimensions.s6),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resend control shared by the one-time-code and recovery flows.
///
/// While [cooldownSeconds] is positive it renders a 20px progress ring (the
/// remaining fraction of the 30s window) beside quiet countdown copy; at zero
/// it becomes a subtle link. [busy] disables interaction without changing the
/// treatment, so resend never competes with the primary CTA.
class AuthResendAction extends StatelessWidget {
  final int cooldownSeconds;
  final bool busy;
  final VoidCallback onResend;

  const AuthResendAction({
    super.key,
    required this.cooldownSeconds,
    required this.busy,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedAuthL10n.of(context);
    final waiting = cooldownSeconds > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (waiting) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: cooldownSeconds / 30,
              strokeWidth: 2.5,
              color: colors.primary,
              backgroundColor: colors.outlineVariant,
              semanticsLabel: t.loginActionResendIn(cooldownSeconds),
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
        ],
        AuthLinkButton(
          label: waiting
              ? t.loginActionResendIn(cooldownSeconds)
              : t.loginActionResendCode,
          subtle: true,
          onPressed: waiting || busy ? null : onResend,
        ),
      ],
    );
  }
}

/// Backwards-compatible alias kept for callers that already use [AuthButton].
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AuthPrimaryButton(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}
