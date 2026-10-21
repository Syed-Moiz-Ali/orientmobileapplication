// Phase-2d AFTER captures: supervisor one-screen login (capture-only).
//
// Staff-local screen, so it lives under apps/staff_app/test (same reason as
// the 2b/2c supervisor characterization). One screen (identifier + password
// behind a single sign-in CTA) x (LTR en, RTL ar) x (text scale 1.0, 1.3) on
// phone 360x800; plus empty-submit banner, loading CTA and offline banner +
// retry states (en, 1.0, 360x800), plus small 320x568 one-screen idle. Staff
// ships the light theme only.
//
// Conventions copied from the phase-1 baseline harness: real bundled fonts
// (Plus Jakarta Sans + IBM Plex Sans Arabic + MaterialIcons) in setUpAll,
// `debugShowCheckedModeBanner: false`, `debugDisableShadows = false`
// restored INLINE at the end of each capture.
//
// Tagged baseline: excluded from `melos run test` (see melos.yaml).
// Generate: flutter test --tags baseline --update-goldens
//             test/phase2d_supervisor_capture_test.dart   (from apps/staff_app)
// Compare:  flutter test --tags baseline test/phase2d_supervisor_capture_test.dart
@Tags(['baseline'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/supervisor_login_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Full font load for pixel captures (same families as the phase-1 harness).
Future<void> loadSupervisorCaptureFonts() async {
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

  const root = '../../packages/shared_core/assets/fonts';
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

/// In-memory [TokenStorage] so the real [AuthNotifier] runs without the
/// platform secure-storage channel.
class CaptureTokenStorage extends TokenStorage {
  CaptureTokenStorage() : super(const FlutterSecureStorage());

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

/// Controllable [AuthRepository] double for the password boundary.
class CaptureAuthRepository implements AuthRepository {
  int loginCalls = 0;

  Future<Result<AuthResult>> Function(String email, String phone, String password)?
      loginHandler;

  @override
  Future<Result<void>> sendOtp(String phone) async => Success<void>(null);

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async =>
      Success(
        const AuthResult(role: UserRole.supervisor, token: 'test-token'),
      );

  @override
  Future<Result<void>> sendEmailOtp(String email) async =>
      Success<void>(null);

  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) async =>
      Success(
        const AuthResult(role: UserRole.supervisor, token: 'test-token'),
      );

  @override
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async =>
      Success(
        const AuthResult(role: UserRole.supervisor, token: 'test-token'),
      );

  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) async {
    loginCalls++;
    return loginHandler?.call(email, phone, password) ??
        Success(
          const AuthResult(role: UserRole.supervisor, token: 'test-token'),
        );
  }

  @override
  Future<Result<AuthResult>> refreshToken(String refreshToken) async =>
      Success(
        const AuthResult(role: UserRole.supervisor, token: 'test-token'),
      );

  @override
  Future<Result<void>> logout() async => Success<void>(null);

  @override
  Future<Result<void>> forgotPassword(
    String type,
    String phone,
    String email,
  ) async =>
      Success<void>(null);

  @override
  Future<Result<void>> resetPassword(
    String type,
    String phone,
    String email,
    String otp,
    String newPassword,
  ) async =>
      Success<void>(null);

  @override
  List<RoleConfig> getRoleConfigs() => const [];
}

/// Pumps the real [SupervisorLoginView] on an exact viewport.
Future<void> pumpSupervisorCapture(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Size physical = const Size(1080, 2400),
  double dpr = 3.0,
  CaptureAuthRepository? repo,
}) async {
  debugDisableShadows = false;
  tester.view.physicalSize = physical;
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          repo ?? CaptureAuthRepository(),
        ),
        tokenStorageProvider.overrideWithValue(CaptureTokenStorage()),
      ],
      child: MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: StaffLocalizations.supportedLocales,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          home: const SupervisorLoginView(),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> captureSupervisor(WidgetTester tester, String fileName) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(
      '../../../docs/ui-redesign/baseline/after-phase-2/$fileName',
    ),
  );
  debugDisableShadows = true;
  expect(tester.takeException(), isNull);
}

