// Phase-2c verification (migrated to the step flow): the C16 step
// recomposition uses App* widgets everywhere, the legacy auth controls are
// gone from the tree (segmented switcher + cooldown ring removed by design),
// contrast pairs measure AA, and 320px + 1.3x text scale stay overflow-free.
//
// Behavior assertions live in the 2b characterization files; this file pins
// the step-flow structure itself (steps, tokens, states, small screens).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Pumps a [LoginView] on a 320x568 phone at 1.3x text scale.
Future<ProviderContainer> pumpLoginSmall(
  WidgetTester tester, {
  FakeAuthRepository? repo,
  bool allowRegistration = false,
}) async {
  final resolvedRepo = repo ?? FakeAuthRepository();
  final resolvedStorage = FakeTokenStorage();
  tester.view.physicalSize = const Size(640, 1136);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(resolvedRepo),
        tokenStorageProvider.overrideWithValue(resolvedStorage),
      ],
      child: MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: SharedAuthLocalizations.supportedLocales,
          localizationsDelegates:
              SharedAuthLocalizations.localizationsDelegates,
          theme: AppTheme.light(BrandConfig.orient),
          home: LoginView(
            onLoginSuccess: () {},
            allowRegistration: allowRegistration,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(LoginView)));
}

/// Pumps a [ForgotPasswordView] on a 320x568 phone at 1.3x text scale.
Future<ProviderContainer> pumpForgotSmall(
  WidgetTester tester, {
  FakeAuthRepository? repo,
}) async {
  final resolvedRepo = repo ?? FakeAuthRepository();
  final resolvedStorage = FakeTokenStorage();
  tester.view.physicalSize = const Size(640, 1136);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(resolvedRepo),
        tokenStorageProvider.overrideWithValue(resolvedStorage),
      ],
      child: MediaQuery(
        data: MediaQueryData.fromView(
          tester.view,
        ).copyWith(textScaler: const TextScaler.linear(1.3)),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: SharedAuthLocalizations.supportedLocales,
          localizationsDelegates:
              SharedAuthLocalizations.localizationsDelegates,
          theme: AppTheme.light(BrandConfig.orient),
          home: ForgotPasswordView(onBackToLogin: () {}),
        ),
      ),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(ForgotPasswordView)),
  );
}

/// The step scrollable: the vertical [Scrollable] inside the step scaffold
/// (single-line fields own horizontal internals). Passed explicitly because
/// [WidgetTester.scrollUntilVisible] cannot disambiguate on its own.
Finder authColumnScrollable() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axis == Axis.vertical,
    );

