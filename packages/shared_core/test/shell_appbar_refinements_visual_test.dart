import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase04_shell_gallery.dart';

/// Phase 04 closure — rendered evidence for the frosted-glass workspace header
/// with the integrated offline telemetry pill and the ⌘K search trigger, over
/// scrolling content, EN-LTR / AR-RTL and light / dark.
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

    final flutterBin = File(
      Platform.resolvedExecutable,
    ).parent.parent.parent.parent.parent;
    final materialFont = File(
      '${flutterBin.path}${Platform.pathSeparator}cache'
      '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
      '${Platform.pathSeparator}materialicons-regular.otf',
    );
    final iconBytes = await materialFont.readAsBytes();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
  });

  testWidgets('frosted header desktop (EN light)', (tester) async {
    await _capture(
      tester,
      size: const Size(1280, 800),
      locale: const Locale('en'),
      fileName: 'goldens/phase04_appbar_desktop_en.png',
    );
  });

  testWidgets('frosted header mobile (AR RTL light)', (tester) async {
    await _capture(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ar'),
      fileName: 'goldens/phase04_appbar_mobile_ar.png',
    );
  });

  testWidgets('frosted header mobile (EN dark)', (tester) async {
    await _capture(
      tester,
      size: const Size(390, 844),
      locale: const Locale('en'),
      dark: true,
      fileName: 'goldens/phase04_appbar_mobile_dark.png',
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
    ProviderScope(
      overrides: [
        connectivityStatusProvider.overrideWith(
          (ref) => Stream.value(ConnectivityResult.wifi),
        ),
      ],
      child: MaterialApp(
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
        home: const Phase04RefinedShell(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}
