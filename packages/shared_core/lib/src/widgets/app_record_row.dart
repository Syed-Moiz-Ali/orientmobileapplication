import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// A compact, accessible record surface for operational lists, vehicles, jobs, bookings, and settings.
class AppRecordRow extends StatelessWidget {
  final Widget? leading;
  final String? identifier;
  final String title;
  final String? subtitle;
  final Widget? metadata;
  final Widget? status;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool emphasized;
  final EdgeInsetsGeometry padding;

  const AppRecordRow({
    super.key,
    this.leading,
    this.identifier,
    required this.title,
    this.subtitle,
    this.metadata,
    this.status,
    this.trailing,
    this.onTap,
    this.emphasized = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.s16,
      vertical: AppDimensions.s12,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: emphasized
          ? AppColors.primarySubtle
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: emphasized
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.borderDefault,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: colors.primary.withValues(alpha: 0.08),
        highlightColor: colors.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppDimensions.s12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (identifier != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.s6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                        ),
                        child: Text(
                          identifier!,
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurfaceVariant,
                            letterSpacing: 0.4,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(width: AppDimensions.s8),
                          status!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (metadata != null) ...[
                      const SizedBox(height: AppDimensions.s6),
                      metadata!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppDimensions.s12),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: AppDimensions.s8),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
