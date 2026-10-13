// PHASE 03A — component-catalog render capture harness (NOT part of the normal
// test suite).
//
// Regenerates the J2 evidence pack under
// `phases/reports/PHASE_03A/screens/`.
//
// To use:
//   1. Copy this file into `packages/shared_core/test/`.
//   2. From `packages/shared_core`, run:
//        flutter test test/primitives_capture_test.dart --update-goldens
//   3. Copy the produced files (paths below are relative to the test dir, which
//      resolves to phases/reports/PHASE_03A/screens/) — or simply run the
//      in-suite `shared_components_visual_test.dart` and copy its goldens.
//
// The dashboard-gallery widget itself lives in `test/support/phase03a_gallery.dart`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase03a_gallery.dart';

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

  const out = '../../../phases/reports/PHASE_03A/screens';

  for (final (label, size, locale, dark) in <(String, Size, Locale, bool)>[
    ('primitives_390_en_light', Size(390, 3000), Locale('en'), false),
    ('primitives_390_ar_light', Size(390, 3000), Locale('ar'), false),
    ('primitives_834_en_light', Size(834, 3000), Locale('en'), false),
    ('primitives_834_ar_light', Size(834, 3000), Locale('ar'), false),
    ('primitives_1400_en_light', Size(1400, 2400), Locale('en'), false),
    ('primitives_1400_ar_light', Size(1400, 2400), Locale('ar'), false),
    ('primitives_390_en_dark', Size(390, 3000), Locale('en'), true),
    ('primitives_390_ar_dark', Size(390, 3000), Locale('ar'), true),
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
            body: const SingleChildScrollView(child: Phase03aGallery()),
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
