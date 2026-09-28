import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/common/presentation/staff_shimmer_skeletons.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorDashboardTab extends ConsumerWidget {
  const SupervisorDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isDashboardLoading) {
      return const SupervisorQueueSkeleton();
    }

    final bookings = notifier.bookings;
    final breakdowns = notifier.breakdowns;
    final awaitingQc = notifier.awaitingCompletions;
    final activeJobs = notifier.jobs;
    final advisorWorkload = notifier.advisorJobData;
    final jobTypes = notifier.jobTypes;
    final kpis = notifier.kpis;

    final unassignedBookingsCount = bookings.length;
    final breakdownsWaitingCount = breakdowns.length;
    final awaitingQcCount = awaitingQc.length;
    final hasAttentionItems =
        unassignedBookingsCount > 0 ||
        breakdownsWaitingCount > 0 ||
        awaitingQcCount > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: notifier.refreshDashboard,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.pagePadding.left,
            16,
            context.pagePadding.right,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. HEADER CONTEXT ──────────────────────────────────────────
              _SupervisorContextBanner(
                totalJobs: activeJobs.length,
                pendingCount: unassignedBookingsCount + breakdownsWaitingCount,
              ),
              const SizedBox(height: 16),

              if (state.dashboardError.isNotEmpty) ...[
                _SupervisorErrorNotice(
                  message: state.dashboardError,
                  onRetry: notifier.refreshDashboard,
                ),
                const SizedBox(height: 16),
              ],

              // ── 2. OPERATIONAL ATTENTION AREA ──────────────────────────────
              if (hasAttentionItems) ...[
                _OperationalAttentionArea(
                  unassignedBookings: unassignedBookingsCount,
                  breakdownsWaiting: breakdownsWaitingCount,
                  awaitingQc: awaitingQcCount,
                  onOpenQueue: () => notifier.selectTab(2),
                  onOpenReview: () => notifier.selectTab(3),
                ),
                const SizedBox(height: 24),
              ],

              // ── 3. QUEUE PREVIEW ───────────────────────────────────────────
              _QueuePreviewSection(
                bookingsCount: unassignedBookingsCount,
                breakdownsCount: breakdownsWaitingCount,
                firstBooking: bookings.firstOrNull,
                firstBreakdown: breakdowns.firstOrNull,
                onOpenQueue: () => notifier.selectTab(2),
              ),
              const SizedBox(height: 24),

              // ── 4. ACTIVE WORK / JOBS PREVIEW ──────────────────────────────
              _ActiveJobsPreviewSection(
                jobs: activeJobs.take(3).toList(),
                totalCount: activeJobs.length,
                onViewAll: () => context.push(AppRoutes.supervisorJobs),
                onAssignNew: () => notifier.selectTab(1),
              ),
              const SizedBox(height: 24),

              // ── 5. ADVISOR WORKLOAD & JOB DISTRIBUTION ─────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 768;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AdvisorWorkloadCard(data: advisorWorkload),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _JobCategoryDistributionCard(types: jobTypes),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _AdvisorWorkloadCard(data: advisorWorkload),
                      const SizedBox(height: 16),
                      _JobCategoryDistributionCard(types: jobTypes),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── 6. CONTEXTUAL NAVIGATION TILES ─────────────────────────────
              _ContextualNavigationMatrix(),
              const SizedBox(height: 24),

              // ── 7. OPERATIONAL KPIS ────────────────────────────────────────
              if (kpis.isNotEmpty) ...[
                _SectionTitle(title: 'Operational Summary'),
                const SizedBox(height: 12),
                _KpiOverviewGrid(kpis: kpis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. CONTEXT BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _SupervisorContextBanner extends StatelessWidget {
  final int totalJobs;
  final int pendingCount;

  const _SupervisorContextBanner({
    required this.totalJobs,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.dashboard_customize_outlined,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workshop Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$totalJobs active jobs • $pendingCount incoming items',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. OPERATIONAL ATTENTION AREA
// ─────────────────────────────────────────────────────────────────────────────
class _OperationalAttentionArea extends StatelessWidget {
  final int unassignedBookings;
  final int breakdownsWaiting;
  final int awaitingQc;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenReview;

  const _OperationalAttentionArea({
    required this.unassignedBookings,
    required this.breakdownsWaiting,
    required this.awaitingQc,
    required this.onOpenQueue,
    required this.onOpenReview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Attention Required'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (unassignedBookings > 0)
              _AttentionChip(
                icon: Icons.calendar_today_rounded,
                count: unassignedBookings,
                label: 'Unassigned Bookings',
                color: colors.primary,
                onTap: onOpenQueue,
              ),
            if (breakdownsWaiting > 0)
              _AttentionChip(
                icon: Icons.car_crash_outlined,
                count: breakdownsWaiting,
                label: 'Breakdowns Waiting',
                color: colors.error,
                onTap: onOpenQueue,
              ),
            if (awaitingQc > 0)
              _AttentionChip(
                icon: Icons.verified_outlined,
                count: awaitingQc,
                label: 'Awaiting Inspection',
                color: const Color(0xFFD97706),
                onTap: onOpenReview,
              ),
          ],
        ),
      ],
    );
  }
}

class _AttentionChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttentionChip({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. QUEUE PREVIEW SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _QueuePreviewSection extends StatelessWidget {
  final int bookingsCount;
  final int breakdownsCount;
  final dynamic firstBooking;
  final dynamic firstBreakdown;
  final VoidCallback onOpenQueue;

  const _QueuePreviewSection({
    required this.bookingsCount,
    required this.breakdownsCount,
    required this.firstBooking,
    required this.firstBreakdown,
    required this.onOpenQueue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incoming Work Queue',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$bookingsCount bookings • $breakdownsCount breakdowns waiting',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onOpenQueue();
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Open Queue'),
              ),
            ],
          ),
          if (firstBooking == null && firstBreakdown == null) ...[
            const SizedBox(height: 12),
            const EmptyState(
              icon: Icons.inbox_outlined,
              message: 'No pending bookings or breakdowns in the queue',
            ),
          ] else ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            if (firstBreakdown != null)
              _QueueItemRow(
                badgeLabel: 'BREAKDOWN',
                badgeColor: colors.error,
                title:
                    '${firstBreakdown.vehicleName} • ${firstBreakdown.vehiclePlate}',
                subtitle:
                    '${firstBreakdown.issue} • ${firstBreakdown.location}',
              ),
            if (firstBreakdown != null && firstBooking != null)
              const SizedBox(height: 10),
            if (firstBooking != null)
              _QueueItemRow(
                badgeLabel: 'BOOKING',
                badgeColor: colors.primary,
                title:
                    '${firstBooking.vehicleName} • ${firstBooking.plateNumber}',
                subtitle:
                    '${firstBooking.serviceType} • ${firstBooking.bookingDate}',
              ),
          ],
        ],
      ),
    );
  }
}

