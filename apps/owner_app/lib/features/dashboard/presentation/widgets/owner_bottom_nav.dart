import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class OwnerBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const OwnerBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: SizedBox(
        height: 66,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.72),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.16),
                    blurRadius: 28,
                    spreadRadius: -6,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: List.generate(items.length, (i) {
                    final sel = selectedIndex == i;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: sel,
                        label: items[i].label,
                        child: InkWell(
                          onTap: () => onTap(i),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 7,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  width: sel ? 42 : 34,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.12,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    sel ? items[i].selectedIcon : items[i].icon,
                                    color: sel
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    size: sel ? 22 : 21,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Flexible(
                                  child: Text(
                                    items[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: sel
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: sel
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 11,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
