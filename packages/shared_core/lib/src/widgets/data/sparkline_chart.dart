import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_chart_theme.dart';

/// One plotted series for a [SparklineChart].
class SparklineSeries {
  /// Ordered sample values (oldest → newest). Fewer than 2 samples renders a
  /// flat marker rather than a crash.
  final List<double> values;

  /// Explicit series colour; when null the active chart palette is used.
  final Color? color;

  const SparklineSeries(this.values, {this.color});
}

/// **Sparkline chart (Phase 03, Concept A).**
///
/// A lightweight, dependency-free `CustomPaint` curve for revenue velocity and
/// bay-occupancy telemetry. It deliberately does **not** pull in `fl_chart`.
///
/// Rules carried from the shared chart language (`AppChartTheme`):
/// - at most [AppChartTheme.maxSeries] series are plotted;
/// - series colours come from the active semantic chart palette;
/// - the baseline uses `ColorScheme.outlineVariant`; the curve uses the series
///   colour;
/// - series / legend order mirrors in RTL via the chart theme, but the time
///   axis stays chronological in every locale;
/// - empty data renders [AppChartPlaceholder], never a blank plot.
class SparklineChart extends StatelessWidget {
  final List<SparklineSeries> series;

  /// Plot height.
  final double height;

  /// Fills the area under the first series with a soft gradient.
  final bool filled;

  /// Draws the baseline axis rule.
  final bool showBaseline;

  /// Stroke width of the primary curve.
  final double lineWidth;

  /// Draws a data dot on the newest sample of each series.
  final bool showLastDot;

  /// Copy for the empty placeholder.
  final String? emptyMessage;

  const SparklineChart({
    super.key,
    required this.series,
    this.height = 72,
    this.filled = true,
    this.showBaseline = true,
    this.lineWidth = 2,
    this.showLastDot = true,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = series.any((s) => s.values.isNotEmpty);
    if (!hasData) {
      return AppChartPlaceholder(height: height, message: emptyMessage);
    }

    final chart = AppChartTheme.of(context);
    final ordered = chart.orderSeries(series).take(AppChartTheme.maxSeries).toList();

    final resolved = <SparklineSeries>[
      for (var i = 0; i < ordered.length; i++)
        SparklineSeries(
          ordered[i].values,
          color: ordered[i].color ?? chart.seriesColor(i),
        ),
    ];

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          series: resolved,
          filled: filled,
          showBaseline: showBaseline,
          lineWidth: lineWidth,
          showLastDot: showLastDot,
          baselineColor: chart.baselineColor,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<SparklineSeries> series;
  final bool filled;
  final bool showBaseline;
  final double lineWidth;
  final bool showLastDot;
  final Color baselineColor;

  const _SparklinePainter({
    required this.series,
    required this.filled,
    required this.showBaseline,
    required this.lineWidth,
    required this.showLastDot,
    required this.baselineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final bottomInset = showBaseline ? 1.0 : 0.0;
    final plotHeight = size.height - bottomInset;

    if (showBaseline) {
      final baseline = Paint()
        ..color = baselineColor
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(0, plotHeight),
        Offset(size.width, plotHeight),
        baseline,
      );
    }

    // Resolve the value domain across all series so they share one scale.
    var min = double.infinity;
    var max = double.negativeInfinity;
    for (final s in series) {
      for (final v in s.values) {
        if (v < min) min = v;
        if (v > max) max = v;
      }
    }
    if (!min.isFinite || !max.isFinite) return;
    if (min == max) {
      min -= 1;
      max += 1;
    }
    final span = max - min;

    Offset pointFor(int i, int count, double value) {
      final dx = count <= 1 ? size.width / 2 : (i / (count - 1)) * size.width;
      final dy = plotHeight - ((value - min) / span) * plotHeight;
      return Offset(dx, dy);
    }

    for (final s in series) {
      final color = s.color ?? baselineColor;
      final count = s.values.length;
      if (count == 0) continue;

      if (count == 1) {
        final p = pointFor(0, 1, s.values.first);
        canvas.drawCircle(Offset(p.dx, p.dy), lineWidth, Paint()..color = color);
        continue;
      }

      final path = Path();
      final points = <Offset>[
        for (var i = 0; i < count; i++) pointFor(i, count, s.values[i]),
      ];

      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        // Smooth Catmull-Rom-style curve via quadratic mid-points.
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
        if (i == points.length - 2) {
          path.lineTo(p1.dx, p1.dy);
        }
      }

      if (filled) {
        final fillPath = Path.from(path)
          ..lineTo(points.last.dx, plotHeight)
          ..lineTo(points.first.dx, plotHeight)
          ..close();
        final fillPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(0, plotHeight),
            [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
          );
        canvas.drawPath(fillPath, fillPaint);
      }

      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, linePaint);

      if (showLastDot) {
        final last = points.last;
        canvas.drawCircle(last, lineWidth + 1.5, Paint()..color = color);
        canvas.drawCircle(
          last,
          lineWidth + 1.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = baselineColor.withValues(alpha: 0.4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return old.series != series ||
        old.filled != filled ||
        old.showBaseline != showBaseline ||
        old.lineWidth != lineWidth ||
        old.showLastDot != showLastDot ||
        old.baselineColor != baselineColor;
  }
}
