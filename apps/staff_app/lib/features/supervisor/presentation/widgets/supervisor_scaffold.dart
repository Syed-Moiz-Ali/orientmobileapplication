import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/staff_notification_bell.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_floor_search.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_reports_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_staff_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Supervisor workspace shell (Phase 11).
///
/// Greeting-style header owns identity (name, branch · shift, live floor-status
/// pill, Synced pill, notifications, profile) — no bespoke app bar (the Phase
/// 07.1 migration removed the bespoke `SupervisorAppBar`; this shell keeps the
/// shared navigation + offline vocabulary and adds the greeting header above
/// the tab stack, in home-grammar siblinghood with the advisor hub).
class SupervisorScaffold extends ConsumerStatefulWidget {
  const SupervisorScaffold({super.key});

  @override
  ConsumerState<SupervisorScaffold> createState() => _SupervisorScaffoldState();
}

class _SupervisorScaffoldState extends ConsumerState<SupervisorScaffold> {
  int _navIndex = 0;

  List<AppNavItem> _items(StaffLocalizations t) => <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: t.svNavFloor,
    ),
    AppNavItem(
      selectedIcon: Icons.assignment_rounded,
      icon: Icons.assignment_outlined,
      label: t.svNavJobs,
    ),
    AppNavItem(
      selectedIcon: Icons.alt_route_rounded,
      icon: Icons.alt_route_outlined,
      label: t.svNavQueue,
    ),
    AppNavItem(
      selectedIcon: Icons.verified_rounded,
      icon: Icons.verified_outlined,
      label: t.svNavReview,
    ),
    AppNavItem(
      selectedIcon: Icons.bar_chart_rounded,
      icon: Icons.bar_chart_outlined,
      label: t.svNavReports,
    ),
    AppNavItem(
      selectedIcon: Icons.groups_rounded,
      icon: Icons.groups_outlined,
      label: t.svNavStaff,
    ),
    AppNavItem(
      selectedIcon: Icons.calendar_month_rounded,
      icon: Icons.calendar_month_outlined,
      label: t.svNavSchedule,
    ),
  ];

  void _showProfile() {
    showProfileSheet(
      context,
      _profileSheetData(context, ref),
      onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
    );
  }

  void _openAssign() => showSupervisorAssignSheet(context);

  /// Bar search (U1): floor-wide bay lookup over the same derived board data
  /// the floor tab renders — no new routes, no logic changes. A result opens
  /// the same assign sheet a bay tap opens.
  void _openSearch() {
    HapticFeedback.selectionClick();
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final bays = buildSupervisorBays(
      awaiting: notifier.awaitingCompletions,
      jobs: notifier.jobs,
      bookings: notifier.bookings,
    );
    showSupervisorFloorSearch(
      context,
      bays: bays,
      onSelect: (_) => showSupervisorAssignSheet(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final adaptive = context.adaptive;
    final items = _items(t);

    return DashboardShell(
      // C16: connectivity announces only when abnormal via the banner — no
      // permanent "Synced" pill, never duplicated state.
      showOfflineBanner: true,
      appBar: _SupervisorChrome(
        selectedIndex: _navIndex,
        onSearch: _openSearch,
        onProfile: _showProfile,
      ),
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: _navIndex,
        onSelected: (index) => setState(() => _navIndex = index),
        headerBuilder: (ctx, ext) =>
            OrientBrandMark(workspace: t.svWorkspaceName, compact: !ext),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: _showProfile,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ext ? AppDimensions.s8 : 0,
              vertical: AppDimensions.s4,
            ),
            child: ext
                ? Row(
                    children: [
                      _SupervisorAvatar(
                        radius: 16,
                        initials: _profile(ref)?.initials ?? 'S',
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          t.svProfileLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: t.svProfileLabel,
                    child: _SupervisorAvatar(
                      radius: 18,
                      initials: _profile(ref)?.initials ?? 'S',
                    ),
                  ),
          ),
        ),
        child: Column(
          children: [
            _SupervisorGreetingHeader(
              onOpenFloor: () => setState(() => _navIndex = 0),
            ),
            Expanded(
              child: IndexedStack(
                index: _navIndex,
                children: [
                  SupervisorDashboardTab(
                    onOpenAssign: _openAssign,
                    onOpenQueue: () => setState(() => _navIndex = 2),
                    onOpenReview: () => setState(() => _navIndex = 3),
                  ),
                  SupervisorJobsTab(onOpenAssign: _openAssign),
                  SupervisorQueueTab(
                    onOpenReview: () => setState(() => _navIndex = 3),
                  ),
                  const SupervisorReviewTab(),
                  const SupervisorReportsTab(),
                  const SupervisorStaffTab(),
                  SupervisorScheduleTab(onOpenQueue: _openQueueFromSchedule),
                ],
              ),
            ),
          ],
        ),
      ),
      // STOP (shell-fix round 2): the 7-destination IA is a KEPT contract
      // (phase-5 brief flow: "bottom nav (7 items)") and spec C16 caps the
      // new AppBottomNav at 5 (asserts 1–5). Consolidating to 5 is a product
      // IA decision, not presentation — so the shared overflow bar stays
      // until the reviewer adjudicates. The AppBar above is migrated.
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: _navIndex,
              onSelected: (index) => setState(() => _navIndex = index),
            ),
    );
  }

  void _openQueueFromSchedule() => setState(() => _navIndex = 2);
}

