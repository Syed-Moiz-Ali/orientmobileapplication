import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';

class DualLinePainter extends CustomPainter {
  final List<SalesTrendPoint> primaryData;
  final List<SalesTrendPoint> secondaryData;
  final Color primaryColor;
  final Color secondaryColor;

  const DualLinePainter({
    required this.primaryData,
    required this.secondaryData,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allValues = [
      ...primaryData.map((d) => d.value),
      ...secondaryData.map((d) => d.value),
    ];
    final maxVal = allValues.reduce(math.max);
    final minVal = allValues.reduce(math.min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    void drawLine(List<SalesTrendPoint> data, Color color) {
      final path = Path();
      final fill = Path();

      for (var i = 0; i < data.length; i++) {
        final x = size.width * i / (data.length - 1);
        final y = size.height * (1 - (data[i].value - minVal) / range);
        if (i == 0) {
          path.moveTo(x, y);
          fill.moveTo(x, y);
        } else {
          path.lineTo(x, y);
          fill.lineTo(x, y);
        }
      }
      fill
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      for (var i = 0; i < data.length; i++) {
        final x = size.width * i / (data.length - 1);
        final y = size.height * (1 - (data[i].value - minVal) / range);
        canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = color);
        canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = Colors.white);
      }
    }

    drawLine(secondaryData, secondaryColor);
    drawLine(primaryData, primaryColor);
  }

  @override
  bool shouldRepaint(_) => false;
}
