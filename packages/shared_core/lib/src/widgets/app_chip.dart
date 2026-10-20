import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Spec-C8 filter chip (phase-1c-ii).
///
/// Pill that looks 32 dp tall but offers a >= 48 dp hit area via transparent
/// padding. Selected state is never color-alone: a check icon plus label
/// weight join the fill change. Name verified free (no legacy `AppChip`).
///
/// ```dart
/// AppChip(label: 'Open', selected: onlyOpen, onSelected: (v) => setOnlyOpen(v))
/// ```
///
/// - Tokens only: selected = `inverseSurface` / `onInverseSurface`
///   (17.8+:1 both themes); unselected = `surface` + 1 px `outlineVariant`
///   ring with `onSurface` label (17.5+:1). Caller text, Directional-safe.
/// - Real button Semantics (`selected` flag), keyboard-focusable [InkWell],
///   disabled = 40% opacity + no response. Wraps at text scale 1.3x.
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final String? semanticLabel;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = onSelected != null;
    // Dark-mode adaptation of C8 selected fill; AA asserted in tests.
    final fill = selected ? scheme.inverseSurface : scheme.surface;
    final ink = selected ? scheme.onInverseSurface : scheme.onSurface;

    final Widget pill = Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: selected ? null : Border.all(color: scheme.outlineVariant),
      ),
      // No alignment: an aligning Container expands to the full line width
      // inside a Wrap. The Row sizes to its content; crossAxisAlignment
      // keeps it vertically centered in the 32 dp pill.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
              child: Icon(Icons.check_rounded, size: 16, color: ink),
            ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: ink,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    // 48 dp hit area WITHOUT expanding to the incoming line width: 8 px
    // vertical padding around the 32 dp pill (8+32+8 = 48) plus a 48 min
    // width. Deliberately no Center/Align here — those expand to the full
    // line inside a Wrap/Row and turned every chip full-width in review.
    final Widget target = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48),
        child: pill,
      ),
    );

    if (!enabled) {
      return Semantics(
        button: true,
        enabled: false,
        selected: selected,
        label: semanticLabel ?? label,
        child: Opacity(opacity: 0.4, child: ExcludeSemantics(child: target)),
      );
    }
    return Semantics(
      button: true,
      enabled: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: InkWell(
        onTap: () => onSelected!(!selected),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: target,
      ),
    );
  }
}
