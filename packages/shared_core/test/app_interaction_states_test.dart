import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 03A — centralized interaction-state accessibility.
///
/// Proves that every enabled interaction state (hover / pressed / focused)
/// keeps normal-sized button-label contrast at or above WCAG AA 4.5:1 in both
/// brightnesses. This closes the Phase 01.1 deviation where the light danger
/// button's pressed overlay lightened the fill to ≈4.21:1.
void main() {
  Widget host(Widget child, {required bool dark}) {
    return MaterialApp(
      theme: dark
          ? AppTheme.dark(BrandConfig.orient)
          : AppTheme.light(BrandConfig.orient),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('Light theme enabled states', () {
    testWidgets('danger button label keeps ≥4.5:1 in every enabled state', (
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
      final fill = style.backgroundColor!.resolve({})!;
      expect(fill, AppColors.danger);

      _expectStateContrast(
        style,
        ink: AppColors.textInverse,
        fill: fill,
        reason: 'light danger',
      );
    });

    testWidgets('primary button label keeps ≥4.5:1 in every enabled state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(label: 'Continue', isExpanded: false, onPressed: () {}),
          dark: false,
        ),
      );
      final style = tester
          .widget<ElevatedButton>(find.byType(ElevatedButton))
          .style!;
      _expectStateContrast(
        style,
        ink: AppColors.textInverse,
        fill: style.backgroundColor!.resolve({})!,
        reason: 'light primary',
      );
    });
  });

  group('Dark theme enabled states', () {
    testWidgets('dark primary label keeps ≥4.5:1 in every enabled state', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          PrimaryButton(label: 'Continue', isExpanded: false, onPressed: () {}),
          dark: true,
        ),
      );
      final style = tester
          .widget<ElevatedButton>(find.byType(ElevatedButton))
          .style!;
      expect(style.backgroundColor!.resolve({}), AppDarkColors.primary);
      _expectStateContrast(
        style,
        ink: AppDarkColors.onPrimary,
        fill: AppDarkColors.primary,
        reason: 'dark primary',
      );
    });

    testWidgets('dark danger label keeps ≥4.5:1 in every enabled state', (
      tester,
    ) async {
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
      _expectStateContrast(
        style,
        ink: AppDarkColors.onError,
        fill: AppDarkColors.danger,
        reason: 'dark danger',
      );
    });
  });

  testWidgets('focused primary button resolves a 2 px focus ring', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        PrimaryButton(label: 'Continue', isExpanded: false, onPressed: () {}),
        dark: false,
      ),
    );
    final style = tester
        .widget<ElevatedButton>(find.byType(ElevatedButton))
        .style!;
    final side = style.side!.resolve({WidgetState.focused});
    expect(side, isNotNull);
    expect(side!.width, AppInteractionStates.focusRingWidth);
    expect(
      side.color,
      AppColors.primary,
      reason: 'focus ring uses the frozen focus token (spec §8.4)',
    );
  });

  test('contrast overlay tone inverts with the ink lightness', () {
    expect(
      AppInteractionStates.contrastOverlayTone(AppColors.textInverse),
      Colors.black,
    );
    expect(
      AppInteractionStates.contrastOverlayTone(AppDarkColors.onPrimary),
      Colors.white,
    );
  });
}

void _expectStateContrast(
  ButtonStyle style, {
  required Color ink,
  required Color fill,
  required String reason,
}) {
  for (final entry in {
    'hovered': WidgetState.hovered,
    'pressed': WidgetState.pressed,
    'focused': WidgetState.focused,
  }.entries) {
    final overlay = style.overlayColor?.resolve({entry.value});
    expect(overlay, isNotNull, reason: '$reason ${entry.key} overlay missing');
    final composited = Color.alphaBlend(overlay!, fill);
    final ratio = _contrastRatio(ink, composited);
    expect(
      ratio,
      greaterThanOrEqualTo(4.5),
      reason:
          '$reason ${entry.key} contrast ${ratio.toStringAsFixed(2)}:1 < 4.5:1',
    );
  }
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
