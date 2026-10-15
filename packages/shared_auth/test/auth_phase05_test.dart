import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 05 — Authentication & Onboarding widget coverage.
///
/// Verifies the redesigned auth surfaces in English and Arabic (RTL), the
/// method paths, OTP entry + resend countdown, recovery stages, responsive
/// 320 px / 1.3x layouts, focus order, and the app-aware security notice.
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
  double textScale = 1.0,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: _delegates,
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: home,
    ),
  );
}

void main() {
  setUpAll(_loadFonts);
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (_) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('method paths', () {
    testWidgets('password method renders EN', (tester) async {
      await _pumpLogin(tester, const Size(390, 844));
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Password'), findsWidgets);
      expect(find.text('One-time code'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('code method (before send) renders EN', (tester) async {
      await _pumpLogin(tester, const Size(390, 844));
      await tester.tap(find.text('One-time code'));
      await tester.pumpAndSettle();
      expect(find.text('Security code'), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);
    });

    testWidgets('code method (sent) shows OTP field and resend countdown', (
      tester,
    ) async {
      await _pumpLogin(
        tester,
        const Size(390, 844),
        overrides: [loginProvider.overrideWith(_OtpSentNotifier.new)],
      );
      await tester.tap(find.text('One-time code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(AuthOtpField), findsOneWidget);
      expect(find.text('Verify code'), findsOneWidget);
      expect(find.text('Resend in 30 seconds'), findsOneWidget);
    });

    testWidgets('registration renders EN and can return to sign in', (
      tester,
    ) async {
      await _pumpLogin(tester, const Size(390, 844), allowRegistration: true);
      await tester.tap(find.text('New customer? Create an account'));
      await tester.pumpAndSettle();
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Already have an account? Sign in'), findsOneWidget);
    });

    testWidgets('loading CTA keeps the button mounted and disables submit', (
      tester,
    ) async {
      await _pumpLogin(
        tester,
        const Size(390, 844),
        overrides: [loginProvider.overrideWith(_LoadingNotifier.new)],
        settle: false,
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('Arabic + RTL', () {
    testWidgets('password method renders AR and mirrors', (tester) async {
      await _pumpLogin(
        tester,
        const Size(390, 844),
        locale: const Locale('ar'),
      );
      expect(find.text('مرحباً بعودتك'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsWidgets);
      expect(find.text('رمز لمرة واحدة'), findsOneWidget);
      expect(find.text('متابعة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(LoginView))),
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('identifier field content stays LTR in AR', (tester) async {
      await _pumpLogin(
        tester,
        const Size(390, 844),
        locale: const Locale('ar'),
      );
      final identifier = tester.widget<TextField>(find.byType(TextField).first);
      expect(identifier.textDirection, TextDirection.ltr);
    });

    testWidgets('recovery renders AR step labels', (tester) async {
      await _pumpForgot(
        tester,
        const Size(390, 844),
        locale: const Locale('ar'),
      );
      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
      expect(find.text('تأكيد الحساب'), findsOneWidget);
      expect(find.text('إرسال رمز الاستعادة'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(ForgotPasswordView))),
        TextDirection.rtl,
      );
    });
  });

  group('responsive', () {
    for (final locale in <Locale>[const Locale('en'), const Locale('ar')]) {
      testWidgets('login 320px @1.3x no overflow (${locale.languageCode})', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _host(
            locale: locale,
            textScale: 1.3,
            home: LoginView(
              onLoginSuccess: () {},
              onForgotPassword: () {},
              allowRegistration: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('OTP at 320px @1.3x no overflow (${locale.languageCode})', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _host(
            locale: locale,
            textScale: 1.3,
            overrides: [loginProvider.overrideWith(_OtpSentNotifier.new)],
            home: LoginView(onLoginSuccess: () {}, onForgotPassword: () {}),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(
            locale.languageCode == 'ar' ? 'رمز لمرة واحدة' : 'One-time code',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(AuthOtpField), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('desktop split shows the identity panel; compact hides it', (
      tester,
    ) async {
      await _pumpLogin(tester, const Size(1280, 900));
      expect(
        find.text('Automotive Garage ERP & Workshop Suite.'),
        findsOneWidget,
      );

      await _pumpLogin(tester, const Size(390, 844));
      expect(
        find.text('Automotive Garage ERP & Workshop Suite.'),
        findsNothing,
      );
    });
  });

  group('focus + semantics', () {
    testWidgets('tab order flows identifier -> password', (tester) async {
      await _pumpLogin(tester, const Size(390, 844));
      final identifierNode = tester
          .widget<TextField>(find.byType(TextField).at(0))
          .focusNode!;
      final passwordNode = tester
          .widget<TextField>(find.byType(TextField).at(1))
          .focusNode!;

      identifierNode.requestFocus();
      await tester.pump();
      expect(identifierNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(passwordNode.hasFocus, isTrue);
    });

    testWidgets('security notice is app-aware when provided', (tester) async {
      await tester.pumpWidget(
        _host(
          home: const AuthShell(
            title: 'Sign in',
            subtitle: 'Welcome',
            securityNotice: 'App-specific terms apply.',
            child: SizedBox.shrink(),
          ),
        ),
      );
      expect(find.text('App-specific terms apply.'), findsOneWidget);
    });
  });

  group('resend action', () {
    testWidgets('cooldown renders a progress ring and quiet countdown', (
      tester,
    ) async {
      var resent = false;
      await tester.pumpWidget(
        _host(
          home: Scaffold(
            body: AuthResendAction(
              cooldownSeconds: 24,
              busy: false,
              onResend: () => resent = true,
            ),
          ),
        ),
      );
      await tester.pump();

      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(ring.value, closeTo(24 / 30, 0.001));
      expect(find.text('Resend in 24 seconds'), findsOneWidget);
      await tester.tap(find.text('Resend in 24 seconds'));
      await tester.pump();
      expect(resent, isFalse);
    });

    testWidgets('idle renders a tappable resend link', (tester) async {
      var resent = false;
      await tester.pumpWidget(
        _host(
          home: Scaffold(
            body: AuthResendAction(
              cooldownSeconds: 0,
              busy: false,
              onResend: () => resent = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Resend code'), findsOneWidget);
      await tester.tap(find.text('Resend code'));
      await tester.pump();
      expect(resent, isTrue);
    });
  });
}

Future<void> _pumpLogin(
  WidgetTester tester,
  Size size, {
  bool allowRegistration = false,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
  bool settle = true,
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
        allowRegistration: allowRegistration,
        appName: 'Orient Staff App',
        intendedUsers: 'For advisors, technicians, and supervisors',
        appPurpose: 'Confirm bookings, check in vehicles and run QC.',
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Future<void> _pumpForgot(
  WidgetTester tester,
  Size size, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
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
}

class _OtpSentNotifier extends LoginNotifier {
  @override
  LoginState build() => const LoginState(
    method: AuthMethod.email,
    email: 'advisor@orientworkshop.ae',
    otpSent: true,
    resendCooldown: 30,
  );

  @override
  void reset() {}
}

class _LoadingNotifier extends LoginNotifier {
  @override
  LoginState build() => const LoginState(isLoading: true);

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
