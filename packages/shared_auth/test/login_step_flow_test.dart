// One-screen tests (new): the single-screen password form maps onto the same
// notifier calls with view-level UI state only.
//
// Covers: Continue IS the login call (no zero-API advance step); Back
// preserves typed values on the remaining steps; errors land on the right
// surface; resend countdown ticks without rebuilding the step; register
// R1→R2→R3 ends in a single register() with all fields; password-first
// one-screen default with the code alt row present; motion/a11y gates.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Scrolls [finder] into view inside the step scrollable, then taps it.
/// Below-the-fold rows at 320px would otherwise sit under the sticky CTA.
Future<void> scrollTapVisible(WidgetTester tester, Finder finder) async {
  final scrollable = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axis == Axis.vertical,
  );
  await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('one-screen password submit', () {
    testWidgets('Continue with valid credentials fires a single login()',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      // One screen, one submit: identifier + password + Continue.
      expect(find.text(t.loginTitle), findsOneWidget);
      await fillLoginForm(tester, 'user@example.com', 'secret123');
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(repo.sendOtpCalls, 0);
      expect(repo.sendEmailOtpCalls, 0);
      expect(repo.verifyOtpCalls, 0);
      expect(repo.verifyEmailOtpCalls, 0);
      expect(repo.registerCalls, 0);
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone identifier submits through the same single login()',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await fillLoginForm(tester, '501234567', 'secret123');
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(repo.sendOtpCalls, 0);
      expect(repo.sendEmailOtpCalls, 0);
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid identifier blocks submit with no API call',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.enterText(find.byType(TextField).first, '123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterValidPhone), findsOneWidget);
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(repo.loginCalls, 0);
      expect(repo.sendOtpCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty form shows both inline errors with no API call',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(find.text(t.validationEnterPassword), findsWidgets);
      expect(repo.loginCalls, 0);
      expect(repo.registerCalls, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('back preserves typed values', () {
    testWidgets('register back chain preserves name + contact',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, allowRegistration: true);
      await reachRegisterR3(tester, 'Sam Example', 'user@example.com');

      // R3 → R2: contact preserved.
      await tapAndSettleStep(
        tester,
        find.byTooltip(t.loginStepBack),
      );
      expect(find.text(t.loginStepRegisterContactTitle), findsOneWidget);
      expect(find.textContaining('user@example.com'), findsWidgets);

      // R2 → R1: name preserved.
      await tapAndSettleStep(
        tester,
        find.byTooltip(t.loginStepBack),
      );
      expect(find.text(t.loginStepRegisterNameTitle), findsOneWidget);
      expect(find.textContaining('Sam Example'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('code back lands on the one-screen with values intact',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);
      await reachCodeConfirm(tester, '501234567');

      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      await tapAndSettleStep(
        tester,
        find.byTooltip(t.loginStepBack),
      );
      // Back returns to the single password screen with both values intact.
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(find.textContaining('501234567'), findsWidgets);
      expect(find.text(t.loginFieldPassword), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('errors land on the right surface', () {
    testWidgets('identifier error stays on the single screen',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);

      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.loginTitle), findsOneWidget);
      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password error stays on the single screen with no snackbar',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(ValidationException('wrong password'));
      await pumpLoginView(tester, repo: repo);
      await fillLoginForm(tester, 'user@example.com', 'secret123');

      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(find.text('wrong password'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expired code stays on confirm with no snackbar',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..verifyOtpHandler = (_, __) async =>
            const Failure(ValidationException('otp expired, request another'));
      final container = await pumpLoginView(tester, repo: repo);
      await reachCodeConfirm(tester, '501234567');

      container.read(loginProvider.notifier).setOtp('123456');
      await tester.pump();
      await tester.tap(find.text(t.loginActionVerifyCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(find.text(t.errorOtpExpired), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('resend countdown', () {
    testWidgets('ticks without rebuilding the step', (tester) async {
      final t = enAuthL10n();
      final container = await pumpLoginView(tester);
      await reachCodeConfirm(tester, '501234567');

      expect(find.text(t.loginActionResendIn(30)), findsOneWidget);
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);

      // Two fake-async seconds: the isolated row ticks to 28 while the step
      // headline, destination line and OTP field stand still.
      await tester.pump(const Duration(seconds: 2));

      expect(container.read(loginProvider).resendCooldown, 28);
      expect(find.text(t.loginActionResendIn(28)), findsOneWidget);
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(find.byType(AuthOtpField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('countdown is a disabled readable link with semantics',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);
      await reachCodeConfirm(tester, '501234567');

      final resend = tester.widget<AppTextButton>(
        find.widgetWithText(AppTextButton, t.loginActionResendIn(30)),
      );
      expect(resend.onPressed, isNull);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.liveRegion ?? false) &&
              w.properties.label == t.loginActionResendIn(30),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('register three steps end to end', () {
    testWidgets('single register() carries all fields', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      String? seenName, seenEmail, seenPhone, seenPassword, seenRole;
      repo.registerHandler = (name, email, phone, password, role) async {
        seenName = name;
        seenEmail = email;
        seenPhone = phone;
        seenPassword = password;
        seenRole = role;
        return Success(FakeAuthRepository.authResult());
      };
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        allowRegistration: true,
        onLoginSuccess: () => successes++,
      );

      // R1 + R2 advance with zero API calls.
      await tapAndSettleStep(tester, find.text(t.loginStepCreateAccountRow));
      await tester.enterText(find.byType(TextField).first, 'Sam Example');
      await tester.pump();
      await tapAndSettleStep(tester, find.text(t.loginActionContinue));
      expect(repo.registerCalls, 0);
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();
      await tapAndSettleStep(tester, find.text(t.loginActionContinue));
      expect(repo.registerCalls, 0);

      await tester.enterText(find.byType(TextField).first, 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionCreateAccount));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.registerCalls, 1);
      expect(seenName, 'Sam Example');
      expect(seenEmail, 'user@example.com');
      expect(seenPassword, 'secret123');
      expect(seenRole, 'customer');
      expect(seenPhone, isNotNull);
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('per-app defaults', () {
    testWidgets('every app is password-first with the code alt row',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(
        tester,
        onForgotPassword: () {},
      );

      // Fresh views open on the one-screen form — never code-first, with
      // both fields visible.
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(find.text(t.loginSubtitle), findsOneWidget);
      expect(find.text(t.loginFieldIdentifier), findsOneWidget);
      expect(find.text(t.loginFieldPassword), findsOneWidget);
      expect(find.byType(AuthOtpField), findsNothing);
      // The code path is the secondary alternative everywhere the shared
      // view runs.
      expect(find.text(t.loginStepUseCodeInstead), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('register row hides without allowRegistration',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);

      expect(find.text(t.loginStepCreateAccountRow), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('forgot password link routes through the callback',
        (tester) async {
      final t = enAuthL10n();
      var forgotCalls = 0;
      await pumpLoginView(
        tester,
        onForgotPassword: () => forgotCalls++,
      );

      // The forgot link lives on the single screen — no advance needed.
      expect(find.byType(AppInputField), findsNWidgets(2));
      await tester.tap(find.text(t.loginActionForgotPassword));
      await tester.pump();
      expect(forgotCalls, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('motion + accessibility', () {
    test('step motion uses the 200-300ms C16 window', () {
      expect(
        AppMotion.standard,
        greaterThanOrEqualTo(const Duration(milliseconds: 200)),
      );
      expect(
        AppMotion.standard,
        lessThanOrEqualTo(const Duration(milliseconds: 300)),
      );
      expect(
        AppMotion.emphasized,
        lessThanOrEqualTo(const Duration(milliseconds: 300)),
      );
    });

    testWidgets('step transitions are static under reduced motion',
        (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      );
      // AppStepScaffold resolves its slide + fade through this: instant
      // under reduced motion, the 220 ms token otherwise.
      expect(AppMotion.reducedMotion(captured), isTrue);
      expect(AppMotion.resolve(captured, AppMotion.standard), Duration.zero);
    });

    testWidgets('new headline is a screen-reader header with step semantics',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.header ?? false) &&
              w.child is Text &&
              (w.child as Text).data == t.loginTitle,
        ),
        findsOneWidget,
      );
      // The single screen exposes step-1-of-1 semantics.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == t.loginStepProgress(1, 1),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('back is a 48dp RTL-mirroring target', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);
      await reachCodeConfirm(tester, '501234567');

      final back = find.byTooltip(t.loginStepBack);
      expect(back, findsOneWidget);
      expect(tester.getSize(back).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(back).height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });

    testWidgets('back mirrors and works under ar RTL', (tester) async {
      final t = arAuthL10n();
      await pumpLoginView(tester, locale: const Locale('ar'));

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.loginStepUseCodeInstead));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);

      await tapAndSettleStep(tester, find.byTooltip(t.loginStepBack));
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sticky CTA stays above the keyboard (viewInsets)',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);

      tester.view.viewInsets = const FakeViewPadding(
        bottom: 300,
      );
      await tester.pump();

      // The single primary CTA is still laid out and tappable with the
      // keyboard up; one tap validates both one-screen fields together.
      expect(find.widgetWithText(AppPillButton, t.loginActionContinue), findsOneWidget);
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(find.text(t.validationEnterPassword), findsWidgets);
      expect(tester.takeException(), isNull);

      tester.view.resetViewInsets();
      await tester.pump();
    });

    testWidgets('320px + 1.3x + ar + customer dark never overflows',
        (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      final repo = FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
            localeProvider.overrideWith((ref) => LocaleController(const Locale('ar'))),
          ],
          child: MediaQuery(
            data: MediaQueryData.fromView(tester.view).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar'),
              supportedLocales: SharedAuthLocalizations.supportedLocales,
              localizationsDelegates:
                  SharedAuthLocalizations.localizationsDelegates,
              theme: AppTheme.light(BrandConfig.orient),
              darkTheme: AppTheme.dark(BrandConfig.orient),
              themeMode: ThemeMode.dark,
              home: LoginView(
                onLoginSuccess: () {},
                onForgotPassword: () {},
                allowRegistration: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final t = arAuthL10n();

      // Walk every family: one-screen → code → register R1 → R2 → R3.
      expect(find.text(t.loginTitle), findsOneWidget);
      expect(find.text(t.loginFieldPassword), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await scrollTapVisible(tester, find.text(t.loginStepUseCodeInstead));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expanded shows the centered 480 column + brand panel only',
        (tester) async {
      await pumpLoginView(tester);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Split widths render the brand panel beside the same one-screen flow.
      expect(find.byType(AuthStepBrandPanel), findsOneWidget);
      expect(find.text(enAuthL10n().loginTitle), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.maxWidth == 480,
        ),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact shows no split brand panel', (tester) async {
      await pumpLoginView(tester);

      expect(find.byType(AuthStepBrandPanel), findsNothing);
      expect(find.text(enAuthL10n().loginTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
