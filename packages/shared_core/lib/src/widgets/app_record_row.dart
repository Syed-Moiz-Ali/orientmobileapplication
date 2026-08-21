import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// A compact, accessible record surface for operational lists and settings.
class AppRecordRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? metadata;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool emphasized;
  final EdgeInsetsGeometry padding;

  const AppRecordRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.metadata,
    this.trailing,
    this.onTap,
    this.emphasized = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.s16,
      vertical: AppDimensions.s14,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: emphasized
          ? colors.primary.withValues(alpha: 0.045)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        side: BorderSide(
          color: emphasized
              ? colors.primary.withValues(alpha: 0.28)
              : colors.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppDimensions.s14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (metadata != null) ...[
                      const SizedBox(height: AppDimensions.s8),
                      metadata!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppDimensions.s12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
