import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_icon_container.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

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
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final semantic = context.semanticColors;

    final (bgColor, borderColor, fgColor, iconColor) = switch (variant) {
      AppInfoPanelVariant.neutral => (
        semantic.surfaceSunken,
        semantic.borderDefault,
        colors.onSurface,
        colors.onSurfaceVariant,
      ),
      AppInfoPanelVariant.primary => (
        semantic.primarySubtle,
        semantic.primaryBorder,
        colors.onSurface,
        semantic.primary,
      ),
      AppInfoPanelVariant.success => (
        semantic.success.subtle,
        semantic.success.border,
        semantic.success.ink,
        semantic.success.base,
      ),
      AppInfoPanelVariant.warning => (
        semantic.warning.subtle,
        semantic.warning.border,
        semantic.warning.ink,
        semantic.warning.base,
      ),
      AppInfoPanelVariant.danger => (
        semantic.danger.subtle,
        semantic.danger.border,
        semantic.danger.ink,
        semantic.danger.base,
      ),
      // The navy panel is a fixed brand asset (inverse high-emphasis surface);
      // it intentionally does not follow the light/dark semantic palette.
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
          AppIconContainer(
            icon: icon!,
            size: AppIconSize.small,
            iconColor: iconColor,
            backgroundColor: iconColor.withValues(alpha: 0.14),
            borderColor: borderColor.withValues(alpha: 0.6),
          ),
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
