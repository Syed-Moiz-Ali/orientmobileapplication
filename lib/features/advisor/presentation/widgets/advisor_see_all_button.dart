import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';

class AdvisorSeeAllButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AdvisorSeeAllButton(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 13),
        ],
      ),
    ),
  );
}