class _QueueItemRow extends StatelessWidget {
  final String badgeLabel;
  final Color badgeColor;
  final String title;
  final String subtitle;

  const _QueueItemRow({
    required this.badgeLabel,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            badgeLabel,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. ACTIVE JOBS PREVIEW SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveJobsPreviewSection extends StatelessWidget {
  final List<AssignedJobEntity> jobs;
  final int totalCount;
  final VoidCallback onViewAll;
  final VoidCallback onAssignNew;

  const _ActiveJobsPreviewSection({
    required this.jobs,
    required this.totalCount,
    required this.onViewAll,
    required this.onAssignNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Workshop Jobs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCount jobs currently on the floor',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onViewAll();
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (jobs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: EmptyState(
                icon: Icons.assignment_outlined,
                message: 'No active workshop jobs found',
              ),
            )
          else
            ...jobs.map((job) => _ActiveJobMiniCard(job: job)),
        ],
      ),
    );
  }
}

class _ActiveJobMiniCard extends StatelessWidget {
  final AssignedJobEntity job;
  const _ActiveJobMiniCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDone = job.status == 'Completed';
    final isInProgress = job.status == 'In Progress';
    final statusColor = isDone
        ? const Color(0xFF0F9D73)
        : isInProgress
        ? colors.primary
        : const Color(0xFFD97706);

