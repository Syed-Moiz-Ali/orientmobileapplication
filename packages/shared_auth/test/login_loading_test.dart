// Phase-2b characterization: loading state on login.
//
// While a login future is pending the CTA swaps to its busy label, shows a
// spinner, is disabled, and a second tap cannot submit twice.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('login loading', () {
    testWidgets('pending login shows busy label + spinner and is disabled',
        (tester) async {
      final t = enAuthL10n();
      final gate = Completer<Result<AuthResult>>();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) => gate.future;
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

      // Busy label swap + spinner, rest label gone.
      expect(find.text(t.authActionSigningIn), findsOneWidget);
      expect(find.text(t.loginActionContinue), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Disabled: the inner FilledButton drops its callback while loading.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);

      gate.complete(
        const Success(AuthResult(role: UserRole.customer, token: 'tok')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('double-tap while busy submits exactly once', (tester) async {
      final t = enAuthL10n();
      final gate = Completer<Result<AuthResult>>();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) => gate.future;
      await pumpLoginView(tester, repo: repo);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      // Second tap lands on the busy (disabled) CTA.
      await tester.tap(find.text(t.authActionSigningIn));
      await tester.pump();

      expect(repo.loginCalls, 1);

      gate.complete(
        const Success(AuthResult(role: UserRole.customer, token: 'tok')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(repo.loginCalls, 1);
      expect(tester.takeException(), isNull);
    });
  });
}
