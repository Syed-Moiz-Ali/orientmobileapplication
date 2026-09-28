import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class StatusPill extends StatelessWidget {
  final String label;
  final Color? bg;
  final Color? fg;
  final Color? borderColor;
  final IconData? icon;
  final bool showDot;

  const StatusPill({
    super.key,
    required this.label,
    this.bg,
    this.fg,
    this.borderColor,
    this.icon,
    this.showDot = false,
  });

  /// Neutral / default pill
  const StatusPill.neutral(
    this.label, {
    super.key,
    this.icon,
    this.showDot = false,
  })  : bg = const Color(0xFFF1F5F9),
        fg = const Color(0xFF475569),
        borderColor = const Color(0xFFE2E8F0);

  /// Informational pill (blue)
  const StatusPill.info(
    this.label, {
    super.key,
    this.icon = Icons.info_outline_rounded,
    this.showDot = false,
  })  : bg = const Color(0xFFEFF6FF),
        fg = const Color(0xFF1D4ED8),
        borderColor = const Color(0xFFBFDBFE);

  /// Success / completed pill (green)
  const StatusPill.success(
    this.label, {
    super.key,
    this.icon = Icons.check_circle_outline_rounded,
    this.showDot = false,
  })  : bg = const Color(0xFFF0FDF4),
        fg = const Color(0xFF15803D),
        borderColor = const Color(0xFFBBF7D0);

  /// Warning / pending pill (amber)
  const StatusPill.warning(
    this.label, {
    super.key,
    this.icon = Icons.schedule_rounded,
    this.showDot = false,
  })  : bg = const Color(0xFFFFFBEB),
        fg = const Color(0xFFB45309),
        borderColor = const Color(0xFFFDE68A);

  /// Danger / rejected / blocked pill (red)
  const StatusPill.danger(
    this.label, {
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.showDot = false,
  })  : bg = const Color(0xFFFEF2F2),
        fg = const Color(0xFFB91C1C),
        borderColor = const Color(0xFFFECACA);

  /// In-progress operational pill with prominent dot indicator
  const StatusPill.inProgress(
    this.label, {
    super.key,
    this.icon,
  })  : bg = const Color(0xFFEEF2FF),
        fg = const Color(0xFF4338CA),
        borderColor = const Color(0xFFC7D2FE),
        showDot = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveBg =
        bg ?? colorScheme.primaryContainer.withValues(alpha: 0.5);
    final effectiveFg = fg ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppDimensions.rPill),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
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
          // The label shrinks instead of overflowing when the pill is narrow,
          // for example at large text scales or with a long status name.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: effectiveFg,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
