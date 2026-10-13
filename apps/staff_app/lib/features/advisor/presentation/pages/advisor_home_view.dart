import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_jobs_view.dart';
import 'advisor_reports_view.dart';
import '../widgets/advisor_approval_row.dart';
import '../widgets/advisor_approval_sheet.dart';
import '../widgets/advisor_contact_sheet.dart';
import '../widgets/advisor_job_card_row.dart';
import '../widgets/advisor_meta_pill.dart';
import '../widgets/advisor_notification_sheet.dart';
import '../widgets/advisor_profile_sheet.dart';
import '../widgets/advisor_search_sheet.dart';
import '../widgets/advisor_stat_dialog.dart';

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

  void _openInspectionDirect() {
    HapticFeedback.mediumImpact();
    // An inspection must belong to a customer, vehicle and job card. Starting
    // with intake also supports selecting an existing customer/vehicle; after
    // the job card is saved the advisor is prompted to begin the inspection.
    context.push(AppRoutes.vehicleCustomer);
  }

  void _toast(String msg, {IconData? icon, Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.textInverse,
                size: AppDimensions.iconSm,
              ),
              const SizedBox(width: AppDimensions.s8),
            ],
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w700,
                ),
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
            t.advisorToastApproved(pa.typeLabel, pa.estimateId),
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          );
        },
        onReject: () {
          Navigator.pop(context);
          _persistApproval(pa, 'reject');
          _toast(
            t.advisorToastRejected(pa.typeLabel, pa.estimateId),
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

  void _onContact(FollowupReminderEntity r) {
    HapticFeedback.lightImpact();
    final t = StaffLocalizations.of(context)!;
    _sheet(
      AdvisorContactSheet(
        r: r,
        onCall: () {
          Navigator.pop(context);
          _toast(
            t.advisorToastCalling(r.customerName),
            icon: Icons.phone_outlined,
          );
        },
        onWhatsApp: () {
          Navigator.pop(context);
          _toast(
            t.advisorToastOpeningWhatsApp,
            icon: Icons.chat_outlined,
            color: AppColors.success,
          );
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
            color: AppColors.success,
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

  void _onStat(String label, int count, Color color) {
    showDialog(
      context: context,
      builder: (_) => AdvisorStatDialog(
        label: label,
        count: count,
        color: color,
        onViewAll: () => setState(() => _navIndex = 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final t = StaffLocalizations.of(context)!;
    final items = _advisorNavItems(t);

    return DashboardShell(
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
                      _AdvisorAvatar(radius: 16),
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
                    child: _AdvisorAvatar(radius: 18),
                  ),
          ),
        ),
        child: IndexedStack(
          index: _navIndex,
          children: [
            _AdvisorDashboardContent(
              onShowNotifications: _showNotifications,
              onShowSearch: _showSearch,
              onOpenScan: _openScan,
              onNewJobCard: _openNewJobCard,
              onOpenInspection: _openInspectionDirect,
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
class _AdvisorDashboardContent extends ConsumerWidget {
  final VoidCallback onShowNotifications;
  final VoidCallback onShowSearch;
  final VoidCallback onOpenScan;
  final VoidCallback onNewJobCard;
  final VoidCallback onOpenInspection;
  final void Function(JobCardEntity) onJobCard;
  final void Function(PendingApprovalEntity) onApproval;
  final void Function(FollowupReminderEntity) onContact;
  final void Function(String, int, Color) onStat;
  final void Function(int) onNavigateTab;

  const _AdvisorDashboardContent({
    required this.onShowNotifications,
    required this.onShowSearch,
    required this.onOpenScan,
    required this.onNewJobCard,
    required this.onOpenInspection,
    required this.onJobCard,
    required this.onApproval,
    required this.onContact,
    required this.onStat,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final info = ref.watch(advisorInfoProvider);

    final recentJobsState = ref.watch(advisorRecentJobCardsProvider);
    final bookingsState = ref.watch(advisorAssignedBookingsProvider);
    final approvalsState = ref.watch(advisorPendingApprovalsProvider);
    final reminders = ref.watch(advisorFollowupRemindersProvider);

    final recentJobs = recentJobsState.value ?? const <JobCardEntity>[];
    final assignedBookings =
        bookingsState.value ?? const <AdvisorBookingResponse>[];
    final approvals = approvalsState.value ?? const <PendingApprovalEntity>[];
    final activeBooking = assignedBookings.firstOrNull;

    final hasDataError =
        recentJobsState.hasError ||
        bookingsState.hasError ||
        approvalsState.hasError;
    final isInitialLoading =
        (recentJobsState.isLoading || bookingsState.isLoading) &&
        recentJobs.isEmpty &&
        assignedBookings.isEmpty;

    final attentionCount = approvals.length + reminders.length;

    return RefreshIndicator(
      onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
      color: colors.primary,
      backgroundColor: colors.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          context.pagePadding.top,
          context.pagePadding.right,
          110,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. SHIFT HEADER ───────────────────────────────────────────
            _AdvisorHeader(
              name: info.name,
              branch: info.branch,
              shift: info.shift,
              onNotificationTap: onShowNotifications,
              onProfileTap: () => context.push(
                AppRoutes.profile,
                extra: ProfileData(
                  name: info.name,
                  id: info.id,
                  role: t.advisorWorkspaceName,
                  branch: info.branch,
                  shift: info.shift,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s18),

            if (isInitialLoading) ...[
              const AppSkeleton.listRows(rows: 3),
              const SizedBox(height: AppDimensions.s16),
            ],
            if (hasDataError) ...[
              AppInfoPanel.danger(
                message: t.advisorDataError,
                action: TextButton(
                  onPressed: () =>
                      ref.read(advisorRefreshProvider.notifier).state++,
                  child: Text(t.advisorActionRefreshJobCard),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            if (activeBooking != null) ...[
              _ActiveIntakeCard(
                booking: activeBooking,
                onTap: () => onNavigateTab(1),
              ),
              const SizedBox(height: AppDimensions.s18),
            ],

            // ── 2. SEARCH PILL ────────────────────────────────────────────
            _AdvisorSearchPill(onTap: onShowSearch),
            const SizedBox(height: AppDimensions.s18),

            // ── 3. ATTENTION BLOCK ────────────────────────────────────────
            if (attentionCount > 0) ...[
              SectionHeader(
                title: t.advisorAttentionTitle,
                count: attentionCount,
                leadingIcon: Icons.notifications_active_outlined,
              ),
              if (approvals.isNotEmpty)
                ...approvals
                    .take(3)
                    .map((pa) => AdvisorApprovalRow(pa: pa, onTap: onApproval)),
              if (reminders.isNotEmpty)
                ...reminders
                    .take(3)
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.s8,
                        ),
                        child: AppRecordRow(
                          leading: Icon(
                            Icons.alarm_rounded,
                            color: colors.primary,
                          ),
                          title: r.customerName,
                          subtitle: r.task,
                          metadata: Text(
                            r.dueDate,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          onTap: () => onContact(r),
                        ),
                      ),
                    ),
              const SizedBox(height: AppDimensions.s20),
            ],

            // ── 4. QUICK ACTIONS ──────────────────────────────────────────
            Text(
              t.advisorQuickActionsEyebrow.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: AppTypography.tracking(context, 0.8),
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            _AdvisorQuickActionsGrid(
              onScan: onOpenScan,
              onNewJob: onNewJobCard,
              onInspection: onOpenInspection,
              onReports: () => onNavigateTab(2),
            ),
            const SizedBox(height: AppDimensions.s28),

            // ── 5. WORK SUMMARY METRICS ───────────────────────────────────
            SectionHeader(
              title: t.advisorWorkSummary,
              action: t.advisorActionAnalytics,
              onAction: () => onNavigateTab(2),
            ),
            _AdvisorShiftMetrics(
              totalCount: recentJobs.length,
              inProgressCount: recentJobs
                  .where((j) => j.status == JobCardStatus.inProgress)
                  .length,
              completedCount: recentJobs
                  .where(
                    (j) =>
                        j.status == JobCardStatus.completed ||
                        j.status == JobCardStatus.delivered,
                  )
                  .length,
              onStat: onStat,
            ),
            const SizedBox(height: AppDimensions.s28),

            // ── 6. RECENT WORK ORDERS ─────────────────────────────────────
            SectionHeader(
              title: t.advisorAssignedWorkOrders,
              action: t.advisorViewAll(recentJobs.length),
              onAction: () => onNavigateTab(1),
            ),
            if (recentJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.s24,
                ),
                child: EmptyState(
                  icon: Icons.assignment_outlined,
                  message: t.advisorNoActiveJobs,
                ),
              )
            else
              ...recentJobs
                  .take(3)
                  .map((jc) => AdvisorJobCardRow(jc: jc, onTap: onJobCard)),
          ],
        ),
      ),
    );
  }
}

// ─── 1. SHIFT HEADER ─────────────────────────────────────────────────────────
class _AdvisorHeader extends StatelessWidget {
  final String name;
  final String branch;
  final String shift;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _AdvisorHeader({
    required this.name,
    required this.branch,
    required this.shift,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final contextLine = [
      branch,
      shift,
    ].where((s) => s.trim().isNotEmpty).join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.advisorRoleEyebrow.toUpperCase(),
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
                t.advisorDeskTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                t.advisorGreeting(name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (contextLine.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s6),
                Wrap(
                  spacing: AppDimensions.s8,
                  runSpacing: AppDimensions.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AdvisorMetaPill(
                      icon: Icons.store_mall_directory_outlined,
                      label: contextLine,
                    ),
                    AdvisorMetaPill(
                      icon: Icons.cloud_done_outlined,
                      label: t.advisorFreshnessLive,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onNotificationTap();
              },
              tooltip: t.advisorNotificationsTitle,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onProfileTap();
              },
              tooltip: t.advisorProfileLabel,
              icon: const Icon(Icons.person_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── 2. QUICK INTAKE SEARCH PILL ─────────────────────────────────────────────
class _AdvisorSearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _AdvisorSearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s16,
            vertical: AppDimensions.s12,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.s8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: colors.primary,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.advisorSearchPillTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      t.advisorSearchPillSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              Icon(
                Icons.qr_code_scanner_rounded,
                color: colors.onSurfaceVariant,
                size: AppDimensions.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 3. QUICK ACTIONS GRID ───────────────────────────────────────────────────
class _AdvisorQuickActionsGrid extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onNewJob;
  final VoidCallback onInspection;
  final VoidCallback onReports;

  const _AdvisorQuickActionsGrid({
    required this.onScan,
    required this.onNewJob,
    required this.onInspection,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final tiles = <Widget>[
      _AdvisorActionTile(
        title: t.advisorActionScanTitle,
        subtitle: t.advisorActionScanSubtitle,
        icon: Icons.qr_code_scanner_rounded,
        isPrimary: true,
        onTap: onScan,
      ),
      _AdvisorActionTile(
        title: t.advisorActionNewJobTitle,
        subtitle: t.advisorActionNewJobSubtitle,
        icon: Icons.add_to_photos_rounded,
        isPrimary: false,
        onTap: onNewJob,
      ),
      _AdvisorActionTile(
        title: t.advisorActionInspectionTitle,
        subtitle: t.advisorActionInspectionSubtitle,
        icon: Icons.fact_check_rounded,
        isPrimary: false,
        onTap: onInspection,
      ),
      _AdvisorActionTile(
        title: t.advisorActionReportsTitle,
        subtitle: t.advisorActionReportsSubtitle,
        icon: Icons.bar_chart_rounded,
        isPrimary: false,
        onTap: onReports,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppDimensions.cardGap;
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

class _AdvisorActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AdvisorActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        side: BorderSide(
          color: isPrimary ? Colors.transparent : colors.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.s6),
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? colors.onPrimary.withValues(alpha: 0.18)
                          : colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusControl,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isPrimary ? fgColor : colors.primary,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: isPrimary
                        ? colors.onPrimary.withValues(alpha: 0.6)
                        : colors.onSurfaceVariant,
                    size: AppDimensions.iconSm,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPrimary
                      ? colors.onPrimary.withValues(alpha: 0.8)
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 4. CONFIRMED ARRIVAL / ACTIVE INTAKE ────────────────────────────────────
class _ActiveIntakeCard extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onTap;

  const _ActiveIntakeCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s18),
          child: Column(
            children: [
              Row(
                children: [
                  StatusPill.info(t.advisorActiveArrival, showDot: true),
                  const Spacer(),
                  Text(
                    t.advisorConfirmedAppointment.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.s12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusInput,
                      ),
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: colors.primary,
                      size: AppDimensions.iconLg,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.serviceType} · ${booking.vehicleName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          '${t.advisorClientPrefix(booking.customerName)} · ${booking.bookingDate}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DirectionalIcon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 5. SHIFT METRICS ────────────────────────────────────────────────────────
class _AdvisorShiftMetrics extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int completedCount;
  final void Function(String, int, Color) onStat;

  const _AdvisorShiftMetrics({
    required this.totalCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.onStat,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = StaffLocalizations.of(context)!;

    final tiles = <Widget>[
      AppKpiCard.compact(
        label: t.advisorMetricTotalOrders,
        value: '$totalCount',
        icon: Icons.assignment_outlined,
        onTap: () =>
            onStat(t.advisorMetricTotalOrders, totalCount, colors.primary),
      ),
      AppKpiCard.compact(
        label: t.advisorMetricInProgress,
        value: '$inProgressCount',
        icon: Icons.build_circle_outlined,
        semanticState: KpiSemanticState.info,
        onTap: () =>
            onStat(t.advisorMetricInProgress, inProgressCount, AppColors.info),
      ),
      AppKpiCard.compact(
        label: t.advisorMetricDelivered,
        value: '$completedCount',
        icon: Icons.verified_outlined,
        semanticState: KpiSemanticState.success,
        onTap: () =>
            onStat(t.advisorMetricDelivered, completedCount, AppColors.success),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppDimensions.cardGap;
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}
