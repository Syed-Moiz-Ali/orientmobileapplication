import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_jobs_view.dart';
import 'advisor_reports_view.dart';
import '../widgets/advisor_approval_sheet.dart';
import '../widgets/advisor_contact_sheet.dart';
import '../widgets/advisor_job_card_row.dart';
import '../widgets/advisor_notification_sheet.dart';
import '../widgets/advisor_profile_sheet.dart';
import '../widgets/advisor_search_sheet.dart';
import '../widgets/advisor_stat_dialog.dart';
import '../widgets/advisor_status.dart';

List<AppNavItem> _advisorNavItems(StaffLocalizations t) => <AppNavItem>[
  AppNavItem(selectedIcon: Icons.dashboard_rounded, icon: Icons.dashboard_outlined, label: t.advisorNavToday),
  AppNavItem(selectedIcon: Icons.receipt_long_rounded, icon: Icons.receipt_long_outlined, label: t.advisorNavJobs),
  AppNavItem(selectedIcon: Icons.bar_chart_rounded, icon: Icons.bar_chart_outlined, label: t.advisorNavReports),
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

  void _showNotifications() {
    HapticFeedback.lightImpact();
    _sheet(const AdvisorNotificationSheet());
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
            t.advisorToastApproved(advisorApprovalTypeLabel(t, pa.approvalType), pa.estimateId),
            icon: Icons.check_circle_outline,
            color: context.semanticColors.success.base,
          );
        },
        onReject: () {
          Navigator.pop(context);
          _persistApproval(pa, 'reject');
          _toast(
            t.advisorToastRejected(advisorApprovalTypeLabel(t, pa.approvalType), pa.estimateId),
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
        payload: {'estimateId': pa.estimateId, 'action': action, 'customerName': pa.customerName, 'amount': pa.amount},
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await ref.read(syncEngineProvider).syncAll();
  }

  void _onContact(FollowupReminderEntity r) {
    HapticFeedback.lightImpact();
    final t = StaffLocalizations.of(context)!;
    _sheet(
      AdvisorContactSheet(
        r: r,
        onCall: () {
          Navigator.pop(context);
          _toast(t.advisorToastCalling(r.customerName), icon: Icons.phone_outlined);
        },
        onWhatsApp: () {
          Navigator.pop(context);
          _toast(t.advisorToastOpeningWhatsApp, icon: Icons.chat_outlined, color: context.semanticColors.success.base);
        },
        onSms: () {
          Navigator.pop(context);
          _toast(t.advisorToastSmsSent, icon: Icons.sms_outlined);
        },
        onDone: () {
          Navigator.pop(context);
          _toast(
            t.advisorToastMarkedDone,
            icon: Icons.check_circle_outline_rounded,
            color: context.semanticColors.success.base,
          );
        },
      ),
    );
  }

  void _showSearch() => _sheet(
    AdvisorSearchSheet(
      onScan: () {
        Navigator.pop(context);
        _openScan();
      },
    ),
  );

  void _onStat(String label, int count, String delta, Color color) {
    showDialog(
      context: context,
      builder: (_) => AdvisorStatDialog(
        label: label,
        count: count,
        delta: delta,
        color: color,
        onViewAll: () => setState(() => _navIndex = 1),
      ),
    );
  }

  void _openApprovals() {
    final approvals = ref.read(advisorPendingApprovalsProvider).valueOrNull ?? const <PendingApprovalEntity>[];
    if (approvals.isEmpty) {
      _toast(
        StaffLocalizations.of(context)!.advisorAttentionEmptyTitle,
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
    final info = ref.watch(advisorInfoProvider);
    final items = _advisorNavItems(t);
    final pendingSync = ref.watch(advisorPendingSyncCountProvider).value ?? 0;
    final approvalsCount = ref.watch(advisorPendingApprovalsProvider).valueOrNull?.length ?? 0;
    final contextLine = [info.branch, info.shift].where((s) => s.trim().isNotEmpty).join(' · ');

    final shell = DashboardShell(
      // The header carries the integrated OfflineStatusPill; suppress the
      // duplicate full-width banner (Phase 04.1 rule).
      showOfflineBanner: false,
      appBar: WorkspaceAppBar(
        title: t.advisorDeskTitle,
        subtitle: contextLine.isEmpty ? null : contextLine,
        frosted: !context.isCompact,
        showOfflineStatus: true,
        offlinePendingCount: pendingSync,
        onSearch: _showSearch,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              _showNotifications();
            },
            tooltip: t.advisorNotificationsTitle,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppDimensions.s8),
            child: InkWell(
              onTap: _showProfile,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              child: Tooltip(message: t.advisorProfileLabel, child: const _AdvisorAvatar(radius: 16)),
            ),
          ),
        ],
      ),
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: _navIndex,
        onSelected: (index) => setState(() => _navIndex = index),
        headerBuilder: (ctx, ext) => OrientBrandMark(workspace: t.advisorWorkspaceName, compact: !ext),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: _showProfile,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ext ? AppDimensions.s8 : 0, vertical: AppDimensions.s4),
            child: ext
                ? Row(
                    children: [
                      const _AdvisorAvatar(radius: 16),
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
                : Tooltip(message: t.advisorProfileLabel, child: const _AdvisorAvatar(radius: 18)),
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
              onJobCard: _onJobCard,
              onApproval: _onApproval,
              onContact: _onContact,
              onStat: _onStat,
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

    // ⌘K / Ctrl+K global search, plus the always-visible app-bar trigger above.
    return WorkspaceSearchShortcuts(onSearch: _showSearch, child: shell);
  }
}

