import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Semantic tone for a [StatusPill].
///
/// Widgets never pick a light/dark hex by hand: the tone resolves against the
/// active [AppSemanticColors] `ThemeExtension`, so a pill rendered under the
/// light, dark, English or Arabic theme is always the approved Concept A value.
enum StatusPillTone { neutral, info, success, warning, danger, inProgress }

class StatusPill extends StatelessWidget {
  final String label;
  final Color? bg;
  final Color? fg;
  final Color? borderColor;
  final IconData? icon;
  final bool showDot;

  /// When non-null the pill resolves its colours from the active theme's
  /// semantic palette; explicit [bg]/[fg]/[borderColor] are ignored.
  final StatusPillTone? _tone;

  const StatusPill({
    super.key,
    required this.label,
    this.bg,
    this.fg,
    this.borderColor,
    this.icon,
    this.showDot = false,
  }) : _tone = null;

  /// Neutral / default pill
  const StatusPill.neutral(
    this.label, {
    super.key,
    this.icon,
    this.showDot = false,
  })  : bg = null,
        fg = null,
        borderColor = null,
        _tone = StatusPillTone.neutral;

  /// Informational pill (blue)
  const StatusPill.info(
    this.label, {
    super.key,
    this.icon = Icons.info_outline_rounded,
    this.showDot = false,
  })  : bg = null,
        fg = null,
        borderColor = null,
        _tone = StatusPillTone.info;

  /// Success / completed pill (green)
  const StatusPill.success(
    this.label, {
    super.key,
    this.icon = Icons.check_circle_outline_rounded,
    this.showDot = false,
  })  : bg = null,
        fg = null,
        borderColor = null,
        _tone = StatusPillTone.success;

  /// Warning / pending pill (amber)
  const StatusPill.warning(
    this.label, {
    super.key,
    this.icon = Icons.schedule_rounded,
    this.showDot = false,
  })  : bg = null,
        fg = null,
        borderColor = null,
        _tone = StatusPillTone.warning;

  /// Danger / rejected / blocked pill (red)
  const StatusPill.danger(
    this.label, {
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.showDot = false,
  })  : bg = null,
        fg = null,
        borderColor = null,
        _tone = StatusPillTone.danger;

  /// In-progress operational pill with prominent dot indicator
  const StatusPill.inProgress(
    this.label, {
    super.key,
    this.icon,
  })  : bg = null,
        fg = null,
        borderColor = null,
        showDot = true,
        _tone = StatusPillTone.inProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final textTheme = theme.textTheme;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    Color effectiveBg;
    Color effectiveFg;
    Color? effectiveBorder;

    final tone = _tone;
    if (tone != null) {
      final role = switch (tone) {
        StatusPillTone.neutral => semantic.neutral,
        StatusPillTone.info => semantic.info,
        StatusPillTone.success => semantic.success,
        StatusPillTone.warning => semantic.warning,
        StatusPillTone.danger => semantic.danger,
        StatusPillTone.inProgress => semantic.info,
      };
      effectiveBg = role.subtle;
      effectiveFg = role.ink;
      effectiveBorder = role.border;
    } else {
      effectiveBg =
          bg ?? theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
      effectiveFg = fg ?? theme.colorScheme.primary;
      effectiveBorder = borderColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        border: Border.all(
          color: effectiveBorder ?? effectiveFg.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: effectiveFg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.s6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: effectiveFg),
            const SizedBox(width: AppDimensions.s4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: effectiveFg,
                letterSpacing: arabic ? 0 : 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
