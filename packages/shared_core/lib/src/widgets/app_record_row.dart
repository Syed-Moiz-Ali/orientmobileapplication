import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_density.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

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
    final semantic = context.semanticColors;
    final density = context.density;
    final textTheme = theme.textTheme;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));
    // Phase 01.2 density: default padding follows the active density mode;
    // an explicit [padding] override is honoured as-is.
    const defaultPadding = EdgeInsets.symmetric(
      horizontal: AppDimensions.s16,
      vertical: AppDimensions.s12,
    );
    final resolvedPadding = padding == defaultPadding
        ? EdgeInsets.symmetric(
            horizontal: density.rowPaddingHorizontal,
            vertical: density.rowPaddingVertical,
          )
        : padding;

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      container: true,
      child: Material(
        color: emphasized ? semantic.selectedSurface : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(
            color: emphasized
                ? semantic.primary.withValues(alpha: 0.35)
                : semantic.borderDefault,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: resolvedPadding,
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
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXs,
                            ),
                          ),
                          child: Text(
                            identifier!,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurfaceVariant,
                              letterSpacing: arabic ? 0 : 0.4,
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
                                fontWeight: FontWeight.w700,
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
                  DirectionalIcon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
