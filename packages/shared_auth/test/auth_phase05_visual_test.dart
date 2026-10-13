import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 05 — authentication visual references (EN/AR, compact + expanded).
///
/// Regenerated only for the auth surfaces intentionally redesigned in Phase 05
/// and visually reviewed before re-baselining (J2 gate).
const _delegates = <LocalizationsDelegate<dynamic>>[
  SharedAuthLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _host({
  required Widget home,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: _delegates,
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      home: home,
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
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  for (final (label, locale) in <(String, Locale)>[
    ('en', const Locale('en')),
    ('ar', const Locale('ar')),
  ]) {
    testWidgets('login compact visual reference ($label)', (tester) async {
      await _pump(tester, const Size(390, 844), locale);
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_login_compact_$label.png'),
      );
    });

    testWidgets('login expanded visual reference ($label)', (tester) async {
      await _pump(tester, const Size(1280, 900), locale);
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_login_expanded_$label.png'),
      );
    });

    testWidgets('login tablet visual reference ($label)', (tester) async {
      await _pump(tester, const Size(768, 1024), locale);
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_login_tablet_$label.png'),
      );
    });

    testWidgets('otp compact visual reference ($label)', (tester) async {
      await _pump(
        tester,
        const Size(390, 844),
        locale,
        overrides: [loginProvider.overrideWith(_OtpSentNotifier.new)],
      );
      await tester.tap(
        find.text(
          locale.languageCode == 'ar' ? 'رمز لمرة واحدة' : 'One-time code',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_otp_compact_$label.png'),
      );
    });

    testWidgets('recovery compact visual reference ($label)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          locale: locale,
          home: ForgotPasswordView(
            onBackToLogin: () {},
            appName: 'Orient Staff App',
            intendedUsers: 'For advisors, technicians, and supervisors',
            appPurpose: 'Confirm bookings, check in vehicles and run QC.',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ForgotPasswordView),
        matchesGoldenFile('goldens/auth_phase05_recovery_compact_$label.png'),
      );
    });

    testWidgets('splash visual reference ($label)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(locale: locale, home: const AuthLoadingView()),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(AuthLoadingView),
        matchesGoldenFile('goldens/auth_phase05_splash_$label.png'),
      );
    });
  }
}

Future<void> _pump(
  WidgetTester tester,
  Size size,
  Locale locale, {
  List<Override> overrides = const [],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _host(
      locale: locale,
      overrides: overrides,
      home: LoginView(
        onLoginSuccess: () {},
        onForgotPassword: () {},
        allowRegistration: true,
        appName: 'Orient Staff App',
        intendedUsers: 'For advisors, technicians, and supervisors',
        appPurpose: 'Confirm bookings, check in vehicles and run QC.',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _OtpSentNotifier extends LoginNotifier {
  @override
  LoginState build() => const LoginState(
    method: AuthMethod.email,
    email: 'advisor@orientworkshop.ae',
    otpSent: true,
    resendCooldown: 24,
  );

  @override
  void reset() {}
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
    '..${sep}shared_core${sep}assets${sep}fonts${sep}plus_jakarta_sans'
    '${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final weight in <String>['Regular', 'Medium', 'SemiBold', 'Bold']) {
    await load(
      AppFontFamilies.arabic,
      '..${sep}shared_core${sep}assets${sep}fonts${sep}ibm_plex_sans_arabic'
      '${sep}IBMPlexSansArabic-$weight.ttf',
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
