import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// One crumb in an [AppBreadcrumbs] trail.
class AppBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const AppBreadcrumbItem({required this.label, this.onTap, this.icon});

  /// A non-interactive crumb (the current page).
  const AppBreadcrumbItem.current(this.label, {this.icon}) : onTap = null;
}

/// Desktop wayfinding trail for depth â‰¥2 pages (spec Â§6.5). Renders inline and
/// scrolls horizontally when the trail is longer than the available width, so
/// it never overflows or wraps. The separator chevron mirrors with the reading
/// direction via [DirectionalIcon].
class AppBreadcrumbs extends StatelessWidget {
  final List<AppBreadcrumbItem> items;
  final EdgeInsetsGeometry padding;

  const AppBreadcrumbs({
    super.key,
    required this.items,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      final label = Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isLast ? colors.onSurface : colors.primary,
          fontWeight: isLast ? FontWeight.w700 : FontWeight.w600,
        ),
      );

      if (isLast || item.onTap == null) {
        children.add(
          Semantics(
            header: isLast,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 14, color: colors.onSurfaceVariant),
                  const SizedBox(width: AppDimensions.s6),
                ],
                label,
              ],
            ),
          ),
        );
      } else {
        children.add(
          Semantics(
            button: true,
            child: InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s4,
                  vertical: AppDimensions.s4,
                ),
                child: label,
              ),
            ),
          ),
        );
      }

      if (!isLast) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s4),
            child: DirectionalIcon(
              Icons.chevron_right_rounded,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}
