import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 02 evidence capture harness (shared chrome, EN + AR).
/// Copy into `packages/shared_core/test/`, run
/// `flutter test --update-goldens test/phase02_capture_test.dart`, then delete.
void main() {
  setUpAll(_loadFonts);

  const delegates = [
    SharedCoreLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  Widget host({
    required Widget child,
    required String language,
    double scale = 1.0,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(language),
      supportedLocales: AppLocales.supported,
      localizationsDelegates: delegates,
      theme: AppTheme.light(BrandConfig.orient, locale: Locale(language)),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: c!,
      ),
      home: Scaffold(body: child),
    );
  }

  Widget chrome(String language) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppTopBar(title: ''),
          const SizedBox(height: AppDimensions.s16),
          EmptyState.error(message: '', onRetry: () {}),
          const SizedBox(height: AppDimensions.s16),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: ErrorView(
              message: language == 'ar'
                  ? 'تعذّر تحميل بيانات الورشة. تحقق من الاتصال وأعد المحاولة.'
                  : 'The workshop data could not be loaded. Check the connection and retry.',
              onRetry: () {},
            ),
          ),
        ],
      ),
    );
  }

  testWidgets('capture shared_chrome_390_en', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(child: chrome('en'), language: 'en'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../phases/reports/PHASE_02/screens/shared_chrome_390_en.png'),
    );
  });

  testWidgets('capture shared_chrome_390_ar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(child: chrome('ar'), language: 'ar'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../phases/reports/PHASE_02/screens/shared_chrome_390_ar.png'),
    );
  });

  testWidgets('capture shared_chrome_320_ar_scale13', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(child: chrome('ar'), language: 'ar', scale: 1.3));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../phases/reports/PHASE_02/screens/shared_chrome_320_ar_scale13.png'),
    );
  });

  testWidgets('capture shared_dialog_390_ar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        language: 'ar',
        child: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showLogoutDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../phases/reports/PHASE_02/screens/shared_dialog_390_ar.png'),
    );
  });

  testWidgets('capture shared_language_sheet_390_ar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: host(
          language: 'ar',
          child: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showLanguagePickerSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../../phases/reports/PHASE_02/screens/shared_language_sheet_390_ar.png'),
    );
  });
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    await (FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(bytes))))
        .load();
  }

  final sep = Platform.pathSeparator;
  await load(
    AppFontFamilies.app,
    'assets${sep}fonts${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final w in const [
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
  ]) {
    await load(
      AppFontFamilies.arabic,
      'assets${sep}fonts${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$w.ttf',
    );
  }

  final flutterBin =
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(iconBytes))))
      .load();
}
