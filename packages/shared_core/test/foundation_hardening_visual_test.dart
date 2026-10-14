import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase01_2_gallery.dart';

/// Phase 01.2 rendered-review goldens: the seven new foundation primitives,
/// density modes and the focus/disabled grammar, at 320 / 768 / 1280 widths
/// in EN-LTR and AR-RTL plus dark renders — all with real fonts.
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

  for (final width in [320.0, 768.0, 1280.0]) {
    final tag = width.toInt();
    testWidgets('foundation 01.2 ${tag}px (English)', (tester) async {
      await _capture(
        tester,
        size: Size(width, 3600),
        locale: const Locale('en'),
        fileName: 'goldens/foundation_01_2_${tag}_en.png',
      );
    });

    testWidgets('foundation 01.2 ${tag}px (Arabic)', (tester) async {
      await _capture(
        tester,
        size: Size(width, 3600),
        locale: const Locale('ar'),
        fileName: 'goldens/foundation_01_2_${tag}_ar.png',
      );
    });
  }

  testWidgets('foundation 01.2 768px dark (English)', (tester) async {
    await _capture(
      tester,
      size: const Size(768, 3600),
      locale: const Locale('en'),
      dark: true,
      fileName: 'goldens/foundation_01_2_768_en_dark.png',
    );
  });

  testWidgets('foundation 01.2 768px dark (Arabic)', (tester) async {
    await _capture(
      tester,
      size: const Size(768, 3600),
      locale: const Locale('ar'),
      dark: true,
      fileName: 'goldens/foundation_01_2_768_ar_dark.png',
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
        body: const SingleChildScrollView(child: Phase012Gallery()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}