class _AdvisorAvatar extends StatelessWidget {
  final double radius;
  const _AdvisorAvatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primary.withValues(alpha: 0.14),
      child: Text(
        'A',
        style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800, fontSize: radius * 0.8),
      ),
    );
  }
}

// ─── ADVISOR DASHBOARD TAB CONTENT ───────────────────────────────────────────
// Command board composition (Phase 06 rework §2): identity → attention radar
// → action dock → KPI strip → recent work → freshness footer. Attention always
// sits above passive metrics; every section owns its loading/error/empty
// treatment so nothing fails silently.
class _AdvisorDashboardContent extends ConsumerStatefulWidget {
  final VoidCallback onOpenScan;
  final VoidCallback onNewJobCard;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenApprovals;
  final int approvalsCount;
  final void Function(JobCardEntity) onJobCard;
  final void Function(PendingApprovalEntity) onApproval;
  final void Function(FollowupReminderEntity) onContact;
  final void Function(String, int, String, Color) onStat;
  final void Function(int) onNavigateTab;

  const _AdvisorDashboardContent({
    required this.onOpenScan,
    required this.onNewJobCard,
    required this.onOpenSearch,
    required this.onOpenApprovals,
    required this.approvalsCount,
    required this.onJobCard,
    required this.onApproval,
    required this.onContact,
    required this.onStat,
    required this.onNavigateTab,
  });

  @override
  ConsumerState<_AdvisorDashboardContent> createState() => _AdvisorDashboardContentState();
}

class _AdvisorDashboardContentState extends ConsumerState<_AdvisorDashboardContent> {
  bool _attentionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final info = ref.watch(advisorInfoProvider);

    final recentJobsState = ref.watch(advisorRecentJobCardsProvider);
    final approvalsState = ref.watch(advisorPendingApprovalsProvider);
    final statsState = ref.watch(advisorDashboardProvider);
    final reminders = ref.watch(advisorFollowupRemindersProvider);

    final recentJobs = recentJobsState.valueOrNull ?? const <JobCardEntity>[];
    final approvals = approvalsState.valueOrNull ?? const <PendingApprovalEntity>[];
    final stats = statsState.valueOrNull;

    final jobsLoading = recentJobsState.isLoading && recentJobs.isEmpty;
    final jobsError = recentJobsState.hasError;
    final attentionLoading = approvalsState.isLoading && approvals.isEmpty;
    final attentionError = approvalsState.hasError;
    final statsLoading = statsState.isLoading && stats == null;
    final firstLoad = jobsLoading && attentionLoading && statsLoading;

