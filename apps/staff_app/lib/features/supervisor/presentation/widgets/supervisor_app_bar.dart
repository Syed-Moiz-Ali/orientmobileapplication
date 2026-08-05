import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/staff_notification_bell.dart';

class SupervisorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  const SupervisorAppBar({super.key, required this.selectedIndex});

  static const _titles = [
    'Dashboard',
    'Assign Work',
    'Work List',
    'Queue',
    'Review',
    'Staff',
    'Schedule',
    'Reports',
  ];
  static const _subtitles = [
    'Overview & Analytics',
    'Assign Tasks to Technicians',
    'All Job Assignments',
    'Route bookings & breakdowns',
    'Approve completed work',
    'Team Overview',
    'Today\'s Jobs',
    'Job Statistics',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.navy, AppColors.accent]),
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
          child: const Icon(
            Icons.build_circle_rounded,
            color: Colors.white,
            size: AppDimensions.iconLg,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _titles[selectedIndex],
            style: AppTextStyles.rajdhaniLabel(color: Colors.white),
          ),
          Text(
            _subtitles[selectedIndex],
            style: AppTextStyles.rajdhaniBodySmall(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        const StaffNotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(
            initials: 'S',
            onTap: () => showProfileSheet(context, _profileData(context)),
          ),
        ),
      ],
    );
  }
}

ProfileSheetData _profileData(BuildContext context) => ProfileSheetData(
  name: 'Supervisor',
  initials: 'S',
  roleLabel: 'Supervisor',
  roleBadge: 'Admin \u2022 Auto Garage ERP',
  menuItems: [
    ProfileSheetItem(
      icon: Icons.person_outline_rounded,
      label: 'My Profile',
      onTap: () => context.push(AppRoutes.profile),
    ),
    ProfileSheetItem(
      icon: Icons.calendar_month_outlined,
      label: 'Shift Details',
      onTap: () => context.push(AppRoutes.shiftDetails),
    ),
    ProfileSheetItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      onTap: () => context.push(AppRoutes.settings),
    ),
  ],
);
