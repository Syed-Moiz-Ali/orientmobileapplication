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
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: effectiveFg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
