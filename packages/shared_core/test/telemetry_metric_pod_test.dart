import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({
  required Widget child,
  Size size = const Size(390, 900),
  TextScaler scaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      SharedCoreLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light(BrandConfig.orient),
    home: MediaQuery(
      data: MediaQueryData(size: size, textScaler: scaler),
      child: Scaffold(body: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      )),
    ),
  );
}

void main() {
  group('TelemetryMetricPod delta row', () {
    testWidgets('long delta never overflows at 320px and 1.3x', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          scaler: const TextScaler.linear(1.3),
          child: const TelemetryMetricPod(
            label: 'Approvals',
            value: '7',
            deltaLabel: 'Needs attention from the service desk',
            trend: TelemetryTrend.up,
            icon: Icons.fact_check_outlined,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Needs attention from the service desk'), findsOneWidget);
    });

    testWidgets('delta and supporting line share the row', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const TelemetryMetricPod(
            label: 'Revenue',
            value: 'AED 84K',
            deltaLabel: '+18.4% vs target',
            supportingText: 'This month',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('+18.4% vs target'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
    });
  });
}
