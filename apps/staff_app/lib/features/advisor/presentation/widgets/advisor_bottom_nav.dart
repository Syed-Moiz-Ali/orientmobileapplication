import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
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
  Widget build(BuildContext context) => BottomAppBar(
    color: AppColors.surface,
    elevation: 0,
    shadowColor: Colors.transparent,
    notchMargin: 8,
    shape: const CircularNotchedRectangle(),
    child: Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
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
          const Expanded(child: SizedBox()),
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
  );
}

