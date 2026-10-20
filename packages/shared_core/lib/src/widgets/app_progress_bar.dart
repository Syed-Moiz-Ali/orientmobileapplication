import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Threshold tone for [AppProgressBar]. [auto] maps the value to a tone
/// (accent < 50 %, success < 75 %, warning < 90 %, error at/above 90 %);
/// explicit tones pin the fill regardless of value.
enum AppProgressTone { auto, accent, success, warning, error }

/// Spec-C8 progress bar (phase-1d-i).
///
/// 8 px pill, track `surfaceContainerHighest`, fill by threshold tone, label
/// row above (`"62% of 90% limit"` style — caller text). Fill-vs-track is
/// asserted >= 3:1 (non-text) in both themes in the feedback tests; light
/// success/warning fills use the darker ink cuts so they stay legible on
/// the pale track (never white-on-green).
///
/// Name verified free (no legacy `AppProgressBar`); no rename needed.
///
/// ```dart
/// AppProgressBar(value: 0.62, label: '62% of 90% limit')
/// AppProgressBar(value: 0.95, label: 'Over limit', tone: AppProgressTone.error)
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (fill grows from
///   the `start` edge in both LTR and RTL).
/// - Label and percent are bidi-isolated (U+2066…U+2069) so leading numbers
///   never reorder in RTL paragraphs (1d-i review); paragraph direction and
///   alignment still follow the locale.
/// - Semantics expose the percent as `value` (`'62 percent'`); pass
///   [semanticLabel] to name the meter, [semanticValue] to override.
/// - Display-only (no tap target); wraps at text scale 1.3x, never clips.
///
/// Bidi-isolates [text] (U+2066…U+2069); see [AppStatTile] for the rationale.
String _isolate(String text) => '\u2066$text\u2069';

class AppProgressBar extends StatelessWidget {
  /// 0.0 – 1.0 (clamped). Values outside the range are pinned, not thrown.
  final double value;
  final String? label;
  final AppProgressTone tone;
  final String? semanticLabel;
  final String? semanticValue;

  const AppProgressBar({
    super.key,
    required this.value,
    this.label,
    this.tone = AppProgressTone.auto,
    this.semanticLabel,
    this.semanticValue,
  });

  AppProgressTone _resolved(double clamped) {
    if (tone != AppProgressTone.auto) return tone;
    if (clamped >= 0.9) return AppProgressTone.error;
    if (clamped >= 0.75) return AppProgressTone.warning;
    if (clamped >= 0.5) return AppProgressTone.success;
    return AppProgressTone.accent;
  }

  /// Fill color per tone. Light success/warning use the darker ink cuts so
  /// the fill keeps >= 3:1 against the pale track (the raw bases are ~2.3
  /// and ~1.8 there); dark fills use the bright bases against the sunken
  /// track. Accent/error use the scheme fills in both themes.
  Color _fill(BuildContext context, AppProgressTone resolved) {
    final scheme = Theme.of(context).colorScheme;
    final sem = context.semanticColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (resolved) {
      case AppProgressTone.accent:
        return scheme.primary;
      case AppProgressTone.success:
        return dark ? AppDarkColors.success : AppColors.successStrong;
      case AppProgressTone.warning:
        return sem.warning.ink;
      case AppProgressTone.error:
        return scheme.error;
      case AppProgressTone.auto:
        return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final resolved = _resolved(clamped);
    final fill = _fill(context, resolved);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final percent = (clamped * 100).round();

    return Semantics(
      label: semanticLabel ?? label,
      value: semanticValue ?? '$percent percent',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isolate(label!),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _isolate('$percent%'),
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: clamped,
                    child: Container(color: fill),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
