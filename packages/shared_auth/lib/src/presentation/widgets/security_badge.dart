import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Legal footnote rendered under the authentication form.
///
/// The copy is app-aware: callers pass the owning app's localized security
/// notice (from that app's ARB) through [text]; when omitted the shared generic
/// wording is used. This is what removes the previous "workshop" leak from
/// non-workshop apps such as CRM without duplicating widget code.
class SecurityBadge extends StatelessWidget {
  final String? text;

  const SecurityBadge({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = SharedAuthL10n.of(context);
    final message = text ?? t.authSecurityBadge;

    return Semantics(
      liveRegion: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.r2),
            child: Icon(
              Icons.lock_outline_rounded,
              size: AppDimensions.iconSm,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
