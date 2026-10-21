// Phase-2b characterization: login local validation (migrated to the
// one-screen form).
//
// Guards the CURRENT inline-error copy + routing so the redesign preserves
// them: empty identifier, invalid email, short phone, empty password, short
// create-password, and empty name in register mode. One-screen mapping: a
// single Continue validates the identifier AND the password together (fires
// ZERO API calls on any invalid input); R1 validates the name and R3 the
// created password.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('login local validation (password mode)', () {
    testWidgets('empty identifier shows the mapped inline error',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      expect(find.text(t.loginTitle), findsOneWidget);
      // Both fields share the single screen.
      expect(find.byType(AppInputField), findsNWidgets(2));
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(repo.loginCalls, 0);
      expect(repo.sendOtpCalls, 0);
      expect(repo.sendEmailOtpCalls, 0);
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
      expect(repo.sendOtpCalls, 0);
      expect(repo.sendEmailOtpCalls, 0);
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

      // One screen: a valid identifier alone still submits nothing until the
      // password is filled — a single tap validates both fields together.
      expect(find.text(t.loginTitle), findsOneWidget);
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
          .widgetList<AppInputField>(find.byType(AppInputField))
          .firstWhere((f) => f.label == t.loginFieldPassword);
      expect(passwordField.error, t.validationEnterPassword);
      expect(repo.loginCalls, 0);
      expect(repo.sendOtpCalls, 0);
      expect(repo.sendEmailOtpCalls, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('login local validation (register mode)', () {
    Future<void> openRegister(WidgetTester tester) async {
      final t = enAuthL10n();
      await tapAndSettleStep(tester, find.text(t.loginStepCreateAccountRow));
    }

    testWidgets('register toggle reveals the name field', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester, allowRegistration: true);
      await openRegister(tester);

      expect(find.text(t.loginStepRegisterNameTitle), findsOneWidget);
      expect(find.text(t.loginFieldFullName), findsOneWidget);
      expect(find.text(t.loginActionContinue), findsOneWidget);
      // The create-account CTA lives only on R3, not on R1.
      expect(find.text(t.loginActionCreateAccount), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty name shows the name error', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo, allowRegistration: true);
      await openRegister(tester);

      await tester.tap(find.text(t.loginActionContinue));
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

      await tester.enterText(find.byType(TextField).first, 'Sam Example');
      await tester.pump();
      await tapAndSettleStep(tester, find.text(t.loginActionContinue));
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();
      await tapAndSettleStep(tester, find.text(t.loginActionContinue));

      expect(find.text(t.loginStepRegisterPasswordTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '123');
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

      expect(find.text(t.loginTitle), findsOneWidget);
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
