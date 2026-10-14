import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase02_component_gallery.dart';

/// Concept A V2 — Phase 02 rendered component catalog goldens.
///
/// Renders the production shared primitives at compact / tablet / desktop
/// widths in EN-LTR and AR-RTL, light and dark, with the real Plus Jakarta Sans
/// and IBM Plex Sans Arabic fonts loaded. Also captures the modal surfaces
/// (confirmation dialog + searchable selection sheet).
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

  testWidgets('phase 02 primitives mobile (EN light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 5400),
      locale: const Locale('en'),
      fileName: 'goldens/phase02_primitives_mobile_en.png',
    );
  });

  testWidgets('phase 02 primitives tablet (EN light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(834, 4600),
      locale: const Locale('en'),
      fileName: 'goldens/phase02_primitives_tablet_en.png',
    );
  });

  testWidgets('phase 02 primitives desktop (EN light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(1400, 4800),
      locale: const Locale('en'),
      fileName: 'goldens/phase02_primitives_desktop_en.png',
    );
  });

  testWidgets('phase 02 primitives mobile (AR RTL light)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 5400),
      locale: const Locale('ar'),
      fileName: 'goldens/phase02_primitives_mobile_ar.png',
    );
  });

  testWidgets('phase 02 primitives mobile (EN dark)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 5400),
      locale: const Locale('en'),
      dark: true,
      fileName: 'goldens/phase02_primitives_mobile_dark.png',
    );
  });

  testWidgets('phase 02 primitives mobile (AR RTL dark)', (tester) async {
    await _expectGallery(
      tester,
      size: const Size(390, 5400),
      locale: const Locale('ar'),
      dark: true,
      fileName: 'goldens/phase02_primitives_mobile_dark_ar.png',
    );
  });

  testWidgets('phase 02 confirmation dialog (EN light)', (tester) async {
    await _expectDialog(
      tester,
      locale: const Locale('en'),
      fileName: 'goldens/phase02_dialog_mobile_en.png',
    );
  });

  testWidgets('phase 02 selection sheet (EN light)', (tester) async {
    await _expectSelectionSheet(
      tester,
      locale: const Locale('en'),
      fileName: 'goldens/phase02_selection_sheet_mobile_en.png',
    );
  });

  testWidgets('phase 02 selection sheet (AR RTL light)', (tester) async {
    await _expectSelectionSheet(
      tester,
      locale: const Locale('ar'),
      fileName: 'goldens/phase02_selection_sheet_mobile_ar.png',
    );
  });
}

Widget _app({required Locale locale, required Widget home, bool dark = false}) {
  return MaterialApp(
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
    home: home,
  );
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
    _app(
      locale: locale,
      dark: dark,
      home: Scaffold(
        backgroundColor: dark ? AppDarkColors.canvas : AppColors.canvas,
        body: const Phase02ComponentGallery(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(tester.takeException(), isNull);
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}

Future<void> _expectDialog(
  WidgetTester tester, {
  required Locale locale,
  required String fileName,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _app(
      locale: locale,
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.canvas,
          body: Center(
            child: AppButton.primary(
              label: 'Cancel booking',
              isExpanded: false,
              onPressed: () => showAppConfirmationDialog(
                context,
                title: 'Cancel this booking?',
                message:
                    'The reservation and its inspection slot will be released.',
                confirmLabel: 'Cancel booking',
                destructive: true,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Cancel booking'));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsOneWidget);
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(fileName));
}

Future<void> _expectSelectionSheet(
  WidgetTester tester, {
  required Locale locale,
  required String fileName,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _app(
      locale: locale,
      home: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.canvas,
          body: Center(
            child: AppButton.secondary(
              label: 'Select technician',
              isExpanded: false,
              onPressed: () => showAppSelectionSheet<int>(
                context: context,
                title: 'Select technician',
                selected: 2,
                options: [
                  for (var i = 1; i <= 10; i++)
                    AppSelectionOption<int>(
                      value: i,
                      label: 'Technician $i',
                      subtitle: 'Bay ${i.toString().padLeft(2, '0')}',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Select technician'));
  await tester.pumpAndSettle();
  expect(find.byType(BottomSheet), findsOneWidget);
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(fileName));
}
