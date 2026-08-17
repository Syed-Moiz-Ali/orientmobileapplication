import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/followup_reminder_entity.dart';
import 'advisor_jobs_view.dart';
import 'advisor_job_detail_view.dart';
import 'advisor_reports_view.dart';
import '../widgets/advisor_profile_sheet.dart';
import '../widgets/advisor_notification_sheet.dart';
import '../widgets/advisor_approval_sheet.dart';
import '../widgets/advisor_contact_sheet.dart';
import '../widgets/advisor_search_sheet.dart';
import '../widgets/advisor_stat_dialog.dart';

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
    final callbacks = InspectionCallbacks(
      onBack: () => context.pop(),
      onSaveDraft: () {
        context.pop();
        _toast('Draft saved successfully', icon: Icons.save_outlined);
      },
      onPreview: () {
        context.push(AppRoutes.inspectionPreview, extra: {'onBack': () => context.go(AppRoutes.advisorDashboard)});
      },
    );
    context.push(AppRoutes.inspectionSheet, extra: callbacks);
  }

  void _toast(String msg, {IconData? icon, Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8)],
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
        duration: const Duration(seconds: 3),
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => AdvisorJobDetailView(jc: jc)));
  }

  void _onApproval(PendingApprovalEntity pa) {
    HapticFeedback.mediumImpact();
    final colorScheme = Theme.of(context).colorScheme;
    _sheet(
      AdvisorApprovalSheet(
        pa: pa,
        onApprove: () {
          Navigator.pop(context);
          _persistApproval(pa, 'approved');
          _toast(
            'Estimate ${pa.estimateId} approved',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF10B981),
          );
        },
        onReject: () {
          Navigator.pop(context);
          _persistApproval(pa, 'rejected');
          _toast('Sent back for revision', icon: Icons.undo, color: colorScheme.secondary);
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
    _sheet(
      AdvisorContactSheet(
        r: r,
        onCall: () {
          Navigator.pop(context);
          _toast('Calling ${r.customerName}…', icon: Icons.phone_outlined);
        },
        onWhatsApp: () {
          Navigator.pop(context);
          _toast('Opening WhatsApp…', icon: Icons.chat_outlined, color: const Color(0xFF10B981));
        },
        onSms: () {
          Navigator.pop(context);
          _toast('SMS sent', icon: Icons.sms_outlined);
        },
        onDone: () {
          Navigator.pop(context);
          _toast('Marked as completed', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF10B981));
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
      builder: (_) => AdvisorStatDialog(label: label, count: count, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _navIndex,
            children: [
              _AdvisorDashboardContent(
                onShowProfile: _showProfile,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _AdvisorStreamlinedNav(
              selectedIndex: _navIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() => _navIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ADVISOR DASHBOARD TAB CONTENT ───────────────────────────────────────────
class _AdvisorDashboardContent extends ConsumerWidget {
  final VoidCallback onShowProfile;
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
    required this.onShowProfile,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final recentJobs = ref.watch(advisorRecentJobCardsProvider).value ?? const <JobCardEntity>[];
    final assignedBookings = ref.watch(advisorAssignedBookingsProvider).value ?? const <AdvisorBookingResponse>[];
    final activeBooking = assignedBookings.firstOrNull;

    return RefreshIndicator(
      onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. PREMIUM ADVISOR HEADER ─────────────────────────────────
            _AdvisorCommandHeader(onNotificationTap: onShowNotifications, onProfileTap: onShowProfile),
            const SizedBox(height: 24),

            // ── 2. QUICK INTAKE SEARCH PILL ───────────────────────────────
            _AdvisorSearchPill(onTap: onShowSearch),
            const SizedBox(height: 24),

            // ── 3. BENTO ACTION MATRIX ────────────────────────────────────
            _AdvisorBentoMatrix(
              onScan: onOpenScan,
              onNewJob: onNewJobCard,
              onInspection: onOpenInspection,
              onReports: () => onNavigateTab(2),
            ),
            const SizedBox(height: 28),

            // ── 4. LIVE INTAKE RADAR HUD ──────────────────────────────────
            if (activeBooking != null) ...[
              _ActiveIntakeRadarHUD(booking: activeBooking, onTap: () => onNavigateTab(1)),
              const SizedBox(height: 28),
            ],

            // ── 5. OPERATIONAL SPOTLIGHT HERO ─────────────────────────────
            const _AdvisorSpotlightHeroBanner(),
            const SizedBox(height: 32),

            // ── 6. SHIFT TELEMETRY QUICK METRICS ──────────────────────────
            _SectionHeadingWithAction(
              title: 'Shift Throughput',
              actionText: 'Analytics',
              onAction: () => onNavigateTab(2),
            ),
            const SizedBox(height: 14),
            _AdvisorShiftMetricsRow(
              totalCount: recentJobs.length,
              inProgressCount: recentJobs.where((j) => j.status == JobCardStatus.inProgress).length,
              completedCount: recentJobs.where((j) => j.status == JobCardStatus.completed).length,
            ),
            const SizedBox(height: 32),

            // ── 7. ACTIVE WORK ORDERS LIST ────────────────────────────────
            _SectionHeadingWithAction(
              title: 'Assigned Work Orders',
              actionText: 'View All (${recentJobs.length})',
              onAction: () => onNavigateTab(1),
            ),
            const SizedBox(height: 14),
            if (recentJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(icon: Icons.assignment_outlined, message: 'No active job cards assigned'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentJobs.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final jc = recentJobs[i];
                  return _AdvisorJobCardTile(job: jc, onTap: () => onJobCard(jc));
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─── 1. ADVISOR COMMAND HEADER ───────────────────────────────────────────────
class _AdvisorCommandHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _AdvisorCommandHeader({required this.onNotificationTap, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'ADVISOR INTAKE · COMMAND',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Service Desk',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _PressScale(
              onTap: () {
                HapticFeedback.selectionClick();
                onNotificationTap();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Icon(Icons.notifications_none_rounded, color: colorScheme.onSurface, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            _PressScale(
              onTap: () {
                HapticFeedback.selectionClick();
                onProfileTap();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── 2. UBER-STYLE QUICK INTAKE SEARCH ───────────────────────────────────────
class _AdvisorSearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _AdvisorSearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search intake, customer, or VIN...',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Lookup repair orders, estimates & history',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.qr_code_scanner_rounded, color: colorScheme.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── 3. BENTO QUICK ACTIONS MATRIX ───────────────────────────────────────────
class _AdvisorBentoMatrix extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onNewJob;
  final VoidCallback onInspection;
  final VoidCallback onReports;

  const _AdvisorBentoMatrix({
    required this.onScan,
    required this.onNewJob,
    required this.onInspection,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _AdvisorBentoTile(
                title: 'Quick VIN\nScanner',
                subtitle: 'Camera scan',
                icon: Icons.qr_code_scanner_rounded,
                isPrimary: true,
                onTap: onScan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _AdvisorBentoTile(
                title: 'New Job\nCard',
                subtitle: 'Client intake',
                icon: Icons.add_to_photos_rounded,
                isPrimary: false,
                onTap: onNewJob,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _AdvisorBentoTile(
                title: 'Vehicle\nInspection',
                subtitle: 'Checkpoints',
                icon: Icons.fact_check_rounded,
                isPrimary: false,
                onTap: onInspection,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _AdvisorBentoTile(
                title: 'Advisor\nReports',
                subtitle: 'Throughput logs',
                icon: Icons.bar_chart_rounded,
                isPrimary: false,
                onTap: onReports,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdvisorBentoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AdvisorBentoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bgColor = isPrimary ? colorScheme.primary : colorScheme.surface;
    final fgColor = isPrimary ? colorScheme.onPrimary : colorScheme.onSurface;

    return _PressScale(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPrimary ? Colors.transparent : colorScheme.outlineVariant),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? colorScheme.onPrimary.withValues(alpha: 0.18)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: fgColor, size: 18),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: isPrimary ? colorScheme.onPrimary.withValues(alpha: 0.6) : colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(color: fgColor, fontWeight: FontWeight.w900, height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: isPrimary ? colorScheme.onPrimary.withValues(alpha: 0.8) : colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 4. LIVE INTAKE RADAR HUD ────────────────────────────────────────────────
class _ActiveIntakeRadarHUD extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onTap;

  const _ActiveIntakeRadarHUD({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return _PressScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(color: colorScheme.primary.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'INTAKE RADAR ACTIVE',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'CONFIRMED ARRIVAL',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.car_crash_rounded, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.serviceType} · ${booking.vehicleName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Client: ${booking.customerName} · ${booking.bookingDate}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 5. PHOTOGRAPHIC OPERATIONAL HERO BANNER ─────────────────────────────────
class _AdvisorSpotlightHeroBanner extends StatelessWidget {
  const _AdvisorSpotlightHeroBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1486006920555-c77dce18193b?q=80&w=800&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.88), Colors.black.withValues(alpha: 0.35)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'ADVISOR DESK ERP',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Automated Estimate Approvals\n& Transparent Inspections.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 6. SHIFT METRICS QUICK ROW ──────────────────────────────────────────────
class _AdvisorShiftMetricsRow extends StatelessWidget {
  final int totalCount;
  final int inProgressCount;
  final int completedCount;

  const _AdvisorShiftMetricsRow({
    required this.totalCount,
    required this.inProgressCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _MetricTile(label: 'Total Orders', value: '$totalCount', color: colorScheme.primary),
        const SizedBox(width: 8),
        _MetricTile(label: 'In Progress', value: '$inProgressCount', color: colorScheme.secondary),
        const SizedBox(width: 8),
        _MetricTile(label: 'Delivered', value: '$completedCount', color: const Color(0xFF10B981)),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 7. ADVISOR JOB CARD TILE ────────────────────────────────────────────────
class _AdvisorJobCardTile extends StatelessWidget {
  final JobCardEntity job;
  final VoidCallback onTap;

  const _AdvisorJobCardTile({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final statusColor = job.status == JobCardStatus.completed
        ? const Color(0xFF10B981)
        : job.status == JobCardStatus.inProgress
        ? colorScheme.secondary
        : colorScheme.primary;

    return _PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: Text(
                job.customerName.isNotEmpty ? job.customerName[0] : 'C',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.customerName,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                  ),
                  Text(
                    '${job.vehicleInfo} · ${job.id}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job.status.name.toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 8. STREAMLINED BOTTOM NAV ───────────────────────────────────────────────
class _AdvisorStreamlinedNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _AdvisorStreamlinedNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    const items = [
      _NavDef(selectedIcon: Icons.dashboard_rounded, icon: Icons.dashboard_outlined, label: 'Command'),
      _NavDef(selectedIcon: Icons.receipt_long_rounded, icon: Icons.receipt_long_outlined, label: 'Job Cards'),
      _NavDef(selectedIcon: Icons.bar_chart_rounded, icon: Icons.bar_chart_outlined, label: 'Reports'),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = selectedIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary.withValues(alpha: 0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? items[i].selectedIcon : items[i].icon,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  const _NavDef({required this.selectedIcon, required this.icon, required this.label});
}

// ─── HEADINGS & MOTION HELPERS ───────────────────────────────────────────────
class _SectionHeadingWithAction extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeadingWithAction({required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onAction();
          },
          child: Text(
            actionText,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
