// Responsive + overflow verification (spec §E):
// every screen × the full review width matrix × EN/AR, asserting zero
// overflow/layout exceptions during layout and pumping.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

const _widths = <String, Size>{
  '320x640 small phone': Size(320, 640),
  '360x740 phone': Size(360, 740),
  '390x844 phone': Size(390, 844),
  '430x932 large phone': Size(430, 932),
  '600x960 tablet portrait': Size(600, 960),
  '768x1024 tablet': Size(768, 1024),
  '1024x768 laptop': Size(1024, 768),
  '1280x800 desktop': Size(1280, 800),
  '1440x900 large desktop': Size(1440, 900),
};

void main() {
  for (final screen in ProtoScreen.values) {
    for (final entry in _widths.entries) {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        final code = locale.languageCode;
        testWidgets('${screen.goldenName} ${entry.key} $code — no overflow',
            (tester) async {
          await pumpScreen(
            tester,
            screen,
            variant: screen.baseVariant,
            size: entry.value,
            locale: locale,
          );
          // Let pulsing skeletons / async assets advance several frames.
          for (var i = 0; i < 4; i++) {
            await tester.pump(const Duration(milliseconds: 120));
            expect(tester.takeException(), isNull,
                reason: 'layout exception at ${entry.key} ($code)');
          }
          await disposeTree(tester);
        });
      }
    }
  }

  testWidgets('skeleton loading variants are overflow-free at 320 (EN/AR)',
      (tester) async {
    for (final screen in ProtoScreen.values) {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        final variant = screen == ProtoScreen.addVehicle
            ? 'saving'
            : screen == ProtoScreen.login
                ? 'loading'
                : screen == ProtoScreen.inspection
                    ? 'exitGuard'
                    : 'loading';
        await pumpScreen(
          tester,
          screen,
          variant: variant,
          size: const Size(320, 640),
          locale: locale,
        );
        for (var i = 0; i < 3; i++) {
          await tester.pump(const Duration(milliseconds: 120));
          expect(tester.takeException(), isNull,
              reason: 'state variant exception: ${screen.goldenName} $variant');
        }
        await disposeTree(tester);
      }
    }
  });
}
