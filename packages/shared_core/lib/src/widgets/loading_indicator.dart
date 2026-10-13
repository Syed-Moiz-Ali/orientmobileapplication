import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.s16),
            Text(
              message!,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Deprecated (Phase 03B): use a shape-matched `AppSkeleton` variant
  /// (`AppSkeleton.listRows` / `.card` / `.table` / `.chart`) instead — a
  /// generic shimmer line does not mirror the final layout.
  @Deprecated(
    'Use an AppSkeleton variant (Phase 03B). Removed in a later phase.',
  )
  static const shimmer = ShimmerLoading();
}

/// Deprecated (Phase 03B): superseded by `AppSkeleton`, which mirrors the final
/// layout and honours reduced motion. Retained for source compatibility until
/// the owning feature phases replace their consumers
/// (owner/staff/customer shimmer files — see the 03B completion report).
@Deprecated('Use an AppSkeleton variant (Phase 03B). Removed in a later phase.')
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SizedBox(
        width: 180,
        child: LinearProgressIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          minHeight: 4,
        ),
      ),
    );
  }
}