    return RefreshIndicator(
      onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
      color: colors.primary,
      backgroundColor: colors.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(context.pagePadding.left, context.pagePadding.top, context.pagePadding.right, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. COMMAND IDENTITY ──────────────────────────────────
            _AdvisorCommandIdentity(name: info.name),
            const SizedBox(height: AppDimensions.s18),

            if (firstLoad) ...[
              const _HomeSkeleton(),
            ] else ...[
              // ── 2. ATTENTION RADAR (always above metrics) ──────────
              _AttentionPanel(
                approvals: approvals,
                reminders: reminders,
                isLoading: attentionLoading,
                hasError: attentionError,
                expanded: _attentionExpanded,
                onToggleExpanded: () => setState(() => _attentionExpanded = !_attentionExpanded),
                onApproval: widget.onApproval,
                onContact: widget.onContact,
                onRetry: () => ref.invalidate(advisorPendingApprovalsProvider),
              ),
              const SizedBox(height: AppDimensions.s24),

              // ── 3. ACTION DOCK ─────────────────────────────────────
              _SectionEyebrow(label: t.advisorQuickActionsEyebrow),
              const SizedBox(height: AppDimensions.s12),
              _AdvisorActionDock(
                onScan: widget.onOpenScan,
                onNewJob: widget.onNewJobCard,
                onApprovals: widget.onOpenApprovals,
                onSearch: widget.onOpenSearch,
                approvalsCount: widget.approvalsCount,
              ),
              const SizedBox(height: AppDimensions.s28),

              // ── 4. KPI STRIP (scroll-snap, never a grid) ───────────
              SectionHeader(
                title: t.advisorWorkSummary,
                action: t.advisorActionAnalytics,
                onAction: () => widget.onNavigateTab(2),
              ),
              _AdvisorMetricStrip(
                totalCount: recentJobs.length,
                inProgressCount: recentJobs.where((j) => j.status == JobCardStatus.inProgress).length,
                completedCount: recentJobs
                    .where((j) => j.status == JobCardStatus.completed || j.status == JobCardStatus.delivered)
                    .length,
                newToday: stats?.newJobCardsToday ?? 0,
                inspectionsToday: stats?.inspectionsToday ?? 0,
                deliveredToday: stats?.delivered ?? 0,
                isLoading: statsLoading || jobsLoading,
                onStat: widget.onStat,
              ),
              const SizedBox(height: AppDimensions.s28),

              // ── 5. RECENT WORK ─────────────────────────────────────
              SectionHeader(
                title: t.advisorAssignedWorkOrders,
                action: t.advisorSeeAll,
                onAction: () => widget.onNavigateTab(1),
              ),
              if (jobsLoading)
                const AppSkeleton.listRows(rows: 3)
              else if (jobsError)
                AppInfoPanel.danger(
                  message: t.advisorDataError,
                  action: TextButton(
                    onPressed: () => ref.invalidate(advisorRecentJobCardsProvider),
                    child: Text(t.advisorActionRefreshJobCard),
                  ),
                )
              else if (recentJobs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
                  child: EmptyState(icon: Icons.assignment_outlined, message: t.advisorNoActiveJobs),
                )
              else
                ...recentJobs.take(5).map((jc) => AdvisorJobCardRow(jc: jc, onTap: widget.onJobCard)),
              const SizedBox(height: AppDimensions.s8),
              _FreshnessFooter(semantic: context.semanticColors),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String label;
  const _SectionEyebrow({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: AppTypography.tracking(context, 0.8),
      ),
    );
  }
}

// ─── 1. COMMAND IDENTITY ─────────────────────────────────────────────────────
// Eyebrow (TODAY) + greeting + localized date. Branch/shift context already
// lives in the WorkspaceAppBar subtitle, so no hero banner or duplicate pills.
class _AdvisorCommandIdentity extends StatelessWidget {
  final String name;

  const _AdvisorCommandIdentity({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final date = MaterialLocalizations.of(context).formatMediumDate(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.advisorTodayEyebrow.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: AppTypography.tracking(context, 1.1),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          t.advisorGreeting(name),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          date,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FreshnessFooter extends StatelessWidget {
  final AppSemanticColors semantic;
  const _FreshnessFooter({required this.semantic});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.bolt_rounded, size: AppDimensions.iconXs, color: semantic.success.base),
        const SizedBox(width: AppDimensions.s6),
        Flexible(
          child: Text(
            t.advisorFreshnessLive,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

// ─── 2. ATTENTION RADAR ──────────────────────────────────────────────────────
// Amber 1px border on a warning-subtle fill. Urgent rows carry a status pill +
// customer / vehicle / plate + time + chevron; the list caps at 4 with an
// inline See-all expansion. An empty radar renders a success card — attention
// is never silently absent.
class _AttentionPanel extends StatelessWidget {
  static const _visibleCap = 4;

  final List<PendingApprovalEntity> approvals;
  final List<FollowupReminderEntity> reminders;
  final bool isLoading;
  final bool hasError;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final void Function(PendingApprovalEntity) onApproval;
  final void Function(FollowupReminderEntity) onContact;
  final VoidCallback onRetry;

  const _AttentionPanel({
    required this.approvals,
    required this.reminders,
    required this.isLoading,
    required this.hasError,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onApproval,
    required this.onContact,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final count = approvals.length + reminders.length;

    if (isLoading) {
      return const AppSkeleton.card(height: 168);
    }

    if (hasError) {
      return AppInfoPanel.danger(
        message: t.advisorDataError,
        action: TextButton(onPressed: onRetry, child: Text(t.advisorActionRefreshJobCard)),
      );
    }

    // Empty radar: success-illustration card, not a silent gap.
    if (count == 0) {
      return Container(
        decoration: BoxDecoration(
          color: semantic.success.subtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: semantic.success.border),
        ),
        padding: const EdgeInsets.all(AppDimensions.s14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.s6),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
              ),
              child: Icon(Icons.check_circle_outline_rounded, size: AppDimensions.iconMd, color: semantic.success.ink),
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.advisorAttentionEmptyTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface),
                  ),
                  Text(
                    t.advisorAttentionEmptyHint,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final rows = <Widget>[
      for (final pa in approvals)
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.s8),
          child: AppRecordRow(
            status: StatusPill.warning(advisorApprovalTypeLabel(t, pa.approvalType)),
            title: pa.customerName,
            subtitle: '${pa.vehicleId} · ${pa.estimateId}',
            metadata: Text(pa.timeAgo, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
            onTap: () => onApproval(pa),
          ),
        ),
      for (final r in reminders)
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.s8),
          child: AppRecordRow(
            status: _reminderPill(t, r),
            title: r.customerName,
            subtitle: '${r.vehicleId} · ${r.task}',
            metadata: Text(r.dueDate, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
            onTap: () => onContact(r),
          ),
        ),
    ];
    final visible = expanded ? rows : rows.take(_visibleCap).toList();

    return Container(
      decoration: BoxDecoration(
        color: semantic.warning.subtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: semantic.warning.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.s6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  size: AppDimensions.iconMd,
                  color: semantic.warning.ink,
                ),
              ),
              const SizedBox(width: AppDimensions.s10),
              Expanded(
                child: Text(
                  t.advisorAttentionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface),
                ),
              ),
              StatusPill.warning('$count'),
            ],
          ),
          const SizedBox(height: AppDimensions.s12),
          ...visible,
          if (rows.length > _visibleCap)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onToggleExpanded,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                  minimumSize: const Size(0, AppDimensions.touchTarget),
                ),
                child: Text(expanded ? t.advisorShowLess : t.advisorSeeAll),
              ),
            ),
        ],
      ),
    );
  }
}

