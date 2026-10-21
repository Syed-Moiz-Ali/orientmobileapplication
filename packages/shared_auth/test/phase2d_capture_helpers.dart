// Phase-2d AFTER-capture shared harness (capture-only support file: no tests,
// no production code touched).
//
// Conventions copied from the phase-1 baseline harness
// (`apps/customer_app/test/baseline_capture_test.dart`) and the 2b fakes
// (`test_helpers.dart`):
// - Real bundled fonts (Plus Jakarta Sans + IBM Plex Sans Arabic) plus the
//   real MaterialIcons via FontLoader in setUpAll (never file I/O inside a
//   testWidgets body).
// - `debugShowCheckedModeBanner: false`; `debugDisableShadows = false`
//   restored INLINE at the end of each capture (framework invariant check runs
//   before addTearDown, so restoring in a tearDown is too late).
// - RTL: locale ar + `SharedAuthLocalizations.localizationsDelegates` (which
//   already bundles the global Material/Widgets/Cupertino delegates) +
//   `AppTheme.light/dark(brand, locale: ar)`.
// - Explicit text scale through a MediaQuery wrapper (linear 1.0 / 1.3).
// - 2b fakes (`FakeAuthRepository` / `FakeTokenStorage`) drive deterministic
//   states (offline/500 failures, otpSent, cooldown).
//
// Per-app hook strings are the English fallbacks from each app's router (what
// the shared views receive when the app localizations are absent); customer
// alone enables registration, matching its router.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Full font load for pixel captures: Latin + Arabic bundles plus the real
/// MaterialIcons (SDK path walk-up). Call once per file via setUpAll.
Future<void> loadCaptureFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(Uint8List.fromList(bytes))),
      );
    }
    await loader.load();
  }

  const root = '../shared_core/assets/fonts';
  await load('packages/shared_core/Plus Jakarta Sans', [
    '$root/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Medium.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-SemiBold.ttf',
    '$root/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
  ]);

  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(candidate.readAsBytesSync())));
      await loader.load();
      return;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

/// Per-app hook strings (= router English fallbacks).
class CaptureApp {
  final String id;
  final String appName;
  final String intendedUsers;
  final String appPurpose;
  final bool allowRegistration;

  const CaptureApp({
    required this.id,
    required this.appName,
    required this.intendedUsers,
    required this.appPurpose,
    required this.allowRegistration,
  });
}

const captureCustomer = CaptureApp(
  id: 'customer',
  appName: 'Orient Customer App',
  intendedUsers: 'For vehicle owners and service customers',
  appPurpose:
      'Book service, track your vehicle, review estimates, approve repairs, and view invoices.',
  allowRegistration: true,
);

const captureStaff = CaptureApp(
  id: 'staff',
  appName: 'Orient Staff App',
  intendedUsers: 'For advisors, technicians, and supervisors',
  appPurpose:
      'Confirm bookings, check in vehicles, run inspections, assign repair work, update tasks, and complete QC.',
  allowRegistration: false,
);

const captureOwner = CaptureApp(
  id: 'owner',
  appName: 'Orient Owner App',
  intendedUsers: 'For workshop owners and admins',
  appPurpose:
      'Monitor branches, job cards, staff, revenue, approvals, inventory, and workshop performance.',
  allowRegistration: false,
);

const captureCrm = CaptureApp(
  id: 'crm',
  appName: 'Orient CRM App',
  intendedUsers: 'For CRM and customer support users',
  appPurpose:
      'Manage customer follow-ups, service communication, leads, reminders, and support activity.',
  allowRegistration: false,
);

/// Viewport presets. Phone 360x800 and small 320x568 are logical sizes at
/// fixed pixel ratios; tablet is 768x1024 portrait.
const phoneSize = Size(1080, 2400);
const phoneDpr = 3.0;
const smallSize = Size(640, 1136);
const smallDpr = 2.0;
const tabletSize = Size(1536, 2048);
const tabletDpr = 2.0;

/// `<app>_<screen>_<state>_<theme>_<scale>_<locale>_<width>x<height>.png`.
String afterName({
  required String app,
  required String screen,
  required String state,
  required bool dark,
  required double textScale,
  required Locale locale,
  required int w,
  required int h,
}) {
  final scale = textScale.toStringAsFixed(1);
  final theme = dark ? 'dark' : 'light';
  return '${app}_${screen}_${state}_${theme}_${scale}_${locale.languageCode}_${w}x$h.png';
}

/// Locale bundle for finder text (mirrors the view's resolved copy).
SharedAuthLocalizations bundleFor(Locale locale) =>
    locale.languageCode == 'ar' ? arAuthL10n() : enAuthL10n();

/// The auth column scrollable: the only vertical [Scrollable] in the tree.
Finder authScroll() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axis == Axis.vertical,
    );

/// Brings [finder] on screen inside the auth column (no-op when visible).
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: authScroll());
  await tester.pump();
}

ThemeData _captureTheme(bool dark, Locale locale) => dark
    ? AppTheme.dark(BrandConfig.orient, locale: locale)
    : AppTheme.light(BrandConfig.orient, locale: locale);

