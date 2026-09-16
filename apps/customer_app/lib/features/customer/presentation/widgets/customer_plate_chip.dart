import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Registration plate rendered as a readable mono chip instead of a hardcoded
/// plate-coloured surface, so it stays legible in both light and dark themes.
class CustomerPlateChip extends StatelessWidget {
  final String plate;

  const CustomerPlateChip({super.key, required this.plate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outline),
      ),
      child: Text(
        plate.trim().toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurface,
          fontFamily: AppFontFamilies.mono,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
