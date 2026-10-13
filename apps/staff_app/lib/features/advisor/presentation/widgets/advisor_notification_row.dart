import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'advisor_notification_data.dart';

/// A single notification row in the advisor notification sheet.
class AdvisorNotificationRow extends StatelessWidget {
  final AdvisorNotificationData n;
  const AdvisorNotificationRow({super.key, required this.n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s8),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: n.color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(n.icon, color: n.color, size: 18),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            Text(
              n.time,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
