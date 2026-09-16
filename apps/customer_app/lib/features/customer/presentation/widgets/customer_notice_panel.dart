import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Compact, non-blocking notice with one recovery action.
///
/// Used wherever a section inside a screen fails to load while the rest of the
/// screen is still usable, so a failed availability request never blanks the
/// booking flow.
class CustomerNoticePanel extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final bool destructive;

  const CustomerNoticePanel({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.error_outline_rounded,
    this.destructive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = destructive ? colors.error : colors.primary;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(tone.withValues(alpha: 0.06), colors.surface),
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: AppDimensions.iconSm, color: tone),
              const SizedBox(width: AppDimensions.s6),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
        ],
      ),
    );
  }
}
