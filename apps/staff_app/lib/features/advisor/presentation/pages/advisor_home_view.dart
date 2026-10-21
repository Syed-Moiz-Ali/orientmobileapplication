import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_jobs_view.dart';
import 'advisor_reports_view.dart';
import '../widgets/advisor_approval_sheet.dart';
import '../widgets/advisor_notification_sheet.dart';
import '../widgets/advisor_profile_sheet.dart';
import '../widgets/advisor_search_sheet.dart';
import '../widgets/advisor_status.dart';

List<AppNavItem> _advisorNavItems(StaffLocalizations t) => <AppNavItem>[
  AppNavItem(
    selectedIcon: Icons.dashboard_rounded,
    icon: Icons.dashboard_outlined,
    label: t.advisorNavToday,
  ),
  AppNavItem(
    selectedIcon: Icons.receipt_long_rounded,
    icon: Icons.receipt_long_outlined,
    label: t.advisorNavJobs,
  ),
  AppNavItem(
    selectedIcon: Icons.bar_chart_rounded,
    icon: Icons.bar_chart_outlined,
    label: t.advisorNavReports,
  ),
];

class AdvisorHomeView extends ConsumerStatefulWidget {
  const AdvisorHomeView({super.key});

  @override
  ConsumerState<AdvisorHomeView> createState() => _AdvisorHomeViewState();
}

class _AdvisorHomeViewState extends ConsumerState<AdvisorHomeView> {
  int _navIndex = 0;

  /// Session-only recent searches (presentation state): owned here so the
  /// full-screen search sheet shows recents across opens within the home
  /// session. Same list shape the removed inline pill kept — no logic.
  final List<String> _searchRecents = <String>[];

