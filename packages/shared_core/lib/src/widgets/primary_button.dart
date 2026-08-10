import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.icon,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          disabledBackgroundColor: effectiveBackgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: effectiveForegroundColor.withValues(alpha: 0.7),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(0, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppDimensions.iconSm),
                      const SizedBox(width: AppDimensions.s8),
                    ],
                    Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: effectiveForegroundColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final Color? foregroundColor;
  final Color? borderColor;
  final double height;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.foregroundColor,
    this.borderColor,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline.withValues(alpha: 0.16);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveForegroundColor,
          disabledForegroundColor: effectiveForegroundColor.withValues(alpha: 0.38),
          side: BorderSide(color: effectiveBorderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
          minimumSize: Size(0, height),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: AppDimensions.iconSm, color: effectiveForegroundColor),
              const SizedBox(width: AppDimensions.s8),
            ],
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(color: effectiveForegroundColor, fontWeight: FontWeight.w600),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppDimensions.s8),
              Icon(trailingIcon, size: AppDimensions.iconSm, color: effectiveForegroundColor),
            ],
          ],
        ),
      ),
    );
  }
}
