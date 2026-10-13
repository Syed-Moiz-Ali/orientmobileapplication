// Shared helpers for the Phase 00 prototype tests.
//
// Loads the bundled Latin + Arabic fonts into the test renderer so goldens
// contain real glyphs (including shaped Arabic), pumps individual prototype
// screens at an exact viewport size, and exposes deterministic pumping
// helpers that cooperate with the skeleton pulse / OTP countdown timers.
import 'package:design_prototype/design/prototype_theme.dart';
import 'package:design_prototype/screens/auth/login_prototype.dart';
import 'package:design_prototype/screens/dashboards/owner_dashboard_prototype.dart';
import 'package:design_prototype/screens/detail/technician_job_detail_prototype.dart';
import 'package:design_prototype/screens/forms/add_vehicle_prototype.dart';
import 'package:design_prototype/screens/listings/job_cards_prototype.dart';
import 'package:design_prototype/screens/workflows/inspection_prototype.dart';
import 'package:design_prototype/widgets/proto_vehicle_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:io';

bool _fontsLoaded = false;

/// Loads Plus Jakarta Sans, IBM Plex Sans Arabic and the SDK MaterialIcons font
/// through the test engine so goldens contain real glyphs (including shaped
/// Arabic) and real icons instead of tofu boxes.
Future<void> loadPrototypeFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;

  final jakarta = FontLoader('PlusJakartaSans')
    ..addFont(rootBundle.load('assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf'));
  await jakarta.load();

  final arabic = FontLoader('IBMPlexSansArabic');
  for (final file in const [
    'IBMPlexSansArabic-Regular.ttf',
    'IBMPlexSansArabic-Medium.ttf',
    'IBMPlexSansArabic-SemiBold.ttf',
    'IBMPlexSansArabic-Bold.ttf',
  ]) {
    arabic.addFont(rootBundle.load('assets/fonts/ibm_plex_sans_arabic/$file'));
  }
  await arabic.load();

  // MaterialIcons ships with the Flutter SDK cache, not the app bundle.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final iconFont = File('$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (iconFont.existsSync()) {
      final icons = FontLoader('MaterialIcons')
        ..addFont(Future.value(iconFont.readAsBytesSync().buffer.asByteData()));
      await icons.load();
    }
  }
}

enum ProtoScreen { ownerDashboard, jobCards, technicianJob, addVehicle, login, inspection }

extension ProtoScreenX on ProtoScreen {
  String get goldenName => switch (this) {
        ProtoScreen.ownerDashboard => 'owner_dashboard',
        ProtoScreen.jobCards => 'job_cards',
        ProtoScreen.technicianJob => 'technician_job',
        ProtoScreen.addVehicle => 'add_vehicle',
        ProtoScreen.login => 'login',
        ProtoScreen.inspection => 'inspection',
      };

  Widget build(String variant) => switch (this) {
        ProtoScreen.ownerDashboard => OwnerDashboardPrototype(variant: variant),
        ProtoScreen.jobCards => JobCardsPrototype(variant: variant),
        ProtoScreen.technicianJob => TechnicianJobDetailPrototype(variant: variant),
        ProtoScreen.addVehicle => AddVehiclePrototype(variant: variant),
        ProtoScreen.login => LoginPrototype(variant: variant),
        ProtoScreen.inspection => InspectionPrototype(variant: variant),
      };

  /// Base populated/partial state used by the size matrix.
  String get baseVariant => switch (this) {
        ProtoScreen.ownerDashboard => 'populated',
        ProtoScreen.jobCards => 'populated',
        ProtoScreen.technicianJob => 'active',
        ProtoScreen.addVehicle => 'pristine',
        ProtoScreen.login => 'default',
        ProtoScreen.inspection => 'partial',
      };
}

/// Sizes the test viewport exactly (logical pixels) and pumps one screen.
Future<void> pumpScreen(
  WidgetTester tester,
  ProtoScreen screen, {
  required String variant,
  required Size size,
  Locale locale = const Locale('en'),
  bool dark = false,
  double textScale = 1.0,
}) async {
  await loadPrototypeFonts();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Warm the real-asset caches outside the fake-async zone so the inspection
  // prototype's vehicle map renders deterministically from the first frame.
  await tester.runAsync(() async {
    await ProtoVehicleMapLoader.load();
    await ProtoVehicleMapLoader.loadBaseImage();
  });

  final arabic = locale.languageCode == 'ar';
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: dark ? PrototypeTheme.dark(arabic: arabic) : PrototypeTheme.light(arabic: arabic),
      builder: textScale == 1.0
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
      home: Scaffold(
        body: screen.build(variant),
      ),
    ),
  );
  // Two frames: tree + post-frame callbacks (auto-opened sheets/dialogs).
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Pumps frames until [finder] matches or [maxFrames] is reached. Avoids
/// `pumpAndSettle` which never settles while skeleton pulses or indeterminate
/// progress indicators are on screen.
Future<bool> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxFrames = 40,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxFrames; i++) {
    if (finder.evaluate().isNotEmpty) return true;
    await tester.pump(step);
  }
  return finder.evaluate().isNotEmpty;
}

/// Disposes the tree so periodic timers (OTP countdown) are cancelled before
/// the test framework checks for pending timers.
Future<void> disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}
