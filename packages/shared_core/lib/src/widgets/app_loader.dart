import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Centered blocking-action spinner (phase-1d-ii, spec `AppLoader`).
///
/// 28 px accent spinner for SHORT blocking actions only (submit, retry);
/// content areas use [AppShimmerSkeleton] instead (C10). The busy state is
/// announced through a live-region label — Flutter's `Semantics` widget
/// exposes no `busy` flag, so `'Label, loading'` is the mechanism (same
/// pattern as `AppPillButton`'s loading label).
///
/// Static (determinate, no ticker) under reduced motion
/// (`AppMotion.reducedMotion`, same pattern as `AppShimmer`); live
/// indeterminate spinner otherwise.
///
/// Name verified free in `packages/`; no rename needed.
///
/// ```dart
/// AppLoader(label: 'Saving changes') // blocks, announces, resolves fast
/// ```
///
/// - Tokens only (accent from the active scheme, light + dark), caller text,
///   wraps at 1.3x (label below the spinner, never clipped). Not
///   interactive, so no 48 dp target — it replaces the action in place.
class AppLoader extends StatelessWidget {
  final String label;
  final double size;

  const AppLoader({
    super.key,
    this.label = 'Loading',
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reduced = AppMotion.reducedMotion(context);
    return Semantics(
      label: '$label, loading',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                // Determinate = no ticker = static under reduced motion.
                value: reduced ? 0.75 : null,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
