// Phase-2b characterization: register mode on login.
//
// Register is a progressive disclosure of the same column (never a separate
// route): the toggle reveals the name field, submit goes through
// LoginNotifier.register(), and success fires onLoginSuccess.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Opens register mode (customer builds) and retires the outgoing form.
Future<void> openRegister(WidgetTester tester) async {
  final t = enAuthL10n();
  await tapAndSettleMode(tester, find.text(t.loginNewCustomer));
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('register mode', () {
    testWidgets('toggle reveals name field + create-account CTA',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, allowRegistration: true);
      await openRegister(tester);

      expect(find.text(t.loginFieldFullName), findsOneWidget);
      expect(find.text(t.loginFieldCreatePassword), findsOneWidget);
      expect(find.text(t.loginActionCreateAccount), findsOneWidget);
      // Password-mode CTA is replaced, not duplicated.
      expect(find.text(t.loginActionContinue), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('valid registration submits via register() once',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        allowRegistration: true,
        onLoginSuccess: () => successes++,
      );
      await openRegister(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Sam Example');
      await tester.enterText(fields.at(1), 'user@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionCreateAccount));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.registerCalls, 1);
      expect(repo.loginCalls, 0);
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('existing account maps inline to the identifier field',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..registerHandler = (_, __, ___, ____, _____) async =>
            const Failure(
              ValidationException(
                'account already exists for this email',
              ),
            );
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        allowRegistration: true,
        onLoginSuccess: () => successes++,
      );
      await openRegister(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Sam Example');
      await tester.enterText(fields.at(1), 'user@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionCreateAccount));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.registerCalls, 1);
      expect(find.text(t.errorAccountExists), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(successes, 0);
      expect(tester.takeException(), isNull);
    });
  });
}
