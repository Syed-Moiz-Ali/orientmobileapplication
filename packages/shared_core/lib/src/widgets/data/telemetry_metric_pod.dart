import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/app_card.dart';

/// Direction of a metric delta (drives the delta badge icon + colour).
enum TelemetryTrend { up, down, flat }

/// **Telemetry metric pod (Phase 03, Concept A).**
///
/// High-contrast numeric display: a sentence-case cobalt overline label, a
/// prominent tabular value, an optional delta badge (`+18.4% vs Target`) and a
/// live-data indicator. It replaces the "generic statistic box" with a single
/// deliberate data instrument.
///
/// Only render [deltaLabel] when real movement data exists — never fabricate
/// trends. Colours resolve through the active theme; the delta badge borrows
/// the semantic success / danger / neutral families.
class TelemetryMetricPod extends StatelessWidget {
  /// Sentence-case overline label (e.g. "Revenue velocity").
  final String label;

  /// The prominent metric value (e.g. "AED 48,250.00").
  final String value;

  /// Optional small unit/suffix rendered next to the value (e.g. "/ day").
  final String? unit;

  /// Optional delta text (e.g. "+18.4% vs Target").
  final String? deltaLabel;

  /// Delta direction.
  final TelemetryTrend trend;

  /// Explicit semantic polarity. When null it is derived from [trend]
  /// (`up` → positive, `down` → negative, `flat` → neutral). Use this to
  /// express "lower is better" metrics (e.g. cycle time).
  final bool? trendIsPositive;

  /// Shows a live-data indicator dot + label.
  final bool isLive;

  /// Optional secondary supporting line under the value.
  final String? supportingText;

  /// Optional leading glyph.
  final IconData? icon;

  /// Renders the value with the hero display role (larger) when true.
  final bool isHero;

  final VoidCallback? onTap;

  const TelemetryMetricPod({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.deltaLabel,
    this.trend = TelemetryTrend.flat,
    this.trendIsPositive,
    this.isLive = false,
    this.supportingText,
    this.icon,
    this.isHero = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final t = SharedCoreL10n.of(context);
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    final valueStyle = isHero
        ? AppTextStyles.displayHero(color: colors.onSurface, arabic: arabic)
        : AppTextStyles.metric(color: colors.onSurface, arabic: arabic);

    final deltaRow = _buildDelta(context, arabic);

    return AppCard.standard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimensions.iconSm, color: colors.primary),
                const SizedBox(width: AppDimensions.s6),
              ],
              Expanded(
                child: Text(
                  // C16: caller sentence case verbatim — never uppercased.
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: arabic ? 0 : 0.8,
                  ),
                ),
              ),
              if (isLive) ...[
                const SizedBox(width: AppDimensions.s8),
                _LiveBadge(label: t.telemetryLive, arabic: arabic),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, maxLines: 1, style: valueStyle),
                if (unit != null) ...[
                  const SizedBox(width: AppDimensions.s4),
                  Text(
                    unit!,
                    maxLines: 1,
                    style: AppTextStyles.bodyRegular(
                      color: colors.onSurfaceVariant,
                      arabic: arabic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (deltaRow != null || supportingText != null) ...[
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                if (deltaRow != null) ...[
                  // System gap (Phase 13): the badge was unshrinkable, so a
                  // long delta clipped at 320px/1.3x. It now flexes and the
                  // inner label ellipsizes; the gap renders only when a
                  // supporting line actually follows.
                  Flexible(child: deltaRow),
                  if (supportingText != null)
                    const SizedBox(width: AppDimensions.s8),
                ],
                if (supportingText != null)
                  Expanded(
                    child: Text(
                      supportingText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                        color: colors.onSurfaceVariant,
                        arabic: arabic,
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

  Widget? _buildDelta(BuildContext context, bool arabic) {
    final label = deltaLabel;
    if (label == null) return null;
    final colors = context.colors;
    final AppSemanticColors s = context.semanticColors;
    final positive = trendIsPositive ?? (trend == TelemetryTrend.up);
    final flat = trend == TelemetryTrend.flat;

    final ({Color bg, Color ink, Color ring}) tone = flat
        ? (bg: colors.surface, ink: colors.onSurfaceVariant, ring: colors.outline)
        : positive
        ? (bg: s.success.subtle, ink: s.success.ink, ring: s.success.border)
        : (bg: s.danger.subtle, ink: s.danger.ink, ring: s.danger.border);

    final icon = switch (trend) {
      TelemetryTrend.up => Icons.arrow_upward_rounded,
      TelemetryTrend.down => Icons.arrow_downward_rounded,
      TelemetryTrend.flat => Icons.trending_flat_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s8,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        border: Border.all(color: tone.ring),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconXs, color: tone.ink),
          const SizedBox(width: AppDimensions.s4),
          // Bounded so long deltas ellipsize instead of forcing the badge
          // (and its parent row) past narrow viewports.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metadata(color: tone.ink, arabic: arabic)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.label, required this.arabic});

  final String label;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: semantic.success.base,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.s4),
        Text(
          // C16: localized "Live" verbatim — never uppercased.
          label,
          style: AppTextStyles.telemetry(
            color: semantic.success.ink,
            arabic: arabic,
          ).copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