    final progressFrac = job.total > 0
        ? (job.done / job.total).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.vehicle.isNotEmpty ? job.vehicle : 'Vehicle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${job.jobCard} • ${job.customer} • ${job.dateAssigned}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (job.total > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressFrac,
                      minHeight: 5,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${job.done}/${job.total} tasks',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. ADVISOR WORKLOAD & JOB DISTRIBUTION
// ─────────────────────────────────────────────────────────────────────────────
class _AdvisorWorkloadCard extends StatelessWidget {
  final List<AdvisorJobEntity> data;
  const _AdvisorWorkloadCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advisor Workload',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Assigned active jobs per service advisor',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (data.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: EmptyState(
                icon: Icons.people_outline_rounded,
                message: 'No advisor workload data recorded',
              ),
            )
          else
            ...data.map((item) {
              final count = item.count.toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colors.primary.withValues(alpha: 0.1),
                      child: Text(
                        item.name.isNotEmpty ? item.name[0] : 'A',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count job${count == 1 ? '' : 's'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _JobCategoryDistributionCard extends StatelessWidget {
  final List<JobTypeEntity> types;
  const _JobCategoryDistributionCard({required this.types});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = types.fold<int>(0, (sum, item) => sum + item.count);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Type Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Active work categories across bays',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (types.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: EmptyState(
                icon: Icons.category_outlined,
                message: 'No job type categories recorded',
              ),
            )
          else
            ...types.map((type) {
              final frac = total > 0 ? type.count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            type.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${type.count}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 6,
                        backgroundColor: colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(type.color),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. CONTEXTUAL NAVIGATION MATRIX
// ─────────────────────────────────────────────────────────────────────────────
class _ContextualNavigationMatrix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Workshop Operations Navigation'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;
            final destinations = [
              _NavTileData(
                title: 'Active Jobs',
                subtitle: 'Track floor repairs & progress',
                icon: Icons.directions_car_filled_outlined,
                route: AppRoutes.supervisorJobs,
              ),
              _NavTileData(
                title: 'Workshop Roster',
                subtitle: 'Technicians & departments',
                icon: Icons.groups_outlined,
                route: AppRoutes.supervisorStaff,
              ),
              _NavTileData(
                title: 'Bay Schedule',
                subtitle: 'View booking agendas',
                icon: Icons.calendar_month_outlined,
                route: AppRoutes.supervisorSchedule,
              ),
              _NavTileData(
                title: 'Operations Report',
                subtitle: 'Summary metrics & financial logs',
                icon: Icons.analytics_outlined,
                route: AppRoutes.supervisorReports,
              ),
            ];

            if (isWide) {
              return Row(
                children: [
                  for (int i = 0; i < destinations.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _ContextNavTile(data: destinations[i])),
                  ],
                ],
              );
            }

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: destinations
                  .map((d) => _ContextNavTile(data: d))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _NavTileData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _NavTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class _ContextNavTile extends StatelessWidget {
  final _NavTileData data;
  const _ContextNavTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(data.route);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 20, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. OPERATIONAL KPIS OVERVIEW
// ─────────────────────────────────────────────────────────────────────────────
class _KpiOverviewGrid extends StatelessWidget {
  final List<SupervisorKpiEntity> kpis;
  const _KpiOverviewGrid({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 768 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kpis.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            final kpi = kpis[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(kpi.icon, size: 16, color: colors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          kpi.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kpi.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED LABELS & ERROR NOTICES
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _SupervisorErrorNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SupervisorErrorNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
