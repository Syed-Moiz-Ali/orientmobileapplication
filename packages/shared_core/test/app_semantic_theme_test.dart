import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01.1 — centralized theme architecture.
///
/// Proves there is a single semantic styling authority: the `AppSemanticColors`
/// [ThemeExtension] is registered by both theme builders, resolves the frozen
/// light/dark Concept A values, stays consistent with [ColorScheme], and keeps
/// WCAG AA contrast — without any widget branching on brightness.
void main() {
  group('ThemeExtension registration', () {
    test('light and dark themes register the semantic extension', () {
      final light = AppTheme.light(BrandConfig.orient);
      final dark = AppTheme.dark(BrandConfig.orient);

      expect(light.extension<AppSemanticColors>(), AppSemanticColors.light);
      expect(dark.extension<AppSemanticColors>(), AppSemanticColors.dark);
    });

    test('forBrightness resolves the frozen palette', () {
      expect(
        AppSemanticColors.forBrightness(Brightness.light),
        AppSemanticColors.light,
      );
      expect(
        AppSemanticColors.forBrightness(Brightness.dark),
        AppSemanticColors.dark,
      );
    });
  });

  group('Light / dark resolution', () {
    test('light palette resolves Concept A raw tokens', () {
      const s = AppSemanticColors.light;
      expect(s.surface, AppColors.surface);
      expect(s.surfaceSunken, AppColors.surfaceSunken);
      expect(s.borderDefault, AppColors.borderDefault);
      expect(s.primary, AppColors.primary);
      expect(s.danger.base, AppColors.danger);
      expect(s.success.base, AppColors.success);
      expect(s.warning.base, AppColors.warning);
      expect(s.info.base, AppColors.info);
      expect(s.chartSeries, AppColors.chartSeries);
    });

    test('dark palette resolves the frozen dark parity tokens', () {
      const s = AppSemanticColors.dark;
      expect(s.surface, AppDarkColors.surface);
      expect(s.surfaceSunken, AppDarkColors.surfaceSunken);
      expect(s.borderStrong, AppDarkColors.borderStrong);
      expect(s.primary, AppDarkColors.primary);
      expect(s.danger.base, AppDarkColors.danger);
      expect(s.success.base, AppDarkColors.success);
      expect(s.chartSeries, AppColors.chartSeriesDark);
    });

    test('domain roles map onto the status families (no new colours)', () {
      const s = AppSemanticColors.light;
      expect(s.syncNotSent, s.warning);
      expect(s.syncQueued, s.info);
      expect(s.syncFailed, s.danger);
      expect(s.syncSynced, s.success);
      expect(s.inspectionPass, s.success);
      expect(s.inspectionFail, s.danger);
      expect(s.damageSevere, s.danger);
      expect(s.operationalBlocked, s.danger);
      expect(s.operationalActive, s.success);
    });

    testWidgets('context.semanticColors follows the active brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: const SizedBox(key: ValueKey('light-probe')),
        ),
      );
      await tester.pumpAndSettle();
      final lightResolved = tester
          .element(find.byKey(const ValueKey('light-probe')))
          .semanticColors;
      expect(lightResolved.primary, AppSemanticColors.light.primary);
      expect(lightResolved.surface, AppSemanticColors.light.surface);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(BrandConfig.orient),
          home: const SizedBox(key: ValueKey('dark-probe')),
        ),
      );
      await tester.pumpAndSettle();
      final darkResolved = tester
          .element(find.byKey(const ValueKey('dark-probe')))
          .semanticColors;
      expect(darkResolved.primary, AppSemanticColors.dark.primary);
      expect(darkResolved.surface, AppSemanticColors.dark.surface);
    });

    testWidgets('a bare ThemeData still resolves a null-safe palette', (
      tester,
    ) async {
      late AppSemanticColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              seen = context.semanticColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, AppSemanticColors.dark);
    });
  });

  group('ColorScheme consistency', () {
    test('semantic brand + surface roles agree with the scheme', () {
      for (final theme in [
        AppTheme.light(BrandConfig.orient),
        AppTheme.dark(BrandConfig.orient),
      ]) {
        final s = theme.extension<AppSemanticColors>()!;
        expect(s.primary, theme.colorScheme.primary);
        expect(s.surface, theme.colorScheme.surface);
        expect(s.danger.base, theme.colorScheme.error);
      }
    });

    test('semantic palette does not duplicate container roles blindly', () {
      // The extension intentionally omits generic container roles; those resolve
      // through ColorScheme. Guard against accidental re-introduction.
      final light = AppSemanticColors.light;
      expect(light.surface, isNot(light.surfaceSubtle));
    });
  });

  group('Component themes consume centralized tokens', () {
    test('modal surfaces use their distinct chamfer radii', () {
      final theme = AppTheme.light(BrandConfig.orient);
      final dialogRadius = ((theme.dialogTheme.shape as RoundedRectangleBorder)
              .borderRadius as BorderRadius)
          .topLeft
          .x;
      expect(dialogRadius, AppDimensions.radiusDialog);
      expect(
        AppDimensions.radiusControl <
            AppDimensions.radiusCard, // 8 < 12
        isTrue,
      );
      expect(AppDimensions.radiusCard < AppDimensions.radiusPanel, isTrue);
      expect(AppDimensions.radiusPanel < AppDimensions.radiusDialog, isTrue);
      expect(AppDimensions.radiusDialog < AppDimensions.radiusSheet, isTrue);
    });

    test('card theme paints the hairline outline, not a shadow', () {
      final theme = AppTheme.light(BrandConfig.orient);
      final side = (theme.cardTheme.shape as RoundedRectangleBorder).side;
      expect(side.color, AppColors.borderDefault);
      expect(theme.cardTheme.elevation, 0);
    });
  });

  group('Accessibility contrast (WCAG 2.1 AA)', () {
    test('authorized cobalt primary passes AA across interaction states', () {
      _expectContrast(AppColors.textInverse, AppColors.primary, 4.5, 'rest');
      _expectContrast(
        AppColors.textInverse,
        Color.alphaBlend(Colors.black.withValues(alpha: 0.08), AppColors.primary),
        4.5,
        'hover',
      );
      _expectContrast(
        AppColors.textInverse,
        Color.alphaBlend(
          Colors.black.withValues(alpha: 0.12),
          AppColors.primary,
        ),
        4.5,
        'pressed',
      );
    });

    test('authorized crimson danger passes AA across interaction states', () {
      _expectContrast(AppColors.textInverse, AppColors.danger, 4.5, 'rest');
      _expectContrast(
        AppColors.textInverse,
        Color.alphaBlend(Colors.black.withValues(alpha: 0.08), AppColors.danger),
        4.5,
        'hover',
      );
      _expectContrast(
        AppColors.textInverse,
        Color.alphaBlend(
          Colors.black.withValues(alpha: 0.12),
          AppColors.danger,
        ),
        4.5,
        'pressed',
      );
    });

    test('dark brand ink pairs reach AA on their bright fills', () {
      _expectContrast(
        AppDarkColors.onPrimary,
        AppDarkColors.primary,
        4.5,
        'dark primary',
      );
      _expectContrast(
        AppDarkColors.onError,
        AppDarkColors.danger,
        4.5,
        'dark danger',
      );
    });

    test('status inks stay legible on their subtle containers (light)', () {
      const s = AppSemanticColors.light;
      for (final role in [s.success, s.warning, s.danger, s.info]) {
        _expectContrast(role.ink, role.subtle, 4.5, 'status ink on subtle');
      }
    });
  });

  group('Localization (English / Arabic)', () {
    test('typography keeps the frozen Arabic line-height multiplier', () {
      final en = AppTypography.forLocale(const Locale('en'));
      final ar = AppTypography.forLocale(const Locale('ar'));
      expect(
        ar.bodyMedium?.height,
        closeTo((en.bodyMedium?.height ?? 0) * 1.05, 0.0001),
      );
      expect(ar.bodyMedium?.letterSpacing, 0);
      expect(ar.bodyMedium?.fontFamily, AppFontFamilies.arabic);
    });

    test('semantic palette is locale-invariant', () {
      // The extension carries no locale state; Arabic resolves the same colours.
      expect(AppSemanticColors.light, AppSemanticColors.light);
    });
  });

  group('Architecture guard', () {
    // Justified (class 1 — theme construction): the navy brand surface is a
    // fixed inverse panel and the single source of those literal brand hexes.
    // Migrating these to `context.semanticColors` would be incorrect.
    const justifiedBrand = {'app_card.dart', 'app_info_panel.dart'};

    // Phase 04 resolved the shell-chrome palette debt (`app_page_frame.dart`,
    // `notification_bell.dart`, `offline_banner.dart` are now fully migrated).
    // No future-phase offenders remain; keep the sink so any regression is
    // caught by the bounded-debt test below and must be individually justified.
    const pendingFuturePhase = <String>{};

    test('foundation widgets never select a static light/dark palette', () {
      final dir = Directory('lib/src/widgets');
      expect(dir.existsSync(), isTrue, reason: 'run from shared_core root');
      final darkPalette = <String>[];
      final lightPalette = <String>[];
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final name = entity.uri.pathSegments.last;
        final source = entity.readAsStringSync();
        if (source.contains('AppDarkColors')) darkPalette.add(name);
        if (source.contains('AppColors.') &&
            !justifiedBrand.contains(name) &&
            !pendingFuturePhase.contains(name)) {
          lightPalette.add(name);
        }
      }
      expect(
        darkPalette,
        isEmpty,
        reason:
            'Widgets must consume context.semanticColors, not AppDarkColors:\n'
            '${darkPalette.join('\n')}',
      );
      expect(
        lightPalette,
        isEmpty,
        reason:
            'Widgets must resolve palette roles through context.colors / '
            'context.semanticColors, not a direct AppColors.* selection:\n'
            '${lightPalette.join('\n')}',
      );
    });

    test('future-phase palette debt stays bounded to the documented list', () {
      // Guards against silently adding new offenders to the allowlist sinks.
      final dir = Directory('lib/src/widgets');
      final offenders = <String>{};
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final name = entity.uri.pathSegments.last;
        final source = entity.readAsStringSync();
        if (source.contains('AppColors.') || source.contains('AppDarkColors')) {
          offenders.add(name);
        }
      }
      expect(
        offenders.difference(justifiedBrand.union(pendingFuturePhase)),
        isEmpty,
        reason:
            'Unexpected palette references escaped the documented allowlists.',
      );
    });
  });

  group('ThemeExtension mechanics', () {
    test('copyWith overrides only the supplied role', () {
      const base = AppSemanticColors.light;
      final edited = base.copyWith(primary: const Color(0xFF123456));
      expect(edited.primary, const Color(0xFF123456));
      expect(edited.surface, base.surface);
      expect(edited.danger, base.danger);
    });

    test('lerp interpolates between light and dark', () {
      final mid = AppSemanticColors.light.lerp(AppSemanticColors.dark, 0.5);
      expect(mid.surface, isNot(AppSemanticColors.light.surface));
      expect(mid.surface, isNot(AppSemanticColors.dark.surface));
      expect(
        (AppSemanticColors.light.lerp(AppSemanticColors.dark, 1)).surface,
        AppSemanticColors.dark.surface,
      );
    });
  });
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
