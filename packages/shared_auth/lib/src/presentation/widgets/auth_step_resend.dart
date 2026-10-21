import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/providers/login_provider.dart';
import 'package:shared_core/shared_core.dart';

/// Isolated resend control for the login code-confirm step.
///
/// Replaces [AuthResendAction] (deleted): the cooldown ring is gone — the
/// control is a plain tappable [AppTextButton] link when idle
/// ([loginActionResendCode]) and a disabled, screen-reader-readable countdown
/// ([loginActionResendIn]) while cooling down. No spinner lives beside the
/// countdown, so the orphan-spinner + detached-text layout failure cannot
/// recur.
///
/// Rebuild isolation: this widget watches ONLY
/// `loginProvider.select(resendCooldown)`, so the 1 Hz countdown ticks
/// rebuild this row alone — never the whole step. The parent step must NOT
/// `ref.watch(loginProvider)` wholesale; it selects every other slice it
/// needs and leaves the cooldown to this row.
class LoginResendRow extends ConsumerWidget {
  final bool busy;
  final VoidCallback onResend;

  const LoginResendRow({super.key, required this.busy, required this.onResend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cooldown = ref.watch(
      loginProvider.select((s) => s.resendCooldown),
    );
    final t = SharedAuthL10n.of(context);
    final waiting = cooldown > 0;

    if (waiting) {
      return Semantics(
        liveRegion: true,
        label: t.loginActionResendIn(cooldown),
        child: AppTextButton(
          label: t.loginActionResendIn(cooldown),
          onPressed: null,
        ),
      );
    }
    return AppTextButton(
      label: t.loginActionResendCode,
      onPressed: busy ? null : onResend,
    );
  }
}

/// Isolated resend control for the recovery reset step.
///
/// Same link + countdown grammar as [LoginResendRow], driven by a caller-owned
/// [ValueNotifier] instead of Riverpod so the 1 Hz ticks rebuild only the
/// [ValueListenableBuilder] below — never the whole reset step. The parent
/// updates `cooldown.value` once per second; no `setState` on the step.
class ForgotResendRow extends StatelessWidget {
  final ValueNotifier<int> cooldown;
  final bool busy;
  final VoidCallback onResend;

  const ForgotResendRow({
    super.key,
    required this.cooldown,
    required this.busy,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final t = SharedAuthL10n.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: cooldown,
      builder: (context, seconds, _) {
        if (seconds > 0) {
          return Semantics(
            liveRegion: true,
            label: t.loginActionResendIn(seconds),
            child: AppTextButton(
              label: t.loginActionResendIn(seconds),
              onPressed: null,
            ),
          );
        }
        return AppTextButton(
          label: t.loginActionResendCode,
          onPressed: busy ? null : onResend,
        );
      },
    );
  }
}
