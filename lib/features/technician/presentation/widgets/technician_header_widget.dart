import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/technician/domain/entities/technician_entities.dart';
import 'package:orientmobileapplication/features/technician/providers/technician_providers.dart';

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
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
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
                    style: AppTextStyles.rajdhaniButton(
                      color: Colors.white,
                    ),
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
                      style: AppTextStyles.rajdhaniButton(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppDimensions.s4),
                    Text(
                      '${profile.empId} \u2022 ${profile.branch}',
                      style: AppTextStyles.rajdhaniLabel(
                        color: Colors.white70,
                      ),
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
                          width: 1,
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
                        border: Border.all(
                          color: AppColors.navy,
                          width: 1.5,
                        ),
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
                      style: AppTextStyles.rajdhaniBody(
                        color: Colors.white,
                      ),
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
                  style: AppTextStyles.rajdhaniTitle(
                    color: Colors.white,
                  ),
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
                style: AppTextStyles.rajdhaniLabel(
                  color: AppColors.accent,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.s6),
            Text(
              'Shift: ${profile.shift}',
              style: AppTextStyles.rajdhaniBodySmall(
                color: AppColors.text3,
              ),
            ),
            SizedBox(height: AppDimensions.s28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
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
                  style: AppTextStyles.rajdhaniLabel(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
