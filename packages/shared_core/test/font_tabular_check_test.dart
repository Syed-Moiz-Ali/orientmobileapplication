// Verifies tabular-figure support in the bundled fonts (phase-0 font check).
//
// Part (a) of the check is static: `tnum` is present in the GSUB table of
// PlusJakartaSans-Variable.ttf (see phase-0 report). This test is part (b):
// it loads the REAL bundled fonts via FontLoader and proves at runtime that
// digits render at equal widths with tabular figures on, and that the Arabic
// fallback chain resolves without errors.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Future<double> _digitWidth(
  WidgetTester tester,
  String digit,
  TextStyle style,
) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: Text(digit, style: style)))),
  );
  await tester.pump();
  final size = tester.getSize(find.text(digit));
  expect(size.width, greaterThan(0), reason: 'digit "$digit" rendered empty');
  return size.width;
}

void main() {
  testWidgets('tabular figures give equal digit widths (Jakarta Sans)',
      (tester) async {
    await _loadRealFonts();

    final tabular = AppTextStyles.metric(color: Colors.black);
    expect(tabular.fontFeatures, contains(const FontFeature.tabularFigures()));

    final widths = <String, double>{};
    for (var i = 0; i <= 9; i++) {
      widths['$i'] = await _digitWidth(tester, '$i', tabular);
    }
    // ignore: avoid_print — diagnostic output for the phase-0 font report.
    print('tabular digit widths: $widths');

    final reference = widths['0']!;
    for (final entry in widths.entries) {
      expect(
        entry.value,
        moreOrLessEquals(reference, epsilon: 0.5),
        reason: 'digit "${entry.key}" width differs under tabular figures',
      );
    }
  });

  testWidgets('arabic fallback chain resolves (Plex Arabic + numerals)',
      (tester) async {
    await _loadRealFonts();

    // Mono roles stay Latin in both locales (VIN/plate/money/codes).
    final mono = AppTextStyles.mono(color: Colors.black, arabic: true);
    expect(mono.fontFamily, AppFontFamilies.app);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'مرحبا 0123456789',
              style: AppTextStyles.body(color: Colors.black, arabic: true),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('مرحبا 0123456789'), findsOneWidget);
    expect(
      tester.getSize(find.text('مرحبا 0123456789')).width,
      greaterThan(0),
    );
  });
}
