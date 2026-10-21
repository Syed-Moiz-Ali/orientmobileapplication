// Phase-2b characterization: resend cooldown on login (migrated to the step flow).
//
// After a code send, resend shows the 30s countdown and is disabled.
// Only the START state is asserted — the suite never waits 30 real seconds.
// The cooldown ring is gone: the control is a link + countdown text only
// ([LoginResendRow], rebuilt in isolation — never the whole step).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'test_helpers.dart';

void main() {
  setUpAll(loadAuthTestFonts);

  group('login resend cooldown', () {
    testWidgets('after send, resend shows 30s countdown and is disabled',
        (tester) async {
      final t = enAuthL10n();
      final container = await pumpLoginView(tester);

      await reachCodeConfirm(tester, '501234567');

      // START of the 30s window (no clock advance in this suite).
      expect(container.read(loginProvider).resendCooldown, 30);
      expect(
        find.text(t.loginActionResendIn(30)),
        findsOneWidget,
      );
      expect(find.text(t.loginActionResendCode), findsNothing);

      // Disabled while cooling down.
      final resend = tester.widget<AppTextButton>(
        find.widgetWithText(AppTextButton, t.loginActionResendIn(30)),
      );
      expect(resend.onPressed, isNull);

      // Isolated resend row, link + text only — the cooldown ring is gone.
      expect(find.byType(LoginResendRow), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cooldown start state is stable across frames (no waiting)',
        (tester) async {
      final t = enAuthL10n();
      final container = await pumpLoginView(tester);

      await reachCodeConfirm(tester, '501234567');

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
