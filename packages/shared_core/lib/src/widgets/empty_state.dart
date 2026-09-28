import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_motion.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const EmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  });

  /// Unified Error state constructor
  const EmptyState.error({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.icon = Icons.error_outline_rounded,
    this.actionLabel = 'Retry',
    required VoidCallback onRetry,
  })  : onAction = onRetry,
        iconColor = const Color(0xFFDC2626),
        iconBackgroundColor = const Color(0xFFFEF2F2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s32),
        child: TweenAnimationBuilder<double>(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.emphasized,
          curve: AppMotion.enter,
          tween: Tween<double>(
            begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
            end: 1,
          ),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ambient Minimalist Icon Container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 28,
                    color: iconColor ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),

              // Optional Typographic Title
              if (title != null) ...[
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
              ],

              // Descriptive Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              // Optional Action Button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppDimensions.s24),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s20,
                      vertical: AppDimensions.s12,
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
