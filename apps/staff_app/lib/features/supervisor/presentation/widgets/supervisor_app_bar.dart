import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/staff_notification_bell.dart';

class SupervisorAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;
  const SupervisorAppBar({super.key, required this.selectedIndex});

  static const _titles = [
    'Command Center',
    'Task Assignment',
    'Dispatch Queue',
    'QC Verification',
    'Staff Profile',
  ];

  static const _subtitles = [
    'Shift Telemetry & Velocity',
    'Dispatch Tasks to Technicians',
    'Incoming Bookings & Breakdowns',
    'Sign-off Completed Repairs',
    'Personal & Shift Settings',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
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
          child: UserAvatar(
            initials: _profile(ref)?.initials ?? 'S',
            onTap: () => showProfileSheet(
              context,
              _profileSheetData(context, ref),
              onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
            ),
          ),
        ),
      ],
    );
  }
}

MeResponse? _profile(WidgetRef ref) {
  final auth = ref.read(authNotifierProvider);
  return auth is AuthAuthenticated ? auth.profile : null;
}

ProfileSheetData _profileSheetData(BuildContext context, WidgetRef ref) {
  final profile = _profile(ref);
  final name = profile?.name.isNotEmpty == true ? profile!.name : 'Supervisor';
  final role = profile?.designation.isNotEmpty == true
      ? profile!.designation
      : 'Supervisor';
  final details = ProfileData(
    name: name,
    id: profile?.empId ?? '',
    role: role,
    branch: profile?.branchName ?? '',
    shift: profile?.shift ?? '',
    email: profile?.email ?? '',
    phone: profile?.phone ?? '',
    avatarInitials: profile?.initials,
  );
  return ProfileSheetData(
    name: name,
    initials: profile?.initials ?? 'S',
    roleLabel: role,
    roleBadge: profile?.department.isNotEmpty == true
        ? profile!.department
        : 'Workshop operations',
    menuItems: [
      ProfileSheetItem(
        icon: Icons.person_outline_rounded,
        label: 'My Profile',
        onTap: () => context.push(AppRoutes.profile, extra: details),
      ),
      ProfileSheetItem(
        icon: Icons.fingerprint_rounded,
        label: 'Attendance · Punch In / Out',
        onTap: () => context.push(AppRoutes.attendance),
      ),
      ProfileSheetItem(
        icon: Icons.calendar_month_outlined,
        label: 'Shift Timeline',
        onTap: () => context.push(
          AppRoutes.shiftDetails,
          extra: {'shift': details.shift, 'branch': details.branch},
        ),
      ),
      ProfileSheetItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () => context.push(AppRoutes.settings),
      ),
    ],
  );
}
