import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Horizontal filter-chip bar (Phase 01.2 foundation primitive).
///
/// Renders [options] as single-select filter chips plus an "All" reset chip
/// and a text "Clear" action when a selection is active. Selection state is
/// owned by the caller; this widget is presentation only.
///
/// Styling resolves exclusively through `context.colors` /
/// `context.semanticColors` — no static palettes, no hardcoded hex.
class AppFilterBar extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool showAllOption;

  const AppFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    final chips = <Widget>[];
    if (showAllOption) {
      final allActive = selected == null;
      chips.add(
        _FilterChip(
          label: t.filterBarAll,
          active: allActive,
          onTap: () => onSelected(null),
        ),
      );
    }
    for (final option in options) {
      chips.add(
        _FilterChip(
          label: option,
          active: selected == option,
          onTap: () => onSelected(selected == option ? null : option),
        ),
      );
    }

    return Semantics(
      container: true,
      label: t.filterBarAll,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppDimensions.s8),
                    chips[i],
                  ],
                ],
              ),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(width: AppDimensions.s8),
            TextButton(
              onPressed: () => onSelected(null),
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                minimumSize: const Size(0, AppDimensions.touchTarget),
              ),
              child: Text(t.filterBarClear),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    final bg = active ? colors.primary : semantic.surfaceRaised;
    final fg = active ? colors.onPrimary : colors.onSurface;
    final border = active ? colors.primary : semantic.borderDefault;

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s14,
              vertical: AppDimensions.s8,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: Border.all(color: border),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
