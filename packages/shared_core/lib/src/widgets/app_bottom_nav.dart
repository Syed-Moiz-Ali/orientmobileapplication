import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_badge.dart';

/// Destination for [AppBottomNav] and [AppNavRail].
class AppBottomNavItem {
  final String label;
  final IconData icon;
  final int? badgeCount;

  const AppBottomNavItem({
    required this.label,
    required this.icon,
    this.badgeCount,
  });
}

/// Spec-C8 bottom nav (phase-1e-i).
///
/// Max 5 items, min 64 + safe area, icon 24 + label 12 (labelSmall), active
/// = accent icon + textPrimary label (semibold + `selected` Semantics, never
/// color alone), inactive = textTertiary (`onSurfaceVariant`), badge support
/// via [AppBadge], >= 48 dp hit areas, labels wrap to 2 lines and grow the
/// bar at text scale 1.3x instead of clipping.
///
/// The NavigationRail variant for medium/expanded lives in
/// `app_nav_rail.dart` as [AppNavRail] (same items, labels always shown).
///
/// Name verified free in `packages/` (neighbours `AppBottomNavigation` and
/// `AppNavigationRail` own their names and are untouched); no rename needed.
///
/// ```dart
/// AppBottomNav(
///   items: const [
///     AppBottomNavItem(label: 'Home', icon: Icons.home_outlined),
///     AppBottomNavItem(label: 'Bookings', icon: Icons.book_outlined, badgeCount: 3),
///   ],
///   currentIndex: index,
///   onTap: go,
/// )
/// ```
class AppBottomNav extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      items.isNotEmpty && items.length <= 5,
      'AppBottomNav supports 1-5 destinations',
    );
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                _BarItem(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One bottom-bar destination: >= 48 dp, icon 24 + label 12.
class _BarItem extends StatelessWidget {
  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = selected ? scheme.onSurface : scheme.onSurfaceVariant;
    final iconColor = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: item.label,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppNavBadgedIcon(
                    icon: item.icon,
                    color: iconColor,
                    badgeCount: item.badgeCount,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    // Spec-conformant reflow: at large text scales a long
                    // label may wrap mid-word and grow the bar rather than
                    // clip — this is the specified wrapping behavior.
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ink,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 24 px icon with an optional [AppBadge] pinned to the directional top end
/// (mirrors in RTL). Display-only; the item Semantics carry the label.
/// Shared with [AppNavRail] (see `app_nav_rail.dart`).
class AppNavBadgedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int? badgeCount;

  const AppNavBadgedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: Icon(icon, size: 24, color: color)),
          if (badgeCount != null)
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: AppBadge(count: badgeCount!),
            ),
        ],
      ),
    );
  }
}
