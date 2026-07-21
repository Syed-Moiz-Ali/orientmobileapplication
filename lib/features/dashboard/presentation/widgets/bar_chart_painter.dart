import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';

class BarChartPainter extends CustomPainter {
  final List<SalesTrendPoint> salesData;
  final List<SalesTrendPoint> expenseData;

  const BarChartPainter({required this.salesData, required this.expenseData});

  @override
  void paint(Canvas canvas, Size size) {
    final allValues = [
      ...salesData.map((d) => d.value),
      ...expenseData.map((d) => d.value),
    ];
    final maxVal = allValues.reduce(math.max);
    final count = salesData.length;
    final groupW = size.width / count;
    final barW = groupW * 0.33;
    const gap = 4.0;
    const bottomPad = 20.0;
    final chartH = size.height - bottomPad;

    for (var i = 0; i < count; i++) {
      final gx = groupW * i + groupW / 2;

      final sh = chartH * salesData[i].value / maxVal;
      final sRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(gx - barW - gap / 2, chartH - sh, barW, sh),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        sRect,
        Paint()
          ..shader = const LinearGradient(
            colors: [AppColors.accent, AppColors.navy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, barW, sh)),
      );

      final eh = chartH * expenseData[i].value / maxVal;
      final eRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(gx + gap / 2, chartH - eh, barW, eh),
        const Radius.circular(5),
      );
      canvas.drawRRect(
        eRect,
        Paint()
          ..shader = LinearGradient(
            colors: [AppColors.warning.withValues(alpha: 0.9), AppColors.warning.withValues(alpha: 0.5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, barW, eh)),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: salesData[i].month,
          style: const TextStyle(color: AppColors.text3, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(gx - tp.width / 2, size.height - tp.height));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
