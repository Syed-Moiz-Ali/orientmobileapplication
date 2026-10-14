import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Shape family for [AppSkeleton].
///
/// The simple shapes (`bar`, `card`, `circle`, `text`) mirror the original
/// primitive; the composite shapes (`textBlock`, `listRows`, `grid`, `chart`,
/// `table`) mirror the final layout so a first-load frame reads as the screen
/// it is about to become (Phase 03B objective 1).
enum AppSkeletonVariant {
  bar,
  card,
  circle,
  text,
  textBlock,
  listRows,
  grid,
  chart,
  table,
}

/// Clean skeleton loader with an animated pulse that mirrors the final layout.
///
/// Colour comes from the `skeletonBase`/`skeletonHighlight` tokens (light +
/// dark parity). A composite skeleton owns **one** animation controller and
/// renders all of its bars from that single tick, so a page of skeletons does
/// not spin up dozens of tickers. Under reduced motion the pulse is static.
class AppSkeleton extends StatefulWidget {
  final AppSkeletonVariant variant;
  final double? width;
  final double height;
  final double borderRadius;

  /// Text-block line count.
  final int lines;

  /// Text-block / list line height.
  final double lineHeight;

  /// Gap between text-block lines.
  final double lineGap;

  /// Fractional width of the last text-block line.
  final double lastLineFraction;

  /// Row count for `listRows` / `table`, item rows for `grid`.
  final int rows;

  /// Column count for `grid` / `table`.
  final int columns;

  /// Whether `listRows` shows a leading avatar block.
  final bool leading;

  /// Item height for `grid`.
  final double itemHeight;

  /// Spacing between grid/table items.
  final double spacing;

