import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 02 evidence capture harness (auth, EN + AR).
/// Copy into `packages/shared_auth/test/`, run
/// `flutter test --update-goldens test/phase02_capture_test.dart`, then delete.
/// PNGs land in `phases/reports/PHASE_02/screens/`.
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

  final cases = <String, _Case>{
    'auth_login_390_en': _Case(const Size(390, 844), 'en'),
    'auth_login_390_ar': _Case(const Size(390, 844), 'ar'),
    'auth_login_320_ar': _Case(const Size(320, 640), 'ar'),
    'auth_login_1024_ar': _Case(const Size(1024, 900), 'ar'),
    'auth_login_390_ar_scale13': _Case(const Size(390, 844), 'ar', scale: 1.3),
    'auth_forgot_390_ar': _Case(const Size(390, 844), 'ar', forgot: true),
  };

  cases.forEach((name, c) {
    testWidgets('capture $name', (tester) async {
      tester.view.physicalSize = c.size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final arabic = c.language == 'ar';
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: Locale(c.language),
            supportedLocales: AppLocales.supported,
            localizationsDelegates: const [
              SharedAuthLocalizations.delegate,
              SharedCoreLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(BrandConfig.orient, locale: Locale(c.language)),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(c.scale),
              ),
              child: child!,
            ),
            home: c.forgot
                ? ForgotPasswordView(
                    onBackToLogin: () {},
                    appName: arabic ? 'تطبيق أورينت — الموظفون' : 'Orient Staff App',
                    appPurpose: arabic
                        ? 'تأكيد الحجوزات واستلام المركبات وإجراء الفحوصات.'
                        : 'Confirm bookings, check in vehicles, run inspections.',
                    intendedUsers: arabic
                        ? 'للمستشارين والفنيين والمشرفين'
                        : 'For advisors, technicians, and supervisors',
                  )
                : LoginView(
                    onLoginSuccess: () {},
                    onForgotPassword: () {},
                    allowRegistration: true,
                    appName: arabic ? 'تطبيق أورينت — الموظفون' : 'Orient Staff App',
                    appPurpose: arabic
                        ? 'تأكيد الحجوزات واستلام المركبات وإجراء الفحوصات.'
                        : 'Confirm bookings, check in vehicles, run inspections.',
                    intendedUsers: arabic
                        ? 'للمستشارين والفنيين والمشرفين'
                        : 'For advisors, technicians, and supervisors',
                  ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../../phases/reports/PHASE_02/screens/$name.png',
        ),
      );
    });
  });
}

class _Case {
  final Size size;
  final String language;
  final double scale;
  final bool forgot;
  const _Case(this.size, this.language, {this.scale = 1.0, this.forgot = false});
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
    '..${sep}shared_core${sep}assets${sep}fonts${sep}plus_jakarta_sans'
    '${sep}PlusJakartaSans-Variable.ttf',
  );
  for (final w in const {
    'Regular': 400,
    'Medium': 500,
    'SemiBold': 600,
    'Bold': 700,
  }.entries) {
    await load(
      AppFontFamilies.arabic,
      '..${sep}shared_core${sep}assets${sep}fonts${sep}ibm_plex_sans_arabic'
      '${sep}IBMPlexSansArabic-${w.key}.ttf',
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
