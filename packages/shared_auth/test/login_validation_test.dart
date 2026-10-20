// Phase-2b characterization: login local validation.
//
// Guards the CURRENT inline-error copy + routing so the 2c redesign preserves
// them: empty identifier, invalid email, short phone, empty password, short
// create-password, and empty name in register mode.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('login local validation (password mode)', () {
    testWidgets('empty identifier shows the mapped inline error',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(repo.loginCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('email-like entry without @ shows the email error',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.enterText(find.byType(TextField).first, 'not-an-email');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterValidEmail), findsOneWidget);
      expect(repo.loginCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('short phone shows the phone error', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.enterText(find.byType(TextField).first, '123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterValidPhone), findsOneWidget);
      expect(repo.loginCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty password shows the password error', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.enterText(
        find.byType(TextField).first,
        'user@example.com',
      );
      await tester.pump();
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsNothing);
      // The en hint ('Enter your password') collides with the error copy, so
      // pin the error on the password field itself, not just the text.
      expect(find.text(t.validationEnterPassword), findsWidgets);
      final passwordField = tester
          .widgetList<AuthTextField>(find.byType(AuthTextField))
          .firstWhere((f) => f.label == t.loginFieldPassword);
      expect(passwordField.errorText, t.validationEnterPassword);
      expect(repo.loginCalls, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('login local validation (register mode)', () {
    Future<void> openRegister(WidgetTester tester) async {
      final t = enAuthL10n();
      await tapAndSettleMode(tester, find.text(t.loginNewCustomer));
    }

    testWidgets('register toggle reveals the name field', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, allowRegistration: true);
      await openRegister(tester);

      expect(find.text(t.loginFieldFullName), findsOneWidget);
      expect(find.text(t.loginActionCreateAccount), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty name shows the name error', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo, allowRegistration: true);
      await openRegister(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), 'user@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionCreateAccount));
      await tester.pump();

      expect(find.text(t.validationEnterName), findsOneWidget);
      expect(repo.registerCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('short create-password shows the 6-char error',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo, allowRegistration: true);
      await openRegister(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Sam Example');
      await tester.enterText(fields.at(1), 'user@example.com');
      await tester.enterText(fields.at(2), '123');
      await tester.pump();
      await tester.tap(find.text(t.loginActionCreateAccount));
      await tester.pump();

      expect(find.text(t.validationPassword6Chars), findsOneWidget);
      expect(repo.registerCalls, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('login validation (rtl/ar)', () {
    testWidgets('empty identifier surfaces Arabic copy under ar',
        (tester) async {
      final t = arAuthL10n();
      await pumpLoginView(tester, locale: const Locale('ar'));

      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
