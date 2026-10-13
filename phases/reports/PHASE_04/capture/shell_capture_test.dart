// PHASE 04 — shell/navigation render capture harness (NOT part of the normal
// test suite).
//
// Regenerates the J2 evidence pack under `phases/reports/PHASE_04/screens/`.
//
// To use:
//   1. Copy this file into `packages/shared_core/test/`.
//   2. From `packages/shared_core`, run:
//        flutter test test/shell_capture_test.dart --update-goldens
//   (paths below are relative to the test dir and resolve into
//    phases/reports/PHASE_04/screens/).
//
// The gallery widget lives in `test/support/phase04_shell_gallery.dart`.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase04_shell_gallery.dart';

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

  const out = '../../../phases/reports/PHASE_04/screens';

  Widget app(Locale locale, Widget home) => MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          SharedCoreLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: home,
      );

  for (final (label, size, locale, nav, title) in <
      (String, Size, Locale, List<AppNavItem>, String)>[
    ('shell_mobile_en_light', Size(390, 844), Locale('en'), kStaffNav, 'Today'),
    ('shell_mobile_ar_light', Size(390, 844), Locale('ar'), kStaffNav, 'Today'),
    ('shell_tablet_en_light', Size(834, 900), Locale('en'), kStaffNav, 'Today'),
    ('shell_tablet_ar_light', Size(834, 900), Locale('ar'), kStaffNav, 'Today'),
    ('shell_desktop_en_light', Size(1440, 900), Locale('en'), kStaffNav, 'Today'),
    ('shell_desktop_ar_light', Size(1440, 900), Locale('ar'), kStaffNav, 'Today'),
  ]) {
    testWidgets('capture $label', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(
          locale,
          Phase04Shell(
            workspace: 'Staff',
            title: title,
            subtitle: 'Workshop Advisor',
            items: nav,
            brandInitial: 'S',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('$out/$label.png'),
      );
    });
  }

  testWidgets('capture shell_master_detail_tablet_en_light', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      app(const Locale('en'), const Phase04MasterDetail()),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('$out/shell_master_detail_tablet_en_light.png'),
    );
  });
}
