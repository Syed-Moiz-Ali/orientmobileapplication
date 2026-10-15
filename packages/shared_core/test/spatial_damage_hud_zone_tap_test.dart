import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 08 — additive `onZoneTap` coverage for [SpatialDamageHud].
///
/// Empty-canvas taps resolve to the nearest blueprint zone; taps landing on
/// an existing pin are left to the pin's own gesture (no double handling).
void main() {
  const diagramWidth = 300.0;
  const diagramHeight = 200.0;

  Widget host(Widget child) {
    return MaterialApp(
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(BrandConfig.orient),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: diagramWidth, child: child),
        ),
      ),
    );
  }

  /// Top-left of the painted blueprint box (the legend sits below it, so the
  /// widget origin is not the diagram origin; the binding surface also owns a
  /// root CustomPaint, so scope the search to the HUD subtree).
  Offset diagramOrigin(WidgetTester tester) => tester.getTopLeft(
    find.descendant(
      of: find.byType(SpatialDamageHud),
      matching: find.byType(CustomPaint),
    ),
  );

  Offset anchorOf(VehicleZone zone, Offset origin) {
    // The shared anchors are Alignment-based ((a+1)/2 fractions); tapping the
    // exact anchor lands well within the 0.05 tap threshold.
    const shared = {
      VehicleZone.front: Alignment(0, -0.86),
      VehicleZone.frontLeft: Alignment(-0.66, -0.56),
      VehicleZone.sideLeft: Alignment(-0.9, 0),
      VehicleZone.rearLeft: Alignment(-0.66, 0.56),
      VehicleZone.rear: Alignment(0, 0.86),
      VehicleZone.rearRight: Alignment(0.66, 0.56),
      VehicleZone.sideRight: Alignment(0.9, 0),
      VehicleZone.frontRight: Alignment(0.66, -0.56),
    };
    final a = shared[zone]!;
    return origin +
        Offset(
          ((a.x + 1) / 2) * diagramWidth,
          ((a.y + 1) / 2) * diagramHeight,
        );
  }

  testWidgets('empty zone tap reports the nearest zone', (tester) async {
    VehicleZone? tapped;
    await tester.pumpWidget(
      host(
        SpatialDamageHud(
          height: diagramHeight,
          onZoneTap: (z) => tapped = z,
        ),
      ),
    );
    await tester.tapAt(
      anchorOf(VehicleZone.rear, diagramOrigin(tester)),
    );
    expect(tapped, VehicleZone.rear);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pin tap fires the hotspot, not a zone tap', (tester) async {
    VehicleZone? zoned;
    DamageHotspot? pinned;
    await tester.pumpWidget(
      host(
        SpatialDamageHud(
          height: diagramHeight,
          hotspots: const [
            DamageHotspot(zone: VehicleZone.front, kind: DamageKind.scratch),
          ],
          onZoneTap: (z) => zoned = z,
          onHotspotTap: (h) => pinned = h,
        ),
      ),
    );
    await tester.tapAt(
      anchorOf(VehicleZone.front, diagramOrigin(tester)),
    );
    expect(pinned?.zone, VehicleZone.front);
    expect(zoned, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('far-off tap reports nothing', (tester) async {
    VehicleZone? tapped;
    await tester.pumpWidget(
      host(
        SpatialDamageHud(
          height: diagramHeight,
          onZoneTap: (z) => tapped = z,
        ),
      ),
    );
    final origin = diagramOrigin(tester);
    // Canvas centre sits between the side anchors, outside the threshold.
    await tester.tapAt(
      origin + const Offset(diagramWidth / 2, diagramHeight / 2),
    );
    expect(tapped, isNull);
    expect(tester.takeException(), isNull);
  });
}
