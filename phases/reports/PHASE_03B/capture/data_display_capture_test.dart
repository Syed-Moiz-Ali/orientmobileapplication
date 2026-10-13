// PHASE 03B — data-display render capture harness (NOT part of the normal test
// suite).
//
// Regenerates the J2 evidence pack under
// `phases/reports/PHASE_03B/screens/`.
//
// To use:
//   1. Copy this file into `packages/shared_core/test/`.
//   2. From `packages/shared_core`, run:
//        flutter test test/data_display_capture_test.dart --update-goldens
//   (paths below are relative to the test dir and resolve into
//    phases/reports/PHASE_03B/screens/).
//
// The gallery widget lives in `test/support/phase03b_gallery.dart`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase03b_gallery.dart';

void main() {
  setUpAll(() async {
    final latin = FontLoader(AppFontFamilies.app)
      ..addFont(
        rootBundle.load(
          'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
        ),
      );
    final arabic = FontLoader(AppFontFamilies.arabic)
      ..addFont(
        rootBundle.load(
          'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
        ),
      )
      ..addFont(
        rootBundle.load(
          'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
        ),
      );
    await latin.load();
    await arabic.load();
  });

  const out = '../../../phases/reports/PHASE_03B/screens';

  for (final (label, size, locale, dark) in <(String, Size, Locale, bool)>[
    ('data_display_390_en_light', Size(390, 2600), Locale('en'), false),
    ('data_display_390_ar_light', Size(390, 2600), Locale('ar'), false),
    ('data_display_1280_en_light', Size(1280, 2200), Locale('en'), false),
    ('data_display_1280_ar_light', Size(1280, 2200), Locale('ar'), false),
    ('data_display_390_en_dark', Size(390, 2600), Locale('en'), true),
    ('data_display_390_ar_dark', Size(390, 2600), Locale('ar'), true),
  ]) {
    testWidgets('capture $label', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: dark
              ? AppTheme.dark(BrandConfig.orient, locale: locale)
              : AppTheme.light(BrandConfig.orient, locale: locale),
          home: Scaffold(
            backgroundColor: dark ? AppDarkColors.canvas : AppColors.canvas,
            body: const SingleChildScrollView(child: Phase03bGallery()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('$out/$label.png'),
      );
    });
  }
}
