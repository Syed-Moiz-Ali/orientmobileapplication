import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';

/// C16 search-first pill affordance (phase-1P).
///
/// A read-only, tappable stadium pill: search icon + hint-or-query text with
/// an optional clear action. Tapping the pill opens the search experience
/// (screen or sheet); it never edits text inline.
///
/// This is intentionally NOT [AppSearchBar]: that widget is a live editable
/// [TextField] (keyboard, focus, controller). [AppSearchPill] is a
/// navigation affordance that displays the current query (caller-owned
/// state) and reports taps. If inline editing is needed, use [AppSearchBar].
///
/// ```dart
/// AppSearchPill(
///   hint: 'Search bookings',
///   query: filter.query,
///   onTap: openSearch,
///   onClear: filter.query.isNotEmpty ? clearQuery : null,
/// )
/// ```
///
/// - Tokens only, caller-supplied text. Pill radius, height 48, fill
///   `surfaceContainerLow`, 1 px `inputBorder` resting boundary (same AA
///   pair as `AppSearchBar`).
/// - Query text stays LTR with physical-left alignment (same rationale as
///   `AppInputField.forceLtr`); the hint follows the ambient direction.
/// - Whole pill is one >= 48 dp button; the clear action is a nested
///   48 dp [AppIconButton] that wins the gesture arena (no double-fire).
/// - 1.3x-safe: text ellipsizes instead of overflowing.
class AppSearchPill extends StatelessWidget {
  /// Placeholder shown when [query] is null or empty.
  final String? hint;

  /// Current query to display (caller-owned). Null/empty shows [hint].
  final String? query;

  /// Opens the search experience. Null = inert pill at 40% opacity.
  final VoidCallback? onTap;

  /// Clears the displayed query. Null (or empty query) hides the clear
  /// action.
  final VoidCallback? onClear;

  /// Accessible label for the clear action.
  final String clearLabel;

  /// Overrides the pill's Semantics label (defaults to query ?? hint).
  final String? semanticLabel;

  const AppSearchPill({
    super.key,
    this.hint,
    this.query,
    this.onTap,
    this.onClear,
    this.clearLabel = 'Clear search',
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = AppTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final showingQuery = (query ?? '').isNotEmpty;
    final showClear = showingQuery && onClear != null;

    // Queries stay LTR with physical-left alignment (same rationale as
    // AppTileRow values); hints follow the ambient direction so localized
    // placeholders read correctly.
    final raw = Text(
      showingQuery ? '\u2066${query!}\u2069' : (hint ?? ''),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: showingQuery ? TextAlign.left : null,
      style: textTheme.bodyLarge?.copyWith(
        color: showingQuery ? scheme.onSurface : scheme.onSurfaceVariant,
      ),
    );
    final text = showingQuery
        ? Directionality(textDirection: TextDirection.ltr, child: raw)
        : raw;

    final pill = Container(
      height: 48,
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: tokens.inputBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 20,
            color: scheme.onSurfaceVariant,
            // Search glyphs never mirror (see DirectionalIcon docs).
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: text),
          if (showClear)
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: AppIconButton(
                  icon: Icons.clear_rounded,
                  onPressed: onTap == null ? null : onClear,
                  tooltip: clearLabel,
                  mirrorInRtl: false,
                ),
              ),
            )
          else
            const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );

    final label = semanticLabel ?? (showingQuery ? query : hint) ?? 'Search';
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: pill,
          ),
        ),
      ),
    );
  }
}