StatusPill _reminderPill(StaffLocalizations t, FollowupReminderEntity r) => switch (r.priority) {
  ReminderPriority.high => StatusPill.danger(t.advisorPriorityHigh),
  ReminderPriority.medium => StatusPill.warning(t.advisorPriorityMedium),
  ReminderPriority.low => StatusPill.info(t.advisorPriorityLow),
};

// ─── 3. ACTION DOCK ──────────────────────────────────────────────────────────
// Four fixed 56px tiles: cobalt-primary Scan, New job, Approvals with a live
// pending badge, and Search (same sheet as Ctrl/Cmd+K). Columns come from the
// adaptive spec — never raw width literals.
class _AdvisorActionDock extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onNewJob;
  final VoidCallback onApprovals;
  final VoidCallback onSearch;
  final int approvalsCount;

  const _AdvisorActionDock({
    required this.onScan,
    required this.onNewJob,
    required this.onApprovals,
    required this.onSearch,
    required this.approvalsCount,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final tiles = <Widget>[
      _DockTile(
        label: t.advisorActionScanTitle,
        icon: Icons.qr_code_scanner_rounded,
        isPrimary: true,
        badgeCount: 0,
        onTap: onScan,
      ),
      _DockTile(
        label: t.advisorActionNewJobTitle,
        icon: Icons.add_rounded,
        isPrimary: false,
        badgeCount: 0,
        onTap: onNewJob,
      ),
      _DockTile(
        label: t.advisorActionApprovalsTitle,
        icon: Icons.fact_check_outlined,
        isPrimary: false,
        badgeCount: approvalsCount,
        onTap: onApprovals,
      ),
      _DockTile(
        label: t.advisorActionSearchTitle,
        icon: Icons.search_rounded,
        isPrimary: false,
        badgeCount: 0,
        onTap: onSearch,
      ),
    ];

    final columns = context.adaptive.pick(compact: 2, medium: 4);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppDimensions.cardGap;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
        );
      },
    );
  }
}

