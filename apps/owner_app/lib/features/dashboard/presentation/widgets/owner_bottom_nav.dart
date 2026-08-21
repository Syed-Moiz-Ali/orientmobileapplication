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
    return AppBottomNavigation(
      items: items,
      selectedIndex: selectedIndex,
      onSelected: onTap,
    );
  }
}
