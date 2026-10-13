import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase03a_gallery.dart';

/// Phase 03A rendered-review goldens: every finalized primitive in its real
/// states, at compact / tablet / expanded widths, in EN-LTR and AR-RTL.
///
/// These are the deterministic component-owned baselines for the catalog. Test
/// names/mobile/tablet/desktop match the pre-existing (previously missing)
/// component references; mobile_ar/tablet_ar/desktop_ar are added in 03A.
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

  testWidgets('shared component mobile visual reference', (tester) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(390, 3000),
      locale: const Locale('en'),
      fileName: 'goldens/shared_components_mobile.png',
    );
  });

  testWidgets('shared component tablet visual reference', (tester) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(834, 3000),
      locale: const Locale('en'),
      fileName: 'goldens/shared_components_tablet.png',
    );
  });

  testWidgets('shared component desktop visual reference', (tester) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(1400, 2400),
      locale: const Locale('en'),
      fileName: 'goldens/shared_components_desktop.png',
    );
  });

  testWidgets('shared component mobile visual reference (Arabic)', (
    tester,
  ) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(390, 3000),
      locale: const Locale('ar'),
      fileName: 'goldens/shared_components_mobile_ar.png',
    );
  });

  testWidgets('shared component tablet visual reference (Arabic)', (
    tester,
  ) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(834, 3000),
      locale: const Locale('ar'),
      fileName: 'goldens/shared_components_tablet_ar.png',
    );
  });

  testWidgets('shared component desktop visual reference (Arabic)', (
    tester,
  ) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(1400, 2400),
      locale: const Locale('ar'),
      fileName: 'goldens/shared_components_desktop_ar.png',
    );
  });

  testWidgets('shared component mobile dark visual reference', (tester) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(390, 3000),
      locale: const Locale('en'),
      dark: true,
      fileName: 'goldens/shared_components_mobile_dark.png',
    );
  });

  testWidgets('shared component mobile dark visual reference (Arabic)', (
    tester,
  ) async {
    await _expectGalleryGolden(
      tester,
      size: const Size(390, 3000),
      locale: const Locale('ar'),
      dark: true,
      fileName: 'goldens/shared_components_mobile_dark_ar.png',
    );
  });
}

Future<void> _expectGalleryGolden(
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
        body: const SingleChildScrollView(child: Phase03aGallery()),
      ),
    ),
  );
  await tester.pump();
  // Fixed-duration pump (instead of pumpAndSettle) so the indeterminate
  // progress indicator renders at a deterministic phase.
  await tester.pump(const Duration(milliseconds: 300));

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}
