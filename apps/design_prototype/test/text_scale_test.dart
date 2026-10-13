// Accessibility: layout integrity at increased system text scale.
// The spec (§3.3/§17) requires screens to survive 1.0–1.3× gracefully with the
// forced 0.85 lock removed; this audit run verifies 1.15× and 1.3× at phone
// and tablet widths in both locales.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

void main() {
  for (final scale in const [1.15, 1.3]) {
    for (final size in const [Size(390, 844), Size(768, 1024)]) {
      for (final screen in ProtoScreen.values) {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          final code = locale.languageCode;
          testWidgets(
            '${screen.goldenName} ${size.width.toInt()}px ${scale}x $code — no overflow',
            (tester) async {
              await pumpScreen(
                tester,
                screen,
                variant: screen.baseVariant,
                size: size,
                locale: locale,
                textScale: scale,
              );
              for (var i = 0; i < 4; i++) {
                await tester.pump(const Duration(milliseconds: 120));
                expect(
                  tester.takeException(),
                  isNull,
                  reason: 'text scale $scale overflow at ${screen.goldenName} '
                      '(${size.width.toInt()}px, $code)',
                );
              }
              await disposeTree(tester);
            },
          );
        }
      }
    }
  }
}
