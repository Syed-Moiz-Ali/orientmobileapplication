import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Resend control shared by the one-time-code and recovery flows.
///
/// Token rebuild (phase-2c) of the previous bespoke control: the action is a
/// plain [AppTextButton] and the cooldown ring is a 16 px progress indicator
/// in primary ink. While [cooldownSeconds] is positive it renders the ring
/// (remaining fraction of the 30 s window) beside quiet countdown copy; at
/// zero it becomes the resend action. [busy] disables interaction without
/// changing the treatment, so resend never competes with the primary CTA.
///
/// The control is a single inline [Row] unit (phase-2 F-3): callers place it
/// beside the change-identifier link in an outer Wrap, and a Row child moves
/// to the next run as one piece — the spinner can never strand away from its
/// countdown with a dead gap between them.
///
/// There is no App* countdown control, so this auth-scoped composite stays —
/// composed purely of tokens + [AppTextButton].
class AuthResendAction extends StatelessWidget {
  final int cooldownSeconds;
  final bool busy;
  final VoidCallback onResend;

  const AuthResendAction({
    super.key,
    required this.cooldownSeconds,
    required this.busy,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = SharedAuthL10n.of(context);
    final waiting = cooldownSeconds > 0;

    // No Flexible around the action: as a non-flex child the button sizes
    // to its content (wrapping to two lines via AppTextButton when narrow),
    // so the Row hugs the spinner+countdown pair and the outer Wrap centers
    // the unit as one piece. A Flexible child would stretch the Row to the
    // full run width and strand the spinner from its text again.
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (waiting)
          SizedBox(
            width: AppDimensions.s16,
            height: AppDimensions.s16,
            child: CircularProgressIndicator(
              value: cooldownSeconds / 30,
              strokeWidth: 2.5,
              color: colors.primary,
              backgroundColor: colors.outlineVariant,
              semanticsLabel: t.loginActionResendIn(cooldownSeconds),
            ),
          ),
        if (waiting) const SizedBox(width: AppDimensions.s12),
        AppTextButton(
          label: waiting
              ? t.loginActionResendIn(cooldownSeconds)
              : t.loginActionResendCode,
          onPressed: waiting || busy ? null : onResend,
        ),
      ],
    );
  }
}
