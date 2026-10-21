// Phase-2b characterization: success/failure navigation on login (migrated
// to the step flow).
//
// An authenticated session fires onLoginSuccess EXACTLY once per successful
// submit — never on failures, never twice across extra frames. Step mapping:
// Step 1 Continue advances with zero API calls; the password step submits via
// loginWithPassword; the code-confirm step (reached through the
// "Send me a code instead" alt row) verifies.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('login success navigation', () {
    testWidgets('password success calls onLoginSuccess exactly once',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      await reachPasswordStep(tester, 'user@example.com');
      // Step 1 advanced with no API call.
      expect(repo.loginCalls, 0);
      await tester.enterText(find.byType(TextField).first, 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('OTP verify success calls onLoginSuccess exactly once',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      var successes = 0;
      final container = await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      await reachCodeConfirm(tester, '501234567');
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);

      container.read(loginProvider.notifier).setOtp('123456');
      await tester.pump();
      await tester.tap(find.text(t.loginActionVerifyCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.verifyOtpCalls, 1);
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('failed login never calls onLoginSuccess', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(ValidationException('wrong password'));
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      await reachPasswordStep(tester, 'user@example.com');
      await tester.enterText(find.byType(TextField).first, 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(successes, 0);
      expect(tester.takeException(), isNull);
    });
  });
}
