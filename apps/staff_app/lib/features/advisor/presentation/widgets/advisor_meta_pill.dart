import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Compact icon + label metadata pill used in the advisor header.
class AdvisorMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const AdvisorMetaPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s6,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors.primary, size: AppDimensions.iconXs),
          const SizedBox(width: AppDimensions.s6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
