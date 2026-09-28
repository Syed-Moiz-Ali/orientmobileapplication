import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_motion.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double height;
  final bool isExpanded;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.height = 52.0,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final adaptive = context.adaptive;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
    final effectiveHeight = height == 52.0 ? adaptive.controlHeight : height;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        disabledBackgroundColor: effectiveBackgroundColor.withValues(alpha: 0.5),
        disabledForegroundColor: effectiveForegroundColor.withValues(alpha: 0.7),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s20),
        minimumSize: Size(isExpanded ? double.infinity : 0, effectiveHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.standard,
        switchInCurve: AppMotion.enter,
        switchOutCurve: AppMotion.exit,
        child: isLoading
            ? SizedBox(
                key: const ValueKey('loading'),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveForegroundColor,
                  ),
                ),
              )
            : Row(
                key: const ValueKey('label'),
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconSm),
                    const SizedBox(width: AppDimensions.s8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: effectiveForegroundColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isExpanded ? double.infinity : 0,
        minHeight: effectiveHeight,
      ),
      child: button,
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
  final bool isExpanded;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.foregroundColor,
    this.borderColor,
    this.height = 52.0,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final adaptive = context.adaptive;

    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
    final effectiveBorderColor =
        borderColor ?? AppColors.borderStrong;
    final effectiveHeight = height == 52.0 ? adaptive.controlHeight : height;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveForegroundColor,
        disabledForegroundColor: effectiveForegroundColor.withValues(
          alpha: 0.38,
        ),
        side: BorderSide(color: effectiveBorderColor),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        minimumSize: Size(isExpanded ? double.infinity : 0, effectiveHeight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: AppDimensions.iconSm,
              color: effectiveForegroundColor,
            ),
            const SizedBox(width: AppDimensions.s8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                color: effectiveForegroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: AppDimensions.s8),
            Icon(
              trailingIcon,
              size: AppDimensions.iconSm,
              color: effectiveForegroundColor,
            ),
          ],
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isExpanded ? double.infinity : 0,
        minHeight: effectiveHeight,
      ),
      child: button,
    );
  }
}

/// Unified Action System representing primary, secondary, tertiary, danger, quietIcon, and compactInline.
class AppButton {
  AppButton._();

  /// Primary prominent button
  static Widget primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isExpanded = true,
    double height = 52.0,
  }) {
    return PrimaryButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isExpanded: isExpanded,
      height: height,
    );
  }

  /// Secondary outlined button
  static Widget secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isExpanded = true,
    double height = 52.0,
  }) {
    return SecondaryButton(
      key: key,
      label: label,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isExpanded: isExpanded,
      height: height,
    );
  }

  /// Tertiary / ghost text button with guaranteed 48px touch target
  static Widget tertiary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final fg = color ?? Theme.of(context).colorScheme.primary;
        return TextButton(
          key: key,
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: fg,
            minimumSize: const Size(48, AppDimensions.touchTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimensions.iconSm, color: fg),
                const SizedBox(width: AppDimensions.s6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: fg,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Danger / destructive action button
  static Widget danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool isExpanded = true,
    double height = 52.0,
  }) {
    return PrimaryButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: AppColors.danger,
      isExpanded: isExpanded,
      height: height,
    );
  }

  /// Quiet icon button with guaranteed 48px hit area and soft hover/pressed feedback
  static Widget quietIcon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    Color? color,
    double size = 20.0,
  }) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final iconColor = color ?? colors.onSurfaceVariant;
        return IconButton(
          key: key,
          onPressed: onPressed,
          tooltip: tooltip,
          iconSize: size,
          style: IconButton.styleFrom(
            foregroundColor: iconColor,
            minimumSize: const Size.square(AppDimensions.touchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
          ),
          icon: Icon(icon, color: iconColor),
        );
      },
    );
  }

  /// Compact inline action for table rows or cards (36px visual height, 48px touch target hit area)
  static Widget compactInline({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isPrimary = false,
  }) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
          child: Center(
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                key: key,
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPrimary ? colors.primary : colors.surface,
                  foregroundColor: isPrimary ? colors.onPrimary : colors.onSurface,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  side: isPrimary ? null : BorderSide(color: AppColors.borderDefault),
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14),
                      const SizedBox(width: AppDimensions.s4),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

