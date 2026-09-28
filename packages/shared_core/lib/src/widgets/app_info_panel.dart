import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_icon_container.dart';

/// Semantic variants for explanatory information panels.
enum AppInfoPanelVariant { neutral, primary, success, warning, danger, navy }

/// Explanatory block component for offline modes, vehicle notices, warranty warnings,
/// approval statuses, instructions, or summaries.
class AppInfoPanel extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final Widget? action;
  final AppInfoPanelVariant variant;
  final VoidCallback? onTap;

  const AppInfoPanel({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.action,
    this.variant = AppInfoPanelVariant.neutral,
    this.onTap,
  });

  const AppInfoPanel.neutral({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.action,
    this.onTap,
  }) : variant = AppInfoPanelVariant.neutral;

  const AppInfoPanel.primary({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.info_rounded,
    this.action,
    this.onTap,
  }) : variant = AppInfoPanelVariant.primary;

  const AppInfoPanel.success({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.check_circle_outline_rounded,
    this.action,
    this.onTap,
  }) : variant = AppInfoPanelVariant.success;

  const AppInfoPanel.warning({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
    this.action,
    this.onTap,
  }) : variant = AppInfoPanelVariant.warning;

  const AppInfoPanel.danger({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.action,
    this.onTap,
  }) : variant = AppInfoPanelVariant.danger;

  const AppInfoPanel.navy({
    super.key,
    this.title,
    required this.message,
    this.icon = Icons.shield_outlined,
    this.action,
    this.onTap,
  }) : variant = AppInfoPanelVariant.navy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final (bgColor, borderColor, fgColor, iconColor) = switch (variant) {
      AppInfoPanelVariant.neutral => (
        AppColors.surfaceSubtle,
        AppColors.borderDefault,
        theme.colorScheme.onSurface,
        theme.colorScheme.onSurfaceVariant,
      ),
      AppInfoPanelVariant.primary => (
        AppColors.primarySubtle,
        AppColors.primary.withValues(alpha: 0.3),
        theme.colorScheme.onSurface,
        AppColors.primary,
      ),
      AppInfoPanelVariant.success => (
        const Color(0xFFF0FDF4),
        const Color(0xFFBBF7D0),
        const Color(0xFF166534),
        AppColors.success,
      ),
      AppInfoPanelVariant.warning => (
        const Color(0xFFFFFBEB),
        const Color(0xFFFDE68A),
        const Color(0xFF92400E),
        AppColors.warning,
      ),
      AppInfoPanelVariant.danger => (
        const Color(0xFFFEF2F2),
        const Color(0xFFFECACA),
        const Color(0xFF991B1B),
        AppColors.danger,
      ),
      AppInfoPanelVariant.navy => (
        AppColors.navy,
        const Color(0xFF2A3A5E),
        Colors.white,
        const Color(0xFF60A5FA),
      ),
    };

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          variant == AppInfoPanelVariant.navy
              ? AppIconContainer(
                  icon: icon!,
                  size: AppIconSize.small,
                  iconColor: iconColor,
                  backgroundColor: iconColor.withValues(alpha: 0.15),
                )
              : Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: AppDimensions.s12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fgColor,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  color: variant == AppInfoPanelVariant.navy
                      ? Colors.white.withValues(alpha: 0.85)
                      : fgColor.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppDimensions.s8),
                action!,
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.s14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: borderColor),
          ),
          child: content,
        ),
      ),
    );
  }
}
