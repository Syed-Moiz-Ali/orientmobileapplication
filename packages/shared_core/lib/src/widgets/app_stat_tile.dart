import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Spec-C8 stat tile (phase-1d-i).
///
/// Label above value (tabular figures so digit columns align), optional delta
/// row (arrow icon + signed value in semantic ink, never color alone) and
/// optional caption. Built for 2-column grids with a 12 px gap; wraps at
/// text scale 1.3x instead of clipping.
///
/// Name verified free (no legacy `AppStatTile`); no rename needed.
///
/// ```dart
/// AppStatTile(label: 'Total revenue', value: 'AED 12,450')
/// AppStatTile(
///   label: 'Active jobs',
///   value: '24',
///   deltaText: '+3 vs last week',
///   deltaUp: true,
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (column aligns to
///   the `start` side in both LTR and RTL).
/// - Delta ink is the semantic *ink* (not the base): `success.ink` /
///   `danger.ink` are AA text colors in both themes, and the arrow icon +
///   sign + screen-reader phrase carry the meaning alongside the hue.
/// - Display-only: merged into one Semantics node
///   (`"$label, $value[, $deltaText]"`); pass [semanticLabel] to override.
/// - Every display string is bidi-isolated (U+2066…U+2069) so a leading
///   +/- sign or edge punctuation never flips in RTL paragraphs (1d-i
///   review: bare `+4` rendered as `4+`). Paragraph direction and alignment
///   still follow the locale; numbers stay Western digits LTR per the
///   frozen product policy.
String _isolated(String text) => '\u2066$text\u2069';

class AppStatTile extends StatelessWidget {
  final String label;
  final String value;

  /// Large hero cut (headline size) or the default card cut (title size).
  final bool large;

  /// Optional delta phrase, e.g. `'+3 vs last week'`. Include the sign in
  /// the caller text (spec: explicit +/- on deltas).
  final String? deltaText;

  /// Direction of the delta. `null` (with [deltaText]) renders a neutral row.
  final bool? deltaUp;

  /// Optional one-line caption under the delta row.
  final String? caption;

  final String? semanticLabel;

  const AppStatTile({
    super.key,
    required this.label,
    required this.value,
    this.large = false,
    this.deltaText,
    this.deltaUp,
    this.caption,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final sem = context.semanticColors;

    final valueStyle = (large
            ? textTheme.headlineMedium
            : textTheme.titleLarge)
        ?.copyWith(
      color: scheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    Widget? delta;
    if (deltaText != null) {
      final Color ink;
      final IconData icon;
      if (deltaUp == null) {
        ink = scheme.onSurfaceVariant;
        icon = Icons.remove_rounded;
      } else if (deltaUp!) {
        ink = sem.success.ink;
        icon = Icons.arrow_upward_rounded;
      } else {
        ink = sem.danger.ink;
        icon = Icons.arrow_downward_rounded;
      }
      delta = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: ink),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              _isolated(deltaText!),
              style: textTheme.labelMedium?.copyWith(color: ink),
            ),
          ),
        ],
      );
      // The outer Semantics node reads the full phrase (direction word +
      // sign + value), so the visual arrow + ink + sign are never color-alone.
    }

    final phrase = StringBuffer('$label, $value');
    if (deltaText != null) {
      phrase.write(
        ', ${deltaUp == null ? 'unchanged' : deltaUp! ? 'up' : 'down'}: $deltaText',
      );
    }
    if (caption != null) phrase.write(', $caption');

    return Semantics(
      label: semanticLabel ?? phrase.toString(),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isolated(label),
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(_isolated(value), style: valueStyle),
            if (delta != null) ...[
              const SizedBox(height: AppSpacing.xs),
              delta,
            ],
            if (caption != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _isolated(caption!),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
