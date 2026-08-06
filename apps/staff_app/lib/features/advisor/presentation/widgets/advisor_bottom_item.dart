import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorBottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AdvisorBottomItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    // P3 (audit): accessibility — labelled, selectable nav item.
    child: Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.r24),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.accent : AppColors.text3,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? AppColors.accent : AppColors.text3,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: active ? 0.2 : 0,
            ),
          ),
        ],
      ),
      ),
    ),
  );
}
