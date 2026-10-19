import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// P0/P1 regression guards (migrated Phase 13): the bespoke owner painters
/// crashed on empty/failed data via `reduce()` on empty lists. The cockpit
/// now plots through the shared [SparklineChart], which renders
/// [AppChartPlaceholder] on empty input — these guards lock that contract so
/// the dashboard can never crash on unfetchable trends again.
void main() {
  testWidgets('SparklineChart renders placeholder on empty data', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SparklineChart(
            series: [SparklineSeries([]), SparklineSeries([])],
          ),
        ),
      ),
    );
    expect(find.byType(AppChartPlaceholder), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SparklineChart paints normally with data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SparklineChart(
            series: [
              SparklineSeries([10.0]),
              SparklineSeries([5.0]),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(AppChartPlaceholder), findsNothing);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SparklineChart survives a single data point', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SparklineChart(
            series: [
              SparklineSeries([10.0]),
              SparklineSeries([]),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(AppChartPlaceholder), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
