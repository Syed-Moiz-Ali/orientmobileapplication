// Phase-2b characterization: one-time-code (OTP) step on login (migrated to
// the step flow).
//
// Covers the send-code transition (verify CTA appears), and that expired vs
// invalid backend codes render DISTINCT inline copy on the OTP field. The
// confirm step shows the masked destination line (new copy key) instead of
// the raw full-number banner.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Sends a code to a valid phone number via the Step 1 alt row.
/// Ends on the code-confirm step (default send handlers succeed).
Future<void> reachVerifyStep(WidgetTester tester) async {
  await reachCodeConfirm(tester, '501234567');
}

/// Masked-destination assertions use the shared [maskedPhoneTail] helper from
/// test_helpers (banner wraps its message in bidi isolates, so tests match
/// with containing-finders, never exact text).


void main() {
  setUpAll(loadAuthTestFonts);

  group('login OTP send-code flow', () {
    testWidgets('send-code sets otpSent: verify CTA appears + confirmation',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository();
      final container = await pumpLoginView(tester, repo: repo);

      await reachVerifyStep(tester);

      expect(repo.sendOtpCalls, 1);
      expect(container.read(loginProvider).otpSent, isTrue);
      expect(find.text(t.loginStepCodeTitle), findsOneWidget);
      expect(find.text(t.loginActionVerifyCode), findsOneWidget);
      expect(find.byType(AuthOtpField), findsOneWidget);
      // Masked destination line on the confirm step (never the raw number).
      expect(find.textContaining('We sent a code to'), findsOneWidget);
      expect(find.textContaining(maskedPhoneTail()), findsOneWidget);
      expect(find.textContaining('501234567'), findsNothing);
      // One-time-code confirmation arrives as an in-flow success banner
      // (phase-2 F-4: never an overlay, so it can't cover the resend row).
      expect(find.byType(AppBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('login OTP verify mapping', () {
    testWidgets('expired code renders the expired copy inline',
        (tester) async {
      final t = enAuthL10n();
      final repo = FakeAuthRepository()
        ..verifyOtpHandler = (_, __) async =>
            const Failure(ValidationException('otp expired, request another'));
      final container = await pumpLoginView(tester, repo: repo);
      await reachVerifyStep(tester);

      container.read(loginProvider.notifier).setOtp('123456');
      await tester.pump();
      await tester.tap(find.text(t.loginActionVerifyCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(t.errorOtpExpired), findsOneWidget);
      // The masked destination line is still up; no error snackbar joins
      // it — code failures never surface as snackbars.
      expect(find.textContaining('We sent a code to'), findsOneWidget);
      expect(find.textContaining(maskedPhoneTail()), findsOneWidget);
      expect(find.textContaining('501234567'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('invalid and expired codes render distinct copy',
        (tester) async {
      final t = enAuthL10n();
      // The two canonical copies must differ — the redesign keeps both.
      expect(t.errorOtpExpired, isNot(equals(t.errorOtpInvalid)));

      final repo = FakeAuthRepository()
        ..verifyOtpHandler = (_, __) async =>
            const Failure(ValidationException('that otp is invalid'));
      final container = await pumpLoginView(tester, repo: repo);
      await reachVerifyStep(tester);

      container.read(loginProvider.notifier).setOtp('123456');
      await tester.pump();
      await tester.tap(find.text(t.loginActionVerifyCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(t.errorOtpInvalid), findsOneWidget);
      expect(find.text(t.errorOtpExpired), findsNothing);
      // No error snackbar either — the destination line stands alone.
      expect(find.textContaining('We sent a code to'), findsOneWidget);
      expect(find.textContaining(maskedPhoneTail()), findsOneWidget);
      expect(find.textContaining('501234567'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
