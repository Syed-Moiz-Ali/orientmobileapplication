// Phase-2b characterization: field-vs-form error routing on login (migrated
// to the one-screen form).
//
// Field-mapped backend failures render INLINE on their field (no snackbar);
// form-level failures (offline / 500) render as a snackbar WITH a retry
// action. The one-screen form preserves this split: identifier/password
// failures stay inline on the single screen, code failures on the confirm
// step.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Fills a valid identifier + password on the one-screen form, then submits.
Future<void> submitValidCredentials(
  WidgetTester tester,
  SharedAuthLocalizations t,
) async {
  await fillLoginForm(tester, 'user@example.com', 'secret123');
  await tester.tap(find.text(t.loginActionContinue));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadAuthTestFonts);

  group('field-mapped failures render inline (no snackbar)', () {
    testWidgets('unknown identifier maps inline to the identifier field',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async => const Failure(
              ValidationException('no account found for this email'),
            );
      await pumpLoginView(tester, repo: repo);
      await submitValidCredentials(tester, t);

      expect(repo.loginCalls, 1);
      // 'no account' backends map to the canonical not-found copy (not raw).
      expect(find.text(t.errorAccountNotFound), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('password failure maps inline to the password field',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(ValidationException('wrong password'));
      await pumpLoginView(tester, repo: repo);
      await submitValidCredentials(tester, t);

      expect(repo.loginCalls, 1);
      expect(find.text('wrong password'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid code maps inline to the OTP field', (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..verifyOtpHandler = (_, __) async =>
            const Failure(ValidationException('that otp is invalid'));
      final container = await pumpLoginView(tester, repo: repo);

      // One-screen alt row sends the code (default success handler).
      await reachCodeConfirm(tester, '501234567');
      expect(find.text(t.loginActionVerifyCode), findsOneWidget);

      container.read(loginProvider.notifier).setOtp('123456');
      await tester.pump();
      await tester.tap(find.text(t.loginActionVerifyCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Canonical invalid-code copy (not the raw message) on the OTP field.
      // The masked destination line is still up; no error snackbar joins
      // it — code failures never surface as snackbars.
      expect(find.text(t.errorOtpInvalid), findsOneWidget);
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(find.textContaining('We sent a code to'), findsOneWidget);
      expect(find.textContaining(maskedPhoneTail()), findsOneWidget);
      expect(find.textContaining('501234567'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('form-level failures render as snackbar with retry', () {
    testWidgets('offline failure shows offline copy + retry action',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async => const Failure(
              NetworkException('socket failed host lookup'),
            );
      await pumpLoginView(tester, repo: repo);
      await submitValidCredentials(tester, t);

      expect(repo.loginCalls, 1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(t.errorOfflineRetry), findsOneWidget);
      expect(find.text(t.authActionRetry), findsOneWidget);
      // Nothing lands inline on the fields (the en password hint shares its
      // copy with the error string, so pin this on field state, not text).
      final inlineErrors = tester
          .widgetList<AppInputField>(find.byType(AppInputField))
          .where((f) => f.error != null);
      expect(inlineErrors, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('server failure shows retry copy; retry resubmits',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..loginHandler = (_, __, ___) async =>
            const Failure(UnknownException('boom'));
      await pumpLoginView(tester, repo: repo);
      await submitValidCredentials(tester, t);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(t.errorServerRetryRef), findsOneWidget);
      expect(find.text(t.authActionRetry), findsOneWidget);

      await tester.tap(find.text(t.authActionRetry));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(repo.loginCalls, 2);
      expect(tester.takeException(), isNull);
    });
  });
}
