// Supervisor login: one-screen characterization (staff-local screen).
//
// Per `packages/shared_auth/test/supervisor_characterization_plan.md` these
// tests live under `apps/staff_app/test/` (staff ARB access) and pin the ONE
// screen: identifier + password collecting into the existing `login()` call.
// Every behavior assertion from the combined form is kept (validation,
// single-submit, mapped copy, no raw text, persisted session, forgot route,
// edit-clears-error); structural pins cover the single screen (no step state,
// no back arrow, both fields visible immediately). Logic is untouched — only
// presentation changed.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/supervisor_login_view.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Loads the real MaterialIcons font (SDK path, in setUpAll — never file I/O
/// inside a test body).
Future<void> loadStaffTestFonts() async {
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

/// Controllable [AuthRepository] double: every seam succeeds by default;
/// assign [loginHandler] to fail the password boundary.
class FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;

  Future<Result<AuthResult>> Function(String email, String phone, String password)?
      loginHandler;

  static AuthResult authResult() => const AuthResult(
        role: UserRole.supervisor,
        token: 'test-token',
        refreshToken: 'test-refresh',
      );

  @override
  Future<Result<void>> sendOtp(String phone) async => Success<void>(null);

  @override
  Future<Result<AuthResult>> verifyOtp(String phone, String otp) async =>
      Success(authResult());

  @override
  Future<Result<void>> sendEmailOtp(String email) async =>
      Success<void>(null);

  @override
  Future<Result<AuthResult>> verifyEmailOtp(String email, String otp) async =>
      Success(authResult());

  @override
  Future<Result<AuthResult>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async =>
      Success(authResult());

  @override
  Future<Result<AuthResult>> loginWithPassword(
    String email,
    String phone,
    String password,
  ) async {
    loginCalls++;
    return loginHandler?.call(email, phone, password) ?? Success(authResult());
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

/// Pumps the real [SupervisorLoginView] with faked boundaries on a tall phone
/// viewport so the full column fits without scrolling.
Future<ProviderContainer> pumpSupervisor(
  WidgetTester tester, {
  FakeAuthRepository? repo,
  FakeTokenStorage? storage,
  Locale? locale,
  GoRouter? router,
}) async {
  final resolvedRepo = repo ?? FakeAuthRepository();
  final resolvedStorage = storage ?? FakeTokenStorage();
  tester.view.physicalSize = const Size(1170, 3600);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  late ProviderContainer container;
  final app = ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(resolvedRepo),
      tokenStorageProvider.overrideWithValue(resolvedStorage),
    ],
    child: router == null
        ? MaterialApp(
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
            theme: AppTheme.light(BrandConfig.orient),
            home: const SupervisorLoginView(),
          )
        : MaterialApp.router(
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
            theme: AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          ),
  );
  await tester.pumpWidget(app);
  await tester.pump();
  container = ProviderScope.containerOf(
    tester.element(find.byType(SupervisorLoginView)),
  );
  return container;
}

/// Enters [identifier] + [password] on the one-screen form. Fires ZERO API
/// calls by itself — the submit happens when the caller taps the CTA.
Future<void> fillSupervisorForm(
  WidgetTester tester,
  String identifier,
  String password,
) async {
  await tester.enterText(find.byType(TextField).at(0), identifier);
  await tester.pump();
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.pump();
}

