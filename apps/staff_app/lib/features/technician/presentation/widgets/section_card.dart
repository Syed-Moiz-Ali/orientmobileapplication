import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.r18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimensions.r2),
                  ),
                ),
                SizedBox(width: AppDimensions.s10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.r8),
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 15),
                ),
                SizedBox(width: AppDimensions.s10),
                Text(
                  title,
                  style: AppTextStyles.rajdhaniLabel(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(AppDimensions.s16), child: child),
        ],
      ),
    );
  }
}