  /// Whether `table` renders a header row.
  final bool headerRow;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppDimensions.radiusControl,
  }) : variant = AppSkeletonVariant.bar,
       lines = 3,
       lineHeight = 12,
       lineGap = 8,
       lastLineFraction = 0.6,
       rows = 4,
       columns = 3,
       leading = true,
       itemHeight = 120,
       spacing = AppDimensions.s12,
       headerRow = true;

  /// Skeleton for a card container
  const AppSkeleton.card({
    super.key,
    this.width,
    this.height = 120.0,
    this.borderRadius = AppDimensions.radiusCard,
  }) : variant = AppSkeletonVariant.card,
       lines = 3,
       lineHeight = 12,
       lineGap = 8,
       lastLineFraction = 0.6,
       rows = 4,
       columns = 3,
       leading = true,
       itemHeight = 120,
       spacing = AppDimensions.s12,
       headerRow = true;

  /// Skeleton for a circular avatar or icon
  const AppSkeleton.circle({super.key, double size = 40.0})
    : width = size,
      height = size,
      borderRadius = AppDimensions.radiusPill,
      variant = AppSkeletonVariant.circle,
      lines = 3,
      lineHeight = 12,
      lineGap = 8,
      lastLineFraction = 0.6,
      rows = 4,
      columns = 3,
      leading = true,
      itemHeight = 120,
      spacing = AppDimensions.s12,
      headerRow = true;

  /// Skeleton for a single line of text
  const AppSkeleton.text({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius = AppDimensions.radiusXs,
    this.lastLineFraction = 0.6,
  }) : variant = AppSkeletonVariant.text,
       lines = 1,
       lineHeight = 14,
       lineGap = 8,
       rows = 4,
       columns = 3,
       leading = true,
       itemHeight = 120,
       spacing = AppDimensions.s12,
       headerRow = true;

  /// Paragraph of text lines (last line shorter).
  const AppSkeleton.textBlock({
    super.key,
    this.width,
    this.lines = 3,
    this.lineHeight = 12,
    this.lineGap = 8,
    this.lastLineFraction = 0.6,
    this.borderRadius = AppDimensions.radiusXs,
  }) : variant = AppSkeletonVariant.textBlock,
       height = 0,
       rows = 4,
       columns = 3,
       leading = true,
       itemHeight = 120,
       spacing = AppDimensions.s12,
       headerRow = true;

  /// Stack of list record rows (optional leading avatar).
  const AppSkeleton.listRows({
    super.key,
    this.rows = 4,
    this.leading = true,
    this.lineHeight = 12,
    this.borderRadius = AppDimensions.radiusXs,
    this.width,
  }) : variant = AppSkeletonVariant.listRows,
       height = 0,
       lines = 2,
       lineGap = 6,
       lastLineFraction = 0.6,
       columns = 1,
       itemHeight = 120,
       spacing = AppDimensions.s12,
       headerRow = false;

  /// Grid of card placeholders.
  const AppSkeleton.grid({
    super.key,
    this.columns = 2,
    this.rows = 2,
    this.itemHeight = 120,
    this.spacing = AppDimensions.s12,
    this.borderRadius = AppDimensions.radiusCard,
    this.width,
  }) : variant = AppSkeletonVariant.grid,
       height = 0,
       lines = 3,
       lineHeight = 12,
       lineGap = 8,
       lastLineFraction = 0.6,
       leading = false,
       headerRow = false;

  /// Chart placeholder mirroring an axis + series bars.
  const AppSkeleton.chart({
    super.key,
    this.height = 180.0,
    this.width,
    this.borderRadius = AppDimensions.radiusSm,
  }) : variant = AppSkeletonVariant.chart,
       lines = 3,
       lineHeight = 12,
       lineGap = 8,
       lastLineFraction = 0.6,
       rows = 4,
       columns = 6,
       leading = false,
       itemHeight = 120,
       spacing = AppDimensions.s12,
       headerRow = false;

  /// Table placeholder (header + data rows).
  const AppSkeleton.table({
    super.key,
    this.rows = 5,
    this.columns = 4,
    this.headerRow = true,
    this.lineHeight = 12,
    this.spacing = AppDimensions.s12,
    this.width,
  }) : variant = AppSkeletonVariant.table,
       height = 0,
       lines = 3,
       lineGap = 8,
       lastLineFraction = 0.6,
       leading = false,
       itemHeight = 120,
       borderRadius = AppDimensions.radiusXs;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Spec §11: the loading shimmer is exempt from the 280 ms ceiling but must
    // pause under reduced motion — the ticker stops, not only the paint.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;
    final base = semantic.skeletonBase;
    final highlight = semantic.skeletonHighlight;

    if (MediaQuery.disableAnimationsOf(context)) {
      // Static, mid-tone placeholder (reduced motion).
      return _buildShape(base, highlight, 0.5);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) =>
          _buildShape(base, highlight, _animation.value),
    );
  }

  Color _color(Color base, Color highlight, double t) =>
      Color.lerp(base, highlight, t)!;

  Widget _box(Color color, {double? width, double? height, double? radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? widget.borderRadius),
      ),
    );
  }

  Widget _buildShape(Color base, Color highlight, double t) {
    final color = _color(base, highlight, t);

    switch (widget.variant) {
      case AppSkeletonVariant.bar:
      case AppSkeletonVariant.card:
      case AppSkeletonVariant.circle:
      case AppSkeletonVariant.text:
        return _box(
          color,
          width: widget.width,
          height: widget.height,
          radius: widget.borderRadius,
        );
      case AppSkeletonVariant.textBlock:
        return _textBlock(color);
      case AppSkeletonVariant.listRows:
        return _listRows(color);
      case AppSkeletonVariant.grid:
        return _grid(color);
      case AppSkeletonVariant.chart:
        return _chart(color);
      case AppSkeletonVariant.table:
        return _table(color);
    }
  }

  Widget _textBlock(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.lines; i++) ...[
          if (i == widget.lines - 1)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: widget.lastLineFraction,
                child: _box(
                  color,
                  height: widget.lineHeight,
                  radius: widget.borderRadius,
                ),
              ),
            )
          else
            _box(color, height: widget.lineHeight, radius: widget.borderRadius),
          if (i != widget.lines - 1) SizedBox(height: widget.lineGap),
        ],
      ],
    );
  }

  Widget _listRows(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.rows; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == widget.rows - 1 ? 0 : AppDimensions.s12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.leading) ...[
                  _box(
                    color,
                    width: 44,
                    height: 44,
                    radius: AppDimensions.radiusControl,
                  ),
                  const SizedBox(width: AppDimensions.s12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _box(
                        color,
                        height: widget.lineHeight,
                        width: double.infinity,
                        radius: widget.borderRadius,
                      ),
                      const SizedBox(height: AppDimensions.s6),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: 0.55,
                          child: _box(
                            color,
                            height: widget.lineHeight - 2,
                            radius: widget.borderRadius,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _grid(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final count = widget.columns <= 0 ? 1 : widget.columns;
        final itemWidth = (total - widget.spacing * (count - 1)) / count;
        return Wrap(
          spacing: widget.spacing,
          runSpacing: widget.spacing,
          children: [
            for (var i = 0; i < count * widget.rows; i++)
              _box(
                color,
                width: itemWidth.clamp(0, total),
                height: widget.itemHeight,
                radius: widget.borderRadius,
              ),
          ],
        );
      },
    );
  }

  Widget _chart(Color color) {
    const heights = <double>[0.45, 0.7, 0.55, 0.85, 0.6, 0.78];
    return SizedBox(
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < heights.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FractionallySizedBox(
                        heightFactor: heights[i],
                        alignment: Alignment.bottomCenter,
                        child: _box(
                          color,
                          width: double.infinity,
                          height: double.infinity,
                          radius: widget.borderRadius,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          _box(color, height: 6, radius: AppDimensions.radiusXs),
        ],
      ),
    );
  }

  Widget _table(Color color) {
    final count = widget.columns <= 0 ? 1 : widget.columns;
    Widget row(double barHeight, {required bool header}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s8),
        child: Row(
          children: [
            for (var c = 0; c < count; c++)
              Expanded(
                flex: c == 0 ? 2 : 1,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AppDimensions.s12,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: header ? 0.5 : (c == 0 ? 0.8 : 0.6),
                      child: _box(color, height: barHeight),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.headerRow) ...[
          row(10, header: true),
          Divider(height: 1, color: color),
        ],
        for (var i = 0; i < widget.rows; i++) ...[
          row(widget.lineHeight, header: false),
          if (i != widget.rows - 1) Divider(height: 1, color: color),
        ],
      ],
    );
  }
}
