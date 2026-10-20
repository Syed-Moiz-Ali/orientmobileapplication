import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_shadows.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/theme/app_tokens.dart';

/// Option for [AppSegmentedControl] and [AppPillTabs].
class AppSegmentedOption<T> {
  final T value;
  final String label;

  /// Optional leading glyph rendered at 18 px beside the label.
  /// Non-directional by default (auth method icons); pass a directional icon
  /// only when mirroring is wanted.
  final IconData? icon;

  const AppSegmentedOption({required this.value, required this.label, this.icon});
}

/// Spec-C8 segmented control (phase-1e-i).
///
/// Track in surfaceSunken, pill, 40 px segments stitched inside a 48 px
/// hit area, selected segment = surface + e1 shadow (light) or border
/// (dark), selected state in Semantics. [AppSegmentedControl.scrollable]
/// scrolls horizontally for many options.
///
/// Name verified free in `packages/`; no rename needed.
///
/// ```dart
/// AppSegmentedControl<String>(
///   options: const [
///     AppSegmentedOption(value: 'day', label: 'Day'),
///     AppSegmentedOption(value: 'week', label: 'Week'),
///   ],
///   selected: range,
///   onChanged: setRange,
/// )
/// ```
///
/// - Tokens only, caller-supplied labels, Directional-safe. Unselected text
///   is textPrimary at regular weight on the sunken track (onSurfaceVariant
///   is 4.40:1 on surfaceSunken in light, below the 4.5 text bar — measured
///   2026-10-20 — so the track keeps the spec token and the ink uses
///   onSurface at 16.49:1 light / 18.19:1 dark); selected is textPrimary
///   semibold on a surface chip (never color alone: chip + e1 shadow in
///   light / outline border in dark + weight + `selected` Semantics).
/// - Text scale 1.3x: labels ellipsize inside their segment; the control
///   keeps its 40/48 geometry.
class AppSegmentedControl<T> extends StatelessWidget {
  final List<AppSegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool _scrollable;

  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  }) : _scrollable = false;

  /// Scrollable variant for many options (timeframes, categories).
  const AppSegmentedControl.scrollable({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  }) : _scrollable = true;

  @override
  Widget build(BuildContext context) {
    assert(options.isNotEmpty, 'AppSegmentedControl needs options');
    final segments = [
      for (final option in options) _segment(context, option),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.semanticColors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: _scrollable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisSize: MainAxisSize.min, children: segments),
              )
            : Row(children: segments),
      ),
    );
  }

  Widget _segment(BuildContext context, AppSegmentedOption<T> option) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = option.value == selected;
    final segment = Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => onChanged(option.value),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Center(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? scheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow:
                      isSelected && !dark ? AppShadows.e1 : null,
                  border: isSelected && dark
                      ? Border.all(color: scheme.outline)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        option.icon,
                        size: 18,
                        color: scheme.onSurface,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              // Unselected ink sits directly on the sunken track:
                              // onSurface keeps >= 4.5 in both modes (see doc).
                              color: scheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return _scrollable ? segment : Expanded(child: segment);
  }
}

/// Scrollable pill-row variant for many options (phase-1e-i).
///
/// Selected pill = accentSoft fill + accent ink semibold (+ `selected`
/// Semantics); unselected = hairline outline + textSecondary. Each pill is
/// 40 px visual inside a >= 48 dp hit area.
///
/// ```dart
/// AppPillTabs<String>(
///   options: const [AppSegmentedOption(value: 'all', label: 'All'), ...],
///   selected: filter,
///   onChanged: setFilter,
/// )
/// ```
class AppPillTabs<T> extends StatelessWidget {
  final List<AppSegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const AppPillTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    assert(options.isNotEmpty, 'AppPillTabs needs options');
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _tab(context, options[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, AppSegmentedOption<T> option) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AppTokens.of(context);
    final isSelected = option.value == selected;
    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => onChanged(option.value),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Center(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? tokens.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected
                        ? tokens.accentSoft
                        : scheme.outline,
                  ),
                ),
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? tokens.accentInk
                            : scheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