/// Scrolls [finder] into view inside the step scrollable, then taps it.
/// The 320px viewport leaves fields below the fold; a raw tap would miss.
/// The sticky CTA never needs this — it stays pinned above the keyboard.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: authColumnScrollable(),
  );
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Scroll-aware step advance for below-the-fold controls.
Future<void> tapSettleVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: authColumnScrollable(),
  );
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('App* composition (login steps)', () {
    testWidgets('step 1 renders App* step controls only', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, onForgotPassword: () {});

      // One step scaffold, step-1 headline, no segmented switcher anywhere.
      expect(find.byType(AppStepScaffold), findsOneWidget);
      expect(find.text(t.loginStepIdentifierTitle), findsOneWidget);
      final segmented = find.byWidgetPredicate(
        (w) => w is AppSegmentedControl<dynamic>,
      );
      expect(segmented, findsNothing);
      // Identifier-only: a single shared input on step 1.
      expect(find.byType(AppInputField), findsOneWidget);
      expect(find.byType(AppPillButton), findsOneWidget);
      expect(
        find.widgetWithText(AppPillButton, t.loginActionContinue),
        findsOneWidget,
      );
      // Alternative paths are outlined rows behind an "or" divider.
      // (Step 1 carries no text-button links; the forgot link lives on the
      // password step and resend on the confirm step.)
      expect(find.byType(AppOrDivider), findsOneWidget);
      expect(find.byType(AppAltAuthRow), findsWidgets);
      expect(find.text(t.loginStepUseCodeInstead), findsOneWidget);
      expect(find.byType(AppTextButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password step keeps forgot link + password field',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, onForgotPassword: () {});
      await reachPasswordStep(tester, 'user@example.com');

      expect(find.text(t.loginStepPasswordTitle), findsOneWidget);
      expect(find.byType(AppInputField), findsOneWidget);
      expect(find.text(t.loginActionForgotPassword), findsOneWidget);
      expect(find.byType(AppTextButton), findsWidgets);
      expect(find.text(t.loginStepUseCodeInstead), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('register R3 keeps the strength slot on AppInputField',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, allowRegistration: true);
      await reachRegisterR3(tester, 'Sam Example', 'user@example.com');

      expect(find.byType(AuthPasswordStrength), findsOneWidget);
      expect(find.text(t.loginMinCharacters), findsOneWidget);
      expect(find.byType(AppPillButton), findsOneWidget);
      expect(
        find.widgetWithText(AppPillButton, t.loginActionCreateAccount),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('code step keeps the token-styled OTP field', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);
      await reachCodeConfirm(tester, '501234567');

      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(find.byType(AuthOtpField), findsOneWidget);
      // OTP digits stay LTR-locked inside any layout direction.
      final ltr = find.ancestor(
        of: find.byType(AuthOtpField),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Directionality &&
              w.textDirection == TextDirection.ltr,
        ),
      );
      expect(ltr, findsWidgets);
      // Resend is the isolated link + countdown row: no cooldown ring.
      expect(find.byType(LoginResendRow), findsOneWidget);
      expect(find.byType(AppTextButton), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('App* composition (forgot steps)', () {
    testWidgets('identifier stage keeps the step scaffold + CTA',
        (tester) async {
      final t = enAuthL10n();
      await pumpForgotView(tester);

      expect(find.byType(AppStepScaffold), findsOneWidget);
      expect(find.text(t.forgotTitle), findsOneWidget);
      expect(find.byType(AppInputField), findsOneWidget);
      expect(
        find.widgetWithText(AppPillButton, t.forgotActionSendRecoveryCode),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('success screen announces once as a live region',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.enterText(find.byType(TextField).first, 'newpass123');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionUpdatePassword));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(t.forgotDoneTitle), findsOneWidget);
      expect(find.byType(AppPillButton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.liveRegion ?? false) &&
              w.properties.label == t.forgotDoneTitle,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });
  });

  group('measured AA contrast pairs (auth surfaces)', () {
    Future<BuildContext> themedContext(
      WidgetTester tester, {
      bool dark = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          darkTheme: AppTheme.dark(BrandConfig.orient),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      await tester.pump();
      return tester.element(find.byType(Scaffold));
    }

    double ratio(Color a, Color b) {
      final l1 = a.computeLuminance(), l2 = b.computeLuminance();
      final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
      return (hi + 0.05) / (lo + 0.05);
    }

    testWidgets('CTA label ink holds 4.5 on the accent fill', (tester) async {
      for (final dark in [false, true]) {
        final ctx = await themedContext(tester, dark: dark);
        final scheme = Theme.of(ctx).colorScheme;
        expect(
          ratio(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
          reason: dark ? 'dark CTA pair' : 'light CTA pair',
        );
      }
    });

    testWidgets('error text holds 4.5 on the surface', (tester) async {
      for (final dark in [false, true]) {
        final ctx = await themedContext(tester, dark: dark);
        final scheme = Theme.of(ctx).colorScheme;
        expect(
          ratio(scheme.error, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: dark ? 'dark error pair' : 'light error pair',
        );
      }
    });

    testWidgets('error banner ink holds 4.5 on its fill', (tester) async {
      for (final dark in [false, true]) {
        final ctx = await themedContext(tester, dark: dark);
        final sem = ctx.semanticColors;
        expect(
          ratio(sem.danger.ink, sem.danger.subtle),
          greaterThanOrEqualTo(4.5),
          reason: dark ? 'dark banner pair' : 'light banner pair',
        );
      }
    });

    testWidgets('OTP resting border holds 3.0 on the cell fill',
        (tester) async {
      for (final dark in [false, true]) {
        final ctx = await themedContext(tester, dark: dark);
        final scheme = Theme.of(ctx).colorScheme;
        final border = AppTokens.of(ctx).inputBorder;
        expect(
          ratio(border, scheme.surfaceContainerLow),
          greaterThanOrEqualTo(3.0),
          reason: dark ? 'dark OTP border' : 'light OTP border',
        );
        expect(
          ratio(border, scheme.surface),
          greaterThanOrEqualTo(3.0),
          reason: dark ? 'dark OTP border on card' : 'light OTP border on card',
        );
      }
    });

    testWidgets('loading progress holds 4.5 on the navy surface',
        (tester) async {
      for (final dark in [false, true]) {
        final ctx = await themedContext(tester, dark: dark);
        final scheme = Theme.of(ctx).colorScheme;
        expect(
          ratio(scheme.inversePrimary, scheme.inverseSurface),
          greaterThanOrEqualTo(4.5),
          reason: dark ? 'dark splash pair' : 'light splash pair',
        );
      }
    });

    test('success confirmation disc holds 4.5 with its check', () {
      expect(
        ratio(const Color(0xFFFFFFFF), AppColors.successStrong),
        greaterThanOrEqualTo(4.5),
        reason: 'light disc pair',
      );
      expect(
        ratio(AppDarkColors.onPrimary, AppDarkColors.successStrong),
        greaterThanOrEqualTo(4.5),
        reason: 'dark disc pair',
      );
    });
  });

  group('supervisor fallback copy (phase-2c ARB keys)', () {
    test('all eight keys resolve in en + ar with no blanks', () {
      final en = lookupSharedAuthLocalizations(const Locale('en'));
      final ar = lookupSharedAuthLocalizations(const Locale('ar'));
      final pairs = <String Function(SharedAuthLocalizations)>[
        (t) => t.supervisorLoginTitle,
        (t) => t.supervisorLoginSubtitle,
        (t) => t.supervisorAppName,
        (t) => t.supervisorAppPurpose,
        (t) => t.supervisorIntendedUsers,
        (t) => t.supervisorUsernameLabel,
        (t) => t.supervisorUsernameHint,
        (t) => t.supervisorEnterCredentials,
      ];
      for (final get in pairs) {
        expect(get(en).trim(), isNotEmpty);
        expect(get(ar).trim(), isNotEmpty);
        expect(get(ar), isNot(equals(get(en))));
      }
      // Fallbacks carry the same meaning as the previous literals.
      expect(en.supervisorLoginTitle, 'Supervisor access');
      expect(en.supervisorEnterCredentials, 'Enter username and password');
      expect(en.supervisorUsernameLabel, 'Username or email');
    });
  });

  group('step keys resolve in en + ar with no blanks', () {
    test('all eighteen step keys resolve with distinct ar copy', () {
      final en = lookupSharedAuthLocalizations(const Locale('en'));
      final ar = lookupSharedAuthLocalizations(const Locale('ar'));
      final pairs = <String Function(SharedAuthLocalizations)>[
        (t) => t.loginStepIdentifierTitle,
        (t) => t.loginStepIdentifierSubtitle,
        (t) => t.loginStepPasswordTitle,
        (t) => t.loginStepRegisterNameTitle,
        (t) => t.loginStepRegisterNameSubtitle,
        (t) => t.loginStepRegisterContactTitle,
        (t) => t.loginStepRegisterContactSubtitle,
        (t) => t.loginStepRegisterPasswordTitle,
        (t) => t.loginStepRegisterPasswordSubtitle,
        (t) => t.loginStepUseCodeInstead,
        (t) => t.loginStepUsePasswordInstead,
        (t) => t.loginStepCreateAccountRow,
        (t) => t.loginStepOr,
        (t) => t.loginStepBack,
      ];
      for (final get in pairs) {
        expect(get(en).trim(), isNotEmpty);
        expect(get(ar).trim(), isNotEmpty);
        expect(get(ar), isNot(equals(get(en))));
      }
      expect(en.loginStepProgress(1, 2), 'Step 1 of 2');
      expect(ar.loginStepProgress(1, 2).trim(), isNotEmpty);
      expect(en.loginStepPasswordSubtitle('sam@example.com'), contains('sam@example.com'));
      expect(en.loginStepCodeDestination('X'), contains('X'));
    });
  });

  group('small screens (320px @ 1.3x)', () {
    testWidgets('step 1 + field errors stay clean', (tester) async {
      final t = enAuthL10n();
      await pumpLoginSmall(tester);

      expect(find.text(t.loginStepIdentifierTitle), findsOneWidget);
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('register R1-R3 stay clean', (tester) async {
      final t = enAuthL10n();
      await pumpLoginSmall(tester, allowRegistration: true);
      await tapSettleVisible(tester, find.text(t.loginStepCreateAccountRow));

      expect(find.text(t.loginStepRegisterNameTitle), findsOneWidget);
      await tapVisible(tester, find.text(t.loginActionContinue));
      expect(find.text(t.validationEnterName), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('code confirm step stays clean', (tester) async {
      final t = enAuthL10n();
      await pumpLoginSmall(tester);
      await tester.scrollUntilVisible(
        find.byType(TextField).first,
        200,
        scrollable: authColumnScrollable(),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tapSettleVisible(tester, find.text(t.loginStepUseCodeInstead));

      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(find.byType(AuthOtpField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('forgot identifier + reset stages stay clean',
        (tester) async {
      final t = enAuthL10n();
      await pumpForgotSmall(tester);

      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      expect(find.text(t.validationEnterIdentifier), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(t.forgotActionUpdatePassword), findsOneWidget);

      await tester.tap(find.text(t.forgotActionUpdatePassword));
      await tester.pump();
      expect(find.text(t.validationEnter6DigitRecovery), findsOneWidget);
      expect(find.text(t.validationUseAtLeast6), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });
  });
}
