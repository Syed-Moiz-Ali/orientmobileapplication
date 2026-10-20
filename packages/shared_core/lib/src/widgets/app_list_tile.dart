import 'package:flutter/material.dart';
import 'package:shared_core/src/widgets/app_tile_row.dart';

/// Spec-C8 list tile (phase-1c-i).
///
/// Min height 56, 40 px leading circle, whole-row tap target, trailing
/// variants (chevron / value / custom widget). Group tiles inside one
/// [AppSurfaceCard] with [AppDivider.inset] between them (see gallery).
///
/// ```dart
/// AppListTile(
///   leadingIcon: Icons.build_outlined,
///   title: 'Oil change',
///   subtitle: 'Due in 2 weeks',
///   valueText: 'AED 240',
///   onTap: openService,
/// )
/// ```
///
/// Row chrome lives in [AppTileRow] (shared with settings tiles). Tokens
/// only, caller-supplied text, Directional-safe. Whole row >= 48 dp
/// (min height 56); Semantics button when tappable. Subtitle + value wrap at
/// text scale 1.3x instead of overflowing.
class AppListTile extends StatelessWidget {
  final IconData? leadingIcon;

  /// Custom leading widget (replaces the 40 px circle when provided).
  final Widget? leading;

  /// Accent-tinted leading circle instead of the neutral surfaceAlt one.
  final bool accentLeading;

  final String title;
  final String? subtitle;

  /// Short end-aligned value (e.g. an amount). Stays LTR inside RTL.
  final String? valueText;

  /// Custom trailing widget (replaces chevron/value).
  final Widget? trailing;

  final VoidCallback? onTap;
  final bool showChevron;
  final String? semanticLabel;

  const AppListTile({
    super.key,
    this.leadingIcon,
    this.leading,
    this.accentLeading = false,
    required this.title,
    this.subtitle,
    this.valueText,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final custom = trailing;
    Widget? trailingWidget;
    if (custom != null) {
      trailingWidget = custom;
    } else if (valueText != null || (showChevron && onTap != null)) {
      trailingWidget = buildTileValueTrailing(
        context: context,
        valueText: valueText,
        showChevron: showChevron && onTap != null,
      );
    }

    final row = AppTileRow(
      leading: buildTileLeading(
        context: context,
        icon: leadingIcon,
        custom: leading,
        accent: accentLeading,
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailingWidget,
    );

    if (onTap == null) return row;
    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel ?? title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: row),
      ),
    );
  }
}
