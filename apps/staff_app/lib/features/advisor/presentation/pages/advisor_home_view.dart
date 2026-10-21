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

  void _showSearch() => _sheet(
    AdvisorSearchSheet(
      onScan: () {
        Navigator.pop(context);
        _openScan();
      },
    ),
  );

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
// C16 dashboard composition (phase 3): greeting header -> ONE hero summary
// card -> 3-tile quick-action row -> pinned search pill (recents) ->
// assigned work as large card rows with Show all -> summary behind See all.
// The horizontal quick-action row follows the brief (C16); it overrides the
// recorded 2026-10-15 owner preference for the 2x2 grid — flagged, not silent.
// Urgent work still surfaces inside the assigned list via the UNCHANGED
// urgent-first sort + status chips; there is no separate attention panel.
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
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  final List<String> _recents = <String>[];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  void _submitSearch(String v) {
    final query = v.trim();
    if (query.isNotEmpty) {
      setState(() {
        _recents.remove(query);
        _recents.insert(0, query);
        if (_recents.length > 4) _recents.removeRange(4, _recents.length);
      });
    }
    FocusScope.of(context).unfocus();
  }

  void _applyRecent(String query) {
    _searchCtrl.text = query;
    setState(() => _query = query);
  }

  static bool _visibleRecents(String query, List<String> recents) {
    final trimmed = query.trim().toLowerCase();
    return recents.any((r) => r.trim().toLowerCase() != trimmed);
  }

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
    // Plate-aware search across id / customer / vehicle (local-first cards
    // carry "Model · PLATE" in vehicleInfo). Filter the full list, then cap.
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? sorted
        : sorted
              .where(
                (jc) =>
                    jc.id.toLowerCase().contains(q) ||
                    jc.customerName.toLowerCase().contains(q) ||
                    jc.vehicleInfo.toLowerCase().contains(q),
              )
              .toList();
    // Min 5 visible without scrolling past chrome; cap keeps summary in reach.
    final visible = matches.take(6).toList();

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
                    pendingSync: widget.pendingSync,
                    approvalsCount: widget.approvalsCount,
                    onOpenSearch: widget.onOpenSearch,
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
              if (offline)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s12,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppBanner(
                      kind: AppBannerKind.warning,
                      message: t.advisorOfflineNotice,
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
              // ── 4. PINNED SEARCH (AppSearchPill + recents + scan) ─────────
              // Hidden when there is nothing to filter (empty/error with a
              // clear query): the header search + Ctrl+K + scan tile stay, so
              // no affordance is lost. This also lifts the empty/error action
              // above the fold at base 360px.
              if (_query.trim().isNotEmpty || sorted.isNotEmpty || jobsLoading)
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 0,
                  titleSpacing: 0,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: colors.surface,
                  shape: Border(
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(
                      _visibleRecents(_query, _recents) ? 116 : 64,
                    ),
                    child: ColoredBox(
                      color: colors.surface,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: _PinnedSearchBar(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          query: _query,
                          recents: _recents,
                          onChanged: (v) => setState(() => _query = v),
                          onSubmitted: _submitSearch,
                          onApplyRecent: _applyRecent,
                          onScan: widget.onOpenScan,
                        ),
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  AppDimensions.s8,
                  AppDimensions.s20,
                  110,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (twoCol) ...[
                        // ── 5. ASSIGNED + SIDE PREVIEW (medium/expanded) ─────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _AssignedCards(
                                jobs: visible,
                                totalCount: matches.length,
                                isLoading: jobsLoading,
                                hasError: jobsError,
                                isSearching: q.isNotEmpty,
                                onClearSearch: _clearSearch,
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
                        const SizedBox(height: AppDimensions.s24),
                        _AdvisorSummary(
                          jobs: sorted,
                          statsNew: stats?.newJobCardsToday ?? 0,
                          isLoading: jobsLoading,
                          onOpenReports: () => widget.onNavigateTab(2),
                        ),
                      ] else ...[
                        // ── 5. ASSIGNED WORK (large card rows) ───────────────
                        _AssignedCards(
                          jobs: visible,
                          totalCount: matches.length,
                          isLoading: jobsLoading,
                          hasError: jobsError,
                          isSearching: q.isNotEmpty,
                          onClearSearch: _clearSearch,
                          onRetry: () =>
                              ref.invalidate(advisorRecentJobCardsProvider),
                          onSelect: widget.onJobCard,
                          onSeeAll: () => widget.onNavigateTab(1),
                          onNewJob: widget.onNewJobCard,
                        ),
                        const SizedBox(height: AppDimensions.s24),

                        // ── 6. SUMMARY BEHIND SEE ALL / REPORTS ──────────────
                        _AdvisorSummary(
                          jobs: sorted,
                          statsNew: stats?.newJobCardsToday ?? 0,
                          isLoading: jobsLoading,
                          onOpenReports: () => widget.onNavigateTab(2),
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
// One AppPageHeader: date eyebrow + greeting title + branch·shift subtitle,
// with the offline pill, bell (+ badge) and avatar as trailing actions.
class _AdvisorHomeHeader extends ConsumerWidget {
  final AdvisorInfo info;
  final int pendingSync;
  final int approvalsCount;
  final VoidCallback onOpenSearch;
  final VoidCallback onNotifications;
  final VoidCallback onShowProfile;

  const _AdvisorHomeHeader({
    required this.info,
    required this.pendingSync,
    required this.approvalsCount,
    required this.onOpenSearch,
    required this.onNotifications,
    required this.onShowProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    // Sentence-case date as its own muted line: AppPageHeader upper-cases
    // its eyebrow slot (shared component, untouched), so the date renders
    // above it instead of going through that slot (customer-home pattern).
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
        Text(
          date,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        AppPageHeader(
          title: t.advisorGreeting(greetingName),
          subtitle: contextLine.isEmpty ? null : contextLine,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconButton(
                icon: Icons.search_rounded,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onOpenSearch();
                },
                tooltip: t.advisorActionSearchTitle,
              ),
              const SizedBox(width: AppDimensions.s4),
              OfflineStatusPill(pendingSyncCount: pendingSync),
              const SizedBox(width: AppDimensions.s4),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppIconButton(
                    icon: Icons.notifications_none_rounded,
                    onPressed: onNotifications,
                    tooltip: t.advisorNotificationsTitle,
                  ),
                  if (bellCount > 0)
                    PositionedDirectional(
                      top: 6,
                      end: 6,
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
                onTap: onShowProfile,
                semanticLabel: t.advisorProfileLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 2. HERO SUMMARY ─────────────────────────────────────────────────────────
// ONE hero card (AppSurfaceCard, no media block — the old icon slot rendered
// a dead grey box-in-box above the headline): the key number (inspections
// due today) + a plain-language delta sentence + ONE verb-first primary CTA
// ("View jobs") into the Jobs tab. No stray full-width "See all" here —
// Show-all lives on the Assigned / summary sections only. Skeleton mirrors
// the card while the first load is in flight.
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
    final title = t.advisorHeroDueTitle(inspectionsDue);
    // Zero state owns honest copy: no "urgent first" when nothing is due.
    final sentence = inspectionsDue == 0
        ? t.advisorHeroCaughtUp
        : newToday == 0
        ? t.advisorHeroSentence
        : '${t.advisorDeltaToday(newToday)}. ${t.advisorHeroSentence}';
    return AppSurfaceCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppDimensions.s12),
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
// One horizontal row of 3 tiles (Scan, New job, Approvals with count) on
// wide rows; narrower rows (< 480 dp: phones, half-width medium column)
// reflow to a 2x2 grid so every label keeps full words on two lines instead
// of truncating mid-word (proven customer-home pattern). New job is the
// emphasized primary. Per the brief this C16 row overrides the recorded
// 2026-10-15 owner preference for the 2x2 grid.
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
    final approvalsLabel = approvalsCount > 0
        ? '${t.advisorActionApprovalsTitle} ($approvalsCount)'
        : t.advisorActionApprovalsTitle;
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
        emphasised: true,
        onTap: onNewJob,
      ),
      _AdvisorQuickTileData(
        key: const Key('advisor_quick_approvals'),
        label: approvalsLabel,
        hint: t.advisorActionApprovalsSubtitle,
        icon: Icons.fact_check_outlined,
        badgeCount: approvalsCount,
        onTap: onApprovals,
      ),
    ];
    return Semantics(
      label: t.advisorQuickActionsEyebrow,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 3-across needs ~120px per tile for full-word labels; narrower
          // rows use a 2x2 grid instead of truncating mid-word. Both keep
          // >= 48dp targets and full Semantics.
          if (constraints.maxWidth < 480) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _AdvisorQuickTile(action: tiles[0])),
                    const SizedBox(width: AppDimensions.s10),
                    Expanded(child: _AdvisorQuickTile(action: tiles[1])),
                  ],
                ),
                const SizedBox(height: AppDimensions.s10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _AdvisorQuickTile(action: tiles[2])),
                    const SizedBox(width: AppDimensions.s10),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: AppDimensions.s10),
                Expanded(child: _AdvisorQuickTile(action: tiles[i])),
              ],
            ],
          );
        },
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
  final bool emphasised;
  final int badgeCount;

  const _AdvisorQuickTileData({
    this.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.emphasised = false,
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
    final emphasised = action.emphasised;

    final tile = Container(
      key: action.key,
      // Fill the cell so the overlay badge anchors to the tile corner.
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: emphasised
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: emphasised
              ? colors.primary.withValues(alpha: 0.32)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            action.icon,
            size: 24,
            color: emphasised ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Two-line wrap on word boundaries; the <480 reflow above keeps
          // full words visible at 1.3x/320/ar instead of mid-word cuts.
          Text(
            action.label,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: emphasised ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    final tappable = Semantics(
      button: true,
      excludeSemantics: true,
      label: '${action.label}, ${action.hint}',
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
                  PositionedDirectional(
                    top: 8,
                    end: 8,
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

// ─── 4. PINNED SEARCH ────────────────────────────────────────────────────────
// Pill-style pinned search (AppSearchBar): the same controller, focus,
// query state, recents and scan CTA as before, so the inline assigned-list
// filter behaves verbatim. The full search sheet stays one tap away (header
// search + Ctrl+K shortcut, same route).
class _PinnedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final List<String> recents;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final void Function(String) onApplyRecent;
  final VoidCallback onScan;

  const _PinnedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.recents,
    required this.onChanged,
    required this.onSubmitted,
    required this.onApplyRecent,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    // Short verb hint ("Search") always fits beside the scan CTA at base
    // 360px, 320px and 1.3x; the long jobs-list hint truncated. Recents
    // never show a chip duplicating the current query.
    final trimmedQuery = query.trim().toLowerCase();
    final chips = recents
        .where((r) => r.trim().toLowerCase() != trimmedQuery)
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AppSearchBar(
                controller: controller,
                focusNode: focusNode,
                hint: t.advisorActionSearchTitle,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            const SizedBox(width: AppDimensions.s8),
            AppIconButton(
              icon: Icons.qr_code_scanner_rounded,
              onPressed: () {
                HapticFeedback.selectionClick();
                onScan();
              },
              tooltip: t.advisorActionScanTitle,
              filled: true,
              active: true,
            ),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s4),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimensions.s8),
              itemBuilder: (context, i) => AppChip(
                label: chips[i],
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  onApplyRecent(chips[i]);
                },
                semanticLabel: chips[i],
              ),
            ),
          ),
        ],
      ],
    );
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
  final bool isSearching;
  final VoidCallback onClearSearch;
  final VoidCallback onRetry;
  final void Function(JobCardEntity) onSelect;
  final VoidCallback onSeeAll;
  final VoidCallback onNewJob;

  const _AssignedCards({
    required this.jobs,
    required this.totalCount,
    required this.isLoading,
    required this.hasError,
    this.isSearching = false,
    required this.onClearSearch,
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
      child = isSearching
          ? AppEmptyState(
              icon: Icons.search_off_rounded,
              title: t.advisorNoMatchingJobs,
              message: t.advisorJobsSearchHint,
              actionLabel: SharedCoreL10n.of(context).filterBarClear,
              onAction: onClearSearch,
            )
          : AppEmptyState(
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

    return AppSection(
      // Count inline on the header line (never on its own line).
      title: '${t.advisorAssignedWorkOrders} ($totalCount)',
      seeAllLabel: t.advisorSeeAll,
      onSeeAll: () {
        HapticFeedback.selectionClick();
        onSeeAll();
      },
      child: child,
    );
  }
}

/// One assigned job as a large card: job id (LTR mono, tabular) first, then
/// customer + vehicle + plate, one plain status sentence, ONE status chip,
/// and a trailing chevron affordance into the job workspace. Urgent-first
/// order is UNCHANGED (logic). Identifiers and times stay LTR in RTL.
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
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    jc.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(color: colors.onSurface),
                  ),
                ),
                const SizedBox(height: AppDimensions.s4),
                Text(
                  '${jc.customerName} · ${jc.vehicleInfo}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
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
                const SizedBox(height: AppDimensions.s8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppStatusChip(
                    label: advisorStatusLabel(t, jc.status),
                    kind: _homeStatusKind(jc.status),
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

// ─── 6. WORK SUMMARY ─────────────────────────────────────────────────────────
// Slim metrics behind See all / the Reports tab: total, in-progress, ready.
// Counts are derived from the same assigned list as before (logic unchanged);
// zeros render as a muted dash, never a giant 0-card.
class _AdvisorSummary extends StatelessWidget {
  final List<JobCardEntity> jobs;
  final int statsNew;
  final bool isLoading;
  final VoidCallback onOpenReports;

  const _AdvisorSummary({
    required this.jobs,
    required this.statsNew,
    required this.isLoading,
    required this.onOpenReports,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;

    final total = jobs.length;
    final inProgress = jobs
        .where((j) => j.status == JobCardStatus.inProgress)
        .length;
    final ready = jobs
        .where(
          (j) =>
              j.status == JobCardStatus.completed ||
              j.status == JobCardStatus.delivered ||
              j.status == JobCardStatus.qualityCheckPassed,
        )
        .length;

    if (isLoading) {
      return const SizedBox(
        height: 76,
        child: AppShimmerSkeleton.card(height: 76),
      );
    }

    String value(int v) => v == 0 ? '–' : '$v';
    // Only Total carries a today-delta ("new job cards today" genuinely
    // grows the total, same source as the hero "+2 today"). Per-metric
    // today-deltas are not reported by the entities, so In progress / Ready
    // show no delta rather than an invented one.
    final String? totalDelta = statsNew == 0
        ? null
        : t.advisorDeltaToday(statsNew);

    return AppSection(
      title: t.advisorWorkSummary,
      seeAllLabel: t.advisorSeeAll,
      onSeeAll: () {
        HapticFeedback.selectionClick();
        onOpenReports();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppStatTile(
              label: t.advisorMetricTotalOrders,
              value: value(total),
              deltaText: totalDelta,
              deltaUp: totalDelta == null ? null : true,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: AppStatTile(
              label: t.advisorMetricInProgress,
              value: value(inProgress),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: AppStatTile(
              label: t.advisorMetricReady,
              value: value(ready),
            ),
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
        child: Text(
          t.advisorJobsSelectPrompt,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return AppSurfaceCard(
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
