// Phase-2b characterization: resend cooldown on login.
//
// After a code send, resend shows the 30s cooldown countdown and is disabled.
// Only the START state is asserted — the suite never waits 30 real seconds.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('login resend cooldown', () {
    testWidgets('after send, resend shows 30s countdown and is disabled',
        (tester) async {
      final t = enAuthL10n();
      final container = await pumpLoginView(tester);

      await tapAndSettleMode(tester, find.text(t.authMethodCode));
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.loginActionSendCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // START of the 30s window (no clock advance in this suite).
      expect(container.read(loginProvider).resendCooldown, 30);
      expect(
        find.text(t.loginActionResendIn(30)),
        findsOneWidget,
      );
      expect(find.text(t.loginActionResendCode), findsNothing);

      // Disabled while cooling down.
      final resend = tester.widget<AuthLinkButton>(
        find.widgetWithText(AuthLinkButton, t.loginActionResendIn(30)),
      );
      expect(resend.onPressed, isNull);

      // Progress ring beside the countdown copy.
      expect(
        find.descendant(
          of: find.byType(AuthResendAction),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('cooldown start state is stable across frames (no waiting)',
        (tester) async {
      final t = enAuthL10n();
      final container = await pumpLoginView(tester);

      await tester.tap(find.text(t.authMethodCode));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(TextField).first, '501234567');
      await tester.pump();
      await tester.tap(find.text(t.loginActionSendCode));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Plain frames do not advance the fake-async clock: the suite pins the
      // START state and never waits out the 30s loop.
      await tester.pump();
      await tester.pump();
      expect(container.read(loginProvider).resendCooldown, 30);
      expect(find.text(t.loginActionResendIn(30)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
