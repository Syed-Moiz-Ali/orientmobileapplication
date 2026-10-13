import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Locale-aware date chip (Latin digits, localized month name).
class AdvisorDateChip extends StatelessWidget {
  const AdvisorDateChip({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final label = AppFormatters.of(context).dateShort(DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s12,
        vertical: AppDimensions.s6,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
