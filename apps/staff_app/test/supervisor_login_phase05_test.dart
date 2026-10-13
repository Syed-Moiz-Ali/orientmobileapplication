import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/supervisor_login_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 05 — supervisor sign-in coverage (shared auth components, EN/AR RTL).
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _host({Locale locale = const Locale('en')}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: _delegates,
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      home: const SupervisorLoginView(),
    ),
  );
}

void main() {
  setUpAll(_loadFonts);
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (_) async => null,
        );
  });

  testWidgets('renders localized English supervisor copy', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.text('Supervisor access'), findsOneWidget);
    expect(find.text('Username or email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders localized Arabic supervisor copy in RTL', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(locale: const Locale('ar')));
    await tester.pumpAndSettle();

    expect(find.text('دخول المشرف'), findsOneWidget);
    expect(find.text('اسم المستخدم أو البريد الإلكتروني'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(SupervisorLoginView))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty submit surfaces a live-region validation notice', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter username and password'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
      findsWidgets,
    );
  });

  testWidgets('supervisor login compact visual reference (en)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SupervisorLoginView),
      matchesGoldenFile('goldens/supervisor_login_compact_en.png'),
    );
  });

  testWidgets('supervisor login compact visual reference (ar)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(locale: const Locale('ar')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SupervisorLoginView),
      matchesGoldenFile('goldens/supervisor_login_compact_ar.png'),
    );
  });
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String relative) async {
    final bytes = await File(relative).readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  final sep = Platform.pathSeparator;
  await load(
    AppFontFamilies.app,
    '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
    '${sep}plus_jakarta_sans${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '..$sep..${sep}packages${sep}shared_core${sep}assets${sep}fonts'
      '${sep}ibm_plex_sans_arabic${sep}IBMPlexSansArabic-$weight.ttf',
    );
  }

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${sep}cache${sep}artifacts${sep}material_fonts'
    '${sep}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
