// Phase-2b characterization: forgot-password stages (migrated to the
// AppStepScaffold step flow).
//
// identifier -> reset (code + new password together; the backend issues and
// consumes the code in one reset-password call) -> done. Guards stage
// transitions, code+password validation, resend start state, expired-code
// mapping, and the success CTA. Copy keys and validation timing are reused
// verbatim; the resend countdown is an isolated row (no whole-step rebuild).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Completes the identifier step with a valid phone number (default forgot
/// handler succeeds) and lands on the reset stage.
Future<void> reachResetStep(WidgetTester tester) async {
  final t = enAuthL10n();
  await tester.enterText(find.byType(TextField).first, '501234567');
  await tester.pump();
  await tester.tap(find.text(t.forgotActionSendRecoveryCode));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('forgot identifier stage', () {
    testWidgets('empty identifier shows the mapped inline error',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);

      expect(find.text(t.forgotTitle), findsOneWidget);
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(repo.forgotCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid email shows the email error', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);

      await tester.enterText(find.byType(TextField).first, 'abc');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();

      expect(find.text(t.validationEnterValidEmailAddress), findsOneWidget);
      expect(repo.forgotCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('short phone shows the mobile error', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);

      await tester.enterText(find.byType(TextField).first, '12');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();

      expect(find.text(t.validationEnterValidMobile), findsOneWidget);
      expect(repo.forgotCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('valid identifier transitions to the reset stage',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);
      await reachResetStep(tester);

      expect(repo.forgotCalls, 1);
      expect(find.text(t.forgotResetTitle), findsOneWidget);
      // 'New password' also labels the progress step, so the field label
      // itself appears twice; the reset CTA + recovery-code label are unique.
      expect(find.text(t.forgotFieldNewPassword), findsWidgets);
      expect(find.text(t.forgotFieldRecoveryCode), findsOneWidget);
      expect(find.text(t.forgotActionUpdatePassword), findsOneWidget);
      // Code-sent confirmation is the in-flow success banner (phase-2 F-4),
      // announced once via its live region — never an overlay.
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.textContaining('Recovery code sent to'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });
  });

  group('forgot reset stage', () {
    testWidgets('short code + short password show both inline errors',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);
      await reachResetStep(tester);

      await tester.tap(find.text(t.forgotActionUpdatePassword));
      await tester.pump();

      expect(find.text(t.validationEnter6DigitRecovery), findsOneWidget);
      expect(find.text(t.validationUseAtLeast6), findsOneWidget);
      expect(repo.resetCalls, 0);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('expired recovery code maps inline to the OTP field',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..resetHandler = (_, __, ___, ____, _____) async =>
            const Failure(ValidationException('recovery code expired'));
      await pumpForgotView(tester, repo: repo);
      await reachResetStep(tester);

      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.enterText(find.byType(TextField).first, 'newpass123');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionUpdatePassword));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.resetCalls, 1);
      expect(find.text(t.errorOtpExpired), findsOneWidget);
      // Editing the OTP hides any snackbar by design (the code-sent
      // confirmation itself is the in-flow banner, unaffected), and the
      // code-mapped failure adds no error snackbar — inline only.
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('resend shows the 30s start state and is disabled',
        (tester) async {
      final t = enAuthL10n();
      await pumpForgotView(tester);
      await reachResetStep(tester);

      expect(find.text(t.loginActionResendIn(30)), findsOneWidget);
      final resend = tester.widget<AppTextButton>(
        find.widgetWithText(AppTextButton, t.loginActionResendIn(30)),
      );
      expect(resend.onPressed, isNull);
      // Isolated resend row, link + text only — no spinner beside it.
      expect(find.byType(ForgotResendRow), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('valid code + password reach done; CTA calls onBackToLogin',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      var backCalls = 0;
      await pumpForgotView(
        tester,
        repo: repo,
        onBackToLogin: () => backCalls++,
      );
      await reachResetStep(tester);

      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.enterText(find.byType(TextField).first, 'newpass123');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionUpdatePassword));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.resetCalls, 1);
      expect(find.text(t.forgotDoneTitle), findsOneWidget);
      // Terminal confirmation announces once as a live region.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.liveRegion ?? false) &&
              w.properties.label == t.forgotDoneTitle,
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(t.forgotBackToSignIn));
      await tester.pump();
      expect(backCalls, 1);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });
  });
}
