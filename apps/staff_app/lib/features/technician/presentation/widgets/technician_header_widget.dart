import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';

class TechnicianHeaderWidget extends ConsumerWidget {
  const TechnicianHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final state = ref.watch(technicianDashboardProvider);
    final profile = notifier.profile;
    final status = state.attendanceStatus;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.navy, AppColors.accent]),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    profile.avatarInitials,
                    style: AppTextStyles.rajdhaniButton(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: AppTextStyles.rajdhaniButton(color: Colors.white),
                    ),
                    SizedBox(height: AppDimensions.s4),
                    Text(
                      '${profile.empId} \u2022 ${profile.branch}',
                      style: AppTextStyles.rajdhaniLabel(color: Colors.white70),
                    ),
                    SizedBox(height: AppDimensions.s4),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.s8,
                        vertical: AppDimensions.s4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.r20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: status == AttendanceStatus.working
                                  ? AppColors.accent
                                  : status == AttendanceStatus.onBreak
                                  ? AppColors.warning
                                  : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppDimensions.s4),
                          Text(
                            status.label,
                            style: AppTextStyles.rajdhaniBodySmall(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showProfile(context, ref),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      profile.avatarInitials.substring(0, 1),
                      style: AppTextStyles.rajdhaniBody(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfile(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final profile = notifier.profile;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.r28),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppDimensions.r2),
              ),
            ),
            SizedBox(height: AppDimensions.s24),
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
                  profile.avatarInitials,
                  style: AppTextStyles.rajdhaniTitle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.s14),
            Text(
              profile.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: AppDimensions.s4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.s12,
                vertical: AppDimensions.s4,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.r20),
              ),
              child: Text(
                '${profile.role} \u2022 ${profile.branch}',
                style: AppTextStyles.rajdhaniLabel(color: AppColors.accent),
              ),
            ),
            SizedBox(height: AppDimensions.s6),
            Text(
              'Shift: ${profile.shift}',
              style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text3),
            ),
            SizedBox(height: AppDimensions.s24),
            _menuItem(
              context,
              icon: Icons.person_outline_rounded,
              label: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.profile,
                  extra: ProfileData(
                    name: profile.name,
                    id: profile.empId,
                    role: profile.role,
                    branch: profile.branch,
                    shift: profile.shift,
                    avatarInitials: profile.avatarInitials,
                  ),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.calendar_month_outlined,
              label: 'Shift Details',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.shiftDetails,
                  extra: {
                    'name': profile.name,
                    'id': profile.empId,
                    'shift': profile.shift,
                    'start': profile.shift.split(' - ').first,
                    'end': profile.shift.split(' - ').last,
                    'branch': profile.branch,
                  },
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.settings, extra: {'version': '1.0.0'});
              },
            ),
            SizedBox(height: AppDimensions.s8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'Logout',
                  style: AppTextStyles.rajdhaniLabel(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.s6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s14,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.text2),
                SizedBox(width: AppDimensions.s12),
                Text(
                  label,
                  style: AppTextStyles.rajdhaniBody(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.text3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    if (HiveCleaner.hasPendingSync()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.r16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.sync_problem_rounded,
                color: AppColors.warning,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'Sync Pending',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'You have pending sync operations.\nPlease wait for sync to complete before logging out.',
            style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?\nAll local data will be cleared.',
          style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text3,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              HiveCleaner.clearAll().then((_) {
                if (context.mounted) context.go(AppRoutes.login);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Yes, Logout',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
