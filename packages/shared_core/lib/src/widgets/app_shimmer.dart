import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_core/src/theme/app_durations.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Shimmer highlight wrapper (phase-1d-ii, spec `AppShimmer`).
///
/// Wraps skeleton shapes in the approved `shimmer` package's travelling
/// highlight (1200 ms loop per C7). Base/highlight default to the
/// `skeletonBase`/`skeletonHighlight` tokens (light + dark); wrap ONE list
/// of shapes in ONE [AppShimmer], not one per row (package guidance).
/// Static (no ticker) under reduced motion or when [enabled] is false, so
/// golden tests get a deterministic frozen frame.
///
/// Name verified free in `packages/`; no rename needed.
///
/// ```dart
/// AppShimmer(
///   child: AppShimmerSkeleton.listRows(rows: 5),
/// )
/// ```
///
/// - Tokens only, Directional-safe (highlight travels from the start edge
///   in RTL via [direction] default). Child shapes must be opaque solids;
///   transparent pixels stay transparent.
/// - Meaning ("loading") is announced through the [semanticLabel] node while
///   the shapes themselves are excluded; motion + label carry it, never the
///   tint alone.
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection? direction;
  final bool enabled;
  final String semanticLabel;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = AppDurations.shimmerLoop,
    this.direction,
    this.enabled = true,
    this.semanticLabel = 'Loading',
  });

  @override
  Widget build(BuildContext context) {
    final sem = context.semanticColors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final body = !enabled || MediaQuery.disableAnimationsOf(context)
        ? child
        : Shimmer.fromColors(
            baseColor: baseColor ?? sem.skeletonBase,
            highlightColor: highlightColor ?? sem.skeletonHighlight,
            period: period,
            direction: direction ??
                (rtl ? ShimmerDirection.rtl : ShimmerDirection.ltr),
            child: child,
          );
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: body,
    );
  }
}
