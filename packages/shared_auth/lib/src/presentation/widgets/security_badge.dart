import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.r2),
          child: Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Flexible(
          child: Text(
            'By signing in, you agree to Orient Workshop Terms of Service & Privacy Policy.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
