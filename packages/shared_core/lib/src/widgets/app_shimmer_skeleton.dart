import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/app_shimmer.dart';

/// Layout-mirroring skeleton shapes (phase-1d-ii).
///
/// Interim name: spec `AppSkeleton` is owned by the legacy pulse loader in
/// `app_skeleton.dart` (off-limits in phase 1). Rename path:
/// `AppShimmerSkeleton` → `AppSkeleton` in one codemod in the polish phase
/// once the legacy skeleton hits zero usages. `AppShimmer` keeps its name.
///
/// Shapes mirror the final layout they stand in for (same radii/heights/
/// gaps as `AppSurfaceCard`/list tiles): card = radius 16, list rows = 40 px
/// leading block + 12 px gaps, text = 14 px lines. One [AppShimmer] drives
/// the whole shape; static under reduced motion (see [AppShimmer]).
///
/// ```dart
/// AppShimmerSkeleton.listRows(rows: 5) // stands in for a tile list
/// AppShimmerSkeleton.card(height: 148) // stands in for an AppSurfaceCard
/// ```
///
/// - Tokens only, caller fixes only counts/sizes, Directional-safe (leading
///   block swaps sides in RTL), wraps at 1.3x (rows use Expanded/Fraction).
/// - Shapes are opaque solids in the skeleton base token; the travelling
///   highlight is painted by [AppShimmer]. Freeze with `enabled: false`.
class AppShimmerSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final int lines;
  final double lineHeight;
  final double lineGap;
  final double lastLineFraction;
  final int rows;
  final bool leading;
  final bool _isRows;
  final bool enabled;
  final String semanticLabel;

  const AppShimmerSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = AppRadius.xs,
    this.enabled = true,
    this.semanticLabel = 'Loading',
  })  : lines = 1,
        lineHeight = 14,
        lineGap = AppSpacing.sm,
        lastLineFraction = 1,
        rows = 1,
        leading = false,
        _isRows = false;

  const AppShimmerSkeleton.card({
    super.key,
    this.width,
    this.height = 120,
    this.radius = AppRadius.card,
    this.enabled = true,
    this.semanticLabel = 'Loading',
  })  : lines = 1,
        lineHeight = 14,
        lineGap = AppSpacing.sm,
        lastLineFraction = 1,
        rows = 1,
        leading = false,
        _isRows = false;

  const AppShimmerSkeleton.circle({
    super.key,
    double size = 40,
    this.enabled = true,
    this.semanticLabel = 'Loading',
  })  : width = size,
        height = size,
        radius = AppRadius.pill,
        lines = 1,
        lineHeight = 14,
        lineGap = AppSpacing.sm,
        lastLineFraction = 1,
        rows = 1,
        leading = false,
        _isRows = false;

  const AppShimmerSkeleton.textBlock({
    super.key,
    this.width,
    this.lines = 3,
    this.lineHeight = 14,
    this.lineGap = AppSpacing.sm,
    this.lastLineFraction = 0.6,
    this.radius = AppRadius.xs,
    this.enabled = true,
    this.semanticLabel = 'Loading',
  })  : height = 0,
        rows = 1,
        leading = false,
        _isRows = false;

  const AppShimmerSkeleton.listRows({
    super.key,
    this.rows = 4,
    this.leading = true,
    this.lineHeight = 12,
    this.radius = AppRadius.xs,
    this.enabled = true,
    this.semanticLabel = 'Loading content',
  })  : width = null,
        height = 0,
        lines = 2,
        lineGap = AppSpacing.xs,
        lastLineFraction = 0.55,
        _isRows = true;

  @override
  Widget build(BuildContext context) {
    final base = context.semanticColors.skeletonBase;
    Widget box({double? w, required double h, double? r}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(r ?? radius),
          ),
        );
    final Widget shapes;
    if (_isRows) {
      shapes = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == rows - 1 ? 0 : AppSpacing.listGap,
              ),
              child: Row(
                children: [
                  if (leading) ...[
                    box(w: 40, h: 40, r: AppRadius.pill),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        box(h: lineHeight),
                        SizedBox(height: lineGap),
                        FractionallySizedBox(
                          widthFactor: lastLineFraction,
                          alignment: AlignmentDirectional.centerStart,
                          child: box(h: lineHeight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } else if (lines > 1) {
      shapes = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < lines; i++) ...[
            if (i == lines - 1)
              FractionallySizedBox(
                widthFactor: lastLineFraction,
                alignment: AlignmentDirectional.centerStart,
                child: box(h: lineHeight),
              )
            else
              box(h: lineHeight),
            if (i != lines - 1) SizedBox(height: lineGap),
          ],
        ],
      );
    } else {
      shapes = box(w: width, h: height);
    }
    return AppShimmer(
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: shapes,
    );
  }
}
