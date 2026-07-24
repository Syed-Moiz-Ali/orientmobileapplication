import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
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
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.profile, extra: ProfileData(
                name: 'Ali Rahman',
                id: 'ADV-001',
                role: 'Service Advisor',
                branch: 'Main Branch - Dubai',
                shift: 'Morning (8:00 AM - 5:00 PM)',
                email: 'ali.rahman@orientauto.com',
                phone: '+971 50 123 4567',
                totalJobs: 12,
                completedJobs: 8,
                pendingJobs: 3,
              ));
            },
          ),
          AdvisorMenuItem(
            icon: Icons.swap_horiz_rounded,
            label: 'Switch Branch',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Branch switching coming soon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              ));
            },
          ),
          AdvisorMenuItem(
            icon: Icons.schedule_rounded,
            label: 'Shift Details',
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.shiftDetails, extra: {
                'name': 'Ali Rahman',
                'id': 'ADV-001',
                'shift': 'Morning',
                'start': '8:00 AM',
                'end': '5:00 PM',
                'branch': 'Main Branch - Dubai',
              });
            },
          ),
          AdvisorMenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.settings, extra: {
                'version': '1.0.0',
              });
            },
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

class ProfileData {
  final String name;
  final String id;
  final String role;
  final String branch;
  final String shift;
  final String email;
  final String phone;
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;

  const ProfileData({
    required this.name,
    required this.id,
    required this.role,
    required this.branch,
    required this.shift,
    required this.email,
    required this.phone,
    required this.totalJobs,
    required this.completedJobs,
    required this.pendingJobs,
  });
}

