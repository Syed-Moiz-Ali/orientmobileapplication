// Phase 00 deterministic screenshot pack (spec §E/§H): every prototype screen
// rendered at the review widths × EN/AR + per-screen state variants, captured
// with `matchesGoldenFile` into test/goldens/.
//
// Naming scheme (spec §K.2): screen_width_locale_state.png
//
// Run once with  : flutter test --update-goldens test/visual_pack_test.dart
// Verify         : flutter test test/visual_pack_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

/// §E review matrix widths (logical pixels).
const _matrix = <String, Size>{
  '320': Size(320, 640),
  '390': Size(390, 844),
  '768': Size(768, 1024),
  '1280': Size(1280, 800),
};

/// State variants captured at 390×844 in both locales.
const _stateVariants = <ProtoScreen, List<String>>{
  ProtoScreen.ownerDashboard: ['loading', 'empty', 'error'],
  ProtoScreen.jobCards: ['loading', 'empty', 'noMatch', 'error'],
  ProtoScreen.technicianJob: ['delayed', 'completed', 'noTasks', 'loading', 'error'],
  ProtoScreen.addVehicle: ['invalid', 'saving', 'saveError'],
  ProtoScreen.login: ['invalid', 'otp', 'loading'],
  ProtoScreen.inspection: ['empty', 'complete', 'findingSheet', 'exitGuard'],
};

void main() {
  group('base matrix (6 screens × 4 widths × EN/AR)', () {
    for (final screen in ProtoScreen.values) {
      for (final width in _matrix.keys) {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          final code = locale.languageCode;
          testWidgets('${screen.goldenName} $width $code', (tester) async {
            await pumpScreen(
              tester,
              screen,
              variant: screen.baseVariant,
              size: _matrix[width]!,
              locale: locale,
            );
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/${screen.goldenName}_${width}_${code}_${screen.baseVariant}.png'),
            );
            await disposeTree(tester);
          });
        }
      }
    }
  });

  group('state variants (390 × EN/AR)', () {
    for (final entry in _stateVariants.entries) {
      final screen = entry.key;
      for (final variant in entry.value) {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          final code = locale.languageCode;
          testWidgets('${screen.goldenName} $variant $code', (tester) async {
            await pumpScreen(
              tester,
              screen,
              variant: variant,
              size: const Size(390, 844),
              locale: locale,
            );
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile('goldens/${screen.goldenName}_390_${code}_$variant.png'),
            );
            await disposeTree(tester);
          });
        }
      }
    }
  });

  group('dark theme spot checks', () {
    for (final screen in ProtoScreen.values) {
      testWidgets('${screen.goldenName} dark en 390', (tester) async {
        await pumpScreen(
          tester,
          screen,
          variant: screen.baseVariant,
          size: const Size(390, 844),
          dark: true,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${screen.goldenName}_390_en_${screen.baseVariant}_dark.png'),
        );
        await disposeTree(tester);
      });
      testWidgets('${screen.goldenName} dark ar 1280', (tester) async {
        await pumpScreen(
          tester,
          screen,
          variant: screen.baseVariant,
          size: const Size(1280, 800),
          locale: const Locale('ar'),
          dark: true,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${screen.goldenName}_1280_ar_${screen.baseVariant}_dark.png'),
        );
        await disposeTree(tester);
      });
    }
  });
}