String _supervisorName({
  required String step,
  required String state,
  required double textScale,
  required Locale locale,
  required int w,
  required int h,
}) =>
    'staff_supervisor_${step}_${state}_light_${textScale.toStringAsFixed(1)}_${locale.languageCode}_${w}x$h.png';

/// Enters [identifier] + [password] on the one-screen supervisor form.
/// Fires ZERO API calls by itself — the submit happens when the caller taps
/// the CTA.
Future<void> fillSupervisorCaptureForm(
  WidgetTester tester, {
  String identifier = 'supervisor',
  String password = 'secret123',
}) async {
  await tester.enterText(find.byType(TextField).at(0), identifier);
  await tester.pump();
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.pump();
}

void main() {
  setUpAll(loadSupervisorCaptureFonts);

  group('supervisor one-screen idle 360x800', () {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'staff supervisor one-screen idle light $scale ${locale.languageCode} 360x800',
          (tester) async {
            await pumpSupervisorCapture(
              tester,
              locale: locale,
              textScale: scale,
            );
            // One-screen headline comes from the staff bundle; both fields
            // share the single screen with no back arrow.
            expect(
              find.text(
                lookupStaffLocalizations(locale).supervisorLoginTitle,
              ),
              findsOneWidget,
            );
            expect(find.byType(AppInputField), findsNWidgets(2));
            expect(find.byType(AppBanner), findsNothing);
            await captureSupervisor(
              tester,
              _supervisorName(
                step: 'one_screen',
                state: 'idle',
                textScale: scale,
                locale: locale,
                w: 360,
                h: 800,
              ),
            );
          },
        );
      }
    }
  });

  group('supervisor one-screen states 360x800', () {
    testWidgets('staff supervisor one-screen field-error light 1.0 en 360x800',
        (tester) async {
      const locale = Locale('en');
      await pumpSupervisorCapture(tester);
      // Empty submit: the non-empty gate raises the banner (bidi-isolated,
      // so match a substring instead of the exact copy).
      await tester.tap(find.byType(AppPillButton));
      await tester.pump();
      expect(find.textContaining('Enter username'), findsWidgets);
      await captureSupervisor(
        tester,
        _supervisorName(
          step: 'one_screen',
          state: 'field_error',
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });

    testWidgets('staff supervisor one-screen loading light 1.0 en 360x800',
        (tester) async {
      const locale = Locale('en');
      final gate = Completer<Result<AuthResult>>();
      final repo = CaptureAuthRepository()
        ..loginHandler = (_, __, ___) => gate.future;
      await pumpSupervisorCapture(tester, repo: repo);
      await fillSupervisorCaptureForm(tester);
      await tester.tap(find.byType(AppPillButton));
      await tester.pump();
      await captureSupervisor(
        tester,
        _supervisorName(
          step: 'one_screen',
          state: 'loading',
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
      gate.complete(
        const Success(
          AuthResult(role: UserRole.supervisor, token: 'tok'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('staff supervisor one-screen form-error light 1.0 en 360x800',
        (tester) async {
      const locale = Locale('en');
      final repo = CaptureAuthRepository()
        ..loginHandler = (_, __, ___) async => const Failure(
              NetworkException('SocketException: failed host lookup'),
            );
      await pumpSupervisorCapture(tester, repo: repo);
      await fillSupervisorCaptureForm(tester);
      await tester.tap(find.byType(AppPillButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await captureSupervisor(
        tester,
        _supervisorName(
          step: 'one_screen',
          state: 'form_error',
          textScale: 1.0,
          locale: locale,
          w: 360,
          h: 800,
        ),
      );
    });
  });

  group('supervisor one-screen small 320x568', () {
    testWidgets('staff supervisor one-screen idle light 1.0 en 320x568',
        (tester) async {
      const locale = Locale('en');
      await pumpSupervisorCapture(
        tester,
        physical: const Size(640, 1136),
        dpr: 2.0,
      );
      await captureSupervisor(
        tester,
        _supervisorName(
          step: 'one_screen',
          state: 'idle',
          textScale: 1.0,
          locale: locale,
          w: 320,
          h: 568,
        ),
      );
    });
  });
}
