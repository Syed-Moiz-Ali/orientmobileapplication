import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Shared 56 dp row chrome for list/settings tiles (spec C8, phase-1c-i).
///
/// Title (titleSmall) + optional subtitle (bodySmall, textSecondary) with an
/// end-aligned trailing. Whole row >= 48 dp (min height 56); callers add the
/// tap/focus wrapper ([AppListTile] InkWell, [AppToggleRow]). Directional-safe
/// padding; value text keeps tabular figures and callers lock it LTR.
class AppTileRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppTileRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lead = leading;
    return Container(
      // Spec C8: grouped-tile rows are min height 56.
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (lead != null) ...[
            lead,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: textTheme.titleSmall),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(child: trailing!),
          ],
        ],
      ),
    );
  }
}

/// Spec-C8 40 px leading circle with a 20 px icon. Returns null when neither
/// [icon] nor [custom] is given (so the row renders with no leading gap);
/// [custom] replaces the circle when provided.
Widget? buildTileLeading({
  required BuildContext context,
  IconData? icon,
  Widget? custom,
  bool accent = false,
}) {
  if (custom != null) return custom;
  final iconData = icon;
  if (iconData == null) return null;
  final scheme = Theme.of(context).colorScheme;
  return Container(
    width: 40, // spec C8: 40 px leading circle.
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent ? scheme.primaryContainer : scheme.surfaceContainerHighest,
    ),
    child: Icon(
      iconData,
      size: 20, // spec C8: 20 px tile icons.
      color: accent ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
    ),
  );
}

/// Shared value + chevron trailing: end-aligned tabular value with an LTR
/// lock, plus an optional 20 px chevron that mirrors in RTL via
/// [DirectionalIcon]. Callers pre-resolve [showChevron] (tiles show it only
/// on tappable rows).
Widget buildTileValueTrailing({
  required BuildContext context,
  String? valueText,
  TextStyle? valueStyle,
  bool showChevron = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (valueText != null)
        Flexible(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              valueText,
              textAlign: TextAlign.end,
              style: valueStyle ??
                  textTheme.titleSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
        ),
      if (showChevron)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
          child: DirectionalIcon(
            Icons.chevron_right_rounded,
            size: 20, // spec C8: 20 px chevrons.
            color: scheme.onSurfaceVariant,
          ),
        ),
    ],
  );
}