/// Shell bar (shell-fix round 2): the shared spec-C8 [AppAppBar] (56,
/// hairline) with the per-tab title, the U1 search trigger (same floor-wide
/// bay lookup), the floor notification bell and the avatar (same profile
/// sheet). Single row, no offline pill (the abnormal-only banner owns it).
class _SupervisorChrome extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final VoidCallback onSearch;
  final VoidCallback onProfile;

  const _SupervisorChrome({
    required this.selectedIndex,
    required this.onSearch,
    required this.onProfile,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final profile = _profile(ref);
    final titles = <String>[
      t.svNavFloor,
      t.svNavJobs,
      t.svNavQueue,
      t.svNavReview,
      t.svNavReports,
      t.svNavStaff,
      t.svNavSchedule,
    ];

    return AppAppBar(
      title: titles[selectedIndex],
      showDivider: true,
      actions: [
        AppIconButton(
          icon: Icons.search_rounded,
          tooltip: t.svSearchTitle,
          onPressed: onSearch,
        ),
        const StaffNotificationBell(),
        SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: UserAvatar(
              initials: profile?.initials ?? 'S',
              onTap: () {
                HapticFeedback.selectionClick();
                onProfile();
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Greeting header: eyebrow date, greeting title, branch · shift context and
/// a live floor-status pill, full width. The bell/avatar/search moved to the
/// shell bar (U7 one path) and the permanent Synced pill is deleted (the
/// abnormal-only banner owns offline state) — which also cures the 320/1.3x
/// greeting + floor-pill truncation (the squeeze is gone, not the copy).
class _SupervisorGreetingHeader extends ConsumerWidget {
  final VoidCallback onOpenFloor;

  const _SupervisorGreetingHeader({required this.onOpenFloor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final profile = _profile(ref);
    final name = (profile?.name.isNotEmpty ?? false) ? profile!.name : 'Supervisor';
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime.now());
    final contextLine = [
      profile?.branchName ?? '',
      profile?.shift ?? '',
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    // Watching the state (not only the notifier) is what makes the pill update
    // the moment the async floor load replaces the empty first frame.
    final dashboard = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final occupied = (notifier.jobs.length +
            notifier.bookings.length +
            notifier.awaitingCompletions.length)
        .clamp(0, kSupervisorBayCount);
    final hasError = dashboard.dashboardError.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.s20,
        AppDimensions.s16,
        AppDimensions.s20,
        AppDimensions.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: AppTypography.tracking(context, 0.8),
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            t.svGreeting(name),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              letterSpacing: -0.2,
            ),
          ),
          if (contextLine.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s4),
            Text(
              contextLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s8),
          _FloorStatusPill(
            occupied: occupied,
            totalBays: kSupervisorBayCount,
            hasError: hasError,
            onTap: onOpenFloor,
          ),
        ],
      ),
    );
  }
}

/// Live workshop-floor status pill: success when bays are working, neutral when
/// the floor is quiet. Tapping returns to the floor board.
class _FloorStatusPill extends StatelessWidget {
  final int occupied;
  final int totalBays;
  final bool hasError;
  final VoidCallback onTap;

  const _FloorStatusPill({
    required this.occupied,
    required this.totalBays,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final label = t.svBaysOccupied(occupied, totalBays);
    final Widget pill;
    if (hasError) {
      pill = StatusPill.danger(
        t.svFloorErrorTitle,
        icon: Icons.cloud_off_rounded,
      );
    } else if (occupied > 0) {
      pill = StatusPill.success(label, icon: Icons.grid_view_rounded);
    } else {
      pill = StatusPill.neutral(label, icon: Icons.grid_view_rounded);
    }
    return TileTap(onTap: onTap, child: pill);
  }
}

/// Minimal tap wrapper that keeps the 48 dp touch target around a pill.
class TileTap extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const TileTap({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s4),
        child: child,
      ),
    );
  }
}

class _SupervisorAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  const _SupervisorAvatar({required this.radius, this.initials = 'S'});

  @override
  Widget build(BuildContext context) {
    return UserAvatar(initials: initials, size: radius * 2);
  }
}

MeResponse? _profile(WidgetRef ref) {
  final auth = ref.read(authNotifierProvider);
  return auth is AuthAuthenticated ? auth.profile : null;
}

ProfileSheetData _profileSheetData(BuildContext context, WidgetRef ref) {
  final t = StaffLocalizations.of(context)!;
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
        : t.svWorkspaceName,
    menuItems: [
      ProfileSheetItem(
        icon: Icons.person_outline_rounded,
        label: t.advisorProfileMyProfile,
        onTap: () => context.push(AppRoutes.profile, extra: details),
      ),
      ProfileSheetItem(
        icon: Icons.fingerprint_rounded,
        label: t.advisorProfileAttendance,
        onTap: () => context.push(AppRoutes.attendance),
      ),
      ProfileSheetItem(
        icon: Icons.calendar_month_outlined,
        label: t.svProfileShift,
        onTap: () => context.push(
          AppRoutes.shiftDetails,
          extra: {'shift': details.shift, 'branch': details.branch},
        ),
      ),
      ProfileSheetItem(
        icon: Icons.settings_outlined,
        label: t.svProfileSettings,
        onTap: () => context.push(AppRoutes.settings),
      ),
    ],
  );
}
