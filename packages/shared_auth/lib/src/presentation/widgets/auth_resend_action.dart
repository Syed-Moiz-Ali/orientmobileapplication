import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Resend control shared by the one-time-code and recovery flows.
///
/// Token rebuild (phase-2c) of the previous bespoke control: the action is a
/// plain [AppTextButton] and the cooldown ring is a 20 px progress indicator
/// in primary ink on the outline hairline. While [cooldownSeconds] is positive
/// it renders the ring (remaining fraction of the 30 s window) beside quiet
/// countdown copy; at zero it becomes the resend action. [busy] disables
/// interaction without changing the treatment, so resend never competes with
/// the primary CTA.
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

    // Wrap (not Row): callers already place this beside the change-identifier
    // link in an outer Wrap, and during the AnimatedSwitcher send transition
    // the row measured a transient frame 140 px over at 320 px widths — a
    // Wrap child can itself wrap instead of overflowing. Steady-state visual
    // is unchanged (ring + 8 gap + action, centered).
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppDimensions.s8,
      runSpacing: AppDimensions.s4,
      children: [
        if (waiting)
          SizedBox(
            width: AppDimensions.iconMd,
            height: AppDimensions.iconMd,
            child: CircularProgressIndicator(
              value: cooldownSeconds / 30,
              strokeWidth: 2.5,
              color: colors.primary,
              backgroundColor: colors.outlineVariant,
              semanticsLabel: t.loginActionResendIn(cooldownSeconds),
            ),
          ),
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
