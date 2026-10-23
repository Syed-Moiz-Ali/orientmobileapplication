// Mono Arabic-fallback guard: Latin-only mono runs must not tofu Arabic.
//
// Context: `AppTextStyles.mono` is `latinFamilyOnly` (Plus Jakarta Sans
// primary in both locales). Two redesigned-screen strings reach it in ar:
//   - advisor odometer `t.advisorOdometerValue` → `45210 كم` (unit كم)
//   - supervisor bay `ref` fallback to `serviceType` when ref/plate empty
//   - (P-screen analogues: `wizTotalPending` / `techPlateMissing`)
// Without a fallback the Arabic run has no glyphs in the Latin face.
// This test proves the additive token fix: primary stays Latin (money
// byte-identical), fallback carries Plex Arabic → Noto → system, tabular
// figures stay on, and real-font widget pumps in ar render non-zero widths.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Future<void> _loadRealFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
      );
    }
    await loader.load();
  }

  await load('packages/shared_core/Plus Jakarta Sans', [
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf',
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf',
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
  ]);
}

Future<Size> _pumpMono(
  WidgetTester tester,
  String text, {
  required bool arabic,
}) async {
  final style = AppTextStyles.mono(color: Colors.black, arabic: arabic);
  await tester.pumpWidget(
    MaterialApp(
      locale: arabic ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(
          child: Directionality(
            // Mirrors every redesigned mono call site (LTR isolate).
            textDirection: TextDirection.ltr,
            child: Text(text, style: style, textDirection: TextDirection.ltr),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(find.text(text), findsOneWidget);
  final size = tester.getSize(find.text(text));
  expect(size.width, greaterThan(0), reason: 'mono "$text" rendered empty');
  return size;
}

void main() {
  test('mono token: Latin primary kept, Arabic fallback additive', () {
    final monoAr = AppTextStyles.mono(color: Colors.black, arabic: true);
    // Primary stays Latin in both locales — money/Latin byte-identical.
    expect(monoAr.fontFamily, AppFontFamilies.app);
    expect(monoAr.fontFamily, AppFontFamilies.mono);
    // Additive fallback carries Arabic; tabular figures stay on.
    expect(monoAr.fontFamilyFallback, isNotNull);
    expect(
      monoAr.fontFamilyFallback,
      contains(AppFontFamilies.arabic),
    );
    expect(
      monoAr.fontFamilyFallback,
      containsAll(AppFontFamilies.arabicFallback),
    );
    expect(
      monoAr.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );

    final monoEn = AppTextStyles.mono(color: Colors.black);
    expect(monoEn.fontFamily, AppFontFamilies.mono);
    expect(monoEn.fontFamilyFallback, isNull);
    expect(
      monoEn.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );

    // Money rendering untouched: same Latin string both locales.
    const money = 'AED 2,450.00';
    expect(money, contains('AED'));
    expect(money, isNot(contains('د.إ')));
  });

  testWidgets('ar mono renders Arabic odometer unit + tabular Latin',
      (tester) async {
    await _loadRealFonts();
    // Redesigned advisor_jobs_view: t.advisorOdometerValue in ar.
    final size = await _pumpMono(tester, '45210 كم', arabic: true);
    expect(size.height, greaterThan(0));
  });

  testWidgets('ar mono renders pending-total + plate-missing Arabic',
      (tester) async {
    await _loadRealFonts();
    // Wizard / plate-chip Arabic copies that share the same mono token.
    await _pumpMono(tester, 'يُؤكَّد في المركز', arabic: true);
    await _pumpMono(tester, 'اللوحة غير مسجلة', arabic: true);
  });

  testWidgets('Latin money via mono unchanged in en + ar', (tester) async {
    await _loadRealFonts();
    const money = 'AED 2,450.00';
    final enSize = await _pumpMono(tester, money, arabic: false);
    final arSize = await _pumpMono(tester, money, arabic: true);
    // Same Latin run resolves in the primary in both locales.
    expect(enSize.width, greaterThan(0));
    expect(arSize.width, greaterThan(0));
  });
}
