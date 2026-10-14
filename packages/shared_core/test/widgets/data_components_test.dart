import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 03 focused tests for the data-presentation instruments.
void main() {
  Widget host(Widget child, {bool dark = false, Locale? locale}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: dark
          ? AppTheme.dark(BrandConfig.orient, locale: locale)
          : AppTheme.light(BrandConfig.orient, locale: locale),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('TelemetryMetricPod', () {
    testWidgets('renders the overline label and the tabular value', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const TelemetryMetricPod(
            label: 'Revenue velocity',
            value: 'AED 48,250.00',
            deltaLabel: '+18.4% vs Target',
            trend: TelemetryTrend.up,
          ),
        ),
      );
      // Overline is uppercased.
      expect(find.text('REVENUE VELOCITY'), findsOneWidget);
      expect(find.text('AED 48,250.00'), findsOneWidget);
      expect(find.text('+18.4% vs Target'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('down trend uses the descending glyph and live badge localizes', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const TelemetryMetricPod(
            label: 'Bay occupancy',
            value: '82',
            deltaLabel: '-3.1%',
            trend: TelemetryTrend.down,
            isLive: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('renders in dark theme without exception', (tester) async {
      await tester.pumpWidget(
        host(
          const TelemetryMetricPod(label: 'Jobs', value: '42'),
          dark: true,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('SparklineChart', () {
    testWidgets('empty series render the chart placeholder, never a blank plot', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SparklineChart(series: [])),
      );
      expect(find.byType(AppChartPlaceholder), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('draws a custom-painted curve for real samples', (tester) async {
      await tester.pumpWidget(
        host(
          const SparklineChart(
            series: [
              SparklineSeries(<double>[0.2, 0.5, 0.4, 0.8, 0.9]),
            ],
          ),
        ),
      );
      expect(find.byType(AppChartPlaceholder), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders two series in dark theme without exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SparklineChart(
            series: [
              SparklineSeries(<double>[0.2, 0.5, 0.4, 0.8]),
              SparklineSeries(<double>[0.6, 0.3, 0.7, 0.5]),
            ],
          ),
          dark: true,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('LiveServiceTelemetryRibbon', () {
    test('maps the live JobCardStatus enum onto the six journey stages', () {
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.pending),
        ServiceStage.intake,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.vehicleReceived),
        ServiceStage.intake,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.inspected),
        ServiceStage.inspection,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.waitingParts),
        ServiceStage.parts,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.inProgress),
        ServiceStage.labor,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.qualityCheck),
        ServiceStage.quality,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.completed),
        ServiceStage.ready,
      );
      expect(
        LiveServiceTelemetryRibbon.stageFor(JobCardStatus.delivered),
        ServiceStage.ready,
      );
      expect(LiveServiceTelemetryRibbon.stageFor(JobCardStatus.cancelled), isNull);
    });

    testWidgets('renders localized stage labels', (tester) async {
      await tester.pumpWidget(
        host(const LiveServiceTelemetryRibbon(status: JobCardStatus.inProgress)),
      );
      expect(find.text('Intake'), findsOneWidget);
      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('Parts'), findsOneWidget);
      expect(find.text('Quality Check'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('renders the cancelled state for a cancelled job', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const LiveServiceTelemetryRibbon(status: JobCardStatus.cancelled)),
      );
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('renders in Arabic RTL without exception', (tester) async {
      await tester.pumpWidget(
        host(
          const LiveServiceTelemetryRibbon(status: JobCardStatus.waitingParts),
          locale: const Locale('ar'),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('قطع الغيار'), findsOneWidget);
    });
  });

  group('SpatialDamageHud', () {
    const hotspots = [
      DamageHotspot(
        zone: VehicleZone.frontLeft,
        kind: DamageKind.scratch,
        label: 'Front-left fender',
      ),
      DamageHotspot(
        zone: VehicleZone.sideRight,
        kind: DamageKind.dent,
        label: 'Rear door',
      ),
      DamageHotspot(
        zone: VehicleZone.front,
        kind: DamageKind.glass,
        label: 'Windshield',
      ),
    ];

    testWidgets('renders the three damage-kind legend labels', (tester) async {
      await tester.pumpWidget(host(const SpatialDamageHud(hotspots: hotspots)));
      expect(find.text('Scratch / Scuff'), findsOneWidget);
      expect(find.text('Dent / Deformation'), findsOneWidget);
      expect(find.text('Glass / Lamp'), findsOneWidget);
    });

    testWidgets('tapping a hotspot fires the callback with that hotspot', (
      tester,
    ) async {
      DamageHotspot? tapped;
      await tester.pumpWidget(
        host(
          SpatialDamageHud(
            hotspots: hotspots,
            onHotspotTap: (h) => tapped = h,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Rear door'));
      expect(tapped?.zone, VehicleZone.sideRight);
      expect(tapped?.kind, DamageKind.dent);
    });

    testWidgets('legend localizes in Arabic and blueprint stays LTR', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SpatialDamageHud(hotspots: hotspots),
          locale: const Locale('ar'),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('خدش / تآكل'), findsOneWidget);
    });
  });

  group('AppTable redesign', () {
    const columns = [
      AppTableColumn(label: 'Plate', flex: 2),
      AppTableColumn(label: 'Amount', numeric: true, sortable: true),
    ];
    const rows = ['A 12345', 'B 98765', 'C 45678'];

    testWidgets('desktop renders a header row and tappable data rows', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      var tapped = '';
      await tester.pumpWidget(
        host(
          AppTable<String>(
            columns: columns,
            items: rows,
            onRowTap: (v) => tapped = v,
            cells: (context, v) => [
              AppTableCell.text(context, v),
              AppTableCell.numeric(context, 'AED 1,250'),
            ],
          ),
        ),
      );
      expect(find.text('Plate'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      await tester.tap(find.text('B 98765'));
      expect(tapped, 'B 98765');
    });

    testWidgets('compact width uses the card fallback builder', (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          AppTable<String>(
            columns: columns,
            items: rows,
            cells: (context, v) => [AppTableCell.text(context, v)],
            compactBuilder: (context, v) => AppRecordRow(title: v),
          ),
        ),
      );
      expect(find.byType(AppRecordRow), findsNWidgets(3));
    });

    testWidgets('maxHeight pins the header above a scrolling row list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        host(
          SizedBox(
            height: 400,
            child: AppTable<String>(
              columns: columns,
              items: rows,
              maxHeight: 220,
              cells: (context, v) => [AppTableCell.text(context, v)],
            ),
          ),
        ),
      );
      expect(find.byType(AppTableHeader), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
