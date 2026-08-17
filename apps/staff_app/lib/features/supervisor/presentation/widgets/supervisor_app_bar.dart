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
    'Command Center',
    'Task Assignment',
    'Active Job Cards',
    'Dispatch Queue',
    'QC Verification',
    'Floor Specialists',
    'Bay Schedule',
    'Financial Intelligence',
  ];

  static const _subtitles = [
    'Shift Telemetry & Velocity',
    'Dispatch Tasks to Technicians',
    'Live Workshop Operations',
    'Incoming Bookings & Breakdowns',
    'Sign-off Completed Repairs',
    'Roster & Specialist Availability',
    'Service Bay Timelines',
    'Throughput & Analytics',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.speed_rounded, color: colors.primary, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _titles[selectedIndex],
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            _subtitles[selectedIndex],
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
      actions: [
        const StaffNotificationBell(),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(initials: 'S', onTap: () => showProfileSheet(context, _profileData(context))),
        ),
      ],
    );
  }
}

ProfileSheetData _profileData(BuildContext context) => ProfileSheetData(
  name: 'Supervisor',
  initials: 'S',
  roleLabel: 'Shift Lead',
  roleBadge: 'Workshop ERP Control',
  menuItems: [
    ProfileSheetItem(
      icon: Icons.person_outline_rounded,
      label: 'My Profile',
      onTap: () => context.push(AppRoutes.profile),
    ),
    ProfileSheetItem(
      icon: Icons.calendar_month_outlined,
      label: 'Shift Timeline',
      onTap: () => context.push(AppRoutes.shiftDetails),
    ),
    ProfileSheetItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push(AppRoutes.settings)),
  ],
);