Widget _captureRoot({
  required WidgetTester tester,
  required double textScale,
  required Widget home,
}) {
  return MediaQuery(
    data: MediaQueryData.fromView(
      tester.view,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: home,
  );
}

/// Pumps a [LoginView] with the per-app hooks on an exact viewport.
Future<ProviderContainer> pumpCaptureLogin(
  WidgetTester tester, {
  required CaptureApp app,
  bool dark = false,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size physical = phoneSize,
  double dpr = phoneDpr,
  FakeAuthRepository? repo,
}) async {
  debugDisableShadows = false;
  tester.view.physicalSize = physical;
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
  final theme = _captureTheme(dark, locale);
  final resolvedRepo = repo ?? FakeAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(resolvedRepo),
        tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        localeProvider.overrideWith((ref) => LocaleController(locale)),
      ],
      child: _captureRoot(
        tester: tester,
        textScale: textScale,
        home: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: SharedAuthLocalizations.supportedLocales,
          localizationsDelegates:
              SharedAuthLocalizations.localizationsDelegates,
          theme: theme,
          darkTheme: theme,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: LoginView(
            onLoginSuccess: () {},
            // Every production router (customer/staff/owner/CRM) supplies
            // onForgotPassword (-> /forgot-password); the shared link
            // renders only when a handler exists, so captures must supply
            // one too — otherwise the goldens falsely show no recovery path
            // (phase-2 F-2). Production wiring is unchanged.
            onForgotPassword: () {},
            allowRegistration: app.allowRegistration,
            appName: app.appName,
            appPurpose: app.appPurpose,
            intendedUsers: app.intendedUsers,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return ProviderScope.containerOf(tester.element(find.byType(LoginView)));
}

/// Pumps a [ForgotPasswordView] with the per-app hooks on an exact viewport.
Future<ProviderContainer> pumpCaptureForgot(
  WidgetTester tester, {
  required CaptureApp app,
  bool dark = false,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size physical = phoneSize,
  double dpr = phoneDpr,
  FakeAuthRepository? repo,
}) async {
  debugDisableShadows = false;
  tester.view.physicalSize = physical;
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
  final theme = _captureTheme(dark, locale);
  final resolvedRepo = repo ?? FakeAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(resolvedRepo),
        tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        localeProvider.overrideWith((ref) => LocaleController(locale)),
      ],
      child: _captureRoot(
        tester: tester,
        textScale: textScale,
        home: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: SharedAuthLocalizations.supportedLocales,
          localizationsDelegates:
              SharedAuthLocalizations.localizationsDelegates,
          theme: theme,
          darkTheme: theme,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: ForgotPasswordView(
            onBackToLogin: () {},
            appName: app.appName,
            appPurpose: app.appPurpose,
            intendedUsers: app.intendedUsers,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return ProviderScope.containerOf(
    tester.element(find.byType(ForgotPasswordView)),
  );
}

/// Pumps the branded navy splash on an exact viewport.
Future<void> pumpCaptureSplash(
  WidgetTester tester, {
  bool dark = false,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size physical = phoneSize,
  double dpr = phoneDpr,
}) async {
  debugDisableShadows = false;
  tester.view.physicalSize = physical;
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
  final theme = _captureTheme(dark, locale);
  await tester.pumpWidget(
    _captureRoot(
      tester: tester,
      textScale: textScale,
      home: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: SharedAuthLocalizations.supportedLocales,
        localizationsDelegates:
            SharedAuthLocalizations.localizationsDelegates,
        theme: theme,
        darkTheme: theme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: const AuthLoadingView(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Writes the AFTER golden and restores shadows inline.
Future<void> captureAfter(WidgetTester tester, String fileName) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(
      '../../../docs/ui-redesign/baseline/after-phase-2/$fileName',
    ),
  );
  debugDisableShadows = true;
  expect(tester.takeException(), isNull);
}

/// Switches the login form to code mode and retires the outgoing form.
Future<void> switchToCodeMode(WidgetTester tester, Locale locale) async {
  final t = bundleFor(locale);
  await tapAndSettleMode(tester, find.text(t.authMethodCode));
}

/// Sends a login code to a valid phone number (ends on the verify step with
/// the in-flow success banner up and the resend cooldown at 30s).
///
/// The entrance animation needs ~800ms of fake time before pixels are fully
/// settled (finder assertions pass at +300ms, but the golden would catch
/// the transition mid-slide).
Future<void> sendLoginCode(WidgetTester tester, Locale locale) async {
  final t = bundleFor(locale);
  await tester.enterText(find.byType(TextField).first, '501234567');
  await tester.pump();
  final cta = find.text(t.loginActionSendCode);
  await reveal(tester, cta);
  await tester.tap(cta);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 500));
}

/// Opens register mode (customer builds) and retires the outgoing form.
Future<void> openRegisterMode(WidgetTester tester, Locale locale) async {
  final t = bundleFor(locale);
  final toggle = find.text(t.loginNewCustomer);
  await reveal(tester, toggle);
  await tapAndSettleMode(tester, toggle);
}

/// Completes the forgot identifier step (ends on the reset stage with the
/// in-flow code-sent banner up and the resend cooldown at 30s).
///
/// Same ~800ms settle as [sendLoginCode]: the stage entrance must finish
/// before pixels are captured.
Future<void> reachForgotReset(WidgetTester tester, Locale locale) async {
  final t = bundleFor(locale);
  await tester.enterText(find.byType(TextField).first, '501234567');
  await tester.pump();
  final cta = find.text(t.forgotActionSendRecoveryCode);
  await reveal(tester, cta);
  await tester.tap(cta);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 500));
}

/// Completes the forgot reset step (ends on the warm success stage).
Future<void> reachForgotDone(WidgetTester tester, Locale locale) async {
  final t = bundleFor(locale);
  await reachForgotReset(tester, locale);
  await tester.enterText(find.byType(EditableText).first, '123456');
  await tester.enterText(find.byType(TextField).first, 'newpass123');
  await tester.pump();
  final cta = find.text(t.forgotActionUpdatePassword);
  await reveal(tester, cta);
  await tester.tap(cta);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
