import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01.2 — global focus-ring + disabled grammar.
///
/// Proves the semantic `focusRing` / `disabledFill` / `disabledInk` /
/// `disabledBorder` tokens resolve in both brightnesses and that
/// `AppTheme._buildTheme` enforces them across buttons, inputs, chips,
/// checkboxes and switches.
void main() {
  group('Semantic tokens resolve (light + dark)', () {
    test('light disabled tokens use the frozen greys', () {
      const s = AppSemanticColors.light;
      expect(s.disabledFill, AppColors.disabled);
      expect(s.disabledInk, AppColors.textDisabled);
      expect(s.disabledBorder, AppColors.borderDefault);
      expect(s.focusRing, AppColors.primary);
    });

    test('dark disabled tokens use the frozen dark parity', () {
      const s = AppSemanticColors.dark;
      expect(s.disabledFill, AppDarkColors.surfaceSunken);
      expect(s.disabledInk, AppDarkColors.textDisabled);
      expect(s.disabledBorder, AppDarkColors.borderDefault);
      expect(s.focusRing, AppDarkColors.focusRing);
    });

    test('copyWith overrides disabled roles independently', () {
      const base = AppSemanticColors.light;
      final edited = base.copyWith(
        disabledFill: const Color(0xFF000001),
        focusRing: const Color(0xFF000002),
      );
      expect(edited.disabledFill, const Color(0xFF000001));
      expect(edited.focusRing, const Color(0xFF000002));
      expect(edited.disabledInk, base.disabledInk);
    });

    test('lerp interpolates disabled + focus roles', () {
      final mid = AppSemanticColors.light.lerp(AppSemanticColors.dark, 0.5);
      expect(mid.disabledFill, isNot(AppSemanticColors.light.disabledFill));
      expect(mid.disabledFill, isNot(AppSemanticColors.dark.disabledFill));
      expect(mid.focusRing, isNot(AppSemanticColors.dark.focusRing));
    });
  });

  group('_buildTheme enforcement', () {
    for (final entry in {
      'light': AppTheme.light(BrandConfig.orient),
      'dark': AppTheme.dark(BrandConfig.orient),
    }.entries) {
      final name = entry.key;
      final theme = entry.value;
      final semantic = theme.extension<AppSemanticColors>()!;

      test('$name ThemeData carries global disabled + focus inks', () {
        expect(theme.disabledColor, semantic.disabledFill);
        expect(theme.focusColor, semantic.focusRing.withValues(alpha: 0.16));
      });

      test('$name elevated/filled buttons use disabled tokens', () {
        final elevated = theme.elevatedButtonTheme.style!;
        expect(
          elevated.backgroundColor!.resolve({WidgetState.disabled}),
          semantic.disabledFill,
        );
        expect(
          elevated.foregroundColor!.resolve({WidgetState.disabled}),
          semantic.disabledInk,
        );
        final filled = theme.filledButtonTheme.style!;
        expect(
          filled.backgroundColor!.resolve({WidgetState.disabled}),
          semantic.disabledFill,
        );
      });

      test('$name outlined buttons ring focus + grey disabled', () {
        final side = theme.outlinedButtonTheme.style!.side!;
        expect(
          side.resolve({WidgetState.focused}),
          BorderSide(
            color: semantic.focusRing,
            width: AppInteractionStates.focusRingWidth,
          ),
        );
        expect(
          side.resolve({WidgetState.disabled})!.color,
          semantic.disabledBorder,
        );
      });

      test('$name inputs use focus ring + disabled border', () {
        final input = theme.inputDecorationTheme;
        expect(
          (input.focusedBorder! as OutlineInputBorder).borderSide.color,
          semantic.focusRing,
        );
        expect(
          (input.disabledBorder! as OutlineInputBorder).borderSide.color,
          semantic.disabledBorder,
        );
      });

      test('$name chips, checkbox and switch consume disabled tokens', () {
        expect(theme.chipTheme.disabledColor, semantic.disabledFill);
        final checkbox = theme.checkboxTheme;
        expect(
          checkbox.fillColor!.resolve({WidgetState.disabled}),
          semantic.disabledFill,
        );
        expect(
          checkbox.checkColor!.resolve({WidgetState.disabled}),
          semantic.disabledInk,
        );
        final switchTheme = theme.switchTheme;
        expect(
          switchTheme.trackColor!.resolve({WidgetState.disabled}),
          semantic.disabledFill,
        );
        expect(
          switchTheme.trackOutlineColor!.resolve({WidgetState.focused}),
          semantic.focusRing,
        );
      });
    }

    testWidgets('disabled controls render without overflow (EN/AR)', (
      tester,
    ) async {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            theme: AppTheme.light(BrandConfig.orient, locale: locale),
            home: Scaffold(
              body: const Column(
                children: [
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(hintText: 'Disabled'),
                  ),
                  FilledButton(
                    onPressed: null,
                    child: Text('Disabled'),
                  ),
                  Checkbox(value: false, onChanged: null),
                  Switch(value: false, onChanged: null),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
