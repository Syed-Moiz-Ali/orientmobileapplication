import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// Hairline–label–hairline divider (phase-1P, C16 auth grammar).
///
/// Separates the primary CTA from alternative paths ("or continue with …").
///
/// ```dart
/// AppOrDivider(label: 'or')
/// AppOrDivider(label: 'أو')
/// ```
///
/// - [label] is REQUIRED and caller-supplied (l10n): the widget never
///   hardcodes "or" or any language.
/// - Tokens only: 1 px hairlines in `outline`, label in `labelMedium` with
///   `onSurfaceVariant`. Directional-safe (hairlines flex symmetrically).
/// - Display-only separator; the label text stays exposed to screen readers
///   while the hairlines are plain [Divider]s. Wraps at text scale 1.3x.
class AppOrDivider extends StatelessWidget {
  /// Center label, e.g. "or" (localized by the caller).
  final String label;

  const AppOrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: scheme.outline)),
      ],
    );
  }
}
