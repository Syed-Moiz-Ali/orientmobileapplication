import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_motion.dart';

/// Shared navigation design language for every Orient workspace.
///
/// Roles have different numbers of destinations, so the frame adapts rather
/// than forcing one structure on every app:
/// - compact (phone): [AppBottomNavigation], with a deliberate "More"
///   overflow once a bar would become crowded.
/// - medium / expanded: [AppNavigationRail] (icon rail, labels on the largest
///   breakpoints).
/// - many destinations on compact: [AppNavDrawer].
///
/// All three surfaces share the same selected-state vocabulary: a cobalt tint
/// chip, a filled selected icon and a heavier label. Colour is never the only
/// cue.
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

/// Single cobalt tint used for every selected navigation surface so the bar,
/// rail and drawer read as one product.
const double _selectedTint = 0.12;
const double _extendedRailWidth = 224;
const double _compactRailWidth = 78;

/// Ignores repeat selections so a second tap on the active destination does
/// not re-trigger navigation or haptics unnecessarily.
bool _isNewSelection(int index, int selectedIndex) => index != selectedIndex;

/// Lightweight, consistent selection feedback. Fired by the shared navigation
/// itself so individual applications do not each have to remember it.
void _selectHaptic() => HapticFeedback.selectionClick();

String _destinationSemantics(String label, {int? count, bool dot = false}) {
  if (count != null && count > 0) return '$label, $count new';
  if (dot) return '$label, new activity';
  return label;
}

/// Compact pending-activity badge. Renders a numeric pill when a real count is
/// available and a small dot otherwise.
class _NavBadge extends StatelessWidget {
  final int? count;

  const _NavBadge({this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasCount = count != null && count! > 0;

    if (!hasCount) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: colors.error,
          shape: BoxShape.circle,
          border: Border.all(color: colors.surface, width: 2),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: colors.surface, width: 1.5),
      ),
      child: Text(
        count! > 99 ? '99+' : '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.onError,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Full-width destination row used by the drawer and the "More" overflow
/// sheet.
class _NavDestinationTile extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool showBadgeDot;
  final bool showTrailingCheck;

  const _NavDestinationTile({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.showBadgeDot = false,
    this.showTrailingCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final badge = (badgeCount ?? 0) > 0 || showBadgeDot;

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: _destinationSemantics(
        item.label,
        count: badgeCount,
        dot: showBadgeDot,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standardCurve,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: _selectedTint)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: AppDimensions.iconMd,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? colors.primary : colors.onSurface,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (badge) ...[
                const SizedBox(width: AppDimensions.s8),
                _NavBadge(count: badgeCount),
              ] else if (showTrailingCheck && selected) ...[
                const SizedBox(width: AppDimensions.s8),
                Icon(
                  Icons.check_rounded,
                  size: AppDimensions.iconSm,
                  color: colors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact, non-floating bottom navigation. Stays content-sized so it grows
/// with text scale instead of clipping destinations.
class AppBottomNavigation extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Set<int> badgeIndices;
  final Map<int, int> badgeCounts;

  /// Total slots shown, including the "More" slot. Once [items] exceed this,
  /// the trailing destinations move into a deliberate overflow sheet so
  /// destinations never become tiny or unreadable.
  final int maxDestinations;

  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.badgeIndices = const {},
    this.badgeCounts = const {},
    this.maxDestinations = 5,
  });

  bool get _hasOverflow => items.length > maxDestinations;

  int get _visibleCount => _hasOverflow ? maxDestinations - 1 : items.length;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visibleCount = _visibleCount;
    final overflowSelected = _hasOverflow && selectedIndex >= visibleCount;
    final overflowBadge = _hasOverflow ? _overflowBadge(visibleCount) : null;

    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var index = 0; index < visibleCount; index++)
                Expanded(
                  child: _BottomDestination(
                    item: items[index],
                    selected: selectedIndex == index,
                    badgeCount: badgeCounts[index],
                    showBadgeDot: badgeIndices.contains(index),
                    onTap: () => _select(index),
                  ),
                ),
              if (_hasOverflow)
                Expanded(
                  child: _BottomDestination(
                    item: const AppNavItem(
                      selectedIcon: Icons.more_horiz_rounded,
                      icon: Icons.more_horiz_rounded,
                      label: 'More',
                    ),
                    selected: overflowSelected,
                    badgeCount: overflowBadge?.count,
                    showBadgeDot: overflowBadge?.dot ?? false,
                    onTap: () => _openOverflow(context, visibleCount),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Aggregates hidden activity so a badge is never lost inside the overflow
  /// slot. Real counts are summed; dot-only activity stays a dot.
  ({int? count, bool dot}) _overflowBadge(int start) {
    var count = 0;
    var dot = false;
    for (var index = start; index < items.length; index++) {
      final value = badgeCounts[index] ?? 0;
      if (value > 0) {
        count += value;
      } else if (badgeIndices.contains(index)) {
        dot = true;
      }
    }
    return (count: count > 0 ? count : null, dot: dot);
  }

  void _select(int index) {
    if (_isNewSelection(index, selectedIndex)) _selectHaptic();
    onSelected(index);
  }

  Future<void> _openOverflow(BuildContext context, int start) async {
    _selectHaptic();
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusSheet),
        ),
      ),
      builder: (_) => _NavOverflowSheet(
        items: items.sublist(start),
        startIndex: start,
        selectedIndex: selectedIndex,
        badgeIndices: badgeIndices,
        badgeCounts: badgeCounts,
      ),
    );
    if (selected != null) onSelected(selected);
  }
}

