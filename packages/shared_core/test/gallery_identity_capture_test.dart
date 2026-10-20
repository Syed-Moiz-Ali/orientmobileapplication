// Gallery capture for 1c-ii (tagged baseline).
//
// Matrix: light/dark x text scale 1.0/1.3 x LTR/RTL = 8 PNGs into
// docs/ui-redesign/baseline/gallery/. Run with --update-goldens to generate,
// plain run to compare.
//
// Plus 4 tooltip-open PNGs (light/dark x LTR/RTL, scale 1.0): the harness
// taps an AppInfoTooltip open before capture, proving the popover (radius
// 12, shadow e2 light / border dark, max width 280, mirrored placement).
@Tags(['baseline'])
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_core/src/gallery/design_system_gallery_screen.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('packages/shared_core/Plus Jakarta Sans', [
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
  ]);

  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(candidate.readAsBytesSync())));
      await loader.load();
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

Future<void> _capture(
  WidgetTester tester, {
  required bool dark,
  required double scale,
  required bool rtl,
}) async {
  final brand = BrandConfig.orient;
  final name =
      'gallery/1c-ii-identity_${dark ? 'dark' : 'light'}_${scale.toStringAsFixed(1)}_${rtl ? 'rtl' : 'ltr'}.png';
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(1170, 4800); // 390x1600 @3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  // Same RTL harness rule as 1b/1c-i: ar locale + global delegates + themed
  // locale so Arabic glyphs resolve and Material widgets localize.
  final activeLocale = rtl ? const Locale('ar') : null;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: activeLocale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(brand, locale: activeLocale),
      darkTheme: AppTheme.dark(brand, locale: activeLocale),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData.fromView(tester.view).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: IdentityGallerySection(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$name'),
  );
  debugDisableShadows = oldShadows;
}

Future<void> _captureTooltipOpen(
  WidgetTester tester, {
  required bool dark,
  required bool rtl,
}) async {
  final brand = BrandConfig.orient;
  final name =
      'gallery/1c-ii-tooltip_${dark ? 'dark' : 'light'}_${rtl ? 'rtl' : 'ltr'}.png';
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(1170, 2532); // 390x844 @3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final activeLocale = rtl ? const Locale('ar') : null;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: activeLocale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(brand, locale: activeLocale),
      darkTheme: AppTheme.dark(brand, locale: activeLocale),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData.fromView(tester.view).copyWith(
          textScaler: TextScaler.linear(1.0),
        ),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(top: 160, left: 20, right: 20),
              child: Builder(
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Short label on purpose: it keeps the icon near the
                    // screen center so the 280-wide popover below fits
                    // fully on screen in both LTR and RTL.
                    Flexible(
                      child: Text(
                        'Watching',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const AppInfoTooltip(
                      message: 'The bot is waiting for a clear signal before '
                          'acting. Nothing is wrong with your settings.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  // Open the popover, then capture with it visible.
  await tester.tap(find.byType(AppInfoTooltip));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../../docs/ui-redesign/baseline/$name'),
  );
  debugDisableShadows = oldShadows;
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('gallery: fonts ready');
  });

  testWidgets('1c-ii identity light 1.0 ltr', (tester) async {
    await _capture(tester, dark: false, scale: 1.0, rtl: false);
  });
  testWidgets('1c-ii identity light 1.3 ltr', (tester) async {
    await _capture(tester, dark: false, scale: 1.3, rtl: false);
  });
  testWidgets('1c-ii identity light 1.0 rtl', (tester) async {
    await _capture(tester, dark: false, scale: 1.0, rtl: true);
  });
  testWidgets('1c-ii identity light 1.3 rtl', (tester) async {
    await _capture(tester, dark: false, scale: 1.3, rtl: true);
  });
  testWidgets('1c-ii identity dark 1.0 ltr', (tester) async {
    await _capture(tester, dark: true, scale: 1.0, rtl: false);
  });
  testWidgets('1c-ii identity dark 1.3 ltr', (tester) async {
    await _capture(tester, dark: true, scale: 1.3, rtl: false);
  });
  testWidgets('1c-ii identity dark 1.0 rtl', (tester) async {
    await _capture(tester, dark: true, scale: 1.0, rtl: true);
  });
  testWidgets('1c-ii identity dark 1.3 rtl', (tester) async {
    await _capture(tester, dark: true, scale: 1.3, rtl: true);
  });
  testWidgets('1c-ii tooltip open light ltr', (tester) async {
    await _captureTooltipOpen(tester, dark: false, rtl: false);
  });
  testWidgets('1c-ii tooltip open light rtl', (tester) async {
    await _captureTooltipOpen(tester, dark: false, rtl: true);
  });
  testWidgets('1c-ii tooltip open dark ltr', (tester) async {
    await _captureTooltipOpen(tester, dark: true, rtl: false);
  });
  testWidgets('1c-ii tooltip open dark rtl', (tester) async {
    await _captureTooltipOpen(tester, dark: true, rtl: true);
  });
}
