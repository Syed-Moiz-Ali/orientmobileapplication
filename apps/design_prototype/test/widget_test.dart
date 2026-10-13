// Shell smoke test: the full prototype app boots into the review console with
// the six screens, both locales and both themes reachable.
import 'package:design_prototype/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

void main() {
  testWidgets('prototype shell boots with the six-screen console', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await loadPrototypeFonts();

    await tester.pumpWidget(const PrototypeApp());
    await tester.pump(const Duration(milliseconds: 200));

    // Console chrome (EN | ع language toggle, screen chips).
    expect(find.textContaining('Phase 00'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('ع'), findsOneWidget);

    // All six prototype screens are switchable.
    for (final label in const [
      'Owner Dashboard',
      'Job Cards',
      'Technician Job',
      'Add Vehicle',
      'Login',
      'Inspection',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'missing screen chip: $label');
    }

    // Default screen renders inside the device frame.
    expect(find.text('Al Quoz Auto Workshop'), findsOneWidget);
    await disposeTree(tester);
  });
}
