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

  testWidgets('forgot password mobile visual reference', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient),
          home: ForgotPasswordView(onBackToLogin: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ForgotPasswordView),
      matchesGoldenFile('goldens/auth_forgot_mobile.png'),
    );
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

Future<void> _pumpLogin(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        home: LoginView(onLoginSuccess: () {}, onForgotPassword: () {}),
      ),
    ),
  );
  await tester.pumpAndSettle();
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
