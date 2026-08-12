import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_colors.dart';
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
            color: AppColors.bg,
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
              backgroundColor: AppColors.bg,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: adaptive.extendNavigationRail
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              indicatorColor: AppColors.darkNavy,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r14),
              ),
              selectedIconTheme: const IconThemeData(
                color: AppColors.cyanBright,
              ),
              unselectedIconTheme: IconThemeData(
                color: colorScheme.onSurfaceVariant,
              ),
              selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.darkNavy,
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
