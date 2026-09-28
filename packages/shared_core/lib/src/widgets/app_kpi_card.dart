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
  final String? timeFrame;

  const KpiTrend({
    required this.label,
    required this.isPositive,
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

  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.supportingText,
    this.trend,
    this.icon,
    this.semanticState = KpiSemanticState.neutral,
    this.onTap,
  });

  const AppKpiCard.compact({
    super.key,
    required this.label,
    required this.value,
    this.supportingText,
    this.icon,
    this.semanticState = KpiSemanticState.neutral,
    this.onTap,
  }) : trend = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final Color semanticColor = switch (semanticState) {
      KpiSemanticState.neutral => colors.onSurfaceVariant,
      KpiSemanticState.success => AppColors.success,
      KpiSemanticState.warning => AppColors.warning,
      KpiSemanticState.danger => AppColors.danger,
      KpiSemanticState.info => AppColors.info,
    };

    return AppCard.standard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppDimensions.s8),
                AppIconContainer(
                  icon: icon!,
                  size: AppIconSize.small,
                  iconColor: semanticState == KpiSemanticState.neutral
                      ? colors.primary
                      : semanticColor,
                  backgroundColor: semanticState == KpiSemanticState.neutral
                      ? AppColors.primarySubtle
                      : semanticColor.withValues(alpha: 0.12),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            value,
            style: AppTextStyles.metric(
              color: colors.onSurface,
            ),
          ),
          if (trend != null || supportingText != null) ...[
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                if (trend != null) ...[
                  Icon(
                    trend!.isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 14,
                    color: trend!.isPositive
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend!.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: trend!.isPositive
                          ? AppColors.success
                          : AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (trend!.timeFrame != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      trend!.timeFrame!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
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
    );
  }
}
