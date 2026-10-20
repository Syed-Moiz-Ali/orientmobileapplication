import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_tokens.dart';
import 'package:shared_core/src/widgets/app_bottom_nav.dart';

/// NavigationRail variant of [AppBottomNav] for medium/expanded breakpoints
/// (phase-1e-i companion to `app_bottom_nav.dart`).
///
/// Same [AppBottomNavItem] list (max 5), labels always shown, active icon in
/// accent with a soft accentSoft indicator, inactive icons in textTertiary.
/// Give it a bounded height (it fills what the layout offers).
///
/// Named `AppNavRail` because the legacy `AppNavigationRail` in
/// `layout/app_adaptive_navigation.dart` owns that name and is off-limits;
/// no rename is planned (the two rails serve different shells).
///
/// ```dart
/// SizedBox(
///   height: 320,
///   child: Row(children: [
///     AppNavRail(items: items, currentIndex: index, onTap: go),
///     Expanded(child: BodyWidget()),
///   ]),
/// )
/// ```
///
/// - Tokens only, caller-supplied labels, badge mirrors in RTL via
///   [AppNavBadgedIcon]. Text scale 1.3x: rail labels wrap instead of
///   clipping.
class AppNavRail extends StatelessWidget {
  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      items.isNotEmpty && items.length <= 5,
      'AppNavRail supports 1-5 destinations',
    );
    final scheme = Theme.of(context).colorScheme;
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0.0,
      backgroundColor: scheme.surface,
      indicatorColor: AppTokens.of(context).accentSoft,
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: AppNavBadgedIcon(
              icon: item.icon,
              color: scheme.onSurfaceVariant,
              badgeCount: item.badgeCount,
            ),
            selectedIcon: AppNavBadgedIcon(
              icon: item.icon,
              color: scheme.primary,
              badgeCount: item.badgeCount,
            ),
            label: Text(item.label),
          ),
      ],
    );
  }
}
