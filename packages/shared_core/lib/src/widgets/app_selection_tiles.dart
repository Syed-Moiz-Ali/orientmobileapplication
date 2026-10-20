import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Whole-row tappable checkbox / switch / radio tiles (phase-1b).
///
/// Each tile is >= 48 dp, carries label + optional subtitle, a disabled
/// state (40 % + no response), and proper Semantics roles. Tapping anywhere
/// on the row toggles.
///
/// ```dart
/// AppCheckTile(title: 'Email notifications', value: email, onChanged: setEmail)
/// AppSwitchTile(title: 'Dark mode', value: dark, onChanged: setDark)
/// AppRadioTile<String>(title: 'Deira', value: 'deira', groupValue: branch, onChanged: setBranch)
/// ```
class AppCheckTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppCheckTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _TileRow(
      enabled: onChanged != null,
      semanticsLabel: title,
      role: _TileRole.checkbox,
      checked: value,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      title: title,
      subtitle: subtitle,
      trailing: Checkbox(
        value: value,
        onChanged: null,
      ),
    );
  }
}

class AppSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _TileRow(
      enabled: onChanged != null,
      semanticsLabel: title,
      role: _TileRole.toggle,
      checked: value,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      title: title,
      subtitle: subtitle,
      trailing: Switch(value: value, onChanged: null),
    );
  }
}

class AppRadioTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  const AppRadioTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // RadioGroup.onChanged is non-nullable; a disabled tile gets no group
    // so keyboard/assistive selection cannot change the value either.
    final row = _TileRow(
      enabled: onChanged != null,
      semanticsLabel: title,
      role: _TileRole.radio,
      checked: value == groupValue,
      onTap: onChanged == null ? null : () => onChanged!(value),
      title: title,
      subtitle: subtitle,
      trailing: Radio<T>(value: value),
    );
    final handler = onChanged;
    if (handler == null) return row;
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: handler,
      child: row,
    );
  }
}

enum _TileRole { checkbox, toggle, radio }

/// Shared row chrome: >= 48 dp, whole-row tap, 40 % disabled, Semantics.
class _TileRow extends StatelessWidget {
  final bool enabled;
  final String semanticsLabel;
  final _TileRole role;
  final bool checked;
  final VoidCallback? onTap;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _TileRow({
    required this.enabled,
    required this.semanticsLabel,
    required this.role,
    required this.checked,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget tile = Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    tile = Opacity(opacity: enabled ? 1.0 : 0.4, child: tile);

    switch (role) {
      case _TileRole.checkbox:
        // Checkbox role = checked state without mutual exclusion.
        return Semantics(
          checked: checked,
          enabled: enabled,
          label: semanticsLabel,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: tile,
          ),
        );
      case _TileRole.toggle:
        return Semantics(
          toggled: checked,
          enabled: enabled,
          label: semanticsLabel,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: tile,
          ),
        );
      case _TileRole.radio:
        return Semantics(
          inMutuallyExclusiveGroup: true,
          checked: checked,
          enabled: enabled,
          label: semanticsLabel,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: tile,
          ),
        );
    }
  }
}