  void _rememberSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _searchRecents.remove(q);
      _searchRecents.insert(0, q);
      if (_searchRecents.length > 5) {
        _searchRecents.removeRange(5, _searchRecents.length);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(advisorRefreshProvider.notifier).state++;
    });
  }

  void _openScan() => context.push(AppRoutes.scanVehicle);
  void _openNewJobCard() => context.push(AppRoutes.vehicleCustomer);

  void _toast(String msg, {IconData? icon, Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: ink, size: AppDimensions.iconSm),
              const SizedBox(width: AppDimensions.s8),
            ],
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sheet(Widget child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => child,
    );
  }

  void _showProfile() {
    _sheet(
      AdvisorProfileSheet(
        onLogout: () async {
          Navigator.pop(context);
          await showLogoutDialog(
            context,
            onLogout: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          );
        },
      ),
    );
  }

  void _onJobCard(JobCardEntity jc) {
    HapticFeedback.selectionClick();
    context.push(AppRoutes.advisorJobDetail, extra: jc);
  }

  void _onApproval(PendingApprovalEntity pa) {
    HapticFeedback.mediumImpact();
    final t = StaffLocalizations.of(context)!;
    _sheet(
      AdvisorApprovalSheet(
        pa: pa,
        onApprove: () {
          Navigator.pop(context);
          _persistApproval(pa, 'approve');
          _toast(
            t.advisorToastApproved(
              advisorApprovalTypeLabel(t, pa.approvalType),
              pa.estimateId,
            ),
            icon: Icons.check_circle_outline,
            color: context.semanticColors.success.base,
          );
        },
        onReject: () {
          Navigator.pop(context);
          _persistApproval(pa, 'reject');
          _toast(
            t.advisorToastRejected(
              advisorApprovalTypeLabel(t, pa.approvalType),
              pa.estimateId,
            ),
            icon: Icons.undo,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }

  Future<void> _persistApproval(PendingApprovalEntity pa, String action) async {
    final local = GenericLocalDataSource(Hive.box<dynamic>('inspections'));
    await local.save('approval_${pa.estimateId}', {
      'estimateId': pa.estimateId,
      'customerName': pa.customerName,
      'amount': pa.amount,
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    final queue = ref.read(syncQueueProvider);
    final id = await IdGenerator.nextId('APPR');
    await queue.enqueue(
      SyncOperation(
        id: id,
        entityType: 'approval',
        entityId: pa.estimateId,
        changeType: ChangeType.update,
        payload: {
          'estimateId': pa.estimateId,
          'action': action,
          'customerName': pa.customerName,
          'amount': pa.amount,
        },
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await ref.read(syncEngineProvider).syncAll();
  }

  // U1: the header search icon is the ONE search path. The existing
  // AdvisorSearchSheet (same predicate, session recents, scan CTA inside,
  // autofocus) presents full-screen via the existing bottom-sheet mechanism
  // only — no new routes. Ctrl+K opens the same sheet.
  void _showSearch() {
    HapticFeedback.selectionClick();
    final size = MediaQuery.sizeOf(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        // Tight full-size box: the sheet route sizes to content, so the
        // content itself claims the full screen (U1 full-screen search).
        // The box carries the surface token (the route Material is
        // transparent), so the whole screen reads as one search surface.
        child: SizedBox.fromSize(
          size: size,
          child: ColoredBox(
            color: Theme.of(sheetContext).colorScheme.surface,
            child: SingleChildScrollView(
              child: AdvisorSearchSheet(
                recents: _searchRecents,
                onRemember: _rememberSearch,
                onScan: () {
                  Navigator.pop(context);
                  _openScan();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openApprovals() {
    final approvals =
        ref.read(advisorPendingApprovalsProvider).valueOrNull ??
        const <PendingApprovalEntity>[];
    if (approvals.isEmpty) {
      _toast(
        StaffLocalizations.of(context)!.advisorNoActiveJobs,
        icon: Icons.check_circle_outline_rounded,
        color: context.semanticColors.success.base,
      );
      return;
    }
    _onApproval(approvals.first);
  }

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final t = StaffLocalizations.of(context)!;
    final items = _advisorNavItems(t);
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).valueOrNull ?? 0;
    final approvalsCount =
        ref.watch(advisorPendingApprovalsProvider).valueOrNull?.length ?? 0;

    // Product exception (Phase 06 correction D2): this tab carries no
    // WorkspaceAppBar. The greeting header below owns identity + search +
    // offline pill + notifications + profile in one row, so a second title row
    // would duplicate chrome and steal viewport from assigned work. Rail /
    // bottom-nav + offline coordination (pill + shortcuts) stay on the shell.
    final shell = DashboardShell(
      showOfflineBanner: false,
      appBar: null,
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: _navIndex,
        onSelected: (index) => setState(() => _navIndex = index),
        headerBuilder: (ctx, ext) =>
            OrientBrandMark(workspace: t.advisorWorkspaceName, compact: !ext),
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
                      _AdvisorAvatar(
                        radius: 16,
                        initials: ref.watch(advisorInfoProvider).initials,
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          t.advisorProfileLabel,
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
                    message: t.advisorProfileLabel,
                    child: _AdvisorAvatar(
                      radius: 18,
                      initials: ref.watch(advisorInfoProvider).initials,
                    ),
                  ),
          ),
        ),
        child: IndexedStack(
          index: _navIndex,
          children: [
            _AdvisorDashboardContent(
              onOpenScan: _openScan,
              onNewJobCard: _openNewJobCard,
              onOpenSearch: _showSearch,
              onOpenApprovals: _openApprovals,
              approvalsCount: approvalsCount,
              pendingSync: pendingSync,
              onJobCard: _onJobCard,
              onNavigateTab: (i) => setState(() => _navIndex = i),
            ),
            AdvisorJobsListView(onJobCard: _onJobCard),
            const AdvisorReportsView(),
          ],
        ),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: _navIndex,
              onSelected: (index) => setState(() => _navIndex = index),
            ),
    );

    // ⌘K / Ctrl+K global search, plus the always-visible header search button.
    return WorkspaceSearchShortcuts(onSearch: _showSearch, child: shell);
  }
}

class _AdvisorAvatar extends StatelessWidget {
  final double radius;
  final String initials;
  const _AdvisorAvatar({required this.radius, this.initials = 'A'});

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

// ─── ADVISOR DASHBOARD TAB CONTENT ───────────────────────────────────────────
// U-laws composition (rebuild): greeting header (date + search/bell/avatar
// row, full-width greeting, muted branch·shift; bell offset badge + avatar,
// search icon opens the full-screen search sheet) -> ONE hero summary card
// (one primary CTA; calm status row with NO button when nothing is due) ->
// ONE row of 3 EQUAL quick-action columns (scan lives only here) ->
// assigned work as a LIST of large borderless cards (vehicle/customer-first,
// conditional See-all) with NO work-summary section behind it. No inline
// search pill: the header icon + Ctrl+K are the one search path. No permanent
// sync pill: offline/queued surfaces once as an AppBanner. Urgent work
// still surfaces inside the assigned list via the UNCHANGED urgent-first
// sort + status chips; there is no separate attention panel.
// Assigned is a LIST (not a carousel): N is small (<= 6 visible),
// statuses need side-by-side comparison, and a carousel would hide urgent
// items and cost the above-the-fold first order at 360x800.
class _AdvisorDashboardContent extends ConsumerStatefulWidget {
  final VoidCallback onOpenScan;
  final VoidCallback onNewJobCard;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenApprovals;
  final int approvalsCount;
  final int pendingSync;
  final void Function(JobCardEntity) onJobCard;
  final void Function(int) onNavigateTab;

  const _AdvisorDashboardContent({
    required this.onOpenScan,
    required this.onNewJobCard,
    required this.onOpenSearch,
    required this.onOpenApprovals,
    required this.approvalsCount,
    required this.pendingSync,
    required this.onJobCard,
    required this.onNavigateTab,
  });

  @override
  ConsumerState<_AdvisorDashboardContent> createState() =>
      _AdvisorDashboardContentState();
}

class _AdvisorDashboardContentState
    extends ConsumerState<_AdvisorDashboardContent> {
  JobCardEntity? _selected;
  DateTime _lastRefresh = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = StaffLocalizations.of(context)!;
    final info = ref.watch(advisorInfoProvider);

    final recentJobsState = ref.watch(advisorRecentJobCardsProvider);
    final statsState = ref.watch(advisorDashboardProvider);

    final recentJobs = recentJobsState.valueOrNull ?? const <JobCardEntity>[];
    final stats = statsState.valueOrNull;

    final jobsLoading = recentJobsState.isLoading && recentJobs.isEmpty;
    final jobsError = recentJobsState.hasError;
    final sorted = _sortedUrgentFirst(recentJobs);
    // Min 6 visible without scrolling past chrome; the conditional See-all
    // below appears only when more exist than shown (U7).
    final visible = sorted.take(6).toList();

    // Medium (600–1024) is two-column like expanded (list + compact
    // preview); compact stays single-column. Expanded caps at 1200.
    final twoCol = context.adaptive.pick(
      compact: false,
      medium: true,
      expanded: true,
    );
    final maxWidth = context.adaptive.pick(
      compact: double.infinity,
      medium: 640.0,
      expanded: 1200.0,
    );
    final offline =
        ref.watch(connectivityStatusProvider).value == ConnectivityResult.none;

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(advisorRefreshProvider.notifier).state++;
        setState(() => _lastRefresh = DateTime.now());
      },
      color: colors.primary,
      backgroundColor: colors.surface,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 1. GREETING HEADER (AppPageHeader + offline pill) ──────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  AppDimensions.s12,
                  AppDimensions.s20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _AdvisorHomeHeader(
                    info: info,
                    approvalsCount: widget.approvalsCount,
                    onSearch: widget.onOpenSearch,
                    onNotifications: () {
                      HapticFeedback.selectionClick();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => const AdvisorNotificationSheet(),
                      );
                    },
                    onShowProfile: () {
                      HapticFeedback.selectionClick();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => AdvisorProfileSheet(
                          onLogout: () async {
                            Navigator.pop(context);
                            await showLogoutDialog(
                              context,
                              onLogout: () => ref
                                  .read(authNotifierProvider.notifier)
                                  .logout(),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Sync telemetry lives ONLY here (C16 hard-reject: no permanent
              // status pill). Normal case (online, nothing queued) shows
              // nothing; abnormal sync surfaces once as an AppBanner.
              if (offline || widget.pendingSync > 0)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s12,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppBanner(
                      kind: offline
                          ? AppBannerKind.warning
                          : AppBannerKind.info,
                      message: offline
                          ? t.advisorOfflineNotice
                          : SharedCoreL10n.of(
                              context,
                            ).connectivityQueuedCount(widget.pendingSync),
                    ),
                  ),
                ),
              // ── 2. HERO SUMMARY (ONE hero card + View-jobs CTA) ───────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  AppDimensions.s10,
                  AppDimensions.s20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _AdvisorHeroCard(
                    inspectionsDue: stats?.inspectionsToday ?? 0,
                    newToday: stats?.newJobCardsToday ?? 0,
                    isLoading: jobsLoading,
                    onViewJobs: () => widget.onNavigateTab(1),
                  ),
                ),
              ),
              // ── 3. QUICK ACTIONS (one row, or 2x2 when narrow) ────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  AppDimensions.s10,
                  AppDimensions.s20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _AdvisorQuickActions(
                    approvalsCount: widget.approvalsCount,
                    onScan: widget.onOpenScan,
                    onNewJob: widget.onNewJobCard,
                    onApprovals: widget.onOpenApprovals,
                  ),
                ),
              ),
              // ── 4. ASSIGNED WORK + SUMMARY ─────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  AppDimensions.s12,
                  AppDimensions.s20,
                  110,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (twoCol) ...[
                        // ── 4. ASSIGNED + SIDE PREVIEW (medium/expanded) ─────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _AssignedCards(
                                jobs: visible,
                                totalCount: sorted.length,
                                isLoading: jobsLoading,
                                hasError: jobsError,
                                onRetry: () => ref.invalidate(
                                  advisorRecentJobCardsProvider,
                                ),
                                onSelect: (jc) =>
                                    setState(() => _selected = jc),
                                onSeeAll: () => widget.onNavigateTab(1),
                                onNewJob: widget.onNewJobCard,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s24),
                            Expanded(
                              flex: 2,
                              child: _AdvisorPreviewCard(
                                jc:
                                    _selected ??
                                    (visible.isNotEmpty ? visible.first : null),
                                onOpen: widget.onJobCard,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // ── 4. ASSIGNED WORK (large card rows) ───────────────
                        _AssignedCards(
                          jobs: visible,
                          totalCount: sorted.length,
                          isLoading: jobsLoading,
                          hasError: jobsError,
                          onRetry: () =>
                              ref.invalidate(advisorRecentJobCardsProvider),
                          onSelect: widget.onJobCard,
                          onSeeAll: () => widget.onNavigateTab(1),
                          onNewJob: widget.onNewJobCard,
                        ),
                      ],
                      const SizedBox(height: AppDimensions.s8),
                      _FreshnessFooter(lastRefresh: _lastRefresh),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── URGENCY SORT ────────────────────────────────────────────────────────────
// Urgent-first ordering is unchanged logic: actionable statuses
// (pending / approval / parts / QC) sort above active work, which sorts above
// finished + cancelled. Stable within rank (server order kept).
int _urgencyRank(JobCardStatus status) => switch (status) {
  JobCardStatus.pending ||
  JobCardStatus.pendingApproval ||
  JobCardStatus.awaitingSupervisor ||
  JobCardStatus.waitingCustomerApproval ||
  JobCardStatus.waitingParts ||
  JobCardStatus.qualityCheck => 0,
  JobCardStatus.inProgress ||
  JobCardStatus.workAssigned ||
  JobCardStatus.inspected ||
  JobCardStatus.vehicleReceived => 1,
  JobCardStatus.completed ||
  JobCardStatus.approved ||
  JobCardStatus.delivered ||
  JobCardStatus.qualityCheckPassed => 2,
  JobCardStatus.cancelled => 3,
};

List<JobCardEntity> _sortedUrgentFirst(List<JobCardEntity> jobs) {
  final indexed = jobs.indexed.toList();
  indexed.sort((a, b) {
    final rank = _urgencyRank(a.$2.status).compareTo(_urgencyRank(b.$2.status));
    if (rank != 0) return rank;
    return a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

String _shortShift(String shift) {
  final cut = shift.split('(').first.trim();
  return cut.isEmpty ? shift.trim() : cut;
}

/// Presentation mapping from job status to the single [AppStatusChip] kind on
/// the home cards. Same taxonomy as [advisorStatusPill]; labels come from the
/// shared [advisorStatusLabel] vocabulary so wording never drifts.
AppStatusKind _homeStatusKind(JobCardStatus status) => switch (status) {
  JobCardStatus.pending ||
  JobCardStatus.pendingApproval ||
  JobCardStatus.awaitingSupervisor ||
  JobCardStatus.waitingCustomerApproval => AppStatusKind.warning,
  JobCardStatus.completed ||
  JobCardStatus.approved ||
  JobCardStatus.delivered ||
  JobCardStatus.qualityCheckPassed => AppStatusKind.success,
  JobCardStatus.waitingParts => AppStatusKind.error,
  JobCardStatus.qualityCheck ||
  JobCardStatus.inProgress ||
  JobCardStatus.workAssigned ||
  JobCardStatus.inspected ||
  JobCardStatus.vehicleReceived => AppStatusKind.info,
  JobCardStatus.cancelled => AppStatusKind.neutral,
};

// ─── 1. GREETING HEADER ──────────────────────────────────────────────────────
// U1/U9 headline header (presentation only): small sentence-case date line
// with the search icon + bell (badge offset OUTSIDE the glyph, never
// covering it) + avatar top-right — same placement as customer home. The
// greeting below spans the full width and wraps to 2 lines with the FULL
// name (never "…" on a person's name, U5), then the muted branch·shift
// subtitle. No sync pill: sync state surfaces only as an AppBanner when
// abnormal (offline or queued). Compact chrome keeps the first assigned
// order above the fold at 360x800.
class _AdvisorHomeHeader extends ConsumerWidget {
  final AdvisorInfo info;
  final int approvalsCount;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onShowProfile;

  const _AdvisorHomeHeader({
    required this.info,
    required this.approvalsCount,
    required this.onSearch,
    required this.onNotifications,
    required this.onShowProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    // Sentence-case date on its own muted line (never ALL CAPS, C3/C11).
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(DateTime.now());
    final shiftShort = _shortShift(info.shift);
    final contextLine = [
      info.branch,
      shiftShort,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    final notifications =
        ref.watch(advisorNotificationsProvider).valueOrNull ??
        const <StaffNotificationResponse>[];
    final bellCount = notifications.length + approvalsCount;
    // Arabic path: Latin names/branch data stay LTR inside isolates; the
    // branch/shift values themselves are backend data (no ar key exists),
    // so they render as received.
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final greetingName = isArabic ? '\u2066${info.name}\u2069' : info.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // The ONE search path (U1/U7): opens the full-screen search
            // sheet (autofocus + recents + scan inside). Ctrl+K stays.
            AppIconButton(
              icon: Icons.search_rounded,
              onPressed: onSearch,
              tooltip: t.advisorSearchTitle,
            ),
            // Bell with its badge floated ABOVE the glyph (top -8 straddles
            // the hit-area edge, disjoint from the centered 20px glyph).
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppIconButton(
                  icon: Icons.notifications_none_rounded,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onNotifications();
                  },
                  tooltip: t.advisorNotificationsTitle,
                ),
                if (bellCount > 0)
                  PositionedDirectional(
                    top: -8,
                    end: -6,
                    child: AppBadge(
                      count: bellCount,
                      kind: AppBadgeKind.error,
                      semanticLabel: '$bellCount',
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppDimensions.s4),
            AppAvatar(
              name: info.name,
              initials: info.initials,
              size: AppAvatarSize.small,
              onTap: () {
                HapticFeedback.selectionClick();
                onShowProfile();
              },
              semanticLabel: t.advisorProfileLabel,
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s8),
        Text(
          t.advisorGreeting(greetingName),
          // Two full lines: the headline names the advisor, so the name
          // wraps instead of amputating to "Omar ...". Visible (never
          // ellipsis): a long name must read in full (U5).
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        if (contextLine.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s4),
          Text(
            contextLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── 2. HERO SUMMARY ─────────────────────────────────────────────────────────
// ONE hero card (AppSurfaceCard, no media block — the old icon slot rendered
// a dead grey box-in-box above the headline): the key number (inspections
// due today) + a plain-language delta sentence + ONE verb-first primary CTA
// ("View jobs") into the Jobs tab. Zero due collapses to a compact calm
// status row with NO filled button (U6: a filled CTA exists only when it
// leads to something that exists). Skeleton mirrors the card while the
// first load is in flight.
class _AdvisorHeroCard extends StatelessWidget {
  final int inspectionsDue;
  final int newToday;
  final bool isLoading;
  final VoidCallback onViewJobs;

  const _AdvisorHeroCard({
    required this.inspectionsDue,
    required this.newToday,
    required this.isLoading,
    required this.onViewJobs,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (isLoading) {
      // Same footprint as the loaded hero card (title + sentence + CTA).
      return const AppShimmerSkeleton.card(height: 148);
    }
    // Zero state owns honest calm copy: no "urgent first", no "0 …" key
    // number, no filled button to nothing.
    if (inspectionsDue == 0) {
      final semantic = context.semanticColors;
      return AppSurfaceCard(
        radius: AppRadius.xl,
        outlined: false,
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: semantic.success.base,
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                t.advisorHeroCaughtUp,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final title = t.advisorHeroDueTitle(inspectionsDue);
    final sentence = newToday == 0
        ? t.advisorHeroSentence
        : '${t.advisorDeltaToday(newToday)}. ${t.advisorHeroSentence}';
    // Borderless in light theme (shadow path, C16 hard-reject); dark takes
    // the shared border path. ONE primary CTA inside the card.
    return AppSurfaceCard(
      radius: AppRadius.xl,
      outlined: false,
      padding: const EdgeInsets.all(AppDimensions.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            sentence,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          AppPillButton.primary(
            label: t.advisorHeroViewJobs,
            size: AppPillButtonSize.small,
            isExpanded: false,
            onPressed: () {
              HapticFeedback.selectionClick();
              onViewJobs();
            },
          ),
        ],
      ),
    );
  }
}

// ─── 3. QUICK ACTIONS ────────────────────────────────────────────────────────
// 3 EQUAL columns (U5: prefer fitting over scrolling for <= 4 items), so
// full-word labels survive 320px + 1.3x + ar with no horizontal cut-offs
// and no mid-word cuts. No filled tile: the hero CTA is the screen's one
// primary action, so every tile is a neutral surface (borderless shadow in
// light, shared border in dark). The approvals count appears exactly ONCE,
// on the badge — never duplicated in the label. Scan lives ONLY here.
class _AdvisorQuickActions extends StatelessWidget {
  final int approvalsCount;
  final VoidCallback onScan;
  final VoidCallback onNewJob;
  final VoidCallback onApprovals;

  const _AdvisorQuickActions({
    required this.approvalsCount,
    required this.onScan,
    required this.onNewJob,
    required this.onApprovals,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final tiles = <_AdvisorQuickTileData>[
      _AdvisorQuickTileData(
        key: const Key('advisor_quick_scan'),
        label: t.advisorActionScanTitle,
        hint: t.advisorActionScanSubtitle,
        icon: Icons.qr_code_scanner_rounded,
        onTap: onScan,
      ),
      _AdvisorQuickTileData(
        key: const Key('advisor_quick_new'),
        label: t.advisorActionNewJobTitle,
        hint: t.advisorActionNewJobSubtitle,
        icon: Icons.add_rounded,
        accentIcon: true,
        onTap: onNewJob,
      ),
      _AdvisorQuickTileData(
        key: const Key('advisor_quick_approvals'),
        label: t.advisorActionApprovalsTitle,
        hint: t.advisorActionApprovalsSubtitle,
        icon: Icons.fact_check_outlined,
        badgeCount: approvalsCount,
        onTap: onApprovals,
      ),
    ];
    return Semantics(
      label: t.advisorQuickActionsEyebrow,
      // IntrinsicHeight + stretch: equal-height columns inside the
      // unbounded sliver height (a bare stretch Row cannot lay out with
      // infinite cross-axis constraints).
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: AppDimensions.s10),
              Expanded(child: _AdvisorQuickTile(action: tiles[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdvisorQuickTileData {
  final Key? key;
  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final bool accentIcon;
  final int badgeCount;

  const _AdvisorQuickTileData({
    this.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.accentIcon = false,
    this.badgeCount = 0,
  });
}

class _AdvisorQuickTile extends StatelessWidget {
  final _AdvisorQuickTileData action;

  const _AdvisorQuickTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    // Borderless in light (shadow + whitespace, C16 hard-reject); the dark
    // path keeps the shared 1px border and no shadow. No fixed width: the
    // parent Row gives each tile an equal third, and the label wraps to
    // 2 lines on word boundaries instead of cutting mid-word (U5).
    final tile = Container(
      key: action.key,
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: dark ? Border.all(color: colors.outline) : null,
        boxShadow: dark ? null : AppShadows.e1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            action.icon,
            size: 24,
            color: action.accentIcon
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Two-line wrap on word boundaries; equal columns keep full words
          // visible at 1.3x/320/ar instead of mid-word cuts. The count lives
          // on the badge only (label has no number).
          Text(
            action.label,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    final tappable = Semantics(
      button: true,
      excludeSemantics: true,
      label: action.badgeCount > 0
          ? '${action.label}, ${action.badgeCount}, ${action.hint}'
          : '${action.label}, ${action.hint}',
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          action.onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: action.badgeCount > 0
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  tile,
                  // Badge floats above the tile corner, disjoint from the
                  // centered glyph (same offset-outside rule as the bell).
                  PositionedDirectional(
                    top: -8,
                    end: -6,
                    child: AppBadge(
                      count: action.badgeCount,
                      kind: AppBadgeKind.error,
                    ),
                  ),
                ],
              )
            : tile,
      ),
    );
    return tappable;
  }
}

// ─── 5. ASSIGNED WORK ────────────────────────────────────────────────────────
// AppSection + large card rows: job id, customer + vehicle + plate, ONE
// status chip + one-line status sentence, trailing chevron into the job
// workspace. Urgent-first order UNCHANGED (logic).
class _AssignedCards extends ConsumerWidget {
  final List<JobCardEntity> jobs;
  final int totalCount;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final void Function(JobCardEntity) onSelect;
  final VoidCallback onSeeAll;
  final VoidCallback onNewJob;

  const _AssignedCards({
    required this.jobs,
    required this.totalCount,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.onSelect,
    required this.onSeeAll,
    required this.onNewJob,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;

    Widget child;
    if (isLoading) {
      // Skeleton mirrors the final large cards (same radii/gaps, two cards).
      child = const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppShimmerSkeleton.card(height: 148),
          SizedBox(height: AppDimensions.s12),
          AppShimmerSkeleton.card(height: 148),
        ],
      );
    } else if (hasError) {
      child = AppErrorState(
        title: t.advisorDataError,
        message: t.advisorOfflineNotice,
        onRetry: onRetry,
        retryLabel: SharedCoreL10n.of(context).commonRetry,
      );
    } else if (jobs.isEmpty) {
      child = AppEmptyState(
        icon: Icons.assignment_outlined,
        title: t.advisorHomeEmptyTitle,
        message: t.advisorHomeEmptyBody,
        actionLabel: t.advisorActionNewJobTitle,
        onAction: () {
          HapticFeedback.selectionClick();
          onNewJob();
        },
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < jobs.length; i++) ...[
            if (i > 0) const SizedBox(height: AppDimensions.s12),
            _AssignedJobCard(
              jc: jobs[i],
              urgent: _urgencyRank(jobs[i].status) == 0,
              onTap: onSelect,
            ),
          ],
        ],
      );
    }

    // U7: See-all appears ONLY when more items exist than shown — the hero
    // "View jobs" CTA is the one persistent path into the Jobs tab.
    final showSeeAll = totalCount > jobs.length;
    return AppSection(
      // Count inline on the header line (never on its own line).
      title: '${t.advisorAssignedWorkOrders} ($totalCount)',
      seeAllLabel: showSeeAll ? t.advisorSeeAll : null,
      onSeeAll: showSeeAll
          ? () {
              HapticFeedback.selectionClick();
              onSeeAll();
            }
          : null,
      child: child,
    );
  }
}

/// One assigned job as a large borderless card, vehicle/customer-first
/// (C16 card hierarchy): title = the thing the advisor recognizes
/// (customer + vehicle), then the single status pill, then meta, with the
/// job id as small LTR mono meta — never the title. One plain status
/// sentence + ONE status chip + trailing chevron into the workspace.
/// Urgent-first order is UNCHANGED (logic). Identifiers and times stay
/// LTR in RTL.
class _AssignedJobCard extends StatelessWidget {
  final JobCardEntity jc;
  final bool urgent;
  final void Function(JobCardEntity) onTap;

  const _AssignedJobCard({
    required this.jc,
    required this.urgent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sentence = urgent ? '${t.advisorDueToday} · ${jc.time}' : jc.time;
    return AppSurfaceCard(
      outlined: false,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(jc);
      },
      semanticLabel: '${jc.customerName}, ${jc.id}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recognized name first: customer + vehicle.
                Text(
                  '${jc.customerName} · ${jc.vehicleInfo}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppStatusChip(
                    label: advisorStatusLabel(t, jc.status),
                    kind: _homeStatusKind(jc.status),
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  sentence,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                // Id is small meta (LTR mono, tabular), never the title.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    jc.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          DirectionalIcon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// Desktop side preview rebuilt with App* cards (same selection state, same
// Open route — no new routes).
class _AdvisorPreviewCard extends StatelessWidget {
  final JobCardEntity? jc;
  final void Function(JobCardEntity) onOpen;

  const _AdvisorPreviewCard({required this.jc, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final job = jc;

    if (job == null) {
      return AppSurfaceCard(
        outlined: false,
        child: Text(
          t.advisorJobsSelectPrompt,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return AppSurfaceCard(
      outlined: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    job.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(color: colors.onSurface),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              // Bounded so long labels wrap inside narrow medium previews
              // (Row gives non-flex children unbounded width otherwise).
              Flexible(
                child: AppStatusChip(
                  label: advisorStatusLabel(t, job.status),
                  kind: _homeStatusKind(job.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            job.customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          Text(
            job.vehicleInfo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          AppPillButton.primary(
            label: t.advisorActionOpenJob,
            icon: Icons.open_in_new_rounded,
            size: AppPillButtonSize.small,
            onPressed: () {
              HapticFeedback.selectionClick();
              onOpen(job);
            },
          ),
        ],
      ),
    );
  }
}

class _FreshnessFooter extends StatelessWidget {
  final DateTime lastRefresh;
  const _FreshnessFooter({required this.lastRefresh});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(lastRefresh),
      alwaysUse24HourFormat: false,
    );
    return Row(
      children: [
        Icon(
          Icons.bolt_rounded,
          size: AppDimensions.iconXs,
          color: semantic.success.base,
        ),
        const SizedBox(width: AppDimensions.s6),
        Flexible(
          child: Text(
            '${t.advisorFreshnessLive} · ${t.advisorHomeUpdatedAt(time)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
