import 'package:flutter/material.dart';
import 'package:shared_core/src/widgets/app_tile_row.dart';
import 'package:shared_core/src/widgets/app_toggle_row.dart';

/// Spec-C8 settings tile (phase-1c-i): same 56 dp chrome as [AppListTile].
///
/// Settings-style trailing: a switch, a value + chevron, or a plain chevron.
/// Group tiles inside one [AppSurfaceCard]. Switch rows toggle via
/// [AppToggleRow]; non-switch tiles expose ONLY [onTap]. Disabled
/// (null callback): 40 % opacity, no response.
///
/// ```dart
/// AppSettingsTile.switchTile(title: 'Push', value: notify, onChanged: setNotify)
/// AppSettingsTile(title: 'Language', valueText: 'English', onTap: pickLanguage)
/// ```
class AppSettingsTile extends StatelessWidget {
  final IconData? leadingIcon;
  final bool accentLeading;
  final String title;
  final String? subtitle;
  final String? valueText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  /// Switch variant state. Null = not a switch tile.
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;

  const AppSettingsTile({
    super.key,
    this.leadingIcon,
    this.accentLeading = false,
    required this.title,
    this.subtitle,
    this.valueText,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  })  : switchValue = null,
        onChanged = null;

  /// Switch variant: the whole row toggles [onChanged].
  const AppSettingsTile.switchTile({
    super.key,
    this.leadingIcon,
    this.accentLeading = false,
    required this.title,
    this.subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  })  : switchValue = value,
        onChanged = onChanged,
        valueText = null,
        trailing = null,
        onTap = null,
        showChevron = false;

  bool get _isSwitch => switchValue != null;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lead = buildTileLeading(
        context: context, icon: leadingIcon, accent: accentLeading);
    Widget tile(Widget? end) => AppTileRow(
        leading: lead, title: title, subtitle: subtitle, trailing: end);

    if (_isSwitch) {
      final value = switchValue!;
      final handler = onChanged;
      // Enabled-rendering switch that never handles pointers itself: a null
      // onChanged would paint the disabled grey (reading as OFF when ON),
      // so the switch renders enabled and IgnorePointer routes every tap to
      // the row. ExcludeSemantics keeps exactly one toggle node (the row).
      final track = ExcludeSemantics(
        // IgnorePointer routes every tap to the row below.
        child: IgnorePointer(
          child: Switch(value: value, onChanged: (_) {}),
        ),
      );
      if (handler != null) {
        return AppToggleRow(
          enabled: true,
          toggled: value,
          label: title,
          onTap: () => handler(!value),
          child: tile(track),
        );
      }
      return Opacity(
        opacity: 0.4,
        child: Semantics(
          toggled: switchValue,
          enabled: false,
          label: title,
          child: tile(track),
        ),
      );
    }

    final custom = trailing;
    final Widget? end = custom ??
        (valueText != null || showChevron
            ? buildTileValueTrailing(
                context: context,
                valueText: valueText,
                valueStyle: textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
                showChevron: showChevron && onTap != null,
              )
            : null);

    final row = tile(end);
    if (onTap == null) {
      return Opacity(opacity: 0.4, child: row);
    }
    return Semantics(
      button: true,
      enabled: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: row),
      ),
    );
  }
}
