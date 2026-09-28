import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

/// Contextual workshop operations & performance report.
/// All metrics and charts are strictly backed by real server data.
class SupervisorReportsTab extends ConsumerWidget {
  const SupervisorReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);
    final jobTypes = notifier.jobTypes;
    final metrics = notifier.revenueMetrics;
    final total = notifier.totalAssigned;
    final inProgress = notifier.inProgressCount;
    final completed = notifier.completedCount;
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: RefreshIndicator(
            onRefresh: notifier.refreshDashboard,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // ── 1. HEADER ───────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workshop Operations Report',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Floor task volume, category breakdown, and operational metrics',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (state.dashboardError.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: colorScheme.onErrorContainer,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Live report data is currently unavailable. No synthetic figures are shown.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── 2. STATS OVERVIEW ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _ReportStatCard(
                        label: 'Total Volume',
                        value: '$total',
                        color: colorScheme.primary,
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ReportStatCard(
                        label: 'In Progress',
                        value: '$inProgress',
                        color: colorScheme.secondary,
                        icon: Icons.sync_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ReportStatCard(
                        label: 'Completed',
                        value: '$completed',
                        color: colorScheme.primary,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── 3. CONTENT SECTIONS ─────────────────────────────────────
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job category distribution
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              context,
                              title: 'Job Category Distribution',
                              badge: '${jobTypes.length} TYPES',
                            ),
                            const SizedBox(height: 12),
                            _JobCategoryDistributionCard(
                              jobTypes: jobTypes,
                              totalJobs: total,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Operational Summary & Financial Metrics
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              context,
                              title: 'Operational Status',
                            ),
                            const SizedBox(height: 12),
                            _FloorSummaryCard(
                              techCount: notifier.technicians.length,
                              deptCount: notifier.departments.length,
                              queueCount:
                                  notifier.bookings.length +
                                  notifier.breakdowns.length,
                            ),
                            if (metrics.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildSectionHeader(
                                context,
                                title: 'Financial Metrics',
                              ),
                              const SizedBox(height: 12),
                              ...metrics.map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _RevenueMetricCard(metric: m),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Mobile stacked
                  _buildSectionHeader(
                    context,
                    title: 'Job Category Distribution',
                    badge: '${jobTypes.length} TYPES',
                  ),
                  const SizedBox(height: 12),
                  _JobCategoryDistributionCard(
                    jobTypes: jobTypes,
                    totalJobs: total,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, title: 'Operational Status'),
                  const SizedBox(height: 12),
                  _FloorSummaryCard(
                    techCount: notifier.technicians.length,
                    deptCount: notifier.departments.length,
                    queueCount:
                        notifier.bookings.length + notifier.breakdowns.length,
                  ),

                  if (metrics.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, title: 'Financial Metrics'),
                    const SizedBox(height: 12),
                    ...metrics.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RevenueMetricCard(metric: m),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? badge,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 9,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ReportStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
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
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCategoryDistributionCard extends StatelessWidget {
  final List<JobTypeEntity> jobTypes;
  final int totalJobs;

  const _JobCategoryDistributionCard({
    required this.jobTypes,
    required this.totalJobs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (jobTypes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: const EmptyState(
          icon: Icons.pie_chart_outline_rounded,
          title: 'No category data',
          message: 'No categorized job assignments found for this period.',
        ),
      );
    }

    final int calculatedTotal = totalJobs > 0
        ? totalJobs
        : jobTypes.fold(0, (sum, item) => sum + item.count);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: jobTypes.map((type) {
          final double fraction = calculatedTotal > 0
              ? (type.count / calculatedTotal).clamp(0.0, 1.0)
              : 0.0;
          final int percentage = (fraction * 100).round();

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        type.label,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${type.count} jobs ($percentage%)',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(type.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FloorSummaryCard extends StatelessWidget {
  final int techCount;
  final int deptCount;
  final int queueCount;

  const _FloorSummaryCard({
    required this.techCount,
    required this.deptCount,
    required this.queueCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow(
            context,
            icon: Icons.engineering_rounded,
            label: 'Active Floor Technicians',
            value: '$techCount registered',
          ),
          Divider(height: 18, color: colorScheme.outlineVariant),
          _buildRow(
            context,
            icon: Icons.domain_rounded,
            label: 'Workshop Departments',
            value: '$deptCount operational',
          ),
          Divider(height: 18, color: colorScheme.outlineVariant),
          _buildRow(
            context,
            icon: Icons.inbox_rounded,
            label: 'Incoming Work Queue',
            value: '$queueCount pending',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RevenueMetricCard extends StatelessWidget {
  final RevenueMetricEntity metric;

  const _RevenueMetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(metric.icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  metric.amount,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (metric.change.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                metric.change,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
