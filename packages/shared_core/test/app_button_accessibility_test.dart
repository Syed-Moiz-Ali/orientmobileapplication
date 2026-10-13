import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01.1 — primary button accessibility correction.
///
/// Verifies that every primary action variant renders normal-sized labels and
/// icons with at least 4.5:1 contrast in light and dark themes, including the
/// loading state, and that the correction is implemented through the
/// centralized theme/ink tokens (no per-screen overrides).
void main() {
  Widget host(Widget child, {required bool dark}) {
    return MaterialApp(
      theme: dark
          ? AppTheme.dark(BrandConfig.orient)
          : AppTheme.light(BrandConfig.orient),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('PrimaryButton (AppButton.primary)', () {
    testWidgets('dark label and icon use the AA dark ink', (tester) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(
            label: 'Complete task',
            icon: Icons.check_rounded,
            isExpanded: false,
            onPressed: () {},
          ),
          dark: true,
        ),
      );

      final labelColor = tester
          .widget<Text>(find.text('Complete task'))
          .style!
          .color!;
      // The button paints its icons through the inherited IconTheme, which
      // Material resolves from the style foregroundColor.
      final iconColor = IconTheme.of(
        tester.element(find.byIcon(Icons.check_rounded)),
      ).color!;

      expect(labelColor, AppDarkColors.onPrimary);
      expect(iconColor, AppDarkColors.onPrimary);
      _expectContrast(labelColor, AppDarkColors.primary, 4.5, 'dark label');
      _expectContrast(iconColor, AppDarkColors.primary, 4.5, 'dark icon');

      // Interaction overlays derive from the ink; the label must stay AA.
      _expectStyleOverlay(
        tester,
        ElevatedButton,
        ink: AppDarkColors.onPrimary,
        fill: AppDarkColors.primary,
      );
    });

    testWidgets('light label stays white on brand primary (≥4.5:1)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(
            label: 'Complete task',
            isExpanded: false,
            onPressed: () {},
          ),
          dark: false,
        ),
      );

      final labelColor = tester
          .widget<Text>(find.text('Complete task'))
          .style!
          .color!;
      expect(labelColor, AppColors.textInverse);
      _expectContrast(labelColor, AppColors.primary, 4.5, 'light label');
      _expectStyleOverlay(
        tester,
        ElevatedButton,
        ink: AppColors.textInverse,
        fill: AppColors.primary,
      );
    });

    testWidgets('loading keeps the active fill so the spinner stays AA', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(label: 'Save', isLoading: true, onPressed: () {}),
          dark: true,
        ),
      );

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      final spinnerColor =
          (spinner.valueColor! as AlwaysStoppedAnimation<Color>).value;
      expect(spinnerColor, AppDarkColors.onPrimary);
      expect(spinnerColor.a, 1.0, reason: 'no opacity reduction on the ink');
      _expectContrast(
        spinnerColor,
        AppDarkColors.primary,
        4.5,
        'dark loading spinner',
      );

      // While loading the button renders the full-strength fill.
      final style = tester
          .widget<ElevatedButton>(find.byType(ElevatedButton))
          .style!;
      expect(
        style.backgroundColor!.resolve({WidgetState.disabled}),
        AppDarkColors.primary,
      );
      expect(
        style.foregroundColor!.resolve({WidgetState.disabled}),
        AppDarkColors.onPrimary,
      );
    });

    testWidgets('genuinely disabled keeps the dimmed treatment', (tester) async {
      await tester.pumpWidget(
        host(const PrimaryButton(label: 'Save'), dark: true),
      );

      final style = tester
          .widget<ElevatedButton>(find.byType(ElevatedButton))
          .style!;
      final disabledBg =
          style.backgroundColor!.resolve({WidgetState.disabled})!;
      final disabledFg =
          style.foregroundColor!.resolve({WidgetState.disabled})!;
      expect(disabledBg.a, lessThan(1.0));
      expect(disabledFg.a, lessThan(1.0));
      expect(tester.takeException(), isNull);
    });
  });

  group('AppButton.danger', () {
    testWidgets('dark uses the semantic error pair with AA ink', (tester) async {
      await tester.pumpWidget(
        host(
          AppButton.danger(
            label: 'Delete order',
            isExpanded: false,
            onPressed: () {},
          ),
          dark: true,
        ),
      );

      final style = tester
          .widget<ElevatedButton>(find.byType(ElevatedButton))
          .style!;
      final bg = style.backgroundColor!.resolve({});
      final fg = style.foregroundColor!.resolve({});
      expect(bg, AppDarkColors.danger);
      expect(fg, AppDarkColors.onError);
      _expectContrast(fg!, bg!, 4.5, 'dark danger label');
    });

    testWidgets('light keeps the approved white-on-danger look', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          AppButton.danger(
            label: 'Delete order',
            isExpanded: false,
            onPressed: () {},
          ),
          dark: false,
        ),
      );

      final style = tester
          .widget<ElevatedButton>(find.byType(ElevatedButton))
          .style!;
      expect(style.backgroundColor!.resolve({}), AppColors.danger);
      expect(style.foregroundColor!.resolve({}), AppColors.textInverse);
    });
  });

  testWidgets('dark progress step number follows the on-primary ink', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const AppStepProgress(
          steps: [
            AppProgressStep(label: 'Intake'),
            AppProgressStep(label: 'Inspect'),
          ],
          currentStep: 0,
        ),
        dark: true,
      ),
    );

    final stepNumber = tester.widget<Text>(find.text('1'));
    expect(stepNumber.style!.color, AppDarkColors.onPrimary);
    _expectContrast(
      stepNumber.style!.color!,
      AppDarkColors.primary,
      4.5,
      'dark step number',
    );
  });

  test('dark focus ring contrasts with every adjacent surface', () {
    _expectContrast(
      AppDarkColors.focusRing,
      AppDarkColors.canvas,
      3.0,
      'dark focus ring on canvas',
    );
    _expectContrast(
      AppDarkColors.focusRing,
      AppDarkColors.surface,
      3.0,
      'dark focus ring on surface',
    );
    _expectContrast(
      AppColors.focusRing,
      AppColors.canvas,
      3.0,
      'light focus ring on canvas',
    );
  });
}

/// Resolves the interaction overlays of the rendered button's style and
/// proves the composited label ink still meets AA in each enabled state.
void _expectStyleOverlay(
  WidgetTester tester,
  Type buttonType, {
  required Color ink,
  required Color fill,
}) {
  final style = tester.widget<ElevatedButton>(find.byType(buttonType)).style!;
  for (final entry in {
    'hovered': WidgetState.hovered,
    'pressed': WidgetState.pressed,
    'focused': WidgetState.focused,
  }.entries) {
    final overlay = style.overlayColor?.resolve({entry.value});
    expect(
      overlay,
      isNotNull,
      reason: 'button style must resolve the ${entry.key} overlay',
    );
    _expectContrast(
      ink,
      Color.alphaBlend(overlay!, fill),
      4.5,
      '${entry.key} overlay',
    );
  }
}

void _expectContrast(
  Color foreground,
  Color background,
  double atLeast,
  String label,
) {
  final ratio = _contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(atLeast),
    reason:
        '$label contrast ${ratio.toStringAsFixed(2)}:1 is below '
        '${atLeast.toStringAsFixed(1)}:1',
  );
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

double _relativeLuminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}
