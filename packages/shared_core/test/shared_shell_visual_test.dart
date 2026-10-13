import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'support/phase04_shell_gallery.dart';

/// Phase 04 rendered-review goldens: the shared shell/navigation at mobile,
/// tablet and desktop widths, EN-LTR and AR-RTL, plus master–detail, the drawer
/// (RTL) and the compact overflow slot. Deterministic baselines for the shell.
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

    // Load the engine Material icon font so nav/action glyphs render crisply.
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

  testWidgets('shell mobile (English)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(390, 844),
      locale: const Locale('en'),
      fileName: 'goldens/shell_nav_mobile_en.png',
    );
  });

  testWidgets('shell mobile (Arabic)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ar'),
      fileName: 'goldens/shell_nav_mobile_ar.png',
    );
  });

  testWidgets('shell tablet rail (English)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(834, 900),
      locale: const Locale('en'),
      fileName: 'goldens/shell_nav_tablet_en.png',
    );
  });

  testWidgets('shell tablet rail (Arabic)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(834, 900),
      locale: const Locale('ar'),
      fileName: 'goldens/shell_nav_tablet_ar.png',
    );
  });

  testWidgets('shell desktop extended rail (English)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(1440, 900),
      locale: const Locale('en'),
      fileName: 'goldens/shell_nav_desktop_en.png',
    );
  });

  testWidgets('shell desktop extended rail (Arabic)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(1440, 900),
      locale: const Locale('ar'),
      fileName: 'goldens/shell_nav_desktop_ar.png',
    );
  });

  testWidgets('compact overflow slot (Arabic)', (tester) async {
    await _shellGolden(
      tester,
      size: const Size(390, 844),
      locale: const Locale('ar'),
      workspace: 'CRM',
      title: 'Leads',
      subtitle: 'Sales workspace',
      nav: kCrmNav,
      brandInitial: 'C',
      fileName: 'goldens/shell_overflow_mobile_ar.png',
    );
  });

  testWidgets('master-detail template (English)', (tester) async {
    await _plainGolden(
      tester,
      size: const Size(1024, 768),
      locale: const Locale('en'),
      child: const Phase04MasterDetail(),
      fileName: 'goldens/shell_master_detail_en.png',
    );
  });

  testWidgets('master-detail template (Arabic)', (tester) async {
    await _plainGolden(
      tester,
      size: const Size(1024, 768),
      locale: const Locale('ar'),
      child: const Phase04MasterDetail(),
      fileName: 'goldens/shell_master_detail_ar.png',
    );
  });

  testWidgets('drawer opens from the end edge in RTL', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        locale: const Locale('ar'),
        home: Scaffold(
          drawer: AppNavDrawer(
            title: 'Orient CRM',
            subtitle: 'Sales workspace',
            icon: Icons.hub_outlined,
            items: kCrmNav,
            selectedIndex: 1,
            badgeCounts: const {1: 12},
            onSelected: (_) {},
          ),
        ),
      ),
    );
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Drawer),
      matchesGoldenFile('goldens/shell_drawer_mobile_ar.png'),
    );
  });
}

Widget _app({required Locale locale, required Widget home}) {
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
    theme: AppTheme.light(BrandConfig.orient, locale: locale),
    home: home,
  );
}

Future<void> _shellGolden(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
  required String fileName,
  String workspace = 'Staff',
  String title = 'Today',
  String subtitle = 'Workshop Advisor',
  List<AppNavItem> nav = kStaffNav,
  String brandInitial = 'S',
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _app(
      locale: locale,
      home: Phase04Shell(
        workspace: workspace,
        title: title,
        subtitle: subtitle,
        items: nav,
        brandInitial: brandInitial,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
}

Future<void> _plainGolden(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
  required Widget child,
  required String fileName,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(locale: locale, home: child));
  await tester.pumpAndSettle();
  await expectLater(find.byType(Scaffold).first, matchesGoldenFile(fileName));
}
