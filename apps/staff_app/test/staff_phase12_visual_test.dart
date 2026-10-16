import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/features/common/presentation/simple_pages.dart';
import 'package:staff_app/features/common/presentation/staff_attendance_screen.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 12 — common profile / attendance / shift / settings visual
/// references (EN/AR, 390 + 768, light + dark spots, real fonts).
///
/// Seeds are deterministic: punched-out attendance (no live elapsed meter),
/// fixed profile/shift fixtures, queue-less settings. Regenerate with
/// `--update-goldens` only after visual review against the advisor home bar.
const _delegates = <LocalizationsDelegate<dynamic>>[
  StaffLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Bounded settle: fixed 30x100ms pumps instead of pumpAndSettle, so golden
/// renders can never stick on indeterminate progress animations.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => AuthAuthenticated(
        role: UserRole.technician,
        token: 'test_token',
        profile: null,
      );
}

class _SeededAttendance extends StaffAttendanceNotifier {
  final StaffAttendanceState seed;
  _SeededAttendance(this.seed);

  @override
  StaffAttendanceState build() => seed;

  @override
  Future<void> load() async {}
}

const _punchedOut = StaffAttendanceState(
  isLoading: false,
  status: StaffAttendanceStatus.punchedOut,
  punchIn: '08:00 AM',
  punchOut: '05:00 PM',
  workHours: '9h 00m',
);

ProfileData _profileSeed() => ProfileData(
      name: 'Rashid Al Nuaimi',
      id: 'TECH-1042',
      role: 'Technician',
      branch: 'Al Quoz Central',
      shift: 'Morning Shift (08:00 AM - 05:00 PM)',
      email: 'rashid@orient.ae',
      phone: '+971 50 123 4567',
      avatarInitials: 'RN',
    );

Map<String, dynamic> _shiftSeed() => const {
      'shift': 'Morning Bay Shift A',
      'start': '08:00 AM',
      'end': '05:00 PM',
      'breaks': '01:00 PM - 02:00 PM',
      'name': 'Ali Hassan',
      'id': 'EMP-77',
      'branch': 'Dubai South Workshop',
      'supervisor': 'Sara Iqbal',
      'bay': 'B-04',
    };

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  Size size,
  Locale locale, {
  required bool dark,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(_FakeAuth.new),
        staffAttendanceProvider.overrideWith(
          () => _SeededAttendance(_punchedOut),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: dark
            ? AppTheme.dark(BrandConfig.orient, locale: locale)
            : AppTheme.light(BrandConfig.orient, locale: locale),
        home: Scaffold(body: child),
      ),
    ),
  );
  await _settle(tester);
}

void main() {
  setUpAll(_loadFonts);

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('profile 390 $label', (tester) async {
      await _pump(
        tester,
        StaffProfileScreen(data: _profileSeed()),
        const Size(390, 844),
        locale,
        dark: false,
      );
      expect(find.text('Rashid Al Nuaimi'), findsOneWidget);
      await expectLater(
        find.byType(StaffProfileScreen),
        matchesGoldenFile('goldens/common_profile_390_$label.png'),
      );
    });

    testWidgets('attendance 390 $label', (tester) async {
      await _pump(
        tester,
        const StaffAttendanceScreen(),
        const Size(390, 844),
        locale,
        dark: false,
      );
      await expectLater(
        find.byType(StaffAttendanceScreen),
        matchesGoldenFile('goldens/common_attendance_390_$label.png'),
      );
    });

    testWidgets('shift 390 $label', (tester) async {
      await _pump(
        tester,
        ShiftDetailsPage(data: _shiftSeed()),
        const Size(390, 844),
        locale,
        dark: false,
      );
      expect(find.text('Morning Bay Shift A'), findsOneWidget);
      await expectLater(
        find.byType(ShiftDetailsPage),
        matchesGoldenFile('goldens/common_shift_390_$label.png'),
      );
    });

    testWidgets('settings 390 $label', (tester) async {
      await _pump(
        tester,
        const SettingsPage(data: {'version': '2.4.1 (Build 88)'}),
        const Size(390, 844),
        locale,
        dark: false,
      );
      expect(find.text('2.4.1 (Build 88)'), findsOneWidget);
      await expectLater(
        find.byType(SettingsPage),
        matchesGoldenFile('goldens/common_settings_390_$label.png'),
      );
    });
  }

  testWidgets('profile 768 en tablet', (tester) async {
    await _pump(
      tester,
      StaffProfileScreen(data: _profileSeed()),
      const Size(768, 1024),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(StaffProfileScreen),
      matchesGoldenFile('goldens/common_profile_768_en.png'),
    );
  });

  testWidgets('attendance 768 en tablet', (tester) async {
    await _pump(
      tester,
      const StaffAttendanceScreen(),
      const Size(768, 1024),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(StaffAttendanceScreen),
      matchesGoldenFile('goldens/common_attendance_768_en.png'),
    );
  });

  testWidgets('shift 768 en tablet', (tester) async {
    await _pump(
      tester,
      ShiftDetailsPage(data: _shiftSeed()),
      const Size(768, 1024),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(ShiftDetailsPage),
      matchesGoldenFile('goldens/common_shift_768_en.png'),
    );
  });

  testWidgets('settings 768 en tablet', (tester) async {
    await _pump(
      tester,
      const SettingsPage(data: {'version': '2.4.1 (Build 88)'}),
      const Size(768, 1024),
      const Locale('en'),
      dark: false,
    );
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/common_settings_768_en.png'),
    );
  });

  testWidgets('profile 390 en dark spot', (tester) async {
    await _pump(
      tester,
      StaffProfileScreen(data: _profileSeed()),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(StaffProfileScreen),
      matchesGoldenFile('goldens/common_profile_390_dark.png'),
    );
  });

  testWidgets('attendance 390 en dark spot', (tester) async {
    await _pump(
      tester,
      const StaffAttendanceScreen(),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(StaffAttendanceScreen),
      matchesGoldenFile('goldens/common_attendance_390_dark.png'),
    );
  });

  testWidgets('shift 390 en dark spot', (tester) async {
    await _pump(
      tester,
      ShiftDetailsPage(data: _shiftSeed()),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(ShiftDetailsPage),
      matchesGoldenFile('goldens/common_shift_390_dark.png'),
    );
  });

  testWidgets('settings 390 en dark spot', (tester) async {
    await _pump(
      tester,
      const SettingsPage(data: {'version': '2.4.1 (Build 88)'}),
      const Size(390, 844),
      const Locale('en'),
      dark: true,
    );
    await expectLater(
      find.byType(SettingsPage),
      matchesGoldenFile('goldens/common_settings_390_dark.png'),
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
