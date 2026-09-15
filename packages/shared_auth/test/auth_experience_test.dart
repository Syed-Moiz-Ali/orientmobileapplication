import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

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

  testWidgets('login switches between password and code modes', (tester) async {
    await _pumpLogin(tester, const Size(390, 844));

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Use one-time code instead'));
    await tester.pumpAndSettle();
    expect(find.text('Security code'), findsOneWidget);
    expect(find.text('Send code'), findsOneWidget);
  });

  testWidgets('login presents local validation errors as a live notice', (
    tester,
  ) async {
    await _pumpLogin(tester, const Size(390, 844));

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter your password'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('login mobile visual reference', (tester) async {
    await _expectLoginGolden(
      tester,
      size: const Size(390, 844),
      fileName: 'goldens/auth_login_mobile.png',
    );
  });

  testWidgets('login desktop visual reference', (tester) async {
    await _expectLoginGolden(
      tester,
      size: const Size(1440, 900),
      fileName: 'goldens/auth_login_desktop.png',
    );
  });

  testWidgets('customer registration mode presents its own fields and action', (
    tester,
  ) async {
    await _pumpLogin(tester, const Size(390, 844), allowRegistration: true);

    expect(find.text('New customer? Create an account'), findsOneWidget);
    await tester.tap(find.text('New customer? Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Create a password'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
    expect(find.text('Use one-time code instead'), findsNothing);
  });

  testWidgets('registration offers both password and code modes', (
    tester,
  ) async {
    await _pumpLogin(tester, const Size(390, 844), allowRegistration: true);

    await tester.tap(find.text('Use one-time code instead'));
    await tester.pumpAndSettle();
    expect(find.text('Security code'), findsOneWidget);
    expect(find.text('Send code'), findsOneWidget);

    await tester.tap(find.text('Use password instead'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('New customer? Create an account'), findsOneWidget);
  });

  testWidgets('login lays out on the smallest supported phone', (tester) async {
    await _pumpLogin(tester, const Size(360, 640));
    expect(tester.takeException(), isNull);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('login remains usable at an increased text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 760);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: LoginView(onLoginSuccess: () {}, onForgotPassword: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('one-time code mode mobile visual reference', (tester) async {
    await _pumpLogin(tester, const Size(390, 844));
    await tester.tap(find.text('Use one-time code instead'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(LoginView),
      matchesGoldenFile('goldens/auth_login_code_mobile.png'),
    );
  });

  testWidgets('registration mobile visual reference', (tester) async {
    await _pumpLogin(tester, const Size(390, 844), allowRegistration: true);
    await tester.tap(find.text('New customer? Create an account'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(LoginView),
      matchesGoldenFile('goldens/auth_register_mobile.png'),
    );
  });

  testWidgets('one-time code sent state renders and is announced', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loginProvider.overrideWith(_OtpSentNotifier.new)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          home: LoginView(
            onLoginSuccess: () {},
            onForgotPassword: () {},
            appName: 'Orient Staff App',
            intendedUsers: 'For advisors, technicians, and supervisors',
            appPurpose: 'Confirm bookings, check in vehicles and run QC.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Use one-time code instead'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Verify code'), findsOneWidget);
    expect(find.text('Resend code'), findsOneWidget);
    expect(find.textContaining('Code sent to'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(LoginView),
      matchesGoldenFile('goldens/auth_otp_sent_mobile.png'),
    );
  });

  testWidgets('registration stays usable at an increased text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loginProvider.overrideWith(_RegisteringNotifier.new)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.8)),
              child: LoginView(onLoginSuccess: () {}, onForgotPassword: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Create a password'), findsOneWidget);
  });

  testWidgets('reset password visual reference', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    final password = TextEditingController();
    addTearDown(password.dispose);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        home: AuthShell(
          title: 'New password',
          subtitle: 'Enter the code and choose a new password.',
          top: const LinearProgressIndicator(value: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('name@company.com'),
              const SizedBox(height: AppDimensions.s16),
              AuthOtpField(onChanged: (_) {}),
              const SizedBox(height: AppDimensions.s16),
              AuthTextField(
                controller: password,
                label: 'New password',
                hint: 'At least 6 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
              const SizedBox(height: AppDimensions.s20),
              AuthPrimaryButton(
                label: 'Reset password',
                icon: Icons.check_rounded,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await expectLater(
      find.byType(AuthShell),
      matchesGoldenFile('goldens/auth_reset_mobile.png'),
    );
  });

  testWidgets('recovery asks for an identifier and offers a route to sign in', (
    tester,
  ) async {
    var backTaps = 0;
    await _pumpForgot(tester, onBackToLogin: () => backTaps++);

    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Email or mobile number'), findsOneWidget);
    expect(find.text('Send recovery code'), findsOneWidget);
    expect(find.text('Step 1 of 2'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    expect(backTaps, 1);
  });

  testWidgets('recovery validates the identifier locally before sending', (
    tester,
  ) async {
    await _pumpForgot(tester);

    await tester.tap(find.text('Send recovery code'));
    await tester.pump();

    expect(find.text('Enter your email or mobile number.'), findsOneWidget);
    expect(find.text('Step 1 of 2'), findsOneWidget);
  });

  testWidgets('recovery surfaces a backend failure as a live notice', (
    tester,
  ) async {
    await _pumpForgot(
      tester,
      overrides: _recoveryOverrides(
        forgotResult: const Failure<void>(
          ValidationException('No account was found for these details.'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('No account was found for these details.'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('recovery replaces transport failures with friendly copy', (
    tester,
  ) async {
    await _pumpForgot(
      tester,
      overrides: _recoveryOverrides(
        forgotResult: const Failure<void>(
          NetworkException('SocketException: Failed host lookup'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('reach Orient'), findsOneWidget);
    expect(find.textContaining('SocketException'), findsNothing);
  });

  testWidgets('recovery surfaces the code-sent state with resend actions', (
    tester,
  ) async {
    await _pumpForgot(tester, overrides: _recoveryOverrides());

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Choose a new password'), findsOneWidget);
    expect(find.textContaining('Recovery code sent to'), findsOneWidget);
    expect(find.text('Recovery code'), findsOneWidget);
    expect(find.text('Resend in 30s'), findsOneWidget);
    expect(find.text('Change email or mobile'), findsOneWidget);

    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('recovery validates the code and password locally', (
    tester,
  ) async {
    await _pumpForgot(tester, overrides: _recoveryOverrides());

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Update password'));
    await tester.pump();

    expect(find.text('Enter the 6-digit recovery code.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('recovery confirms success and returns the user to sign in', (
    tester,
  ) async {
    var backTaps = 0;
    await _pumpForgot(
      tester,
      overrides: _recoveryOverrides(),
      onBackToLogin: () => backTaps++,
    );

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(EditableText).first, '123456');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'secret123');
    await tester.pump();

    await tester.tap(find.text('Update password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Password updated'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);

    await tester.tap(find.text('Back to sign in'));
    expect(backTaps, 1);

    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('recovery stays usable on the smallest supported phone', (
    tester,
  ) async {
    await _pumpForgot(tester, size: const Size(360, 640));

    expect(tester.takeException(), isNull);
    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Send recovery code'), findsOneWidget);
  });

  testWidgets('recovery stays usable at an increased text scale', (
    tester,
  ) async {
    await _pumpForgot(tester, textScaler: const TextScaler.linear(1.8));

    expect(tester.takeException(), isNull);
    expect(find.text('Forgot your password?'), findsOneWidget);
  });

  testWidgets('forgot password mobile visual reference', (tester) async {
    await _pumpForgot(tester);

    await expectLater(
      find.byType(ForgotPasswordView),
      matchesGoldenFile('goldens/auth_forgot_mobile.png'),
    );
  });

  testWidgets('forgot password desktop visual reference', (tester) async {
    await _pumpForgot(tester, size: const Size(1440, 900));

    await expectLater(
      find.byType(ForgotPasswordView),
      matchesGoldenFile('goldens/auth_forgot_desktop.png'),
    );
  });

  testWidgets('recovery sent state visual reference', (tester) async {
    await _pumpForgot(tester, overrides: _recoveryOverrides());

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(ForgotPasswordView),
      matchesGoldenFile('goldens/auth_forgot_sent_mobile.png'),
    );

    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('recovery success state visual reference', (tester) async {
    await _pumpForgot(tester, overrides: _recoveryOverrides());

    await tester.enterText(find.byType(TextField), 'name@company.com');
    await tester.tap(find.text('Send recovery code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(EditableText).first, '123456');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'secret123');
    await tester.pump();

    await tester.tap(find.text('Update password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(ForgotPasswordView),
      matchesGoldenFile('goldens/auth_forgot_success_mobile.png'),
    );

    await tester.pump(const Duration(seconds: 31));
  });

  testWidgets('session loading view exposes progress semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(BrandConfig.orient),
        home: const AuthLoadingView(),
      ),
    );

    expect(find.text('Restoring your session'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.liveRegion == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('legacy phone and OTP contracts remain visually aligned', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PhoneInputField(error: null, onChanged: (_) {}),
                const SizedBox(height: AppDimensions.s32),
                OtpInputField(
                  phone: '+971 50 123 4567',
                  error: null,
                  isLoading: false,
                  resendCooldown: 0,
                  onResend: () {},
                  onChangePhone: () {},
                  onOtpChanged: (_) {},
                  onVerify: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/auth_controls_mobile.png'),
    );
  });
}

Future<void> _expectLoginGolden(
  WidgetTester tester, {
  required Size size,
  required String fileName,
}) async {
  await _pumpLogin(tester, size);
  await expectLater(find.byType(LoginView), matchesGoldenFile(fileName));
}

Future<void> _pumpLogin(
  WidgetTester tester,
  Size size, {
  bool allowRegistration = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        home: LoginView(
          onLoginSuccess: () {},
          onForgotPassword: () {},
          allowRegistration: allowRegistration,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpForgot(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  List<Override> overrides = const [],
  TextScaler textScaler = TextScaler.noScaling,
  VoidCallback? onBackToLogin,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: ForgotPasswordView(
          onBackToLogin: onBackToLogin ?? () {},
          appName: 'Orient Staff App',
          intendedUsers: 'For advisors, technicians, and supervisors',
          appPurpose: 'Confirm bookings, check in vehicles and run QC.',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Stubs the two recovery use cases so the sent and success states can be
/// exercised without touching the network.
List<Override> _recoveryOverrides({
  Result<void>? forgotResult,
  Result<void>? resetResult,
}) {
  final repository = _FakeAuthRepository(
    forgotResult: forgotResult,
    resetResult: resetResult,
  );
  return [
    forgotPasswordProvider.overrideWithValue(ForgotPassword(repository)),
    resetPasswordProvider.overrideWithValue(ResetPassword(repository)),
  ];
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.forgotResult, this.resetResult});

  final Result<void>? forgotResult;
  final Result<void>? resetResult;

  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) async => forgotResult ?? const Success<void>(null);

  @override
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  ) async => resetResult ?? const Success<void>(null);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not stubbed');
}

/// Renders the one-time-code verification step without going through the
/// network so the sent state can be reviewed visually.
class _OtpSentNotifier extends LoginNotifier {
  @override
  LoginState build() => const LoginState(
    method: AuthMethod.email,
    email: 'name@company.com',
    otpSent: true,
  );

  @override
  void reset() {}
}

/// Renders the registration step without going through the network so the
/// layout can be reviewed at large text scales.
class _RegisteringNotifier extends LoginNotifier {
  @override
  LoginState build() => const LoginState(isRegistering: true);
}

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

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
}
