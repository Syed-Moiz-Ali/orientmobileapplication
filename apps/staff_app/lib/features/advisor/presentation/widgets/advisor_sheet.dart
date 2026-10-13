import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'advisor_handle.dart';

/// Content container for advisor modal sheets.
///
/// Provides the shared modal grammar (surface, rounded top, drag handle and
/// padding) used by every advisor sheet. Kept self-contained so it also works
/// when a sheet is presented directly by another workspace (the technician
/// dashboard reuses [AdvisorNotificationSheet], owned by Phase 10).
class AdvisorSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  const AdvisorSheet({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s20,
            0,
            AppDimensions.s20,
            AppDimensions.s20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.s8),
              const AdvisorHandle(),
              if (title != null) ...[
                const SizedBox(height: AppDimensions.s12),
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.s12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