class _BottomDestination extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool showBadgeDot;

  const _BottomDestination({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.showBadgeDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final badge = (badgeCount ?? 0) > 0 || showBadgeDot;

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: _destinationSemantics(
        item.label,
        count: badgeCount,
        dot: showBadgeDot,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s4,
            vertical: AppDimensions.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.standardCurve,
                    width: 46,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary.withValues(alpha: _selectedTint)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusControl,
                      ),
                    ),
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      size: 22,
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  if (badge)
                    Positioned(
                      top: -4,
                      right: 3,
                      child: _NavBadge(count: badgeCount),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Deliberate overflow surface. Every destination stays directly reachable,
/// and the active destination is marked so users never lose their place.
class _NavOverflowSheet extends StatelessWidget {
  final List<AppNavItem> items;
  final int startIndex;
  final int selectedIndex;
  final Set<int> badgeIndices;
  final Map<int, int> badgeCounts;

  const _NavOverflowSheet({
    required this.items,
    required this.startIndex,
    required this.selectedIndex,
    required this.badgeIndices,
    required this.badgeCounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.s20,
              0,
              AppDimensions.s20,
              AppDimensions.s12,
            ),
            child: Text(
              'More',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s12,
                0,
                AppDimensions.s12,
                AppDimensions.s12,
              ),
              child: Column(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.s4),
                      child: _NavDestinationTile(
                        item: items[index],
                        selected: selectedIndex == startIndex + index,
                        badgeCount: badgeCounts[startIndex + index],
                        showBadgeDot: badgeIndices.contains(startIndex + index),
                        showTrailingCheck: true,
                        onTap: () =>
                            Navigator.of(context).pop(startIndex + index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom navigation rail. Icon-only on tablets to protect horizontal space,
/// labelled on the largest breakpoints where a workspace sidebar is expected.
class AppNavigationRail extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Set<int> badgeIndices;
  final Map<int, int> badgeCounts;
  final bool extended;
  final double compactWidth;
  final double extendedWidth;

  const AppNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.badgeIndices = const {},
    this.badgeCounts = const {},
    this.extended = false,
    this.compactWidth = _compactRailWidth,
    this.extendedWidth = _extendedRailWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: colors.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SizedBox(
            width: extended ? extendedWidth : compactWidth,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.s16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: extended
                          ? AppDimensions.s12
                          : AppDimensions.s8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0; index < items.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.s4,
                            ),
                            child: extended
                                ? _NavDestinationTile(
                                    item: items[index],
                                    selected: selectedIndex == index,
                                    badgeCount: badgeCounts[index],
                                    showBadgeDot: badgeIndices.contains(index),
                                    onTap: () => _select(index),
                                  )
                                : _RailIconDestination(
                                    item: items[index],
                                    selected: selectedIndex == index,
                                    badgeCount: badgeCounts[index],
                                    showBadgeDot: badgeIndices.contains(index),
                                    onTap: () => _select(index),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(int index) {
    if (_isNewSelection(index, selectedIndex)) _selectHaptic();
    onSelected(index);
  }
}

class _RailIconDestination extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool showBadgeDot;

  const _RailIconDestination({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.showBadgeDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final badge = (badgeCount ?? 0) > 0 || showBadgeDot;

    return Tooltip(
      message: item.label,
      child: Semantics(
        button: true,
        selected: selected,
        excludeSemantics: true,
        label: _destinationSemantics(
          item.label,
          count: badgeCount,
          dot: showBadgeDot,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: SizedBox(
            height: 48,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.standardCurve,
                    width: 46,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary.withValues(alpha: _selectedTint)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusControl,
                      ),
                    ),
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      size: 22,
                      color: selected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  if (badge)
                    Positioned(
                      top: 4,
                      right: 5,
                      child: _NavBadge(count: badgeCount),
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

/// Adaptive frame that decides between the rail and the plain body, keeping
/// the existing breakpoint strategy from [AppResponsive].
class AppAdaptiveNavigationFrame extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget child;
  final Set<int> badgeIndices;
  final Map<int, int> badgeCounts;

  const AppAdaptiveNavigationFrame({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.child,
    this.badgeIndices = const {},
    this.badgeCounts = const {},
  });

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;

    if (!adaptive.useNavigationRail) {
      return child;
    }

    return Row(
      children: [
        AppNavigationRail(
          items: items,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          badgeIndices: badgeIndices,
          badgeCounts: badgeCounts,
          extended: adaptive.extendNavigationRail,
          compactWidth: adaptive.navigationRailWidth,
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Shell-level drawer for workspaces with more destinations than a phone
/// bottom bar should carry. Keeps navigation in one visual language.
class AppNavDrawer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Set<int> badgeIndices;
  final Map<int, int> badgeCounts;
  final Widget? footer;

  const AppNavDrawer({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.subtitle,
    this.icon = Icons.grid_view_rounded,
    this.badgeIndices = const {},
    this.badgeCounts = const {},
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: _selectedTint),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                    ),
                    child: Icon(icon, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.s12),
                children: [
                  for (var index = 0; index < items.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.s4),
                      child: _NavDestinationTile(
                        item: items[index],
                        selected: selectedIndex == index,
                        badgeCount: badgeCounts[index],
                        showBadgeDot: badgeIndices.contains(index),
                        onTap: () {
                          if (_isNewSelection(index, selectedIndex)) {
                            _selectHaptic();
                          }
                          onSelected(index);
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}
