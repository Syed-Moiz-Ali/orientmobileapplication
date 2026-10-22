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

  /// Optional live result counts keyed by option label (Phase 07.1: adopted
  /// by the technician jobs toolbar). When `counts[option]` is present the
  /// chip renders a count badge; null (default) keeps the plain chip — the
  /// 01.2 golden rendering is unchanged.
  final Map<String, int>? counts;

  /// Semantics label override for the count badge (`$label, $count jobs`).
  final String Function(String label, int count)? countSemantics;

  /// U5 narrow-viewport mode: when true the chips flow in a [Wrap] (word /
  /// chip boundaries only — a chip is never cut mid-glyph) instead of a
  /// horizontal scroll rail, and the Clear action flows inline as the last
  /// item so it can never overlap a clipped chip. Defaults to false, so
  /// every existing caller keeps the scroll-rail rendering byte-identical.
  final bool wrap;

  const AppFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.showAllOption = true,
    this.counts,
    this.countSemantics,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    final chips = <Widget>[];
    if (showAllOption) {
      final allActive = selected == null;
      final allCount = counts?[t.filterBarAll];
      chips.add(
        _FilterChip(
          label: t.filterBarAll,
          active: allActive,
          count: allCount,
          semanticsLabel: allCount == null
              ? null
              : (countSemantics?.call(t.filterBarAll, allCount) ??
                    '${t.filterBarAll}, $allCount'),
          onTap: () => onSelected(null),
        ),
      );
    }
    for (final option in options) {
      final count = counts?[option];
      chips.add(
        _FilterChip(
          label: option,
          active: selected == option,
          count: count,
          semanticsLabel: count == null
              ? null
              : (countSemantics?.call(option, count) ?? '$option, $count'),
          onTap: () => onSelected(selected == option ? null : option),
        ),
      );
    }

    final clearAction = selected == null
        ? null
        : TextButton(
            onPressed: () => onSelected(null),
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              minimumSize: const Size(0, AppDimensions.touchTarget),
            ),
            child: Text(t.filterBarClear),
          );

    // Wrap mode (U5): chips flow onto multiple lines at chip boundaries and
    // the Clear action is the last flow item — nothing scrolls, nothing is
    // cut mid-word, and Clear can never sit on top of a clipped chip.
    // Each chip is shrink-wrapped (the chip Container centers its content,
    // which would otherwise stretch it to the full line width under Wrap's
    // bounded max constraints).
    if (wrap) {
      return Semantics(
        container: true,
        label: t.filterBarAll,
        child: Wrap(
          spacing: AppDimensions.s8,
          runSpacing: AppDimensions.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final chip in chips) IntrinsicWidth(child: chip),
            if (clearAction != null) clearAction,
          ],
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
              // Trailing inset keeps the peeking chip off the hard edge so
              // the cut never lands mid-glyph without breathing room (U5).
              padding: const EdgeInsetsDirectional.only(
                end: AppDimensions.s20,
              ),
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
          if (clearAction != null) ...[
            const SizedBox(width: AppDimensions.s8),
            clearAction,
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final int? count;
  final String? semanticsLabel;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.count,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    final bg = active ? colors.primary : semantic.surfaceRaised;
    final fg = active ? colors.onPrimary : colors.onSurface;
    final border = active ? colors.primary : semantic.borderDefault;
    final countInk = active ? colors.onPrimary : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: active,
      label: semanticsLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          child: Container(
            // Phase 07.1: minimum 48 dp touch target (the unwrapped chip
            // measured 34 px and failed the tap-target audit).
            constraints: const BoxConstraints(
              minHeight: AppDimensions.touchTarget,
            ),
            alignment: Alignment.center,
            // Compact horizontal padding (token): narrower chips fit more
            // of the rail at 320–360px so cuts land in gaps, not mid-word.
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s8,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              border: Border.all(color: border),
            ),
            // Shrink-wrap horizontally: the Container's `alignment` would
            // otherwise stretch the chip to the incoming max width (Wrap
            // mode passes the full line width down; the scroll rail passes
            // unbounded width, which is why this never showed there).
            // `Center` with `widthFactor: 1.0` keeps the natural chip width
            // in both modes while still centering content vertically.
            child: Center(
              widthFactor: 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
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
                  if (count != null) ...[
                    const SizedBox(width: AppDimensions.s6),
                    Text(
                      '$count',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: countInk,
                        fontWeight:
                            active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
