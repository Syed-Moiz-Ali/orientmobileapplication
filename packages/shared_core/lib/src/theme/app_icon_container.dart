import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

enum AppIconSize {
  small(32, AppDimensions.iconSm, AppDimensions.radiusControl),
  medium(40, AppDimensions.iconMd, AppDimensions.radiusInput),
  large(48, AppDimensions.iconLg, AppDimensions.radiusCard);

  final double containerSize;
  final double iconSize;
  final double radius;

  const AppIconSize(this.containerSize, this.iconSize, this.radius);
}

/// Reusable semantic icon container for the ORIENT visual grammar.
///
/// Renders an optically balanced square / rounded-square with a pale semantic
/// tint fill and centered icon.
class AppIconContainer extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final AppIconSize size;
  final VoidCallback? onTap;
  final String? tooltip;

  const AppIconContainer({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.borderColor,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  });

  /// Primary cobalt brand variant with pale electric blue background.
  const AppIconContainer.primary({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.primarySubtle,
       iconColor = AppColors.primary,
       borderColor = AppColors.primaryBorder;

  /// Semantic success variant (verified, completed, paid).
  const AppIconContainer.success({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.successSubtle,
       iconColor = AppColors.success,
       borderColor = AppColors.successBorder;

  /// Semantic warning variant (pending, attention, review).
  const AppIconContainer.warning({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.warningSubtle,
       iconColor = AppColors.warning,
       borderColor = AppColors.warningBorder;

  /// Semantic danger variant (rejected, emergency, breakdown).
  const AppIconContainer.danger({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.dangerSubtle,
       iconColor = AppColors.danger,
       borderColor = AppColors.dangerBorder;

  /// Semantic info variant (notices, telemetry, calendar).
  const AppIconContainer.info({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.infoSubtle,
       iconColor = AppColors.info,
       borderColor = AppColors.infoBorder;

  /// Inverse navy variant for placement inside dark panels.
  const AppIconContainer.navy({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.navySurfaceRaised,
       iconColor = Colors.white,
       borderColor = AppColors.navyBorder;

  /// Neutral quiet slate variant for inactive or structural slots.
  const AppIconContainer.neutral({
    super.key,
    required this.icon,
    this.size = AppIconSize.medium,
    this.onTap,
    this.tooltip,
  }) : backgroundColor = AppColors.surfaceSunken,
       iconColor = AppColors.textSecondary,
       borderColor = AppColors.borderDefault;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: size.containerSize,
      height: size.containerSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size.radius),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Center(
        child: Icon(icon, size: size.iconSize, color: iconColor),
      ),
    );

    if (onTap == null) {
      if (tooltip != null) {
        return Tooltip(message: tooltip, child: box);
      }
      return box;
    }

    Widget interactive = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size.radius),
        child: box,
      ),
    );

    // Enforce 48px touch target hit area when interactive
    if (size.containerSize < AppDimensions.touchTarget) {
      interactive = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppDimensions.touchTarget,
          minHeight: AppDimensions.touchTarget,
        ),
        child: Center(child: interactive),
      );
    }

    if (tooltip != null) {
      interactive = Tooltip(message: tooltip, child: interactive);
    }

    return interactive;
  }
}
