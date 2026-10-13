import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_icon_container.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/widgets/app_card.dart';

/// Semantic state for KPI metric cards.
enum KpiSemanticState { neutral, success, warning, danger, info }

/// Representation of a real metric trend. Only render when real data exists!
class KpiTrend {
  final String label;
  final bool isPositive;

  /// A flat / unchanged trend (no movement). Renders a neutral icon.
  final bool isFlat;
  final String? timeFrame;

  const KpiTrend({
    required this.label,
    required this.isPositive,
    this.isFlat = false,
    this.timeFrame,
  });
}

/// Operational dashboard metric display component.
/// Supports compact, standard, and wide orientations.
class AppKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? supportingText;
  final KpiTrend? trend;
  final IconData? icon;
  final KpiSemanticState semanticState;
  final VoidCallback? onTap;

  /// Wide layout: icon block on the leading edge, value + label stacked, trend
  /// trailing. Suitable for a single hero row on tablet/desktop.
  final bool isWide;

  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.supportingText,
    this.trend,
    this.icon,
    this.semanticState = KpiSemanticState.neutral,
    this.onTap,
    this.isWide = false,
  });

  const AppKpiCard.compact({
    super.key,
    required this.label,
    required this.value,
    this.supportingText,
    this.icon,
    this.semanticState = KpiSemanticState.neutral,
    this.onTap,
  }) : trend = null,
       isWide = false;

  /// Wide horizontal tile with an optional trend.
  const AppKpiCard.wide({
    super.key,
    required this.label,
    required this.value,
    this.supportingText,
    this.trend,
    this.icon,
    this.semanticState = KpiSemanticState.neutral,
    this.onTap,
  }) : isWide = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dark = theme.brightness == Brightness.dark;

    // Phase 00 frozen decision log (2026-10-13): compact KPI tiles are at
    // least 156 px tall at 1.0x so the Arabic line-height (x1.05) and the
    // label/sub stack never clip at 320 px, and the tile grows with the
    // system text scale (clamped 1.0-2.0x) so 1.3x stays clean.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    final Color semanticColor = switch (semanticState) {
      KpiSemanticState.neutral => colors.onSurfaceVariant,
      KpiSemanticState.success =>
        dark ? AppDarkColors.success : AppColors.success,
      KpiSemanticState.warning =>
        dark ? AppDarkColors.warning : AppColors.warning,
      KpiSemanticState.danger => dark ? AppDarkColors.danger : AppColors.danger,
      KpiSemanticState.info => dark ? AppDarkColors.info : AppColors.info,
    };

    final Widget? iconBlock = icon == null
        ? null
        : AppIconContainer(
            icon: icon!,
            size: AppIconSize.small,
            iconColor: semanticState == KpiSemanticState.neutral
                ? colors.primary
                : semanticColor,
            backgroundColor: semanticState == KpiSemanticState.neutral
                ? colors.primary.withValues(alpha: 0.10)
                : semanticColor.withValues(alpha: 0.12),
          );

    final labelText = Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.labelSmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: arabic ? 0 : 0.8,
      ),
    );
    final valueText = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        value,
        maxLines: 1,
        style: AppTextStyles.metric(color: colors.onSurface),
      ),
    );
    final trendRow = _buildTrendRow(context, textTheme, colors, arabic);

    if (isWide) {
      return AppCard.standard(
        onTap: onTap,
        child: Row(
          children: [
            if (iconBlock != null) ...[
              iconBlock,
              const SizedBox(width: AppDimensions.s14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  labelText,
                  const SizedBox(height: 2),
                  valueText,
                  if (supportingText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      supportingText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trendRow != null) ...[
              const SizedBox(width: AppDimensions.s12),
              trendRow,
            ],
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: AppDimensions.kpiTileMinHeight * textScale,
      ),
      child: AppCard.standard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: labelText),
                if (iconBlock != null) ...[
                  const SizedBox(width: AppDimensions.s8),
                  iconBlock,
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.s8),
            valueText,
            if (trendRow != null || supportingText != null) ...[
              const SizedBox(height: AppDimensions.s8),
              Row(
                children: [
                  if (trendRow != null) ...[
                    trendRow,
                    const SizedBox(width: AppDimensions.s8),
                  ],
                  if (supportingText != null)
                    Expanded(
                      child: Text(
                        supportingText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildTrendRow(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colors,
    bool arabic,
  ) {
    final t = trend;
    if (t == null) return null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final Color color = t.isFlat
        ? colors.onSurfaceVariant
        : (t.isPositive
              ? (dark ? AppDarkColors.success : AppColors.success)
              : (dark ? AppDarkColors.danger : AppColors.danger));
    final IconData iconData = t.isFlat
        ? Icons.trending_flat_rounded
        : (t.isPositive
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          t.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (t.timeFrame != null) ...[
          const SizedBox(width: 4),
          Text(
            t.timeFrame!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
