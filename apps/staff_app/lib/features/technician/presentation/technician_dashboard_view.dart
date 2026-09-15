import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/common/presentation/profile_screen.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_today_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_jobs_view.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_productivity_view.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_notification_sheet.dart';

class TechnicianDashboardView extends ConsumerWidget {
  const TechnicianDashboardView({super.key});

  static const _navItems = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Today',
    ),
    AppNavItem(
      selectedIcon: Icons.car_repair_rounded,
      icon: Icons.car_repair_outlined,
      label: 'Jobs',
    ),
    AppNavItem(
      selectedIcon: Icons.insights_rounded,
      icon: Icons.insights_outlined,
      label: 'Productivity',
    ),
    AppNavItem(
      selectedIcon: Icons.person_rounded,
      icon: Icons.person_outlined,
      label: 'Profile',
    ),
  ];

  static const _pages = <Widget>[
    TechnicianTodayView(),
    TechnicianJobsView(),
    TechnicianProductivityView(),
    StaffProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final adaptive = context.adaptive;
    final effectiveIndex = state.selectedTab < _pages.length
        ? state.selectedTab
        : 0;

    return DashboardShell(
      appBar: TechnicianAppBar(selectedIndex: effectiveIndex),
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: effectiveIndex,
        onSelected: notifier.selectTab,
        child: IndexedStack(index: effectiveIndex, children: _pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: _navItems,
              selectedIndex: effectiveIndex,
              onSelected: notifier.selectTab,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TECHNICIAN APP BAR (MATCHING SUPERVISOR AND ADVISOR STANDARDS)
// ─────────────────────────────────────────────────────────────────────────────
class TechnicianAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;
  const TechnicianAppBar({super.key, required this.selectedIndex});

  static const _titles = [
    'Workshop Bay',
    'My Job Cards',
    'Productivity',
    'Technician Profile',
  ];

  static const _subtitles = [
    'Shift Telemetry & Bay Repairs',
    'Assigned Vehicle Repair Orders',
    'Workshop Velocity & Attendance',
    'Personal & Shift Settings',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final profileName = notifier.profile.name.trim();
    final firstName = profileName.isEmpty
        ? 'Technician'
        : profileName.split(' ').first;
    final isToday = selectedIndex == 0;

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
      titleSpacing: 4,
      leadingWidth: 58,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12),
        child: UserAvatar(
          initials: notifier.profile.avatarInitials.isNotEmpty
              ? notifier.profile.avatarInitials
              : 'T',
          onTap: () {
            showProfileSheet(
              context,
              _profileSheetData(context, ref),
              onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
            );
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isToday ? 'Good to see you, $firstName' : _titles[selectedIndex],
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            isToday
                ? '${notifier.profile.branch.isEmpty ? 'Workshop bay' : notifier.profile.branch} · ${ref.watch(technicianDashboardProvider).attendanceStatus.label}'
                : _subtitles[selectedIndex],
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
      actions: [
        // Notification button
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => const AdvisorNotificationSheet(),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  ProfileSheetData _profileSheetData(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final profile = notifier.profile;
    final name = profile.name.isNotEmpty ? profile.name : 'Technician';
    final role = profile.role.isNotEmpty ? profile.role : 'Technician';

    final details = ProfileData(
      name: name,
      id: profile.empId,
      role: role,
      branch: profile.branch,
      shift: profile.shift,
      email: '',
      phone: '',
      avatarInitials: profile.avatarInitials,
    );

    return ProfileSheetData(
      name: name,
      initials: profile.avatarInitials.isNotEmpty
          ? profile.avatarInitials
          : 'T',
      roleLabel: role,
      roleBadge: profile.branch.isNotEmpty ? profile.branch : 'Workshop Bay',
      menuItems: [
        ProfileSheetItem(
          icon: Icons.person_outline_rounded,
          label: 'My Profile & Settings',
          onTap: () => context.push(AppRoutes.profile, extra: details),
        ),
        ProfileSheetItem(
          icon: Icons.fingerprint_rounded,
          label: 'Attendance · Punch Records',
          onTap: () => context.push(AppRoutes.attendance),
        ),
        ProfileSheetItem(
          icon: Icons.assignment_outlined,
          label: 'View Assigned Jobs',
          onTap: () {
            Navigator.pop(context);
            ref.read(technicianDashboardProvider.notifier).selectTab(1);
          },
        ),
      ],
    );
  }
}
