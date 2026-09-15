import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Primary call-to-action for authentication surfaces.
///
/// Grows with the surrounding text scale, keeps a comfortable touch target,
/// exposes a clear loading state, and gives a very subtle press response.
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
    final disabled = widget.onPressed == null || widget.isLoading;

    Widget button = FilledButton(
      onPressed: disabled ? null : widget.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.surfaceContainerHighest,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
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
            Icon(widget.icon, size: 18),
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
              ),
            ),
          ),
        ],
      ),
    );

    if (!disabled) {
      button = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: button,
      );
    }

    return Listener(
      onPointerDown: disabled ? null : (_) => _setPressed(true),
      onPointerUp: disabled ? null : (_) => _setPressed(false),
      onPointerCancel: disabled ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: AppMotion.instant,
        curve: AppMotion.standardCurve,
        child: SizedBox(width: double.infinity, child: button),
      ),
    );
  }
}

/// Secondary text action. [subtle] keeps the action visually quiet so it never
/// competes with the primary call-to-action.
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
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
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
