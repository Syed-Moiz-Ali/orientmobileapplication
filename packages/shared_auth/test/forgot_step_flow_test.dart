// Step-flow tests (new): forgot-password stages as AppStepScaffold steps.
//
// Covers: identifier → reset → done with the same 3 stages and the same
// use-case calls; back preserves the identifier; resend ticks without
// rebuilding the step; terminal confirmation keeps its single CTA;
// motion/a11y gates mirror the sign-in flow.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('forgot stages as steps', () {
    testWidgets('identifier advances with one forgot() call', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpForgotView(tester, repo: repo);

      expect(find.text(t.forgotTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.forgotCalls, 1);
      expect(find.text(t.forgotResetTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('reset submits code + password in one reset() call',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      String? seenOtp, seenPassword;
      repo.resetHandler = (type, phone, email, otp, password) async {
        seenOtp = otp;
        seenPassword = password;
        return const Success<void>(null);
      };
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

      expect(repo.resetCalls, 1);
      expect(seenOtp, '123456');
      expect(seenPassword, 'newpass123');
      expect(find.text(t.forgotDoneTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('back from reset preserves the identifier', (tester) async {
      final t = enAuthL10n();
      await pumpForgotView(tester);

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(t.forgotResetTitle), findsOneWidget);

      await tester.tap(find.text(t.loginActionChangeIdentifier));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(t.forgotTitle), findsOneWidget);
      expect(find.textContaining('501234567'), findsWidgets);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('done keeps the single back-to-sign-in CTA', (tester) async {
      final t = enAuthL10n();
      var backCalls = 0;
      await pumpForgotView(tester, onBackToLogin: () => backCalls++);

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
      expect(
        find.widgetWithText(AppPillButton, t.forgotBackToSignIn),
        findsOneWidget,
      );
      await tester.tap(find.text(t.forgotBackToSignIn));
      await tester.pump();
      expect(backCalls, 1);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });
  });

  group('forgot resend isolation + a11y', () {
    testWidgets('countdown ticks without rebuilding the reset step',
        (tester) async {
      final t = enAuthL10n();
      await pumpForgotView(tester);

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(t.loginActionResendIn(30)), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text(t.loginActionResendIn(28)), findsOneWidget);
      // The reset step stands still around the ticking row.
      expect(find.text(t.forgotResetTitle), findsOneWidget);
      expect(find.byType(AuthOtpField), findsOneWidget);
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });

    testWidgets('progress exposes step semantics on every stage',
        (tester) async {
      final t = enAuthL10n();
      await pumpForgotView(tester);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == t.loginStepProgress(1, 2),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.forgotActionSendRecoveryCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == t.loginStepProgress(2, 2),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await drainForgotCooldown(tester);
    });
  });
}
