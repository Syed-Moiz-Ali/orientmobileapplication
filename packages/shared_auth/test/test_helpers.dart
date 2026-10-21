// Shared harness for the phase-2b characterization tests.
//
// Rules followed here (mirrors packages/shared_core/test/ helpers):
// - Real fonts via FontLoader from the SDK MaterialIcons path in setUpAll
//   (never inside a testWidgets body, never file I/O under FakeAsync).
// - Every pump uses debugShowCheckedModeBanner: false.
// - RTL/ar coverage runs under locale `ar` with the global
//   Material/Widgets/Cupertino delegates (via
//   SharedAuthLocalizations.localizationsDelegates).
// - No golden files, no network. Backend seams are faked by overriding
//   [authRepositoryProvider]; [tokenStorageProvider] is overridden with an
//   in-memory fake so the REAL AuthNotifier/LoginNotifier logic runs.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Loads the real MaterialIcons font so icon-heavy auth screens render text
/// layout faithfully. Call once per file via `setUpAll(loadAuthTestFonts)`.
Future<void> loadAuthTestFonts() async {
  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(ByteData.sublistView(candidate.readAsBytesSync())),
        );
      await loader.load();
      return;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

/// English copy bundle (mirrors what the views resolve for locale `en`).
SharedAuthLocalizations enAuthL10n() =>
    lookupSharedAuthLocalizations(const Locale('en'));

/// Arabic copy bundle (mirrors what the views resolve for locale `ar`).
SharedAuthLocalizations arAuthL10n() =>
    lookupSharedAuthLocalizations(const Locale('ar'));

/// In-memory [TokenStorage] so the real [AuthNotifier] runs without the
/// platform secure-storage channel.
class FakeTokenStorage extends TokenStorage {
  FakeTokenStorage() : super(const FlutterSecureStorage());

  final Map<String, String> _mem = {};

  @override
  Future<void> save({
    required String token,
    String? refreshToken,
    required String role,
  }) async {
    _mem['auth_token'] = token;
    if (refreshToken != null) _mem['auth_refresh_token'] = refreshToken;
    _mem['auth_role'] = role;
  }

  @override
  Future<String?> getToken() async => _mem['auth_token'];

  @override
  Future<String?> getRefreshToken() async => _mem['auth_refresh_token'];

  @override
  Future<String?> getRole() async => _mem['auth_role'];

  @override
  Future<void> setMetadata(String key, String value) async {
    _mem['meta_$key'] = value;
  }

  @override
  Future<String?> getMetadata(String key) async => _mem['meta_$key'];

  @override
  Future<void> updateToken(String token) async {
    _mem['auth_token'] = token;
  }

  @override
  Future<void> clearAll() async => _mem.clear();
}

/// Controllable [AuthRepository] double. Every seam succeeds by default;
/// assign a handler to fail a single boundary with a typed [AppException].
class FakeAuthRepository implements AuthRepository {
  int sendOtpCalls = 0;
  int verifyOtpCalls = 0;
  int sendEmailOtpCalls = 0;
  int verifyEmailOtpCalls = 0;
  int registerCalls = 0;
  int loginCalls = 0;
  int forgotCalls = 0;
  int resetCalls = 0;

  Future<Result<void>> Function(String phone)? sendOtpHandler;
  Future<Result<AuthResult>> Function(String phone, String otp)?
      verifyOtpHandler;
  Future<Result<void>> Function(String email)? sendEmailOtpHandler;
  Future<Result<AuthResult>> Function(String email, String otp)?
      verifyEmailOtpHandler;
  Future<Result<AuthResult>> Function(
    String name,
    String email,
    String phone,
    String password,
    String role,
  )? registerHandler;
  Future<Result<AuthResult>> Function(
    String email,
    String phone,
    String password,
  )? loginHandler;
  Future<Result<void>> Function(String type, String phone, String email)?
      forgotHandler;
  Future<Result<void>> Function(
    String type,
    String phone,
    String email,
    String otp,
    String password,
  )? resetHandler;

  static AuthResult authResult() => const AuthResult(
        role: UserRole.customer,
        token: 'test-token',
        refreshToken: 'test-refresh',
      );

  @override
  Future<Result<void>> sendOtp(String phone) async {
    sendOtpCalls++;
    return sendOtpHandler?.call(phone) ?? Success<void>(null);
  }

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async {
    verifyOtpCalls++;
    return verifyOtpHandler?.call(phone, otp) ?? Success(authResult());
  }

  @override
  Future<Result<void>> sendEmailOtp(String email) async {
    sendEmailOtpCalls++;
    return sendEmailOtpHandler?.call(email) ?? Success<void>(null);
  }

  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) async {
    verifyEmailOtpCalls++;
    return verifyEmailOtpHandler?.call(email, otp) ??
        Success(authResult());
  }

  @override
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    registerCalls++;
    return registerHandler?.call(name, email, phone, password, role) ??
        Success(authResult());
  }

  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) async {
    loginCalls++;
    return loginHandler?.call(email, phone, password) ??
        Success(authResult());
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async =>
      Success(authResult());

  @override
  Future<Result<void>> logout() async => Success<void>(null);

  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) async {
    forgotCalls++;
    return forgotHandler?.call(type, phone, email) ?? Success<void>(null);
  }

  @override
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  ) async {
    resetCalls++;
    return resetHandler?.call(type, phone, email, otp, newPassword) ??
        Success<void>(null);
  }

  @override
  List<RoleConfig> getRoleConfigs() => const [];
}

