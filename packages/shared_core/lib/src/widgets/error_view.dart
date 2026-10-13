import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/primary_button.dart';

class ErrorView extends StatelessWidget {
  final String message;

  /// Optional plain-language reason line (non-technical). Rendered under the
  /// message in muted ink; omit for a generic failure.
  final String? details;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (details != null) ...[
              const SizedBox(height: AppDimensions.s6),
              Text(
                details!,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.s24),
              PrimaryButton(
                label: SharedCoreL10n.of(context).commonRetry,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
