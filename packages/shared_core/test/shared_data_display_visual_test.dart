import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase03b_gallery.dart';

/// Phase 03B rendered-review goldens: skeleton variants, the list-surface
/// recipe (all four states), the desktop data table (with compact fallback) and
/// the chart language, at compact/expanded widths in EN-LTR and AR-RTL plus a
/// dark render. Component-owned baselines for the data-display catalog.
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

  testWidgets('data display compact (English)', (tester) async {
    await _capture(
      tester,
      size: const Size(390, 3600),
      locale: const Locale('en'),
      fileName: 'goldens/data_display_compact_en.png',
    );
  });

  testWidgets('data display compact (Arabic)', (tester) async {
    await _capture(
      tester,
      size: const Size(390, 3600),
      locale: const Locale('ar'),
      fileName: 'goldens/data_display_compact_ar.png',
    );
  });

  testWidgets('data display expanded (English)', (tester) async {
    await _capture(
      tester,
      size: const Size(1280, 3000),
      locale: const Locale('en'),
      fileName: 'goldens/data_display_expanded_en.png',
    );
  });

  testWidgets('data display expanded (Arabic)', (tester) async {
    await _capture(
      tester,
      size: const Size(1280, 3000),
      locale: const Locale('ar'),
      fileName: 'goldens/data_display_expanded_ar.png',
    );
  });

  testWidgets('data display compact dark (English)', (tester) async {
    await _capture(
      tester,
      size: const Size(390, 3600),
      locale: const Locale('en'),
      dark: true,
      fileName: 'goldens/data_display_compact_en_dark.png',
    );
  });

  testWidgets('data display compact dark (Arabic)', (tester) async {
    await _capture(
      tester,
      size: const Size(390, 3600),
      locale: const Locale('ar'),
      dark: true,
      fileName: 'goldens/data_display_compact_ar_dark.png',
    );
  });
}

Future<void> _capture(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
  required String fileName,
  bool dark = false,
}) async {
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

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}
