import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/bar_chart_painter.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/dual_line_painter.dart';

void main() {
  // P0/P1 regression guards: the owner dashboard crashed on empty/failed data
  // because the painters called reduce() on empty lists.
  test('BarChartPainter does not crash on empty data', () {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const painter = BarChartPainter(salesData: [], expenseData: []);
    painter.paint(canvas, const ui.Size(300, 150));
  });

  test('BarChartPainter paints normally with data', () {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const painter = BarChartPainter(
      salesData: [SalesTrendPoint('Mon', 10)],
      expenseData: [SalesTrendPoint('Mon', 5)],
    );
    painter.paint(canvas, const ui.Size(300, 150));
  });

  test('DualLinePainter does not crash on empty data', () {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const painter = DualLinePainter(
      primaryData: [],
      secondaryData: [],
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFF000000),
    );
    painter.paint(canvas, const ui.Size(300, 150));
  });

  test('DualLinePainter does not crash on a single data point', () {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const painter = DualLinePainter(
      primaryData: [SalesTrendPoint('Mon', 10)],
      secondaryData: [],
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFF000000),
    );
    painter.paint(canvas, const ui.Size(300, 150));
  });
}
