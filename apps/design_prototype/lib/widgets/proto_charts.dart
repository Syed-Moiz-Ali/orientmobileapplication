// Chart language from the spec (V8): shared palette, token typography, max
// 2 series, localized axis labels that MIRROR in RTL (time flows start→end).
// Adapts the production painters (dual_line_painter / bar_chart_painter) to
// the new visual language without adding a chart dependency.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/prototype_theme.dart';
import '../design/provisional_tokens.dart';

class ProtoSeries {
  final String label;
  final List<double> values;
  final Color color;

  const ProtoSeries({required this.label, required this.values, required this.color});
}

class ProtoTrendChart extends StatelessWidget {
  final ProtoSeries primary;
  final ProtoSeries secondary;
  final List<String> xLabels;
  final double height;

  const ProtoTrendChart({
    super.key,
    required this.primary,
    required this.secondary,
    required this.xLabels,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            size: Size.infinite,
            painter: _TrendPainter(
              primary: primary,
              secondary: secondary,
              grid: p.borderSubtle,
              rtl: context.isRtl,
            ),
          ),
        ),
        const SizedBox(height: ProtoSpace.s10),
        _AxisLabels(labels: xLabels),
      ],
    );
  }
}

class ProtoBarChart extends StatelessWidget {
  final ProtoSeries sales;
  final ProtoSeries expenses;
  final List<String> xLabels;
  final double height;

  const ProtoBarChart({
    super.key,
    required this.sales,
    required this.expenses,
    required this.xLabels,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height - 24,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BarPainter(
              sales: sales,
              expenses: expenses,
              grid: p.borderSubtle,
              rtl: context.isRtl,
            ),
          ),
        ),
        const SizedBox(height: ProtoSpace.s10),
        _AxisLabels(labels: xLabels),
      ],
    );
  }
}

class _AxisLabels extends StatelessWidget {
  final List<String> labels;

  const _AxisLabels({required this.labels});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ordered = context.isRtl ? labels.reversed.toList() : labels;
    return Row(
      children: [
        for (final label in ordered)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.types.metadata.copyWith(color: p.textMuted, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

/// Maps logical series index to plot x so RTL mirrors the time axis.
double _x(Size size, int index, int length, bool rtl) {
  final logical = rtl ? length - 1 - index : index;
  return size.width * logical / (length - 1).clamp(1, 1 << 30);
}

class _TrendPainter extends CustomPainter {
  final ProtoSeries primary;
  final ProtoSeries secondary;
  final Color grid;
  final bool rtl;

  const _TrendPainter({
    required this.primary,
    required this.secondary,
    required this.grid,
    required this.rtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...primary.values, ...secondary.values];
    if (all.isEmpty) return;
    final maxVal = all.reduce(math.max);
    final minVal = all.reduce(math.min);
    final range = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

    // Grid lines: quiet, hairline, four rows.
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    void drawLine(ProtoSeries series, {required bool fill}) {
      if (series.values.length < 2) return;
      final path = Path();
      for (var i = 0; i < series.values.length; i++) {
        final x = _x(size, i, series.values.length, rtl);
        final y = size.height * (1 - (series.values[i] - minVal) / range);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      if (fill) {
        final area = Path.from(path)
          ..lineTo(_x(size, series.values.length - 1, series.values.length, rtl), size.height)
          ..lineTo(_x(size, 0, series.values.length, rtl), size.height)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              colors: [series.color.withValues(alpha: 0.16), series.color.withValues(alpha: 0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = series.color
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < series.values.length; i++) {
        final x = _x(size, i, series.values.length, rtl);
        final y = size.height * (1 - (series.values[i] - minVal) / range);
        canvas.drawCircle(Offset(x, y), 3.6, Paint()..color = series.color);
        canvas.drawCircle(Offset(x, y), 1.8, Paint()..color = Colors.white);
      }
    }

    drawLine(secondary, fill: false);
    drawLine(primary, fill: true);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.secondary != secondary || oldDelegate.rtl != rtl;
}

class _BarPainter extends CustomPainter {
  final ProtoSeries sales;
  final ProtoSeries expenses;
  final Color grid;
  final bool rtl;

  const _BarPainter({
    required this.sales,
    required this.expenses,
    required this.grid,
    required this.rtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sales.values.isEmpty || expenses.values.isEmpty) return;
    final count = math.min(sales.values.length, expenses.values.length);
    final maxVal = [...sales.values, ...expenses.values].reduce(math.max);
    if (count == 0 || maxVal <= 0) return;

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final groupW = size.width / count;
    final barW = math.min(groupW * 0.26, 20.0);
    const gap = 4.0;

    for (var i = 0; i < count; i++) {
      final logical = rtl ? count - 1 - i : i;
      final groupCenter = groupW * i + groupW / 2;

      final sh = size.height * sales.values[logical] / maxVal;
      final sRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(groupCenter - barW - gap / 2, size.height - sh, barW, sh),
        const Radius.circular(4),
      );
      canvas.drawRRect(sRect, Paint()..color = sales.color);

      final eh = size.height * expenses.values[logical] / maxVal;
      final eRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(groupCenter + gap / 2, size.height - eh, barW, eh),
        const Radius.circular(4),
      );
      canvas.drawRRect(eRect, Paint()..color = expenses.color.withValues(alpha: 0.65));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter oldDelegate) =>
      oldDelegate.sales != sales || oldDelegate.expenses != expenses || oldDelegate.rtl != rtl;
}

/// Small legend chip: dot + label (max two per chart).
class ProtoChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const ProtoChartLegend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: ProtoSpace.s6),
        Text(
          label,
          style: context.types.metadata.copyWith(color: p.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
