import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Password-strength meter slot (Phase 01.2, no new backend).
///
/// Scores [password] 0–4 (length, mixed case, digit, symbol) and renders four
/// segment bars plus a localized level label. Pure scoring via
/// [passwordStrengthScore] keeps the widget independently testable. Styling
/// resolves through the theme only — weak maps to danger, fair to warning,
/// good to info, strong to success.
class AuthPasswordStrength extends StatelessWidget {
  final String password;

  const AuthPasswordStrength({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = SharedAuthL10n.of(context);

    final score = passwordStrengthScore(password);
    final (label, tone) = switch (score) {
      <= 1 => (t.authPasswordStrengthWeak, semantic.danger),
      2 => (t.authPasswordStrengthFair, semantic.warning),
      3 => (t.authPasswordStrengthGood, semantic.info),
      _ => (t.authPasswordStrengthStrong, semantic.success),
    };

    return Semantics(
      container: true,
      label: t.authPasswordStrengthLabel,
      value: label,
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: AppDimensions.s4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < score ? tone.base : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
              ),
            ),
          ],
          const SizedBox(width: AppDimensions.s8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tone.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pure password-strength score 0–4 (length ≥ 6/8, mixed case, digit, symbol).
int passwordStrengthScore(String password) {
  var score = 0;
  if (password.length >= 6) score++;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password) &&
      RegExp(r'[a-z]').hasMatch(password)) {
    score++;
  }
  if (RegExp(r'\d').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
  return score.clamp(0, 4);
}
