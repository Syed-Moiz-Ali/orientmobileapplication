import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 — light/dark theme parity and contrast verification.
///
/// `AppTheme.light` and `AppTheme.dark` must cover the same component theme
/// surface so no widget silently reverts to a Flutter default when the
/// brightness flips. Contrast is sampled on the pairs users actually read
/// (body/ink on canvas, ink on surface, supporting ink on navy, control label
/// on primary) in both brightnesses.
void main() {
  const brand = BrandConfig.orient;
  final light = AppTheme.light(brand);
  final dark = AppTheme.dark(brand);

  final componentThemes = <String, Object? Function(ThemeData)>{
    'appBarTheme.background': (t) => t.appBarTheme.backgroundColor,
    'appBarTheme.title': (t) => t.appBarTheme.titleTextStyle,
    'elevatedButtonTheme': (t) => t.elevatedButtonTheme.style,
    'filledButtonTheme': (t) => t.filledButtonTheme.style,
    'outlinedButtonTheme': (t) => t.outlinedButtonTheme.style,
    'textButtonTheme': (t) => t.textButtonTheme.style,
    'iconButtonTheme': (t) => t.iconButtonTheme.style,
    'inputDecorationTheme': (t) => t.inputDecorationTheme.border,
    'inputDecorationTheme.hint': (t) => t.inputDecorationTheme.hintStyle,
    'dropdownMenuTheme': (t) => t.dropdownMenuTheme.textStyle,
    'popupMenuTheme': (t) => t.popupMenuTheme.textStyle,
    'floatingActionButtonTheme': (t) => t.floatingActionButtonTheme.backgroundColor,
    'cardTheme.shape': (t) => t.cardTheme.shape,
    'dialogTheme.background': (t) => t.dialogTheme.backgroundColor,
    'dialogTheme.title': (t) => t.dialogTheme.titleTextStyle,
    'bottomSheetTheme.background': (t) => t.bottomSheetTheme.backgroundColor,
    'dividerTheme.color': (t) => t.dividerTheme.color,
    'bottomNavigationBarTheme': (t) => t.bottomNavigationBarTheme.backgroundColor,
    'navigationBarTheme': (t) => t.navigationBarTheme.backgroundColor,
    'navigationRailTheme': (t) => t.navigationRailTheme.backgroundColor,
    'tabBarTheme.label': (t) => t.tabBarTheme.labelColor,
    'chipTheme.label': (t) => t.chipTheme.labelStyle,
    'snackBarTheme.background': (t) => t.snackBarTheme.backgroundColor,
    'snackBarTheme.content': (t) => t.snackBarTheme.contentTextStyle,
    'progressIndicatorTheme.color': (t) => t.progressIndicatorTheme.color,
    'checkboxTheme.fill': (t) => t.checkboxTheme.fillColor,
    'switchTheme.track': (t) => t.switchTheme.trackColor,
    'tooltipTheme.text': (t) => t.tooltipTheme.textStyle,
  };

  group('theme parity', () {
    test('every component theme is defined in both brightnesses', () {
      for (final entry in componentThemes.entries) {
        expect(
          entry.value(light),
          isNotNull,
          reason: 'light ${entry.key} missing',
        );
        expect(
          entry.value(dark),
          isNotNull,
          reason: 'dark ${entry.key} missing',
        );
      }
    });

    test('dark theme resolves the approved parity map roles', () {
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, AppDarkColors.primary);
      // Phase 01.1 accessibility amendment: the dark primary ink is a dark
      // color (WCAG AA), never white.
      expect(dark.colorScheme.onPrimary, AppDarkColors.onPrimary);
      expect(dark.colorScheme.onError, AppDarkColors.onError);
      expect(dark.colorScheme.surface, AppDarkColors.surface);
      expect(dark.colorScheme.onSurface, AppDarkColors.textPrimary);
      expect(dark.colorScheme.onSurfaceVariant, AppDarkColors.textMuted);
      expect(dark.colorScheme.error, AppDarkColors.danger);
      expect(dark.colorScheme.outline, AppDarkColors.borderDefault);
      expect(dark.colorScheme.outlineVariant, AppDarkColors.borderStrong);
      expect(dark.colorScheme.scrim, AppDarkColors.overlayScrim);
      expect(dark.colorScheme.inverseSurface, AppDarkColors.surfaceStrong);
      expect(dark.scaffoldBackgroundColor, AppDarkColors.canvas);
      expect(dark.canvasColor, AppDarkColors.canvas);
    });

    test('light theme keeps the shipped Phase 00 look', () {
      expect(light.colorScheme.brightness, Brightness.light);
      expect(light.colorScheme.primary, AppColors.primary);
      expect(light.colorScheme.surface, AppColors.surface);
      expect(light.scaffoldBackgroundColor, AppColors.canvas);
      expect(light.cardTheme.elevation, 0);
      expect(light.dialogTheme.surfaceTintColor, Colors.transparent);
    });

    test('both themes keep the shared global font family', () {
      expect(light.textTheme.bodyMedium?.fontFamily, AppFontFamilies.app);
      expect(dark.textTheme.bodyMedium?.fontFamily, AppFontFamilies.app);
      expect(light.textTheme.bodyMedium?.height, dark.textTheme.bodyMedium?.height);
    });
  });

  group('contrast verification (WCAG 2.1 ratio)', () {
    test('light body inks meet 4.5:1 on their surfaces', () {
      _expectContrast(
        AppColors.textPrimary,
        AppColors.canvas,
        atLeast: 4.5,
        label: 'light textPrimary on canvas',
      );
      _expectContrast(
        AppColors.textPrimary,
        AppColors.surface,
        atLeast: 4.5,
        label: 'light textPrimary on surface',
      );
      _expectContrast(
        AppColors.textSecondary,
        AppColors.surface,
        atLeast: 4.5,
        label: 'light textSecondary on surface',
      );
      _expectContrast(
        AppColors.textMuted,
        AppColors.canvas,
        atLeast: 4.5,
        label: 'light textMuted on canvas',
      );
      _expectContrast(
        AppColors.textInverse,
        AppColors.primary,
        atLeast: 4.5,
        label: 'light textInverse on primary (button label)',
      );
    });

    test('light supporting ink on navy meets 4.5:1', () {
      _expectContrast(
        AppColors.onNavySecondary,
        AppColors.navy,
        atLeast: 4.5,
        label: 'light onNavySecondary on navy',
      );
      _expectContrast(
        AppColors.textInverse,
        AppColors.navy,
        atLeast: 4.5,
        label: 'light textInverse on navy',
      );
    });

    test('dark primary button labels meet 4.5:1 at rest and under overlays', () {
      // Phase 01.1 accessibility amendment. Material derives interaction
      // overlays from the label ink (hover 8 %, pressed/focus 10 %); the label
      // must stay ≥ 4.5:1 through every enabled state.
      _expectControlStates(
        ink: AppDarkColors.onPrimary,
        fill: AppDarkColors.primary,
        label: 'dark onPrimary on primary',
      );
      _expectControlStates(
        ink: AppDarkColors.onError,
        fill: AppDarkColors.danger,
        label: 'dark onError on danger',
      );
    });

    test('light primary button labels meet 4.5:1 at rest and under overlays', () {
      _expectControlStates(
        ink: AppColors.textInverse,
        fill: AppColors.primary,
        label: 'light textInverse on primary',
      );
    });

    test('dark body inks meet 4.5:1 on their surfaces', () {
      _expectContrast(
        AppDarkColors.textPrimary,
        AppDarkColors.canvas,
        atLeast: 4.5,
        label: 'dark textPrimary on canvas',
      );
      _expectContrast(
        AppDarkColors.textPrimary,
        AppDarkColors.surface,
        atLeast: 4.5,
        label: 'dark textPrimary on surface',
      );
      _expectContrast(
        AppDarkColors.textSecondary,
        AppDarkColors.surface,
        atLeast: 4.5,
        label: 'dark textSecondary on surface',
      );
      _expectContrast(
        AppDarkColors.textMuted,
        AppDarkColors.surface,
        atLeast: 4.5,
        label: 'dark textMuted on surface',
      );
      _expectContrast(
        AppDarkColors.onNavySecondary,
        AppDarkColors.surfaceStrong,
        atLeast: 4.5,
        label: 'dark onNavySecondary on navy',
      );
    });

  });
}

void _expectContrast(
  Color foreground,
  Color background, {
  required double atLeast,
  required String label,
}) {
  final ratio = _contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(atLeast),
    reason:
        '$label contrast ${ratio.toStringAsFixed(2)}:1 is below '
        '${atLeast.toStringAsFixed(1)}:1',
  );
}

/// Verifies a filled-control ink/fill pair at rest and under the Material
/// interaction overlays that derive from the ink (hover 8 %, pressed/focus
/// 10 %), as Flutter composites them over the fill.
void _expectControlStates({
  required Color ink,
  required Color fill,
  required String label,
}) {
  _expectContrast(ink, fill, atLeast: 4.5, label: '$label (rest)');
  _expectContrast(
    ink,
    Color.alphaBlend(ink.withValues(alpha: 0.08), fill),
    atLeast: 4.5,
    label: '$label (hover 8%)',
  );
  _expectContrast(
    ink,
    Color.alphaBlend(ink.withValues(alpha: 0.10), fill),
    atLeast: 4.5,
    label: '$label (pressed/focus 10%)',
  );
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}
