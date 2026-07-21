import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_divider.dart';
import 'advisor_menu_item.dart';

class AdvisorProfileSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const AdvisorProfileSheet({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdvisorHandle(),
          const SizedBox(height: 20),
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'AR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ali Rahman',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ADV-001 · Service Advisor',
            style: TextStyle(fontSize: 13, color: AppColors.text2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'On Shift — Morning',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AdvisorDivider(),
          AdvisorMenuItem(
            icon: Icons.person_outline_rounded,
            label: 'My Profile',
            onTap: () => Navigator.pop(context),
          ),
          AdvisorMenuItem(
            icon: Icons.swap_horiz_rounded,
            label: 'Switch Branch',
            onTap: () => Navigator.pop(context),
          ),
          AdvisorMenuItem(
            icon: Icons.schedule_rounded,
            label: 'Shift Details',
            onTap: () => Navigator.pop(context),
          ),
          AdvisorMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.pop(context),
          ),
          const AdvisorDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.danger),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
