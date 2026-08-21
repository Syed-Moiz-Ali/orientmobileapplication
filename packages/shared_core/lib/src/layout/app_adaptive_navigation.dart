import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class AppNavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  const AppNavItem({
    required this.selectedIcon,
    required this.icon,
    required this.label,
  });
}

class AppAdaptiveNavigationFrame extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;

  const AppAdaptiveNavigationFrame({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;

    if (!adaptive.useNavigationRail) {
      return child;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.14),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: NavigationRail(
              minWidth: adaptive.navigationRailWidth,
              extended: adaptive.extendNavigationRail,
              backgroundColor: colorScheme.surface,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: adaptive.extendNavigationRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r14),
              ),
              selectedIconTheme: IconThemeData(color: colorScheme.primary),
              unselectedIconTheme: IconThemeData(
                color: colorScheme.onSurfaceVariant,
              ),
              selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              destinations: [
                for (final item in items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class AppBottomNavigation extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Set<int> badgeIndices;

  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.badgeIndices = const {},
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (var index = 0; index < items.length; index++)
            NavigationDestination(
              icon: badgeIndices.contains(index)
                  ? Badge(child: Icon(items[index].icon))
                  : Icon(items[index].icon),
              selectedIcon: badgeIndices.contains(index)
                  ? Badge(child: Icon(items[index].selectedIcon))
                  : Icon(items[index].selectedIcon),
              label: items[index].label,
            ),
        ],
      ),
    );
  }
}
