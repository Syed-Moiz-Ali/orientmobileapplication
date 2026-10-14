import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase03_gallery.dart';

/// Concept A V2 — Phase 03 rendered data-component catalog goldens.
///
/// Renders the production Phase 03 data instruments (telemetry pods, sparkline,
/// service ribbon, damage HUD, redesigned table) at compact / tablet / desktop
/// widths in EN-LTR and AR-RTL, light and dark, with the real Plus Jakarta Sans
/// and IBM Plex Sans Arabic fonts loaded.
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

  testWidgets('phase 03 data components mobile (EN light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 2200),
      locale: const Locale('en'),
      fileName: 'goldens/phase03_data_components_mobile_en.png',
    );
  });

  testWidgets('phase 03 data components tablet (EN light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(834, 2100),
      locale: const Locale('en'),
      fileName: 'goldens/phase03_data_components_tablet_en.png',
    );
  });

  testWidgets('phase 03 data components desktop (EN light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(1400, 1900),
      locale: const Locale('en'),
      fileName: 'goldens/phase03_data_components_desktop_en.png',
    );
  });

  testWidgets('phase 03 data components mobile (AR RTL light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 2200),
      locale: const Locale('ar'),
      fileName: 'goldens/phase03_data_components_mobile_ar.png',
    );
  });

  testWidgets('phase 03 data components mobile (EN dark)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 2200),
      locale: const Locale('en'),
      dark: true,
      fileName: 'goldens/phase03_data_components_mobile_dark.png',
    );
  });

  testWidgets('phase 03 data components mobile (AR RTL dark)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 2200),
      locale: const Locale('ar'),
      dark: true,
      fileName: 'goldens/phase03_data_components_mobile_dark_ar.png',
    );
  });
}

Future<void> _expectGallery(
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
        body: const SingleChildScrollView(child: Phase03Gallery()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}
