// Phase-2b characterization: one-time-code (OTP) step on login.
//
// Covers the send-code transition (verify CTA appears), and that expired vs
// invalid backend codes render DISTINCT inline copy on the OTP field.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

/// Switches to code mode and sends a code to a valid phone number.
/// Ends on the verify step (default send handlers succeed).
Future<void> reachVerifyStep(WidgetTester tester) async {
  final t = enAuthL10n();
  await tapAndSettleMode(tester, find.text(t.authMethodCode));
  await tester.enterText(find.byType(TextField).first, '501234567');
  await tester.pump();
  await tester.tap(find.text(t.loginActionSendCode));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

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
      expect(find.text(t.loginActionVerifyCode), findsOneWidget);
      expect(find.byType(AuthOtpField), findsOneWidget);
      // One-time-code confirmation arrives as an in-flow success banner
      // (phase-2 F-4: never an overlay, so it can't cover the resend row).
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.textContaining('Code sent to'), findsOneWidget);
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
      // The send-step success banner is still up; no error snackbar joins
      // it — code failures never surface as snackbars.
      expect(find.textContaining('Code sent to'), findsOneWidget);
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
      // No error snackbar either — the send-step success banner stands alone.
      expect(find.textContaining('Code sent to'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
