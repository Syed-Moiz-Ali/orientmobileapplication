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
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_notification_sheet.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

List<AppNavItem> _technicianNavItems(StaffLocalizations t) => <AppNavItem>[
  AppNavItem(
    selectedIcon: Icons.dashboard_rounded,
    icon: Icons.dashboard_outlined,
    label: t.techNavToday,
  ),
  AppNavItem(
    selectedIcon: Icons.car_repair_rounded,
    icon: Icons.car_repair_outlined,
    label: t.techNavJobs,
  ),
  AppNavItem(
    selectedIcon: Icons.insights_rounded,
    icon: Icons.insights_outlined,
    label: t.techNavProductivity,
  ),
  AppNavItem(
    selectedIcon: Icons.person_rounded,
    icon: Icons.person_outlined,
    label: t.techNavProfile,
  ),
];

/// Technician execution console shell (Phase 10, Archetype 7).
///
/// Home grammar adapted to the bay: a greeting-style compact header owns
/// identity (tech name + branch · shift + attendance dot) plus the Synced
/// pill, bell and avatar — so there is no WorkspaceAppBar bulk on this tab
/// (same product exception as the advisor home). A pinned Active Job banner
/// carries vehicle + plate + stage + live elapsed under the header, and the
/// tab frame is the shared rail / bottom-nav composition.
class TechnicianDashboardView extends ConsumerStatefulWidget {
  /// Fixed freshness instant forwarded to the tabs for deterministic golden
  /// stills. Production passes nothing.
  final DateTime? fixedRefreshAt;

  const TechnicianDashboardView({super.key, this.fixedRefreshAt});

  @override
  ConsumerState<TechnicianDashboardView> createState() =>
      _TechnicianDashboardViewState();
}

class _TechnicianDashboardViewState
    extends ConsumerState<TechnicianDashboardView> {
  /// Session dismissal key for the pinned banner (`ready` or
  /// `job:<ref>:<status>`). Presentation-only; resets on rebuild.
  String? _dismissedKey;

  static const _profilePage = StaffProfileScreen();

  List<Widget> get _pages => [
    TechnicianTodayView(fixedRefreshAt: widget.fixedRefreshAt),
    TechnicianJobsView(fixedRefreshAt: widget.fixedRefreshAt),
    const TechnicianProductivityView(),
    _profilePage,
  ];

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final items = _technicianNavItems(t);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final adaptive = context.adaptive;
    final effectiveIndex = state.selectedTab < _pages.length
        ? state.selectedTab
        : 0;
    final pendingSync =
        ref.watch(technicianPendingSyncCountProvider).valueOrNull ?? 0;

    final activeJob = _activeJob(notifier.allJobs);
    final bannerKey = activeJob == null
        ? 'ready'
        : 'job:${activeJob.jobCardNo}:${activeJob.status.name}';
    final showBanner = _dismissedKey != bannerKey;

    return DashboardShell(
      showOfflineBanner: false,
      appBar: null,
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: effectiveIndex,
        onSelected: notifier.selectTab,
        headerBuilder: (ctx, ext) =>
            OrientBrandMark(workspace: t.techWorkspaceName, compact: !ext),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: () => notifier.selectTab(3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ext ? AppDimensions.s8 : 0,
              vertical: AppDimensions.s4,
            ),
            child: ext
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.s8),
                        child: _TechAvatar(
                          radius: 16,
                          initials: notifier.profile.avatarInitials.isNotEmpty
                              ? notifier.profile.avatarInitials
                              : 'T',
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          t.techProfileLabel,
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
                    message: t.techProfileLabel,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.s6),
                      child: _TechAvatar(
                        radius: 18,
                        initials: notifier.profile.avatarInitials.isNotEmpty
                            ? notifier.profile.avatarInitials
                            : 'T',
                      ),
                    ),
                  ),
          ),
        ),
        child: Column(
          children: [
            _TechnicianGreetingHeader(
              pendingSync: pendingSync,
              onNotifications: () {
                HapticFeedback.selectionClick();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const AdvisorNotificationSheet(),
                );
              },
              onProfile: () {
                showProfileSheet(
                  context,
                  _technicianProfileSheetData(context, ref),
                  onLogout: () =>
                      ref.read(authNotifierProvider.notifier).logout(),
                );
              },
            ),
            if (showBanner)
              _ActiveJobBanner(
                job: activeJob,
                bannerKey: bannerKey,
                onOpenQueue: () => notifier.selectTab(1),
                onOpenJob: activeJob == null
                    ? null
                    : () => _openJobDetail(activeJob),
                onPauseResume: activeJob == null
                    ? null
                    : () => _pauseOrResume(activeJob),
                pauseResumeKind: _pauseResumeKind(activeJob),
                onDismiss: () =>
                    setState(() => _dismissedKey = bannerKey),
              ),
            Expanded(
              child: IndexedStack(index: effectiveIndex, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: effectiveIndex,
              onSelected: notifier.selectTab,
            ),
    );
  }

  /// Urgent-first active job: running, then delayed, then pending.
  TechnicianJobEntity? _activeJob(List<TechnicianJobEntity> jobs) {
    for (final job in jobs) {
      if (job.status == TechJobStatus.inProgress) return job;
    }
    for (final job in jobs) {
      if (job.status == TechJobStatus.delayed) return job;
    }
    for (final job in jobs) {
      if (job.status == TechJobStatus.pending) return job;
    }
    return null;
  }

  /// Which inline action the banner offers: pause a running task, resume a
  /// held one, or start the next pending task. Null when nothing is actionable.
  _BannerAction? _pauseResumeKind(TechnicianJobEntity? job) {
    if (job == null) return null;
    if (job.tasks.any((t) => t.status == TaskStatus.inProgress)) {
      return _BannerAction.pause;
    }
    if (job.tasks.any((t) => t.status == TaskStatus.onHold)) {
      return _BannerAction.resume;
    }
    if (job.tasks.any((t) => t.status == TaskStatus.pending)) {
      return _BannerAction.start;
    }
    return null;
  }

  void _pauseOrResume(TechnicianJobEntity job) {
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final running = job.tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .firstOrNull;
    if (running != null) {
      HapticFeedback.mediumImpact();
      notifier.updateTaskStatus(job, running, TaskStatus.onHold);
      return;
    }
    final held = job.tasks
        .where((t) => t.status == TaskStatus.onHold)
        .firstOrNull;
    final pending = job.tasks
        .where((t) => t.status == TaskStatus.pending)
        .firstOrNull;
    final next = held ?? pending;
    if (next != null) {
      HapticFeedback.mediumImpact();
      notifier.startTask(job, next);
    }
  }

  void _openJobDetail(TechnicianJobEntity job) {
    HapticFeedback.selectionClick();
    ref.read(technicianDashboardProvider.notifier).openJob(job);
    context.push(AppRoutes.technicianJobDetail, extra: job).whenComplete(
      () => ref.read(technicianDashboardProvider.notifier).closeJob(),
    );
  }
}

