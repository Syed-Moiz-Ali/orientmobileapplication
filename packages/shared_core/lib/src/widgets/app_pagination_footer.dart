import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Pagination footer (Phase 01.2 foundation primitive).
///
/// Shows the localized result count, the `Page X of Y` indicator and
/// previous/next actions. Disabled states resolve from the semantic disabled
/// tokens through the global button themes — no local greys.
class AppPaginationFooter extends StatelessWidget {
  final int page;
  final int totalPages;
  final int totalResults;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const AppPaginationFooter({
    super.key,
    required this.page,
    required this.totalPages,
    required this.totalResults,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedCoreL10n.of(context);

    return Semantics(
      container: true,
      label: t.paginationPageOf(page, totalPages),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s12,
          vertical: AppDimensions.s8,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.paginationPageOf(page, totalPages),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    t.paginationResults(totalResults),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            IconButton(
              onPressed: onPrevious,
              tooltip: t.paginationPrevious,
              style: IconButton.styleFrom(
                side: BorderSide(color: colors.outline),
                minimumSize: const Size.square(AppDimensions.touchTarget),
              ),
              icon: const DirectionalIcon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: AppDimensions.s8),
            IconButton(
              onPressed: onNext,
              tooltip: t.paginationNext,
              style: IconButton.styleFrom(
                side: BorderSide(color: colors.outline),
                minimumSize: const Size.square(AppDimensions.touchTarget),
              ),
              icon: const DirectionalIcon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
