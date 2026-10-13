// Final visual-quality-audit captures (not part of the §E review matrix):
//  - 1440 px extended-rail desktop composition
//  - full-page tall renders proving the complete page composition
//    (dashboard: hero → KPI → register → analytics → quick actions)
//    EN and AR.
//
// Run: flutter test test/audit_captures_test.dart --update-goldens
// Output: test/goldens/audit/
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

void main() {
  testWidgets('dashboard 1440 EN extended rail', (tester) async {
    await pumpScreen(tester, ProtoScreen.ownerDashboard,
        variant: 'populated', size: const Size(1440, 900));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/audit/owner_dashboard_1440_en_populated.png'),
    );
    await disposeTree(tester);
  });

  testWidgets('dashboard 1440 AR extended rail', (tester) async {
    await pumpScreen(tester, ProtoScreen.ownerDashboard,
        variant: 'populated', size: const Size(1440, 900), locale: const Locale('ar'));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/audit/owner_dashboard_1440_ar_populated.png'),
    );
    await disposeTree(tester);
  });

  testWidgets('dashboard full page 1280 EN', (tester) async {
    await pumpScreen(tester, ProtoScreen.ownerDashboard,
        variant: 'populated', size: const Size(1280, 1780));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/audit/owner_dashboard_fullpage_1280_en.png'),
    );
    await disposeTree(tester);
  });

  testWidgets('dashboard full page 1280 AR', (tester) async {
    await pumpScreen(tester, ProtoScreen.ownerDashboard,
        variant: 'populated', size: const Size(1280, 1780), locale: const Locale('ar'));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/audit/owner_dashboard_fullpage_1280_ar.png'),
    );
    await disposeTree(tester);
  });

  testWidgets('dashboard full page 390 AR (mobile composition)', (tester) async {
    await pumpScreen(tester, ProtoScreen.ownerDashboard,
        variant: 'populated', size: const Size(390, 2400), locale: const Locale('ar'));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/audit/owner_dashboard_fullpage_390_ar.png'),
    );
    await disposeTree(tester);
  });

  testWidgets('inspection full page 1280 AR (three-pane completeness)',
      (tester) async {
    await pumpScreen(tester, ProtoScreen.inspection,
        variant: 'partial', size: const Size(1280, 1400), locale: const Locale('ar'));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/audit/inspection_fullpage_1280_ar.png'),
    );
    await disposeTree(tester);
  });
}