class _DockTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final int badgeCount;
  final VoidCallback onTap;

  const _DockTile({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bgColor = isPrimary ? colors.primary : colors.surface;
    final fgColor = isPrimary ? colors.onPrimary : colors.onSurface;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        side: BorderSide(color: isPrimary ? Colors.transparent : colors.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s12),
            child: Row(
              children: [
                Icon(icon, color: isPrimary ? fgColor : colors.primary, size: AppDimensions.iconMd),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(color: fgColor, fontWeight: FontWeight.w700),
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: AppDimensions.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? colors.onPrimary.withValues(alpha: 0.22)
                          : colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: theme.textTheme.labelSmall?.copyWith(color: fgColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 4. KPI STRIP ────────────────────────────────────────────────────────────
// Three scroll-snap metrics (never a grid): tabular value + same-day delta.
// Compact viewports page through them with snap; wider viewports lay all
// three out in one row. Columns come from the adaptive spec.
class _AdvisorMetricStrip extends StatefulWidget {
  final int totalCount;
  final int inProgressCount;
  final int completedCount;
  final int newToday;
  final int inspectionsToday;
  final int deliveredToday;
  final bool isLoading;
  final void Function(String, int, String, Color) onStat;

  const _AdvisorMetricStrip({
    required this.totalCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.newToday,
    required this.inspectionsToday,
    required this.deliveredToday,
    required this.isLoading,
    required this.onStat,
  });

  @override
  State<_AdvisorMetricStrip> createState() => _AdvisorMetricStripState();
}

class _AdvisorMetricStripState extends State<_AdvisorMetricStrip> {
  late final PageController _pages;

  @override
  void initState() {
    super.initState();
    _pages = PageController(viewportFraction: 0.62);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final semantic = context.semanticColors;

    if (widget.isLoading) {
      return const SizedBox(height: 124, child: AppSkeleton.card(height: 124));
    }

    final cards = <Widget>[
      _MetricCard(
        label: t.advisorMetricTotalOrders,
        value: widget.totalCount,
        delta: t.advisorDeltaToday(widget.newToday),
        accent: semantic.primary,
        icon: Icons.assignment_outlined,
        onTap: () => widget.onStat(
          t.advisorMetricTotalOrders,
          widget.totalCount,
          t.advisorDeltaToday(widget.newToday),
          semantic.primary,
        ),
      ),
      _MetricCard(
        label: t.advisorMetricInProgress,
        value: widget.inProgressCount,
        delta: t.advisorDeltaToday(widget.inspectionsToday),
        accent: semantic.info.base,
        icon: Icons.build_circle_outlined,
        onTap: () => widget.onStat(
          t.advisorMetricInProgress,
          widget.inProgressCount,
          t.advisorDeltaToday(widget.inspectionsToday),
          semantic.info.base,
        ),
      ),
      _MetricCard(
        label: t.advisorMetricDelivered,
        value: widget.completedCount,
        delta: t.advisorDeltaToday(widget.deliveredToday),
        accent: semantic.success.base,
        icon: Icons.verified_outlined,
        onTap: () => widget.onStat(
          t.advisorMetricDelivered,
          widget.completedCount,
          t.advisorDeltaToday(widget.deliveredToday),
          semantic.success.base,
        ),
      ),
    ];

    // Wide viewports: all three side by side. Compact: snap paging.
    if (!context.adaptive.isCompact) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppDimensions.cardGap),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }
    return SizedBox(
      height: 124,
      child: PageView.builder(
        controller: _pages,
        padEnds: false,
        itemCount: cards.length,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsetsDirectional.only(end: i == cards.length - 1 ? 0 : AppDimensions.cardGap),
          child: cards[i],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final String delta;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: AppDimensions.iconSm, color: accent),
                  const SizedBox(width: AppDimensions.s6),
                  Expanded(
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
              const SizedBox(height: AppDimensions.s4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metric(color: colors.onSurface),
                ),
              ),
              Text(
                delta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FIRST-LOAD SKELETON (mirrors section order) ─────────────────────────────
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton.card(height: 168),
        SizedBox(height: AppDimensions.s24),
        AppSkeleton.card(height: 56),
        SizedBox(height: AppDimensions.s28),
        SizedBox(height: 124, child: AppSkeleton.card(height: 124)),
        SizedBox(height: AppDimensions.s28),
        AppSkeleton.listRows(rows: 3),
      ],
    );
  }
}
