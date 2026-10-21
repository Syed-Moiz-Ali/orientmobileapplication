// Phase-2b characterization: register mode on login (migrated to the R1/R2/R3
// step flow).
//
// Register is its own step flow behind "New here? Create account" (never a
// separate route): R1 name → R2 contact → R3 password, then submit goes
// through LoginNotifier.register() once, and success fires onLoginSuccess.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Opens the register flow (customer builds) and lands on R1.
Future<void> openRegister(WidgetTester tester) async {
  final t = enAuthL10n();
  await tapAndSettleStep(tester, find.text(t.loginStepCreateAccountRow));
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('register mode', () {
    testWidgets('toggle reveals name field + continue CTA', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, allowRegistration: true);
      await openRegister(tester);

      expect(find.text(t.loginStepRegisterNameTitle), findsOneWidget);
      expect(find.text(t.loginFieldFullName), findsOneWidget);
      expect(find.text(t.loginActionContinue), findsOneWidget);
      // The create-account CTA lives only on R3, not on R1.
      expect(find.text(t.loginActionCreateAccount), findsNothing);
      // The password field lives on R3, not on R1.
      expect(find.text(t.loginFieldCreatePassword), findsNothing);
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
      await reachRegisterR3(tester, 'Sam Example', 'user@example.com');

      expect(find.text(t.loginStepRegisterPasswordTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'secret123');
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
      await reachRegisterR3(tester, 'Sam Example', 'user@example.com');

      await tester.enterText(find.byType(TextField).first, 'secret123');
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