/// Gives the test surface a tall phone viewport (390x1200 logical) so the full
/// auth column — lockup, fields, CTA, footer — fits without scrolling.
/// Must run inside the test body (FakeAsync-safe: no I/O, just viewport).
void useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 3600);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// Taps a mode-switch control and lets the [AnimatedSwitcher] retire the
/// outgoing form: one frame to process the tap, then 500ms (past the 220ms
/// standard token) so stale fields leave the tree before finders run.
Future<void> tapAndSettleMode(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Lets a step-flow transition retire the outgoing step: one frame to process
/// the tap, then 500ms (past the 220ms [AppMotion] standard token) so stale
/// fields leave the tree before finders run.
Future<void> tapAndSettleStep(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Enters [identifier] on Step 1 ("Log in or sign up") and taps Continue.
/// Ends on the password step ("Welcome back"). Fires ZERO API calls — the
/// transition is local validation + setter sync only.
Future<void> reachPasswordStep(
  WidgetTester tester,
  String identifier, {
  SharedAuthLocalizations? l10n,
}) async {
  final t = l10n ?? enAuthL10n();
  await tester.enterText(find.byType(TextField).first, identifier);
  await tester.pump();
  await tapAndSettleStep(tester, find.text(t.loginActionContinue));
}

/// Enters [identifier] on Step 1 and taps the "Send me a code instead" alt
/// row. Ends on the code-confirm step (default send handlers succeed, 30s
/// cooldown running).
Future<void> reachCodeConfirm(
  WidgetTester tester,
  String identifier, {
  SharedAuthLocalizations? l10n,
}) async {
  final t = l10n ?? enAuthL10n();
  await tester.enterText(find.byType(TextField).first, identifier);
  await tester.pump();
  await tester.tap(find.text(t.loginStepUseCodeInstead));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Opens the register flow (customer builds) and walks R1 (name) + R2
/// (contact), landing on R3 (password). Fires ZERO API calls — R1/R2 Continue
/// handlers are local validation only. The caller enters the password on R3
/// and taps the create-account CTA.
Future<void> reachRegisterR3(
  WidgetTester tester,
  String name,
  String contact, {
  SharedAuthLocalizations? l10n,
}) async {
  final t = l10n ?? enAuthL10n();
  await tapAndSettleStep(tester, find.text(t.loginStepCreateAccountRow));
  await tester.enterText(find.byType(TextField).first, name);
  await tester.pump();
  await tapAndSettleStep(tester, find.text(t.loginActionContinue));
  await tester.enterText(find.byType(TextField).first, contact);
  await tester.pump();
  await tapAndSettleStep(tester, find.text(t.loginActionContinue));
}

/// Drains the forgot view's 30s resend loop so no fake-async timer is pending
/// at teardown. Call AFTER asserting the START state — the suite never waits
/// out the loop for behavior, this is pure cleanup (the view's dispose only
/// retires the loop generation; the scheduled tick must still elapse).
Future<void> drainForgotCooldown(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 31));
}

/// Pumps a [LoginView] with the real notifiers and faked boundaries.
/// Returns the [ProviderContainer] so tests can drive [LoginNotifier]
/// (e.g. `setOtp`) and read [LoginState] directly.
Future<ProviderContainer> pumpLoginView(
  WidgetTester tester, {
  FakeAuthRepository? repo,
  FakeTokenStorage? storage,
  Locale? locale,
  bool allowRegistration = false,
  VoidCallback? onLoginSuccess,
  VoidCallback? onForgotPassword,
}) async {
  final resolvedRepo = repo ?? FakeAuthRepository();
  final resolvedStorage = storage ?? FakeTokenStorage();
  useTallSurface(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(resolvedRepo),
        tokenStorageProvider.overrideWithValue(resolvedStorage),
        if (locale != null)
          localeProvider.overrideWith((ref) => LocaleController(locale)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: SharedAuthLocalizations.supportedLocales,
        localizationsDelegates:
            SharedAuthLocalizations.localizationsDelegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: LoginView(
          onLoginSuccess: onLoginSuccess ?? () {},
          onForgotPassword: onForgotPassword,
          allowRegistration: allowRegistration,
        ),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(LoginView)));
}

/// Pumps a [ForgotPasswordView] with the real view logic and faked
/// use-case boundaries.
Future<ProviderContainer> pumpForgotView(
  WidgetTester tester, {
  FakeAuthRepository? repo,
  FakeTokenStorage? storage,
  Locale? locale,
  VoidCallback? onBackToLogin,
}) async {
  final resolvedRepo = repo ?? FakeAuthRepository();
  final resolvedStorage = storage ?? FakeTokenStorage();
  useTallSurface(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(resolvedRepo),
        tokenStorageProvider.overrideWithValue(resolvedStorage),
        if (locale != null)
          localeProvider.overrideWith((ref) => LocaleController(locale)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: SharedAuthLocalizations.supportedLocales,
        localizationsDelegates:
            SharedAuthLocalizations.localizationsDelegates,
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: ForgotPasswordView(onBackToLogin: onBackToLogin ?? () {}),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(ForgotPasswordView)),
  );
}

/// Masked phone tail used by OTP destination assertions (shared so every
/// step test pins the same never-raw-number copy). Mirrors the view's
/// masking; matched with containing-finders since the banner wraps copy
/// in bidi isolates.
String maskedPhoneTail() => '••• ••• 567';
