import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/core/widgets/notification_bell.dart';
import 'package:orientmobileapplication/core/widgets/user_avatar.dart';
import 'package:orientmobileapplication/core/widgets/profile_sheet.dart';

class SupervisorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  const SupervisorAppBar({super.key, required this.selectedIndex});

  static const _titles = ['Dashboard', 'Assign Work', 'Work List'];
  static const _subtitles = [
    'Overview & Analytics',
    'Assign Tasks to Technicians',
    'All Job Assignments',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, AppColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(AppDimensions.s10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.r10),
          ),
          child: const Icon(Icons.build_circle_rounded, color: Colors.white, size: AppDimensions.iconLg),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_titles[selectedIndex], style: AppTextStyles.rajdhaniLabel(color: Colors.white)),
          Text(_subtitles[selectedIndex], style: AppTextStyles.rajdhaniBodySmall(color: Colors.white70)),
        ],
      ),
      actions: [
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(initials: 'S', onTap: () => showProfileSheet(context, _profileData)),
        ),
      ],
    );
  }
}

const _profileData = ProfileSheetData(
  name: 'Supervisor',
  initials: 'S',
  roleLabel: 'Supervisor',
  roleBadge: 'Admin \u2022 Auto Garage ERP',
  menuItems: [
    ProfileSheetItem(icon: Icons.person_outline_rounded, label: 'My Profile', route: AppRoutes.profile, extra: {
      'name': 'Supervisor',
      'id': 'SUP-001',
      'role': 'Supervisor',
      'branch': 'Auto Garage ERP',
      'shift': '8:00 AM - 6:00 PM',
      'avatarInitials': 'S',
    }),
    ProfileSheetItem(icon: Icons.calendar_month_outlined, label: 'Shift Details', route: AppRoutes.shiftDetails, extra: {
      'name': 'Supervisor', 'id': 'SUP-001', 'shift': '8:00 AM - 6:00 PM',
      'start': '8:00 AM', 'end': '6:00 PM', 'branch': 'Auto Garage ERP',
    }),
    ProfileSheetItem(icon: Icons.settings_outlined, label: 'Settings', route: AppRoutes.settings, extra: {
      'version': '1.0.0',
    }),
  ],
);
