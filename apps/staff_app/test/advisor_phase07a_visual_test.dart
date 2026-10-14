import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_remote_datasource.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/scan_vehicle_view.dart';
import 'package:staff_app/features/advisor/presentation/pages/vehicle_customer_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 07A — advisor intake / check-in / scan visual references (EN/AR,
/// mobile/tablet/desktop). Regenerated only for the screens intentionally
/// redesigned in Phase 07A and visually reviewed before re-baselining (J2 gate).
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  setUpAll(_loadFonts);
  setUp(() {
    // Deny camera permission deterministically so the scanner renders its
    // permission-denied state instead of touching the platform camera.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async {
            // Echo the requested permission keys with a "denied" (0) status.
            final args = call.arguments;
            if (args is Map) {
              return <int, int>{
                for (final key in args.keys) (key as int): 0,
              };
            }
            return <int, int>{};
          },
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          null,
        );
  });

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    for (final (sizeLabel, size) in <(String, Size)>[
      ('390', const Size(390, 844)),
      ('768', const Size(768, 1024)),
      ('1280', const Size(1280, 800)),
    ]) {
      testWidgets('intake $sizeLabel $label', (tester) async {
        await _pump(tester, const VehicleCustomerView(), size, locale);
        await expectLater(
          find.byType(VehicleCustomerView),
          matchesGoldenFile('goldens/intake_${sizeLabel}_$label.png'),
        );
      });
    }

    testWidgets('checkin 390 $label', (tester) async {
      await _pump(
        tester,
        const AdvisorVehicleCheckinView(
          bookingId: 'BK-2026-0042',
          customerName: 'Rashid Al Nuaimi',
          vehicleInfo: '2024 Toyota Land Cruiser',
        ),
        const Size(390, 844),
        locale,
      );
      await expectLater(
        find.byType(AdvisorVehicleCheckinView),
        matchesGoldenFile('goldens/checkin_390_$label.png'),
      );
    });

    testWidgets('scan 390 $label', (tester) async {
      await _pump(
        tester,
        const ScanVehicleView(scanMode: 'VIN'),
        const Size(390, 844),
        locale,
        settle: false,
      );
      // The scanner animates continuously; advance a fixed duration instead of
      // waiting for settle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(ScanVehicleView),
        matchesGoldenFile('goldens/scan_390_$label.png'),
      );
    });

    testWidgets('intake 390 $label invalid', (tester) async {
      await _pump(tester, const VehicleCustomerView(), const Size(390, 844), locale);
      final t = await StaffLocalizations.delegate.load(locale);
      // In Arabic the page title and the button label are identical; target the
      // action-bar button (the last match).
      await tester.tap(find.text(t.advisorIntakeActionCreate).last);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(VehicleCustomerView),
        matchesGoldenFile('goldens/intake_390_${label}_invalid.png'),
      );
    });
  }

  testWidgets('checkin 390 en damage step', (tester) async {
    await _pump(
      tester,
      const AdvisorVehicleCheckinView(
        bookingId: 'BK-2026-0042',
        customerName: 'Rashid Al Nuaimi',
        vehicleInfo: '2024 Toyota Land Cruiser',
      ),
      const Size(390, 844),
      const Locale('en'),
    );
    final t = await StaffLocalizations.delegate.load(const Locale('en'));
    await tester.tap(find.text(t.advisorCheckInNext));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.advisorCheckInFront));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Deep scratch on the bumper',
    );
    await tester.tap(find.text(t.advisorCheckInAdd));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(AdvisorVehicleCheckinView),
      matchesGoldenFile('goldens/checkin_390_en_damage.png'),
    );
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale, {
  bool settle = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorRemoteDataSourceProvider.overrideWithValue(
          _FakeAdvisorRemoteDataSource(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: child,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

class _FakeAdvisorRemoteDataSource implements AdvisorRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
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