/// Fills both fields, taps the CTA, and settles the login round-trip.
Future<void> submitSupervisorForm(
  WidgetTester tester,
  String identifier,
  String password,
) async {
  await fillSupervisorForm(tester, identifier, password);
  await tester.tap(find.byType(AppPillButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadStaffTestFonts);

  group('supervisor one-screen structure', () {
    testWidgets('single screen shows both fields, one CTA, no back arrow',
        (tester) async {
      await pumpSupervisor(tester);
      final t = lookupSharedAuthLocalizations(const Locale('en'));

      expect(find.byType(AppStepScaffold), findsOneWidget);
      expect(find.byType(AuthShell), findsNothing);
      // Both fields share the single screen: identifier + password.
      expect(find.byType(AppInputField), findsNWidgets(2));
      expect(
        tester
            .widgetList<AppInputField>(find.byType(AppInputField))
            .first
            .forceLtr,
        isTrue,
      );
      expect(find.text(t.loginFieldPassword), findsOneWidget);
      expect(find.text(t.loginActionForgotPassword), findsOneWidget);
      // One CTA (sign-in), no back arrow, only the password toggle icon.
      expect(find.byType(AppPillButton), findsOneWidget);
      expect(
        find.widgetWithText(AppPillButton, t.forgotSignIn),
        findsOneWidget,
      );
      expect(find.byType(AppIconButton), findsNWidgets(1));
      // Single password-managergable group: username + password together.
      expect(find.byType(AutofillGroup), findsOneWidget);
      final fields = tester.widgetList<AppInputField>(
        find.byType(AppInputField),
      );
      expect(
        fields.elementAt(0).autofillHints,
        contains(AutofillHints.username),
      );
      expect(
        fields.elementAt(1).autofillHints,
        contains(AutofillHints.password),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('progress exposes step 1 of 1 semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpSupervisor(tester);
      final s = lookupStaffLocalizations(const Locale('en'));

      expect(
        find.bySemanticsLabel(s.advisorIntakeWizardStepOf(1, 1)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    testWidgets('focus order is identifier then password', (tester) async {
      final t = lookupSharedAuthLocalizations(const Locale('en'));
      await pumpSupervisor(tester);

      final fields = tester.widgetList<AppInputField>(
        find.byType(AppInputField),
      );
      final identifier = fields.elementAt(0);
      final password = fields.elementAt(1);
      expect(identifier.textInputAction, TextInputAction.next);
      expect(password.textInputAction, TextInputAction.done);

      identifier.focusNode?.requestFocus();
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(password.focusNode?.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
      expect(t.loginFieldPassword, isNotEmpty);
    });

    testWidgets('password keyboard action submits the form', (tester) async {
      final repo = FakeAuthRepository();
      final storage = FakeTokenStorage();
      await pumpSupervisor(tester, repo: repo, storage: storage);

      await fillSupervisorForm(tester, 'super', 'secret123');
      final passwordField = tester.widget<TextField>(
        find.byType(TextField).at(1),
      );
      passwordField.focusNode?.requestFocus();
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(await storage.getToken(), 'test-token');
      expect(tester.takeException(), isNull);
    });
  });

  group('supervisor submit mapping', () {
    testWidgets('email identifier maps to the email slot of the same call',
        (tester) async {
      String? gotEmail;
      String? gotPhone;
      String? gotPassword;
      final repo = FakeAuthRepository()
        ..loginHandler = (email, phone, password) async {
          gotEmail = email;
          gotPhone = phone;
          gotPassword = password;
          return Success(FakeAuthRepository.authResult());
        };
      final storage = FakeTokenStorage();
      await pumpSupervisor(tester, repo: repo, storage: storage);

      await submitSupervisorForm(tester, 'lead@orient.ae', 'secret123');

      expect(repo.loginCalls, 1);
      expect(gotEmail, 'lead@orient.ae');
      expect(gotPhone, isEmpty);
      expect(gotPassword, 'secret123');
      expect(await storage.getToken(), 'test-token');
      expect(await storage.getRole(), UserRole.supervisor.name);
      expect(tester.takeException(), isNull);
    });

    testWidgets('username identifier maps to the phone slot of the same call',
        (tester) async {
      String? gotEmail;
      String? gotPhone;
      final repo = FakeAuthRepository()
        ..loginHandler = (email, phone, password) async {
          gotEmail = email;
          gotPhone = phone;
          return Success(FakeAuthRepository.authResult());
        };
      final storage = FakeTokenStorage();
      await pumpSupervisor(tester, repo: repo, storage: storage);

      await submitSupervisorForm(tester, 'super', 'secret123');

      expect(repo.loginCalls, 1);
      expect(gotEmail, isEmpty);
      expect(gotPhone, 'super');
      expect(await storage.getToken(), 'test-token');
      expect(tester.takeException(), isNull);
    });

    testWidgets('typed values survive a mapped failure', (tester) async {
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(UnknownException('boom'));
      await pumpSupervisor(tester, repo: repo);
      final t = lookupSharedAuthLocalizations(const Locale('en'));

      await submitSupervisorForm(tester, 'super', 'secret123');

      // Still on the single screen (password visible), banner with the
      // mapped copy, and both controllers untouched — no step to lose them.
      expect(find.text(t.loginFieldPassword), findsOneWidget);
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.textContaining(t.errorServerRetryRef), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(0)).controller?.text,
        'super',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
        'secret123',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('supervisor validation', () {
    testWidgets('empty identifier shows the staff copy in a banner',
        (tester) async {
      final repo = FakeAuthRepository();
      await pumpSupervisor(tester, repo: repo);

      await tester.tap(find.byType(AppPillButton));
      await tester.pump();

      expect(repo.loginCalls, 0);
      expect(find.byType(AppBanner), findsOneWidget);
      // The single screen stays intact behind the banner.
      expect(find.byType(AppInputField), findsNWidgets(2));
      // AppBanner bidi-isolates its message (U+2066…U+2069), so match the
      // copy as a substring.
      expect(
        find.textContaining('Enter username and password'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('editing a field clears the error banner', (tester) async {
      await pumpSupervisor(tester);

      await tester.tap(find.byType(AppPillButton));
      await tester.pump();
      expect(find.byType(AppBanner), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'super');
      await tester.pump();
      expect(find.byType(AppBanner), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('editing the password clears a login-failure banner',
        (tester) async {
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(UnknownException('boom'));
      await pumpSupervisor(tester, repo: repo);

      await submitSupervisorForm(tester, 'super', 'secret123');
      expect(find.byType(AppBanner), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(1), 'secret1234');
      await tester.pump();
      expect(find.byType(AppBanner), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('supervisor mapped failures (never raw)', () {
    testWidgets('transport failure shows offline copy + retry, not raw',
        (tester) async {
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async => const Failure(
              NetworkException('SocketException: failed host lookup'),
            );
      await pumpSupervisor(tester, repo: repo);

      await submitSupervisorForm(tester, 'super', 'secret123');

      expect(repo.loginCalls, 1);
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.textContaining('SocketException'), findsNothing);
      expect(find.textContaining('failed host lookup'), findsNothing);
      final t = lookupSharedAuthLocalizations(const Locale('en'));
      expect(find.textContaining(t.errorOfflineRetry), findsOneWidget);
      expect(find.text(t.authActionRetry), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('retry resubmits the login', (tester) async {
      var calls = 0;
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async {
          calls++;
          if (calls == 1) {
            return const Failure(UnknownException('boom'));
          }
          return Success(FakeAuthRepository.authResult());
        };
      // The restore-on-boot race can flip the notifier back to unauthenticated
      // after a later pump, so success is pinned on persisted storage (what
      // the router actually reads) rather than the notifier instance state.
      final storage = FakeTokenStorage();
      await pumpSupervisor(tester, repo: repo, storage: storage);

      await submitSupervisorForm(tester, 'super', 'secret123');

      final t = lookupSharedAuthLocalizations(const Locale('en'));
      expect(find.textContaining(t.errorServerRetryRef), findsOneWidget);
      await tester.tap(find.text(t.authActionRetry));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 2);
      expect(await storage.getToken(), 'test-token');
      expect(await storage.getRole(), UserRole.supervisor.name);
      expect(tester.takeException(), isNull);
    });
  });

  group('supervisor busy state', () {
    testWidgets('pending login shows busy label + spinner, single submit',
        (tester) async {
      final gate = Completer<Result<AuthResult>>();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) => gate.future;
      final storage = FakeTokenStorage();
      await pumpSupervisor(tester, repo: repo, storage: storage);
      final t = lookupSharedAuthLocalizations(const Locale('en'));

      await fillSupervisorForm(tester, 'super', 'secret123');
      await tester.tap(find.byType(AppPillButton));
      await tester.pump();

      expect(find.text(t.authActionSigningIn), findsOneWidget);
      expect(find.text(t.loginFieldPassword), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<AppPillButton>(
        find.widgetWithText(AppPillButton, t.authActionSigningIn),
      );
      expect(button.isLoading, isTrue);

      // Second tap while busy is ignored.
      await tester.tap(find.byType(AppPillButton), warnIfMissed: false);
      await tester.pump();
      expect(repo.loginCalls, 1);

      gate.complete(Success(FakeAuthRepository.authResult()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(await storage.getToken(), 'test-token');
      expect(await storage.getRole(), UserRole.supervisor.name);
      expect(tester.takeException(), isNull);
    });
  });

  group('supervisor forgot route', () {
    testWidgets('forgot link pushes /forgot-password', (tester) async {
      final t = lookupSharedAuthLocalizations(const Locale('en'));
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const SupervisorLoginView(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (_, __) =>
                const Scaffold(body: Text('forgot-stub')),
          ),
        ],
      );
      await pumpSupervisor(tester, router: router);

      // The forgot link sits on the single screen — no step to reach first.
      await tester.tap(find.text(t.loginActionForgotPassword));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('forgot-stub'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('supervisor compact RTL large-text', () {
    testWidgets('320px ar 1.3x flow has no overflow', (tester) async {
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(UnknownException('boom'));
      await pumpSupervisor(tester, repo: repo, locale: const Locale('ar'));
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pump();
      expect(tester.takeException(), isNull);

      await submitSupervisorForm(
        tester, 'very-long-supervisor-name@orient-workshop.ae', 'secret123');
      // Failure banner + both fields + forgot link all fit via scrolling
      // (banner retry + forgot link = two text buttons in the failure state).
      // Long identifier exercises recap truncation + 320px overflow.
      final t = lookupSharedAuthLocalizations(const Locale('ar'));
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.byType(AppInputField), findsNWidgets(2));
      expect(find.text(t.loginActionForgotPassword), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  });
}
