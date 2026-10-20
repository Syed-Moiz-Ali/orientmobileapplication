// Gallery capture for 1b (tagged baseline).
//
// Matrix: light/dark x text scale 1.0/1.3 x LTR/RTL = 8 PNGs into
// docs/ui-redesign/baseline/gallery/. Run with --update-goldens to generate,
// plain run to compare.
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
      'gallery/1b-inputs_${dark ? 'dark' : 'light'}_${scale.toStringAsFixed(1)}_${rtl ? 'rtl' : 'ltr'}.png';
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  tester.view.physicalSize = const Size(1170, 4800); // 390x1600 @3x
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  // RTL captures run under the ar locale (not just mirrored direction) so
  // the Arabic-script demo label resolves the real Plex Arabic family via
  // AppTypography — exactly like production. Latin digits stay Latin (policy).
  // Global delegates are required: the default delegates only cover English
  // (DefaultMaterialLocalizations), which breaks TextField under ar.
  // The theme MUST follow the locale too: AppTypography picks the Plex
  // Arabic family (with x1.05 line height, zero tracking) only when the
  // locale is Arabic. Otherwise the Arabic demo label falls back to tofu.
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
                child: InputsGallerySection(),
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

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('gallery: fonts ready');
  });

  testWidgets('1b inputs light 1.0 ltr', (tester) async {
    await _capture(tester, dark: false, scale: 1.0, rtl: false);
  });
  testWidgets('1b inputs light 1.3 ltr', (tester) async {
    await _capture(tester, dark: false, scale: 1.3, rtl: false);
  });
  testWidgets('1b inputs light 1.0 rtl', (tester) async {
    await _capture(tester, dark: false, scale: 1.0, rtl: true);
  });
  testWidgets('1b inputs light 1.3 rtl', (tester) async {
    await _capture(tester, dark: false, scale: 1.3, rtl: true);
  });
  testWidgets('1b inputs dark 1.0 ltr', (tester) async {
    await _capture(tester, dark: true, scale: 1.0, rtl: false);
  });
  testWidgets('1b inputs dark 1.3 ltr', (tester) async {
    await _capture(tester, dark: true, scale: 1.3, rtl: false);
  });
  testWidgets('1b inputs dark 1.0 rtl', (tester) async {
    await _capture(tester, dark: true, scale: 1.0, rtl: true);
  });
  testWidgets('1b inputs dark 1.3 rtl', (tester) async {
    await _capture(tester, dark: true, scale: 1.3, rtl: true);
  });
}
