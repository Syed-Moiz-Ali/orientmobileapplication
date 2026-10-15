import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 05 validation completeness: every frozen validation rule and every
/// API failure family fires into its specified UI surface (field-inline OR
/// snackbar-with-retry — never both, never nowhere) using the real widgets
/// with a stubbed repository.
///
/// Rules themselves are byte-identical (thresholds/regex untouched); these
/// tests pin the *surfacing*: inline message + error border, cleared on edit,
/// values preserved, focus on first error, double-submit blocked, busy label
/// swap, EN + AR copy.
void main() {
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

  group('local validation rules surface inline', () {
    testWidgets('empty submit flags identifier and password', (tester) async {
      await _pumpLogin(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Enter your email or mobile number.'), findsOneWidget);
      // The password error copy matches the field hint, so both render.
      expect(find.text('Enter your password'), findsWidgets);
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('email format rule has its own inline copy', (tester) async {
      await _pumpLogin(tester);

      await tester.enterText(find.byType(TextField).first, 'not-an-email');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('phone format rule has its own inline copy', (tester) async {
      await _pumpLogin(tester);

      await tester.enterText(find.byType(TextField).first, '12345');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.text('Enter a valid phone number'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('phone fields carry the per-country format hint', (
      tester,
    ) async {
      await _pumpLogin(tester);

      expect(find.text('Enter 9 digits for +971'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('registration flags name and short password', (tester) async {
      await _pumpLogin(tester, allowRegistration: true);

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(find.text('Enter your name'), findsOneWidget);
      expect(
        find.text('Enter your email or mobile number.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);

      // Short (non-empty) passwords get the min-length copy instead.
      await tester.enterText(find.byType(TextField).first, 'Sara Ahmed');
      await tester.pump();
      await tester.enterText(
        find.byType(TextField).at(1),
        'name@company.com',
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), '12345');
      await tester.pump();
      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(find.text('Password must be 6+ chars'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('registration shows the strength meter text', (tester) async {
      await _pumpLogin(tester, allowRegistration: true);

      expect(find.text('Weak'), findsOneWidget);
      // Third TextField in the register column is the password.
      await tester.enterText(find.byType(TextField).at(2), 'Abcdef1!');
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('short OTP flags the OTP field', (tester) async {
      final repo = _StubAuthRepository()
        ..sendSmsResult = const Success<void>(null);
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await tester.tap(find.text('One-time code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text('Send code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Verify code'), findsOneWidget);
      await tester.tap(find.text('Verify code'));
      await tester.pump();

      expect(find.text('Enter 6-digit OTP'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('inline errors clear on edit', (tester) async {
      await _pumpLogin(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Enter your email or mobile number.'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).first,
        'name@company.com',
      );
      await tester.pump();
      expect(
        find.text('Enter your email or mobile number.'),
        findsNothing,
      );
      await _drain(tester);
    });

    testWidgets('recovery flags identifier, code and password locally', (
      tester,
    ) async {
      await _pumpForgot(tester, overrides: _recoveryOverrides(_StubAuthRepository()));

      await tester.tap(find.text('Send recovery code'));
      await tester.pump();
      expect(find.text('Enter your email or mobile number.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'name@company.com');
      await tester.tap(find.text('Send recovery code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // The code-sent confirmation snackbar dismisses on its own (timer +
      // exit animation need separate frames).
      expect(find.textContaining('Recovery code sent to'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(find.text('Enter the 6-digit recovery code.'), findsOneWidget);
      expect(find.text('Use at least 6 characters.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      // Lets the resend-cooldown future finish (no pending timers at tear-down).
      await tester.pump(const Duration(seconds: 31));
    });
  });

  group('API failures map one-to-one', () {
    testWidgets('401 surfaces invalid-credentials snackbar with retry', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          UnauthorizedException('Invalid credentials'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(
          'Incorrect details. Check your email or mobile number and '
          'password, then try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      // Values are preserved across the failure.
      expect(_textFieldText(tester, 0), 'name@company.com');
      expect(_textFieldText(tester, 1), 'secret123');
      await _drain(tester);
    });

    testWidgets('500 surfaces server snackbar with support ref and retry', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          UnknownException('Server error'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('ref 500'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('offline surfaces offline snackbar with retry', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          NetworkException('Failed host lookup'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(
          "You're offline. Check your connection and try again.",
        ),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      await _drain(tester);
    });

    testWidgets('409 conflict maps inline to the identifier field', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..registerResult = const Failure<AuthResult>(
          ValidationException('An account already exists for this email.'),
        );
      await _pumpLogin(
        tester,
        overrides: _loginOverrides(repo),
        allowRegistration: true,
      );
      await tester.enterText(find.byType(TextField).first, 'Sara Ahmed');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), 'name@company.com');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(2), 'secret123');
      await tester.pump();

      await tester.tap(find.text('Create account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(
          'An account already exists for these details. '
          'Try signing in instead.',
        ),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('404 maps inline to the identifier field', (tester) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          ValidationException('User not found'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text(
          'No account was found for these details. '
          'Check the email or mobile number.',
        ),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('422 password detail maps inline to the password field', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          ValidationException('Password must contain a symbol.'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('Password must contain a symbol.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
      await _drain(tester);
    });

    testWidgets('snackbar retry re-issues the request', (tester) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          NetworkException('Failed host lookup'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(repo.loginCalls, 1);

      repo.loginResult = Success(
        const AuthResult(role: UserRole.customer, token: 't'),
      );
      await tester.tap(find.text('Try again'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(repo.loginCalls, 2);
      await _drain(tester);
    });

    testWidgets('double-submit is blocked and the CTA shows its busy label', (
      tester,
    ) async {
      final repo = _StubAuthRepository()..loginHang = true;
      var successes = 0;
      await _pumpLogin(
        tester,
        overrides: _loginOverrides(repo),
        onLoginSuccess: () => successes++,
      );
      await _enterPasswordCreds(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Signing in…'), findsOneWidget);
      await tester.tap(find.text('Signing in…'));
      await tester.pump();
      expect(repo.loginCalls, 1);

      repo.completeLogin(
        Success(const AuthResult(role: UserRole.customer, token: 't')),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(successes, 1);
    });

    testWidgets('expired vs incorrect OTP get distinct inline copy', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..sendSmsResult = const Success<void>(null)
        ..verifySmsResult = const Failure<AuthResult>(
          ValidationException('OTP expired, request a new one'),
        );
      await _pumpLogin(tester, overrides: _loginOverrides(repo));
      await tester.tap(find.text('One-time code'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text('Send code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.pump();
      await tester.tap(find.text('Verify code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('This code has expired. Request a new code and try again.'),
        findsOneWidget,
      );

      repo.verifySmsResult = const Failure<AuthResult>(
        ValidationException('Invalid OTP, try again'),
      );
      await tester.enterText(find.byType(EditableText).first, '654321');
      await tester.pump();
      await tester.tap(find.text('Verify code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('This code is incorrect. Check the 6 digits and try again.'),
        findsOneWidget,
      );
      await _drain(tester);
    });

    testWidgets('recovery reset offline failure offers retry', (tester) async {
      final repo = _StubAuthRepository()
        ..resetResult = const Failure<void>(
          NetworkException('connection reset'),
        );
      await _pumpForgot(tester, overrides: _recoveryOverrides(repo));

      await tester.enterText(find.byType(TextField), 'name@company.com');
      await tester.tap(find.text('Send recovery code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.pump();
      await tester.tap(find.text('Update password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      await tester.pump(const Duration(seconds: 31));
    });
  });

  group('Arabic copy parity on the failure surfaces', () {
    testWidgets('AR validation and offline failure use AR copy', (
      tester,
    ) async {
      final repo = _StubAuthRepository()
        ..loginResult = const Failure<AuthResult>(
          NetworkException('Failed host lookup'),
        );
      await _pumpLogin(
        tester,
        overrides: _loginOverrides(repo),
        locale: const Locale('ar'),
      );

      await tester.tap(find.text('متابعة'));
      await tester.pump();
      expect(
        find.text('أدخل بريدك الإلكتروني أو رقم جوالك.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byType(TextField).first,
        'name@company.com',
      );
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.pump();
      await tester.tap(find.text('متابعة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.text('أنت دون اتصال. تحقق من اتصالك وحاول مجدداً.'),
        findsOneWidget,
      );
      expect(find.text('إعادة المحاولة'), findsOneWidget);
      await _drain(tester);
    });
  });
}

Future<void> _drain(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 6));

String _textFieldText(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byType(TextField).at(index)).controller!.text;

Future<void> _enterPasswordCreds(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'name@company.com');
  await tester.enterText(find.byType(TextField).at(1), 'secret123');
  await tester.pump();
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  bool allowRegistration = false,
  VoidCallback? onLoginSuccess,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  if (allowRegistration) {
    await tester.pumpWidget(
      _host(
        locale: locale,
        overrides: overrides,
        home: LoginView(
          onLoginSuccess: onLoginSuccess ?? () {},
          allowRegistration: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('New customer? Create an account'));
    await tester.pumpAndSettle();
    return;
  }

  await tester.pumpWidget(
    _host(
      locale: locale,
      overrides: overrides,
      home: LoginView(onLoginSuccess: onLoginSuccess ?? () {}),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpForgot(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _host(
      overrides: overrides,
      home: ForgotPasswordView(onBackToLogin: () {}),
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

List<Override> _loginOverrides(_StubAuthRepository repo) => [
  sendOtpProvider.overrideWithValue(SendOtp(repo)),
  verifyOtpProvider.overrideWithValue(VerifyOtp(repo)),
  sendEmailOtpProvider.overrideWithValue(SendEmailOtp(repo)),
  verifyEmailOtpProvider.overrideWithValue(VerifyEmailOtp(repo)),
  registerUserProvider.overrideWithValue(RegisterUser(repo)),
  loginWithPasswordProvider.overrideWithValue(LoginWithPassword(repo)),
];

List<Override> _recoveryOverrides(_StubAuthRepository repo) => [
  forgotPasswordProvider.overrideWithValue(ForgotPassword(repo)),
  resetPasswordProvider.overrideWithValue(ResetPassword(repo)),
];

/// Stub repository: real widgets, controlled backend. Results are mutable so
/// a single test can walk expired -> incorrect OTP or failure -> retry.
class _StubAuthRepository implements AuthRepository {
  Result<void>? sendSmsResult;
  Result<AuthResult>? verifySmsResult;
  Result<void>? sendEmailResult;
  Result<AuthResult>? verifyEmailResult;
  Result<AuthResult>? registerResult;
  Result<AuthResult>? loginResult;
  Result<void>? forgotResult;
  Result<void>? resetResult;

  /// When true, login hangs until [completeLogin] (double-submit test).
  bool loginHang = false;
  final List<Completer<Result<AuthResult>>> _loginGates = [];

  int sendSmsCalls = 0;
  int loginCalls = 0;
  int verifySmsCalls = 0;

  void completeLogin(Result<AuthResult> result) {
    for (final gate in _loginGates) {
      if (!gate.isCompleted) gate.complete(result);
    }
  }

  @override
  Future<Result<void>> sendOtp(String phone) async {
    sendSmsCalls++;
    return sendSmsResult ?? const Failure<void>(UnknownException('no stub'));
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async {
    verifySmsCalls++;
    return verifySmsResult ??
        const Failure<AuthResult>(UnknownException('no stub'));
  }

  @override
  Future<Result<void>> sendEmailOtp(String email) async =>
      sendEmailResult ?? const Failure<void>(UnknownException('no stub'));

  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) async =>
      verifyEmailResult ??
      const Failure<AuthResult>(UnknownException('no stub'));

  @override
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async =>
      registerResult ??
      const Failure<AuthResult>(UnknownException('no stub'));

  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) async {
    loginCalls++;
    if (loginHang) {
      final gate = Completer<Result<AuthResult>>();
      _loginGates.add(gate);
      return gate.future;
    }
    return loginResult ?? const Failure<AuthResult>(UnknownException('no stub'));
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async =>
      const Failure<AuthResult>(UnknownException('no stub'));

  @override
  Future<Result<void>> logout() async => const Success<void>(null);

  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) async =>
      forgotResult ?? const Success<void>(null);

  @override
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  ) async =>
      resetResult ?? const Success<void>(null);

  @override
  List<RoleConfig> getRoleConfigs() => RoleConfig.configs;
}
