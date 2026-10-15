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
import '../widgets/advisor_job_card_row.dart';
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
// Greeting-led composition (Phase 06 correction + transformation): greeting
// header (no WorkspaceAppBar) → action grid → assigned work orders
// (urgent-first divider rows) → slim work-summary strip last. Urgent work
// surfaces inside the assigned list via sort + status pills; there is no
// separate attention panel.
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

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
    );
    final maxWidth = context.adaptive.pick(
      compact: double.infinity,
      medium: 640.0,
      expanded: 1180.0,
    );

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
              // ── 1. GREETING HEADER (owns identity + actions, no app bar) ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.s20,
                  AppDimensions.s16,
                  AppDimensions.s20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _GreetingHeader(
                    info: info,
                    pendingSync: widget.pendingSync,
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
                    onProfile: () {
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
              // ── 2. SEARCH HERO (branded SliverAppBar, pinned search) ──────
              SliverAppBar(
                pinned: true,
                floating: false,
                automaticallyImplyLeading: false,
                expandedHeight: context.adaptive.pick(
                  compact: 216.0,
                  medium: 224.0,
                  expanded: 240.0,
                ),
                toolbarHeight: 0,
                titleSpacing: 0,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                backgroundColor: colors.surface,
                shape: Border(bottom: BorderSide(color: colors.outlineVariant)),
                flexibleSpace: FlexibleSpaceBar(
                  background: _SearchHero(
                    recents: _recents,
                    onRecent: _applyRecent,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.s20,
                      AppDimensions.s4,
                      AppDimensions.s20,
                      AppDimensions.s12,
                    ),
                    child: _PremiumSearchField(
                      controller: _searchCtrl,
                      focusNode: _searchFocus,
                      query: _query,
                      hintText: t.advisorJobsSearchHint,
                      onChanged: (v) => setState(() => _query = v),
                      onSubmitted: _submitSearch,
                      onClear: _clearSearch,
                      onScan: widget.onOpenScan,
                    ),
                  ),
                ),
              ),
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
                      if (wide) ...[
                        // ── 3. ACTION GRID + 5. SUMMARY RAIL (desktop) ────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ActionStrip(
                                approvalsCount: widget.approvalsCount,
                                onScan: widget.onOpenScan,
                                onNewJob: widget.onNewJobCard,
                                onApprovals: widget.onOpenApprovals,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s24),
                            SizedBox(
                              width: 320,
                              child: _SummaryStrip(
                                jobs: sorted,
                                statsNew: stats?.newJobCardsToday ?? 0,
                                statsActive: stats?.inspectionsToday ?? 0,
                                statsReady: stats?.delivered ?? 0,
                                isLoading: jobsLoading,
                                onOpenJobs: () => widget.onNavigateTab(1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s24),
                        // ── 4. ASSIGNED + SIDE PREVIEW (desktop) ──────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _AssignedSection(
                                jobs: visible,
                                totalCount: matches.length,
                                isLoading: jobsLoading,
                                hasError: jobsError,
                                isSearching: q.isNotEmpty,
                                onClearSearch: _clearSearch,
                                selectedId: _selected?.id,
                                onRetry: () => ref.invalidate(
                                  advisorRecentJobCardsProvider,
                                ),
                                onSelect: (jc) =>
                                    setState(() => _selected = jc),
                                onSeeAll: () => widget.onNavigateTab(1),
                                onScan: widget.onOpenScan,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s24),
                            Expanded(
                              flex: 2,
                              child: _DesktopPreview(
                                jc:
                                    _selected ??
                                    (visible.isNotEmpty ? visible.first : null),
                                onOpen: widget.onJobCard,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // ── 3. ACTION GRID (compact 2x2, 4-up on wider) ─────────────
                        _ActionStrip(
                          approvalsCount: widget.approvalsCount,
                          onScan: widget.onOpenScan,
                          onNewJob: widget.onNewJobCard,
                          onApprovals: widget.onOpenApprovals,
                        ),
                        const SizedBox(height: AppDimensions.s24),

                        // ── 4. ASSIGNED WORK ORDERS (urgent-first divider rows) ─────
                        _AssignedSection(
                          jobs: visible,
                          totalCount: matches.length,
                          isLoading: jobsLoading,
                          hasError: jobsError,
                          isSearching: q.isNotEmpty,
                          onClearSearch: _clearSearch,
                          selectedId: null,
                          onRetry: () =>
                              ref.invalidate(advisorRecentJobCardsProvider),
                          onSelect: widget.onJobCard,
                          onSeeAll: () => widget.onNavigateTab(1),
                          onScan: widget.onOpenScan,
                        ),
                        const SizedBox(height: AppDimensions.s24),

                        // ── 5. WORK SUMMARY LAST (slim inline metrics, no cards) ────
                        _SummaryStrip(
                          jobs: sorted,
                          statsNew: stats?.newJobCardsToday ?? 0,
                          statsActive: stats?.inspectionsToday ?? 0,
                          statsReady: stats?.delivered ?? 0,
                          isLoading: jobsLoading,
                          onOpenJobs: () => widget.onNavigateTab(1),
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
// Urgent-first ordering replaces the deleted attention panel: actionable
// statuses (pending / approval / parts / QC) sort above active work, which
// sorts above finished + cancelled. Stable within rank (server order kept).
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

// ─── 1. GREETING HEADER ──────────────────────────────────────────────────────
// One header row: greeting texts (eyebrow date + 22/800 title + branch·shift)
// plus integrated actions (search, Synced pill, bell + badge, avatar). No
// WorkspaceAppBar on this tab by product exception.
class _GreetingHeader extends ConsumerWidget {
  final AdvisorInfo info;
  final int pendingSync;
  final int approvalsCount;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _GreetingHeader({
    required this.info,
    required this.pendingSync,
    required this.approvalsCount,
    required this.onSearch,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
                t.advisorGreeting(info.name),
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
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onSearch();
              },
              tooltip: t.advisorActionSearchTitle,
              icon: const Icon(Icons.search_rounded),
              color: colors.onSurfaceVariant,
            ),
            OfflineStatusPill(pendingSyncCount: pendingSync),
            IconButton(
              onPressed: onNotifications,
              tooltip: t.advisorNotificationsTitle,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded),
                  if (bellCount > 0)
                    PositionedDirectional(
                      top: -2,
                      end: -2,
                      child: _HeaderBadge(count: bellCount),
                    ),
                ],
              ),
              color: colors.onSurfaceVariant,
            ),
            InkWell(
              onTap: onProfile,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              child: Tooltip(
                message: t.advisorProfileLabel,
                child: _AdvisorAvatar(radius: 16, initials: info.initials),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final int count;
  const _HeaderBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = count > 9 ? '9+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.onError,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─── 3. ACTION GRID ─────────────────────────────────────────────────────────
// Live product override (2026-10-15): the horizontal scroll strip tested
// poorly — owner preferred the 2x2 grid. Restored as a compact 2x2 grid
// (tight 64px tiles, 8px gaps, eyebrow above) going 4-up static on medium+.
// Recorded as an override of correction D3 in REPORT_PHASE_06 §14.
class _ActionStrip extends StatelessWidget {
  final int approvalsCount;
  final VoidCallback onScan;
  final VoidCallback onNewJob;
  final VoidCallback onApprovals;

  const _ActionStrip({
    required this.approvalsCount,
    required this.onScan,
    required this.onNewJob,
    required this.onApprovals,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final staticRow = context.adaptive.pick(
      compact: false,
      medium: true,
      expanded: true,
    );

    final scan = _StripTile(
      label: t.advisorActionScanTitle,
      icon: Icons.qr_code_scanner_rounded,
      kind: _StripKind.primary,
      badgeCount: 0,
      onTap: onScan,
    );
    final newJob = _StripTile(
      label: t.advisorActionNewJobTitle,
      icon: Icons.add_rounded,
      kind: _StripKind.outlined,
      badgeCount: 0,
      onTap: onNewJob,
    );
    final approvals = _StripTile(
      label: t.advisorActionApprovalsTitle,
      icon: Icons.fact_check_outlined,
      kind: _StripKind.outlined,
      badgeCount: approvalsCount,
      onTap: onApprovals,
    );

    // Search lives in the 30% SliverAppBar hero now, not in the grid: two
    // tiles up top, approvals full-width beneath; 3-up static on medium+.
    if (staticRow) {
      return Row(
        children: [
          Expanded(child: scan),
          const SizedBox(width: AppDimensions.s8),
          Expanded(child: newJob),
          const SizedBox(width: AppDimensions.s8),
          Expanded(child: approvals),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: scan),
            const SizedBox(width: AppDimensions.s8),
            Expanded(child: newJob),
          ],
        ),
        const SizedBox(height: AppDimensions.s8),
        approvals,
      ],
    );
  }
}

enum _StripKind { primary, outlined, ghost }

class _StripTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final _StripKind kind;
  final int badgeCount;
  final VoidCallback onTap;

  const _StripTile({
    required this.label,
    required this.icon,
    required this.kind,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPrimary = kind == _StripKind.primary;
    final isGhost = kind == _StripKind.ghost;
    final bg = isPrimary ? colors.primary : Colors.transparent;
    final fg = isPrimary ? colors.onPrimary : colors.onSurface;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        side: BorderSide(
          color: isPrimary || isGhost
              ? Colors.transparent
              : colors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        splashColor: colors.primary.withValues(alpha: 0.08),
        highlightColor: colors.primary.withValues(alpha: 0.04),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? fg : colors.primary,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: AppDimensions.s8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      color: isPrimary ? fg : colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: AppDimensions.s6),
                  _CountBadge(count: badgeCount, onPrimary: isPrimary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Badge pops on count change (160ms, static under reduced motion).
class _CountBadge extends StatelessWidget {
  final int count;
  final bool onPrimary;
  const _CountBadge({required this.count, required this.onPrimary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(count),
      tween: Tween<double>(begin: 0.7, end: 1),
      duration: AppMotion.resolve(context, AppMotion.fast),
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s8,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: onPrimary
              ? colors.onPrimary.withValues(alpha: 0.22)
              : colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        child: Text(
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            color: onPrimary ? colors.onPrimary : colors.primary,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

// ─── 2b. SEARCH HERO BACKGROUND ──────────────────────────────────────────────
// Premium branded command header for the SliverAppBar: a confident hyper-cobalt
// wash folding into the deep-navy high-emphasis surface, softened by low-alpha
// light blooms and an oversized ghost glyph. White type + frosted recents chips
// sit bottom-aligned so the pinned search field docks into it cleanly. Static
// art (no animation budget); recents are session-only presentation state. The
// copy is top-anchored so the pinned search field never occludes it, with the
// whole band rounded at the bottom to float above the canvas.
class _SearchHero extends StatelessWidget {
  final List<String> recents;
  final void Function(String) onRecent;

  const _SearchHero({required this.recents, required this.onRecent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppDimensions.radiusSheet),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              colors.primary,
              Color.lerp(colors.primary, semantic.surfaceStrong, 0.58)!,
              semantic.surfaceStrong,
            ],
            stops: const [0.0, 0.58, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const PositionedDirectional(
              top: -80,
              end: -56,
              child: _HeroBloom(size: 232, color: Color(0x1FFFFFFF)),
            ),
            PositionedDirectional(
              bottom: -64,
              start: -40,
              child: _HeroBloom(
                size: 184,
                color: colors.primary.withValues(alpha: 0.34),
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: -28,
              child: Icon(
                Icons.travel_explore_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s20,
                AppDimensions.s16,
                AppDimensions.s20,
                0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: AppDimensions.iconLg,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.advisorSearchTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.advisorSearchHint,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (recents.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s14),
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: AppDimensions.iconXs,
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                        const SizedBox(width: AppDimensions.s6),
                        Text(
                          t.advisorSearchRecent.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.70),
                            fontWeight: FontWeight.w800,
                            letterSpacing: AppTypography.tracking(context, 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.s8),
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppDimensions.s8),
                        itemBuilder: (context, i) => _RecentChip(
                          label: recents[i],
                          onTap: () => onRecent(recents[i]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Soft radial light bloom used for depth on the branded hero. Low-alpha only —
// decorative, never a coloured glow on interactive chrome.
class _HeroBloom extends StatelessWidget {
  final double size;
  final Color color;

  const _HeroBloom({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RecentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s12,
            vertical: AppDimensions.s4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: AppDimensions.iconXs,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppDimensions.s6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

// ─── 2c. PREMIUM SEARCH FIELD ────────────────────────────────────────────────
// Pinned base of the search hero: a 56px floating white pill (soft card shadow,
// primed to the modal elevation + cobalt ring on focus) with a trailing cobalt
// scan CTA bisected by a hairline. Filters the assigned list inline by id /
// customer / plate.
class _PremiumSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final String hintText;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onScan;

  const _PremiumSearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.hintText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onScan,
  });

  @override
  State<_PremiumSearchField> createState() => _PremiumSearchFieldState();
}

class _PremiumSearchFieldState extends State<_PremiumSearchField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return AnimatedContainer(
      duration: AppMotion.resolve(context, AppMotion.fast),
      curve: AppMotion.standardCurve,
      height: 56,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(
          color: _focused ? colors.primary : colors.outlineVariant,
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: _focused
            ? AppDimensions.shadowModal
            : AppDimensions.shadowCard,
      ),
      child: Row(
        children: [
          const SizedBox(width: AppDimensions.s16),
          Icon(
            Icons.search_rounded,
            size: AppDimensions.iconMd,
            color: colors.primary,
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              maxLines: 1,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintMaxLines: 1,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (widget.query.isNotEmpty)
            IconButton(
              onPressed: widget.onClear,
              tooltip: SharedCoreL10n.of(context).filterBarClear,
              icon: const Icon(Icons.clear_rounded),
              color: colors.onSurfaceVariant,
            ),
          Container(width: 1, height: 24, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s4),
            child: Material(
              color: colors.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onScan();
                },
                customBorder: const CircleBorder(),
                child: Tooltip(
                  message: t.advisorActionScanTitle,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.s10),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: AppDimensions.iconMd,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s4),
        ],
      ),
    );
  }
}

// ─── 4. ASSIGNED WORK ORDERS ─────────────────────────────────────────────────
// Eyebrow + count + See all; 72px divider rows (no cards-per-row): status dot
// 8px + customer 15/600 + plate pill + job mono 12 LTR + status pill right +
// time muted 12 + chevron. Urgent-first with "Due today" microcopy.
class _AssignedSection extends ConsumerWidget {
  final List<JobCardEntity> jobs;
  final int totalCount;
  final bool isLoading;
  final bool hasError;
  final bool isSearching;
  final VoidCallback onClearSearch;
  final String? selectedId;
  final VoidCallback onRetry;
  final void Function(JobCardEntity) onSelect;
  final VoidCallback onSeeAll;
  final VoidCallback onScan;

  const _AssignedSection({
    required this.jobs,
    required this.totalCount,
    required this.isLoading,
    required this.hasError,
    this.isSearching = false,
    required this.onClearSearch,
    required this.selectedId,
    required this.onRetry,
    required this.onSelect,
    required this.onSeeAll,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final offline =
        ref.watch(connectivityStatusProvider).value == ConnectivityResult.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      t.advisorAssignedWorkOrders.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: AppTypography.tracking(context, 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXs,
                      ),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      '$totalCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s8,
                  vertical: AppDimensions.s4,
                ),
                minimumSize: const Size(0, AppDimensions.touchTarget),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                t.advisorSeeAll,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        if (offline) ...[
          Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: AppDimensions.iconXs,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s6),
              Expanded(
                child: Text(
                  t.advisorOfflineNotice,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
        ],
        if (isLoading)
          const _AssignedSkeletonRows()
        else if (hasError)
          EmptyState.error(message: t.advisorDataError, onRetry: onRetry)
        else if (jobs.isEmpty)
          if (isSearching)
            Column(
              children: [
                EmptyState.noMatch(
                  icon: Icons.search_off_rounded,
                  message: t.advisorNoMatchingJobs,
                ),
                const SizedBox(height: AppDimensions.s16),
                Center(
                  child: TextButton(
                    onPressed: onClearSearch,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppDimensions.touchTarget),
                    ),
                    child: Text(SharedCoreL10n.of(context).filterBarClear),
                  ),
                ),
              ],
            )
          else
            EmptyState(
              icon: Icons.assignment_outlined,
              message: t.advisorNoActiveJobs,
              actionLabel: t.advisorActionScanTitle,
              onAction: onScan,
            )
        else
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colors.outlineVariant),
                bottom: BorderSide(color: colors.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < jobs.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.outlineVariant,
                    ),
                  _FadeSlideIn(
                    child: AdvisorJobCardRow(
                      jc: jobs[i],
                      selected: selectedId == jobs[i].id,
                      showDueToday: _urgencyRank(jobs[i].status) == 0,
                      onTap: onSelect,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// Skeleton mirrors the 72px divider-row geometry (dot + lines + pill).
class _AssignedSkeletonRows extends StatelessWidget {
  const _AssignedSkeletonRows();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 5; i++)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s12,
            ),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  AppSkeleton.circle(size: 8),
                  SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSkeleton.text(width: 160, height: 14),
                        SizedBox(height: AppDimensions.s6),
                        AppSkeleton.text(width: 220, height: 12),
                      ],
                    ),
                  ),
                  SizedBox(width: AppDimensions.s12),
                  AppSkeleton.text(width: 64, height: 22),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// 220ms fade-slide list entrance; static under reduced motion.
class _FadeSlideIn extends StatelessWidget {
  final Widget child;
  const _FadeSlideIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: AppMotion.reducedMotion(context) ? 1 : 0,
        end: 1,
      ),
      duration: AppMotion.resolve(context, AppMotion.standard),
      curve: AppMotion.enter,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ─── 5. WORK SUMMARY (LAST) ──────────────────────────────────────────────────
// Slim 3-inline strip: 20sp tabular values + 11px muted deltas, 1px dividers
// instead of cards. Taps open the jobs tab. Zeros render as a muted dash,
// never giant 0-cards. No analytics link (no such route; reports is a tab).
class _SummaryStrip extends StatelessWidget {
  final List<JobCardEntity> jobs;
  final int statsNew;
  final int statsActive;
  final int statsReady;
  final bool isLoading;
  final VoidCallback onOpenJobs;

  const _SummaryStrip({
    required this.jobs,
    required this.statsNew,
    required this.statsActive,
    required this.statsReady,
    required this.isLoading,
    required this.onOpenJobs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
      return const SizedBox(height: 76, child: AppSkeleton.card(height: 76));
    }

    final cells = <Widget>[
      _MetricCell(
        label: t.advisorMetricTotalOrders,
        value: total,
        delta: statsNew,
        deltaText: statsNew == 0 ? null : t.advisorDeltaToday(statsNew),
        onTap: onOpenJobs,
      ),
      _MetricCell(
        label: t.advisorMetricInProgress,
        value: inProgress,
        delta: statsActive,
        deltaText: statsActive == 0 ? null : t.advisorDeltaToday(statsActive),
        onTap: onOpenJobs,
      ),
      _MetricCell(
        label: t.advisorMetricReady,
        value: ready,
        delta: statsReady,
        deltaText: statsReady == 0 ? null : t.advisorDeltaToday(statsReady),
        onTap: onOpenJobs,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.advisorWorkSummary.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: AppTypography.tracking(context, 0.8),
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  height: 56,
                  color: colors.outlineVariant,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s8,
                  ),
                ),
              Expanded(child: cells[i]),
            ],
          ],
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String label;
  final int value;
  final int delta;
  final String? deltaText;
  final VoidCallback onTap;

  const _MetricCell({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final empty = value == 0;

    return Semantics(
      button: true,
      label: '$label: ${empty ? '–' : value}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.s8,
              horizontal: AppDimensions.s4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empty ? '–' : '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: empty ? colors.onSurfaceVariant : colors.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  deltaText ?? '–',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Desktop side preview reusing the job-card sheet fields inline (no new
// routes; Open pushes the existing job-detail route).
class _DesktopPreview extends StatelessWidget {
  final JobCardEntity? jc;
  final void Function(JobCardEntity) onOpen;

  const _DesktopPreview({required this.jc, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final job = jc;

    if (job == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Text(
          t.advisorJobsSelectPrompt,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              advisorStatusPill(t, job.status),
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onOpen(job),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: AppDimensions.iconSm,
              ),
              label: Text(t.advisorActionOpenJob),
            ),
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
