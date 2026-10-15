import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 05 validation-completeness error states (EN/AR, light).
///
/// Every rule and every API failure family captured on its specified surface:
/// field-inline for validation/field-mapped failures, snackbar-with-retry
/// for form-level failures (bottom-docked on compact, top-end on expanded).
/// Regenerated only after native inspection (§23 of REPORT_PHASE_05).
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
    final continueLabel = label == 'ar' ? 'متابعة' : 'Continue';
    final sendLabel = label == 'ar' ? 'إرسال الرمز' : 'Send code';
    final verifyLabel = label == 'ar' ? 'تحقق من الرمز' : 'Verify code';
    final codeLabel = label == 'ar' ? 'رمز لمرة واحدة' : 'One-time code';
    final registerLink = label == 'ar'
        ? 'عميل جديد؟ أنشئ حساباً'
        : 'New customer? Create an account';
    final createLabel = label == 'ar' ? 'إنشاء الحساب' : 'Create account';
    final recoveryLabel = label == 'ar'
        ? 'إرسال رمز الاستعادة'
        : 'Send recovery code';

    testWidgets('login validation errors ($label)', (tester) async {
      await _pumpLogin(tester, const Size(390, 844), locale);
      await tester.tap(find.text(continueLabel));
      await tester.pump();
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_err_login_validation_$label.png'),
      );
    });

    testWidgets('login 401 snackbar with retry ($label)', (tester) async {
      final repo = _ErrRepository()
        ..loginResult = const Failure<AuthResult>(
          UnauthorizedException('Invalid credentials'),
        );
      await _pumpLogin(
        tester,
        const Size(390, 844),
        locale,
        overrides: _loginOverrides(repo),
      );
      await tester.enterText(find.byType(TextField).first, 'name@company.com');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.pump();
      await tester.tap(find.text(continueLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_err_login_401_$label.png'),
      );
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('incorrect OTP inline ($label)', (tester) async {
      final repo = _ErrRepository()
        ..sendSmsResult = const Success<void>(null)
        ..verifySmsResult = const Failure<AuthResult>(
          ValidationException('Invalid OTP, try again'),
        );
      await _pumpLogin(
        tester,
        const Size(390, 844),
        locale,
        overrides: _loginOverrides(repo),
      );
      await tester.tap(find.text(codeLabel));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(sendLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.pump();
      await tester.tap(find.text(verifyLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_err_otp_invalid_$label.png'),
      );
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('registration errors ($label)', (tester) async {
      await _pumpLogin(
        tester,
        const Size(390, 844),
        locale,
        allowRegistration: true,
      );
      await tester.tap(find.text(registerLink));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Sara Ahmed');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), 'name@company.com');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), '12345');
      await tester.pump();
      await tester.tap(find.text(createLabel));
      await tester.pump();
      await expectLater(
        find.byType(LoginView),
        matchesGoldenFile('goldens/auth_phase05_err_register_$label.png'),
      );
    });

    testWidgets('recovery offline snackbar with retry ($label)', (
      tester,
    ) async {
      final repo = _ErrRepository()
        ..forgotResult = const Failure<void>(
          NetworkException('Failed host lookup'),
        );
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          locale: locale,
          overrides: [
            forgotPasswordProvider.overrideWithValue(ForgotPassword(repo)),
            resetPasswordProvider.overrideWithValue(ResetPassword(repo)),
          ],
          home: ForgotPasswordView(onBackToLogin: () {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'name@company.com');
      await tester.tap(find.text(recoveryLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(
        find.byType(ForgotPasswordView),
        matchesGoldenFile(
          'goldens/auth_phase05_err_recovery_offline_$label.png',
        ),
      );
      await tester.pump(const Duration(seconds: 6));
    });
  }

  testWidgets('desktop offline snackbar pins top-end (en)', (tester) async {
    const locale = Locale('en');
    final repo = _ErrRepository()
      ..loginResult = const Failure<AuthResult>(
        NetworkException('Failed host lookup'),
      );
    await _pumpLogin(
      tester,
      const Size(1280, 900),
      locale,
      overrides: _loginOverrides(repo),
    );
    await tester.enterText(find.byType(TextField).first, 'name@company.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(LoginView),
      matchesGoldenFile('goldens/auth_phase05_err_login_offline_wide_en.png'),
    );
    await tester.pump(const Duration(seconds: 6));
  });
}

Future<void> _pumpLogin(
  WidgetTester tester,
  Size size,
  Locale locale, {
  List<Override> overrides = const [],
  bool allowRegistration = false,
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
      ),
    ),
  );
  await tester.pumpAndSettle();
}

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
      localizationsDelegates: const [
        SharedAuthLocalizations.delegate,
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      home: home,
    ),
  );
}

List<Override> _loginOverrides(_ErrRepository repo) => [
  sendOtpProvider.overrideWithValue(SendOtp(repo)),
  verifyOtpProvider.overrideWithValue(VerifyOtp(repo)),
  sendEmailOtpProvider.overrideWithValue(SendEmailOtp(repo)),
  verifyEmailOtpProvider.overrideWithValue(VerifyEmailOtp(repo)),
  registerUserProvider.overrideWithValue(RegisterUser(repo)),
  loginWithPasswordProvider.overrideWithValue(LoginWithPassword(repo)),
];

class _ErrRepository implements AuthRepository {
  Result<void>? sendSmsResult;
  Result<AuthResult>? verifySmsResult;
  Result<AuthResult>? loginResult;
  Result<void>? forgotResult;

  @override
  Future<Result<void>> sendOtp(String phone) async =>
      sendSmsResult ?? const Failure<void>(UnknownException('no stub'));

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async =>
      verifySmsResult ??
      const Failure<AuthResult>(UnknownException('no stub'));

  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) async =>
      loginResult ?? const Failure<AuthResult>(UnknownException('no stub'));

  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) async =>
      forgotResult ?? const Success<void>(null);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not stubbed');
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
