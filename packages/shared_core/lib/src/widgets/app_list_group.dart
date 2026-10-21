import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_divider.dart';
import 'package:shared_core/src/widgets/app_tile_row.dart';
import 'package:shared_core/src/widgets/app_toggle_row.dart';

/// One row inside an [AppListGroup] (phase-1P).
///
/// Three variants, mirroring [AppListTile]/[AppSettingsTile]:
/// - navigation/value row: [onTap] + optional [valueText] and/or chevron;
/// - switch row: [switchValue] != null (toggles [onChanged], whole-row tap);
/// - inert row: neither callback (40% opacity, no response).
class AppListGroupItem {
  final IconData? leadingIcon;
  final bool accentLeading;
  final String title;
  final String? subtitle;
  final String? valueText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  /// Switch-variant state. Null = not a switch row.
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;

  const AppListGroupItem({
    this.leadingIcon,
    this.accentLeading = false,
    required this.title,
    this.subtitle,
    this.valueText,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.switchValue,
    this.onChanged,
  });
}

/// C16 profile/settings group (phase-1P).
///
/// Section label + icon rows with inset hairline dividers. The group is NOT
/// a card (no border, no shadow, no fill): it sits directly on the page
/// surface, so it can never become a card-in-card (C16).
///
/// ```dart
/// AppListGroup(
///   title: 'Preferences',
///   items: [
///     AppListGroupItem(
///       leadingIcon: Icons.language_rounded,
///       title: 'Language',
///       valueText: 'English',
///       onTap: pickLanguage,
///     ),
///     AppListGroupItem(
///       leadingIcon: Icons.notifications_outlined,
///       title: 'Push notifications',
///       switchValue: notify,
///       onChanged: setNotify,
///     ),
///   ],
/// )
/// ```
///
/// - Row chrome reuses [AppTileRow]/[buildTileLeading]/[buildTileValueTrailing]
///   and [AppToggleRow]; dividers are [AppDivider.inset] (72 px, RTL-safe).
/// - Whole rows are >= 48 dp (min height 56); switch rows expose exactly one
///   toggle Semantics node; inert rows dim to 40%.
/// - 1.3x-safe: titles/subtitles/values wrap instead of overflowing.
class AppListGroup extends StatelessWidget {
  /// Section label (labelMedium, muted, header Semantics). Null = no label.
  final String? title;

  /// Rows in this section, in order.
  final List<AppListGroupItem> items;

  /// Overrides the group's Semantics label.
  final String? semanticLabel;

  const AppListGroup({
    super.key,
    this.title,
    required this.items,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel,
      container: semanticLabel != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.lg,
                end: AppSpacing.lg,
                bottom: AppSpacing.sm,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  title!,
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const AppDivider.inset(),
            _Row(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final AppListGroupItem item;

  const _Row({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lead = buildTileLeading(
      context: context,
      icon: item.leadingIcon,
      accent: item.accentLeading,
    );
    Widget tile(Widget? end) => AppTileRow(
          leading: lead,
          title: item.title,
          subtitle: item.subtitle,
          trailing: end,
        );

    if (item.switchValue != null) {
      final value = item.switchValue!;
      final handler = item.onChanged;
      // Enabled-rendering switch that never handles pointers itself: a null
      // onChanged would paint the disabled grey (reading as OFF when ON),
      // so the switch renders enabled and IgnorePointer routes every tap to
      // the row. ExcludeSemantics keeps exactly one toggle node (the row).
      final track = ExcludeSemantics(
        child: IgnorePointer(
          child: Switch(value: value, onChanged: (_) {}),
        ),
      );
      if (handler != null) {
        return AppToggleRow(
          enabled: true,
          toggled: value,
          label: item.title,
          onTap: () => handler(!value),
          child: tile(track),
        );
      }
      return Opacity(
        opacity: 0.4,
        child: Semantics(
          toggled: item.switchValue,
          enabled: false,
          label: item.title,
          child: tile(track),
        ),
      );
    }

    final custom = item.trailing;
    final Widget? end = custom ??
        (item.valueText != null || item.showChevron
            ? buildTileValueTrailing(
                context: context,
                valueText: item.valueText,
                valueStyle: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                showChevron: item.showChevron && item.onTap != null,
              )
            : null);

    final row = tile(end);
    final onTap = item.onTap;
    if (onTap == null) {
      return Opacity(opacity: 0.4, child: row);
    }
    return Semantics(
      button: true,
      enabled: true,
      label: item.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: row),
      ),
    );
  }
}
