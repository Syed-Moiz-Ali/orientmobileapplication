import 'package:flutter/material.dart';
import 'advisor_bottom_item.dart';

class AdvisorBottomNav extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavChanged;
  final VoidCallback onShowProfile;

  const AdvisorBottomNav({
    super.key,
    required this.navIndex,
    required this.onNavChanged,
    required this.onShowProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  children: [
                    AdvisorBottomItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Home',
                      active: navIndex == 0,
                      onTap: () => onNavChanged(0),
                    ),
                    AdvisorBottomItem(
                      icon: Icons.assignment_outlined,
                      label: 'Jobs',
                      active: navIndex == 1,
                      onTap: () => onNavChanged(1),
                    ),
                    const SizedBox(width: 48), // Gap for floating action button
                    AdvisorBottomItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      active: navIndex == 2,
                      onTap: () => onNavChanged(2),
                    ),
                    AdvisorBottomItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      active: navIndex == 3,
                      onTap: () {
                        onNavChanged(3);
                        onShowProfile();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

