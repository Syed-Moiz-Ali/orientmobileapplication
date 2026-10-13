import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 — locale-aware typography foundations.
///
/// `AppTypography.forLocale` must switch the family stack and Arabic metrics
/// (line-height ×1.05, zero letter-spacing) with a stub family now, before
/// Phase 02 bundles the real IBM Plex Sans Arabic assets. Latin output must be
/// byte-identical to the canonical theme so no call site changes later.
void main() {
  group('AppTypography.forLocale', () {
    test('null and English locales keep the canonical Latin stack', () {
      final canonical = AppTypography.textTheme;
      final en = AppTypography.forLocale(const Locale('en'));
      final nullLocale = AppTypography.forLocale(null);

      for (final theme in [canonical, en, nullLocale]) {
        expect(theme.bodyMedium?.fontFamily, AppFontFamilies.app);
        expect(theme.bodyMedium?.fontFamilyFallback, isNull);
        expect(theme.labelMedium?.fontFamily, AppFontFamilies.app);
      }

      // Latin metrics are unchanged (no accidental Arabic multiplier).
      expect(canonical.bodyMedium?.height, 1.45);
      expect(en.bodyMedium?.height, 1.45);
      expect(nullLocale.labelMedium?.letterSpacing, 0.1);
      expect(nullLocale.displayLarge?.letterSpacing, -0.5);
    });

    test('Arabic switches family stack, line-height and tracking', () {
      final ar = AppTypography.forLocale(const Locale('ar'));

      expect(ar.bodyMedium?.fontFamily, AppFontFamilies.arabic);
      expect(
        ar.bodyMedium?.fontFamilyFallback,
        AppFontFamilies.arabicFallback,
      );
      expect(
        ar.bodyMedium?.height,
        closeTo(1.45 * AppTypography.arabicLineHeightScale, 0.0001),
      );

      // Every mapped role carries the Arabic family with zero tracking.
      final roles = <TextStyle?>[
        ar.displayLarge,
        ar.displayMedium,
        ar.displaySmall,
        ar.headlineLarge,
        ar.headlineMedium,
        ar.headlineSmall,
        ar.titleLarge,
        ar.titleMedium,
        ar.titleSmall,
        ar.bodyLarge,
        ar.bodyMedium,
        ar.bodySmall,
        ar.labelLarge,
        ar.labelMedium,
        ar.labelSmall,
      ];
      for (final style in roles) {
        expect(style?.fontFamily, AppFontFamilies.arabic);
        expect(style?.letterSpacing, 0);
      }

      // Arabic line-height is exactly 1.05x the Latin role height.
      final en = AppTypography.forLocale(const Locale('en'));
      expect(
        ar.headlineMedium?.height,
        closeTo((en.headlineMedium?.height ?? 0) * 1.05, 0.0001),
      );
      expect(
        ar.labelMedium?.height,
        closeTo((en.labelMedium?.height ?? 0) * 1.05, 0.0001),
      );
    });

    test('Arabic regional variants resolve to Arabic', () {
      expect(AppTypography.isArabic(const Locale('ar')), isTrue);
      expect(AppTypography.isArabic(const Locale('ar', 'AE')), isTrue);
      expect(AppTypography.isArabic(const Locale('en')), isFalse);
      expect(AppTypography.isArabic(null), isFalse);

      final arAe = AppTypography.forLocale(const Locale('ar', 'AE'));
      expect(arAe.bodyMedium?.fontFamily, AppFontFamilies.arabic);
    });

    test('mono identifiers stay Latin in Arabic (VIN, plate, money)', () {
      final mono = AppTextStyles.mono(arabic: true);
      expect(mono.fontFamily, AppFontFamilies.mono);
      expect(mono.fontFamilyFallback, isNull);
      expect(mono.fontFeatures, isNotEmpty);

      final monoMetric = AppTextStyles.monoMetric(arabic: true);
      expect(monoMetric.fontFamily, AppFontFamilies.mono);
      // Arabic metric value roles still grow their line-height.
      expect(
        monoMetric.height,
        closeTo(1.35 * AppTypography.arabicLineHeightScale, 0.0001),
      );
    });

    test('custom roles expose the Arabic switch without call-site changes', () {
      final latinMetric = AppTextStyles.metric(color: Colors.black);
      final arabicMetric = AppTextStyles.metric(
        color: Colors.black,
        arabic: true,
      );

      expect(arabicMetric.fontFamily, AppFontFamilies.arabic);
      expect(arabicMetric.letterSpacing, 0);
      expect(
        arabicMetric.height,
        closeTo(latinMetric.height! * 1.05, 0.0001),
      );
      expect(arabicMetric.fontFeatures, isNotEmpty);

      // Default (arabic: false) is identical to the pre-Phase 01 output.
      final legacyMetric = AppTextStyles.metric();
      expect(legacyMetric.fontFamily, AppFontFamilies.display);
      expect(legacyMetric.height, 1.15);
      expect(legacyMetric.letterSpacing, -0.3);
      expect(legacyMetric.fontSize, 26);
      expect(legacyMetric.fontWeight, FontWeight.w800);
    });
  });
}
