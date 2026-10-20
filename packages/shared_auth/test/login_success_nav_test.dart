// Phase-2b characterization: success/failure navigation on login.
//
// An authenticated session fires onLoginSuccess EXACTLY once per successful
// submit — never on failures, never twice across extra frames.
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

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'secret123');
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

      await tapAndSettleMode(tester, find.text(t.authMethodCode));
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.loginActionSendCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

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

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(successes, 0);
      expect(tester.takeException(), isNull);
    });
  });
}
