// One-screen contract (new): the collapsed password login keeps the
// notifier contract byte-for-byte while putting both fields on one screen.
//
// Pins what the characterization files cannot: a single AutofillGroup carries
// username + password hints together (password-managergable); focus order is
// identifier → password; the password keyboard action submits; one Continue
// validates both fields with zero API on failure; the notifier sees the SAME
// calls/args/counts (email→email slot, phone→normalized phone slot,
// password passthrough) and the SAME routing (success fires once).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('one-screen autofill + focus + keyboard', () {
    testWidgets('one AutofillGroup holds username + password together',
        (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);

      // Exactly one group on the password screen (register/code steps own
      // theirs on their own screens).
      expect(find.byType(AutofillGroup), findsOneWidget);
      final fields = tester.widgetList<AppInputField>(
        find.byType(AppInputField),
      );
      expect(fields.length, 2);
      final identifier = fields.firstWhere(
        (f) => f.label == t.loginFieldIdentifier,
      );
      final password = fields.firstWhere(
        (f) => f.label == t.loginFieldPassword,
      );
      expect(identifier.autofillHints, contains(AutofillHints.username));
      expect(password.autofillHints, contains(AutofillHints.password));
      expect(tester.takeException(), isNull);
    });

    testWidgets('focus order is identifier then password', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);

      final fields = tester.widgetList<AppInputField>(
        find.byType(AppInputField),
      );
      final identifier = fields.firstWhere(
        (f) => f.label == t.loginFieldIdentifier,
      );
      final password = fields.firstWhere(
        (f) => f.label == t.loginFieldPassword,
      );
      expect(identifier.textInputAction, TextInputAction.next);
      expect(password.textInputAction, TextInputAction.done);

      // Keyboard "next" on the identifier lands focus on the password field.
      identifier.focusNode?.requestFocus();
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(password.focusNode?.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password keyboard action submits the form', (tester) async {
      final repo = FakeAuthRepository();
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      await fillLoginForm(tester, 'user@example.com', 'secret123');
      final passwordField = tester
          .widget<TextField>(find.byType(TextField).at(1));
      passwordField.focusNode?.requestFocus();
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('one-screen validation timing + notifier contract', () {
    testWidgets('one Continue validates both fields with zero API',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();

      expect(find.text(t.validationEnterIdentifier), findsOneWidget);
      expect(find.text(t.validationEnterPassword), findsWidgets);
      expect(repo.loginCalls, 0);
      expect(repo.sendOtpCalls, 0);
      expect(repo.sendEmailOtpCalls, 0);
      expect(repo.registerCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('email identifier reaches the email slot, password passes',
        (tester) async {
      final t = enAuthL10n();
      String? gotEmail;
      String? gotPhone;
      String? gotPassword;
      final repo = FakeAuthRepository()
        ..loginHandler = (email, phone, password) async {
          gotEmail = email;
          gotPhone = phone;
          gotPassword = password;
          return Success(FakeAuthRepository.authResult());
        };
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      await fillLoginForm(tester, 'lead@orient.ae', 'secret123');
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(gotEmail, 'lead@orient.ae');
      expect(gotPhone, isEmpty);
      expect(gotPassword, 'secret123');
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone identifier reaches the normalized phone slot',
        (tester) async {
      final t = enAuthL10n();
      String? gotEmail;
      String? gotPhone;
      final repo = FakeAuthRepository()
        ..loginHandler = (email, phone, password) async {
          gotEmail = email;
          gotPhone = phone;
          return Success(FakeAuthRepository.authResult());
        };
      var successes = 0;
      await pumpLoginView(
        tester,
        repo: repo,
        onLoginSuccess: () => successes++,
      );

      await fillLoginForm(tester, '501234567', 'secret123');
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Same normalization the notifier always applied (UAE dial prefix).
      expect(repo.loginCalls, 1);
      expect(gotEmail, isEmpty);
      expect(gotPhone, '971501234567');
      expect(successes, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password login costs one tap from launch', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      await pumpLoginView(tester, repo: repo);

      // BEFORE = 1 tap (old single screen), AFTER = 1 tap (one screen).
      await fillLoginForm(tester, 'user@example.com', 'secret123');
      await tester.tap(find.text(t.loginActionContinue));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.loginCalls, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('one-screen 320px layout', () {
    testWidgets('both fields + CTA fit without overflow', (tester) async {
      final t = enAuthL10n();
      await pumpLoginView(tester);
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await tester.pump();

      expect(find.text(t.loginTitle), findsOneWidget);
      expect(find.byType(AppInputField), findsNWidgets(2));
      expect(
        find.widgetWithText(AppPillButton, t.loginActionContinue),
        findsOneWidget,
      );
      expect(find.text(t.loginStepUseCodeInstead), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