enum _BannerAction { pause, resume, start }

class _TechAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  const _TechAvatar({required this.radius, this.initials = 'T'});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primary.withValues(alpha: 0.14),
      child: Text(
        initials,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

// ─── GREETING HEADER ─────────────────────────────────────────────────────────
// One header row: greeting (22/800) + branch · shift + attendance dot, plus
// integrated actions (Synced pill, bell, avatar). No WorkspaceAppBar on this
// tab by product exception — same as the advisor home.
class _TechnicianGreetingHeader extends ConsumerWidget {
  final int pendingSync;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _TechnicianGreetingHeader({
    required this.pendingSync,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final state = ref.watch(technicianDashboardProvider);
    final profile = notifier.profile;
    final name = profile.name.isNotEmpty ? profile.name : t.techWorkspaceName;
    final contextLine = [
      profile.branch,
      profile.shift,
    ].where((s) => s.trim().isNotEmpty).join(' · ');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s16,
        context.pagePadding.right,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.techGreeting(name),
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
                const SizedBox(height: AppDimensions.s6),
                _AttendanceDot(status: state.attendanceStatus),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OfflineStatusPill(pendingSyncCount: pendingSync),
              const SizedBox(height: AppDimensions.s8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onNotifications,
                    tooltip: StaffLocalizations.of(
                      context,
                    )!.advisorNotificationsTitle,
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: colors.onSurfaceVariant,
                  ),
                  InkWell(
                    onTap: onProfile,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                    child: Tooltip(
                      message: t.techProfileLabel,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.s8),
                        child: _TechAvatar(
                          radius: 16,
                          initials: profile.avatarInitials.isNotEmpty
                              ? profile.avatarInitials
                              : 'T',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceDot extends StatelessWidget {
  final AttendanceStatus status;
  const _AttendanceDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final dot = techAttendanceColor(context, status);
    final label = switch (status) {
      AttendanceStatus.working => t.techAttendanceWorking,
      AttendanceStatus.onBreak => t.techAttendanceOnBreak,
      AttendanceStatus.notPunchedIn => t.techAttendanceNotPunchedIn,
      AttendanceStatus.punchedOut => t.techAttendancePunchedOut,
    };
    return Semantics(
      container: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.s6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PINNED ACTIVE JOB BANNER ────────────────────────────────────────────────
// Vehicle + plate pill + stage pill + live elapsed under the header. Tap
// opens the job dossier; pause/resume acts inline on the running task; X
// dismisses for the session. Display only — elapsed derives from the
// recorded start time, actions call the frozen notifier methods.
class _ActiveJobBanner extends StatelessWidget {
  final TechnicianJobEntity? job;
  final String bannerKey;
  final VoidCallback onOpenQueue;
  final VoidCallback? onOpenJob;
  final VoidCallback? onPauseResume;
  final _BannerAction? pauseResumeKind;
  final VoidCallback onDismiss;

  const _ActiveJobBanner({
    required this.job,
    required this.bannerKey,
    required this.onOpenQueue,
    required this.onOpenJob,
    required this.onPauseResume,
    required this.pauseResumeKind,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final current = job;

    return Padding(
      key: ValueKey(bannerKey),
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s12,
        context.pagePadding.right,
        0,
      ),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(
            color: current != null &&
                    current.tasks.any(
                      (task) => task.status == TaskStatus.inProgress,
                    )
                ? colors.primary.withValues(alpha: 0.35)
                : colors.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: current == null ? onOpenQueue : onOpenJob,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s10,
            ),
            child: current == null
                ? _ReadyContent(onDismiss: onDismiss)
                : _JobContent(
                    job: current,
                    pauseResumeKind: pauseResumeKind,
                    onPauseResume: onPauseResume,
                    onDismiss: onDismiss,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReadyContent extends StatelessWidget {
  final VoidCallback onDismiss;
  const _ReadyContent({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Row(
      children: [
        Icon(
          Icons.task_alt_rounded,
          size: AppDimensions.iconMd,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.techBannerReady,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              Text(
                t.techBannerReadyHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close_rounded),
          iconSize: AppDimensions.iconSm,
          color: colors.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _JobContent extends StatelessWidget {
  final TechnicianJobEntity job;
  final _BannerAction? pauseResumeKind;
  final VoidCallback? onPauseResume;
  final VoidCallback onDismiss;

  const _JobContent({
    required this.job,
    required this.pauseResumeKind,
    required this.onPauseResume,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final vehicle =
        '${job.vehicleBrand} ${job.vehicleModel}'.trim().isEmpty
        ? t.techVehicleFallback
        : '${job.vehicleBrand} ${job.vehicleModel}'.trim();
    final running = job.tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .firstOrNull;
    // Static paused readout when the bay is holding: deterministic (no
    // pause instant is recorded, so nothing ticks).
    final stopTask =
        running ??
        job.tasks
            .where((task) => task.status == TaskStatus.onHold)
            .firstOrNull;
    final action = pauseResumeKind;
    final actionIcon = switch (action) {
      _BannerAction.pause => Icons.pause_rounded,
      _BannerAction.resume => Icons.play_arrow_rounded,
      _BannerAction.start => Icons.play_arrow_rounded,
      null => null,
    };
    final actionLabel = switch (action) {
      _BannerAction.pause => t.techBannerPause,
      _BannerAction.resume => t.techBannerResume,
      _BannerAction.start => t.techTodayStartTask,
      null => null,
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.techBannerActive.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                vehicle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.s6,
                runSpacing: AppDimensions.s4,
                children: [
                  if (job.plateNumber.isNotEmpty)
                    TechnicianPlateChip(plate: job.plateNumber),
                  technicianStatusPill(job.status),
                ],
              ),
              if (stopTask != null && stopTask.startTime != null) ...[
                const SizedBox(height: AppDimensions.s6),
                TechnicianStopwatch(task: stopTask, ticking: running != null),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action != null && actionIcon != null) ...[
              Material(
                color: colors.primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  // FIXED-INK: white glyph on the saturated primary action.
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onPauseResume?.call();
                  },
                  customBorder: const CircleBorder(),
                  child: Tooltip(
                    message: actionLabel ?? '',
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.s12),
                      child: Icon(
                        actionIcon,
                        size: AppDimensions.iconMd,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
            ],
            DirectionalIcon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
        IconButton(
          onPressed: onDismiss,
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: const Icon(Icons.close_rounded),
          iconSize: AppDimensions.iconSm,
          color: colors.onSurfaceVariant,
        ),
      ],
    );
  }
}

ProfileSheetData _technicianProfileSheetData(
  BuildContext context,
  WidgetRef ref,
) {
  final notifier = ref.read(technicianDashboardProvider.notifier);
  final profile = notifier.profile;
  final t = StaffLocalizations.of(context)!;
  final name = profile.name.isNotEmpty ? profile.name : t.techWorkspaceName;
  final role = profile.role.isNotEmpty ? profile.role : t.techWorkspaceName;

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
    initials: profile.avatarInitials.isNotEmpty ? profile.avatarInitials : 'T',
    roleLabel: role,
    roleBadge: profile.branch.isNotEmpty ? profile.branch : t.techWorkspaceName,
    menuItems: [
      ProfileSheetItem(
        icon: Icons.person_outline_rounded,
        label: t.techNavProfile,
        onTap: () => context.push(AppRoutes.profile, extra: details),
      ),
      ProfileSheetItem(
        icon: Icons.fingerprint_rounded,
        label: t.techShiftStart,
        onTap: () => context.push(AppRoutes.attendance),
      ),
      ProfileSheetItem(
        icon: Icons.assignment_outlined,
        label: t.techNavJobs,
        onTap: () {
          Navigator.pop(context);
          ref.read(technicianDashboardProvider.notifier).selectTab(1);
        },
      ),
    ],
  );
}
