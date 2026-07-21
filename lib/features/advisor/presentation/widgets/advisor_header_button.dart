import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';

class AdvisorHeaderButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const AdvisorHeaderButton({
    super.key,
    required this.label,
    this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.surface : Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: isPrimary
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isPrimary ? AppColors.navy : Colors.white, size: 15),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.rajdhaniButton(
                color: isPrimary ? AppColors.navy : Colors.white,
              ).copyWith(fontSize: 14, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    ),
  );
}
