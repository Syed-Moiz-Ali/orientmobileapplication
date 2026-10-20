import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Spec-C8 count badge (phase-1c-ii).
///
/// 20 px min pill showing a capped count (`120` -> `99+`). Name verified
/// free in `src/widgets/` (no legacy `AppBadge`); no rename needed.
///
/// ```dart
/// AppBadge(count: 3) // accent fill
/// AppBadge(count: 7, kind: AppBadgeKind.error)
/// ```
///
/// - Tokens only: accent = `ColorScheme.primary` / `onPrimary`, error =
///   `ColorScheme.error` / `onError` (measured 4.8+:1 light / 5.3+:1 dark in
///   the identity tests). Caller data only (no words of our own; the default
///   Semantics label is the displayed count, overridable via
///   [semanticLabel]).
/// - Display-only (no tap target); text scale 1.3x grows the pill, never
///   clips it.
enum AppBadgeKind { accent, error }

class AppBadge extends StatelessWidget {
  final int count;
  final int maxCount;
  final AppBadgeKind kind;
  final String? semanticLabel;

  const AppBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.kind = AppBadgeKind.accent,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = kind == AppBadgeKind.accent ? scheme.primary : scheme.error;
    final ink =
        kind == AppBadgeKind.accent ? scheme.onPrimary : scheme.onError;
    final display = count > maxCount ? '$maxCount+' : '$count';

    return Semantics(
      label: semanticLabel ?? display,
      // No alignment here: an aligning Container would expand to the full
      // incoming line width (e.g. inside a Wrap). Shrink-to-text + padding
      // keeps the pill compact.
      child: Container(
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(
          display,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // Capped pill: ellipsis keeps "99+" inside at 1.3x; the pill
          // grows via padding instead of clipping.
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: ink),
        ),
      ),
    );
  }
}
