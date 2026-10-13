// Adaptive workspace navigation chrome (spec §6.1): bottom bar on compact,
// rail on medium+, extended rail at large. One selection vocabulary
// everywhere: cobalt tint + filled icon + heavier label (+ optional badge).
import 'package:flutter/material.dart';

import '../design/prototype_theme.dart';
import '../design/provisional_tokens.dart';
import 'proto_primitives.dart';

class ProtoNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;

  const ProtoNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge = 0,
  });
}

class ProtoWorkspaceNav extends StatelessWidget {
  final List<ProtoNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String brandPrimary;
  final String brandSecondary;
  final String profileName;
  final String profileRole;
  final bool extendRail;

  const ProtoWorkspaceNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.brandPrimary = 'ORIENT',
    this.brandSecondary = 'WORKSHOP SUITE',
    this.profileName = 'Khalid Al Suwaidi',
    this.profileRole = 'Owner',
    this.extendRail = false,
  });

  @override
  Widget build(BuildContext context) {
    if (context.windowClass.isCompact) {
      return _ProtoBottomNav(
        items: items,
        selectedIndex: selectedIndex,
        onSelect: onSelect,
      );
    }
    return _ProtoRail(
      items: items,
      selectedIndex: selectedIndex,
      onSelect: onSelect,
      brandPrimary: brandPrimary,
      brandSecondary: brandSecondary,
      profileName: profileName,
      profileRole: profileRole,
      extended: extendRail || context.windowClass.isLarge,
    );
  }
}

class _ProtoBottomNav extends StatelessWidget {
  final List<ProtoNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ProtoBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.borderDefault)),
        boxShadow: ProtoElevation.surface,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    label: items[i].badge > 0 ? '${items[i].label}, ${items[i].badge} new' : items[i].label,
                    child: InkWell(
                      onTap: () => onSelect(i),
                      hoverColor: p.hover,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: ProtoMotion.standard,
                            curve: ProtoMotion.standardCurve,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                            decoration: BoxDecoration(
                              color: i == selectedIndex ? p.selected : Colors.transparent,
                              borderRadius: BorderRadius.circular(ProtoRadius.pill),
                            ),
                            child: _NavIcon(
                              item: items[i],
                              selected: i == selectedIndex,
                              color: i == selectedIndex ? p.primary : p.textMuted,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: types.label.copyWith(
                              fontSize: 11,
                              color: i == selectedIndex ? p.primary : p.textMuted,
                              fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final ProtoNavItem item;
  final bool selected;
  final Color color;

  const _NavIcon({required this.item, required this.selected, required this.color});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected ? item.selectedIcon : item.icon, size: 22, color: color);
    if (item.badge <= 0) return icon;
    final p = context.palette;
    return SizedBox(
      width: 34,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: icon),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: p.danger,
                borderRadius: BorderRadius.circular(ProtoRadius.pill),
                border: Border.all(color: p.surface, width: 1.5),
              ),
              child: Text(
                '${item.badge}',
                style: context.types.metadata.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtoRail extends StatelessWidget {
  final List<ProtoNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String brandPrimary;
  final String brandSecondary;
  final String profileName;
  final String profileRole;
  final bool extended;

  const _ProtoRail({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.brandPrimary,
    required this.brandSecondary,
    required this.profileName,
    required this.profileRole,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final width = extended
        ? 224.0
        : (context.windowClass.isMedium ? 76.0 : 92.0);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: p.surface,
        border: BorderDirectional(
          end: BorderSide(color: p.borderDefault),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? ProtoSpace.s20 : ProtoSpace.s16,
              vertical: ProtoSpace.s20,
            ),
            child: extended
                ? _BrandLockup(primary: brandPrimary, secondary: brandSecondary)
                : _BrandMark(),
          ),
          const SizedBox(height: ProtoSpace.s8),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: 2),
              child: _RailItem(
                item: items[i],
                selected: i == selectedIndex,
                extended: extended,
                onTap: () => onSelect(i),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(ProtoSpace.s12),
            child: extended
                ? Row(
                    children: [
                      const ProtoAvatar(initials: 'KS'),
                      const SizedBox(width: ProtoSpace.s10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: types.bodyStrong.copyWith(color: p.textPrimary)),
                            Text(profileRole,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: types.metadata.copyWith(color: p.textMuted)),
                          ],
                        ),
                      ),
                      ProtoDirIcon(Icons.logout_rounded, size: 18, color: p.textMuted),
                    ],
                  )
                : const Center(child: ProtoAvatar(initials: 'KS')),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final ProtoNavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _RailItem({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;

    final content = Row(
      children: [
        _NavIcon(
          item: item,
          selected: selected,
          color: selected ? p.primary : p.textMuted,
        ),
        if (extended) ...[
          const SizedBox(width: ProtoSpace.s12),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: types.label.copyWith(
                color: selected ? p.primary : p.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: extended ? '' : item.label,
        child: AnimatedContainer(
          duration: ProtoMotion.standard,
          curve: ProtoMotion.standardCurve,
          decoration: BoxDecoration(
            color: selected ? p.selected : Colors.transparent,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
            hoverColor: p.hover,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? ProtoSpace.s12 : 0,
                vertical: ProtoSpace.s12,
              ),
              child: extended
                  ? content
                  : Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(ProtoRadius.card),
      ),
      child: const Icon(Icons.build_rounded, color: Colors.white, size: 22),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final String primary;
  final String secondary;

  const _BrandLockup({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return Row(
      children: [
        _BrandMark(),
        const SizedBox(width: ProtoSpace.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: types.cardTitle.copyWith(
                  color: p.textPrimary,
                  letterSpacing: context.isRtl ? 0 : 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: types.metadata.copyWith(
                  color: p.textMuted,
                  letterSpacing: context.isRtl ? 0 : 1.0,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
