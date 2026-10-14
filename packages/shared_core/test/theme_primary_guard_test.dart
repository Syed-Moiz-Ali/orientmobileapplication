import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01.2 — primary lock guard.
///
/// The authorized primary is `#215FE6` (Concept A §1.1, WCAG AA amendment
/// over the `#2563EB` prototype baseline). [BrandConfig] is logo-only: even
/// a brand carrying a custom legacy color must still build a cobalt theme.
/// This test fails the build on any custom-primary regression.
void main() {
  group('Primary single authority (#215FE6)', () {
    test('authorized light primary is exactly #215FE6', () {
      expect(AppTheme.authorizedPrimaryLight, const Color(0xFF215FE6));
      expect(AppColors.primary, const Color(0xFF215FE6));
    });

    test('light theme primary ignores the legacy brand color', () {
      // A white-label brand attempting a custom primary must not escape.
      const rogue = BrandConfig(
        appName: 'Rogue',
        icon: Icons.build_rounded,
        // ignore: deprecated_member_use_from_same_package
        buttonColor: Color(0xFFE11D48),
        // ignore: deprecated_member_use_from_same_package
        accentColor: Color(0xFFE11D48),
        // ignore: deprecated_member_use_from_same_package
        iconColor: Color(0xFFE11D48),
      );
      final theme = AppTheme.light(rogue);
      expect(theme.colorScheme.primary, const Color(0xFF215FE6));
      expect(theme.extension<AppSemanticColors>()!.primary, AppColors.primary);
    });

    test('dark theme primary stays on the frozen dark parity token', () {
      const rogue = BrandConfig(
        appName: 'Rogue',
        icon: Icons.build_rounded,
        // ignore: deprecated_member_use_from_same_package
        buttonColor: Color(0xFFE11D48),
      );
      final theme = AppTheme.dark(rogue);
      expect(theme.colorScheme.primary, AppDarkColors.primary);
      expect(
        theme.extension<AppSemanticColors>()!.primary,
        AppDarkColors.primary,
      );
    });

    test('semantic primary agrees with the scheme in both brightnesses', () {
      for (final theme in [
        AppTheme.light(BrandConfig.orient),
        AppTheme.dark(BrandConfig.orient),
      ]) {
        final semantic = theme.extension<AppSemanticColors>()!;
        expect(semantic.primary, theme.colorScheme.primary);
      }
    });

    test('BrandConfig is logo-only (identity fields only)', () {
      const brand = BrandConfig.orient;
      expect(brand.appName, 'ORIENT');
      expect(brand.logoOnly.appName, brand.appName);
      expect(brand.logoOnly.tagline, brand.tagline);
      // The orient brand itself carries no custom primary.
      expect(AppTheme.light(brand).colorScheme.primary, AppColors.primary);
    });

    test('raw prototype cobalt never appears in the built themes', () {
      const rawPrototype = Color(0xFF2563EB);
      for (final theme in [
        AppTheme.light(BrandConfig.orient),
        AppTheme.dark(BrandConfig.orient),
      ]) {
        expect(theme.colorScheme.primary, isNot(rawPrototype));
        expect(
          theme.extension<AppSemanticColors>()!.primary,
          isNot(rawPrototype),
        );
      }
    });
  });
}
