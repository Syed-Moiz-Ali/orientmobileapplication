import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// A label/value detail line used across advisor sheets and the job-detail hub.
class AdvisorDetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdvisorDetailLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s12),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSm,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
