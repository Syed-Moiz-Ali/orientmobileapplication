import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/app_formatters.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Compact trend stat (Phase 01.2 foundation primitive).
///
/// Shows a [label], a preformatted [displayValue] (currency grouped by the
/// caller through [AppFormatters.moneyAED]) and a directional delta resolved
/// from the semantic success/danger families. `upIsGood` flips the polarity
/// (e.g. falling wait-times are good). The delta keeps Latin digits via
/// [AppFormatters.percent] so Arabic layouts never show eastern digits.
class AppTrendStat extends StatelessWidget {
  final String label;
  final String displayValue;
  final double deltaFraction;
  final bool upIsGood;
  final IconData? icon;

  const AppTrendStat({
    super.key,
    required this.label,
    required this.displayValue,
    required this.deltaFraction,
    this.upIsGood = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedCoreL10n.of(context);
    final formatters = AppFormatters.of(context);

    final up = deltaFraction >= 0;
    final good = up == upIsGood;
    final AppStatusColors tone = good ? semantic.success : semantic.danger;
    final deltaText =
        '${up ? '▲' : '▼'} ${formatters.percent(deltaFraction.abs())}';
    final trendSemantics =
        '${up ? t.trendUpLabel : t.trendDownLabel} ${formatters.percent(deltaFraction.abs())}';

    return Semantics(
      container: true,
      label: '$label, $displayValue, $trendSemantics',
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppDimensions.iconMd, color: tone.base),
                  const SizedBox(width: AppDimensions.s8),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s8,
                    vertical: AppDimensions.s4,
                  ),
                  decoration: BoxDecoration(
                    color: tone.subtle,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                    border: Border.all(color: tone.border),
                  ),
                  child: Text(
                    deltaText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tone.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
