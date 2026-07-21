import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

class OwnerBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const OwnerBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
      (Icons.leaderboard_rounded, Icons.leaderboard_outlined, 'Top Sales'),
      (
        Icons.chat_bubble_rounded,
        Icons.chat_bubble_outline_rounded,
        'Messages',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.accent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.r24,
                          ),
                        ),
                        child: Icon(
                          sel ? items[i].$1 : items[i].$2,
                          color: sel ? AppColors.accent : AppColors.text3,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? AppColors.accent : AppColors.text3,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                          letterSpacing: sel ? 0.2 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
