import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

/// Contextual active jobs floor view for supervisor.
class SupervisorJobsTab extends ConsumerStatefulWidget {
  const SupervisorJobsTab({super.key});

  @override
  ConsumerState<SupervisorJobsTab> createState() => _SupervisorJobsTabState();
}

class _SupervisorJobsTabState extends ConsumerState<SupervisorJobsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    final allJobs = notifier.jobs;
    final filteredJobs = _searchQuery.isEmpty
        ? allJobs
        : allJobs.where((j) {
            final q = _searchQuery.toLowerCase();
            return j.jobCard.toLowerCase().contains(q) ||
                j.customer.toLowerCase().contains(q) ||
                j.vehicle.toLowerCase().contains(q) ||
                j.status.toLowerCase().contains(q);
          }).toList();

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
                // ── 1. STATS BANNER ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _JobsMetricPill(
                        label: 'Total Assigned',
                        value: '${notifier.totalAssigned}',
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _JobsMetricPill(
                        label: 'In Progress',
                        value: '${notifier.inProgressCount}',
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _JobsMetricPill(
                        label: 'Completed',
                        value: '${notifier.completedCount}',
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 2. SEARCH & FILTER ──────────────────────────────────────
                AppSearchField(
                  hintText: 'Search by job card, customer, or vehicle...',
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 16),

                // ── 3. SECTION HEADER ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Workshop Jobs',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${filteredJobs.length} active job${filteredJobs.length == 1 ? '' : 's'} on workshop floor',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifier.onNewAssignment();
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Assign Task'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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
                            state.dashboardError,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── 4. JOBS LIST ────────────────────────────────────────────
                if (filteredJobs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: EmptyState(
                      icon: Icons.checklist_rounded,
                      title: _searchQuery.isNotEmpty
                          ? 'No matching jobs'
                          : 'No assigned jobs on floor',
                      message: _searchQuery.isNotEmpty
                          ? 'Try searching with a different job card or vehicle plate.'
                          : 'Assign new tasks from the work assignment tab.',
                    ),
                  )
                else if (isWide)
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: filteredJobs.map((job) {
                      return SizedBox(
                        width: (1100 - 48) / 2,
                        child: _JobCard(job: job),
                      );
                    }).toList(),
                  )
                else
                  ...filteredJobs.map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _JobCard(job: job),
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

class _JobsMetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _JobsMetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
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
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final AssignedJobEntity job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final progress = job.total > 0 ? job.done / job.total : 0.0;
    final progressPct = (progress * 100).toInt();

    final statusLower = job.status.toLowerCase();
    final bool isDone = statusLower == 'completed' || statusLower == 'done';
    final bool isInProgress =
        statusLower == 'in progress' || statusLower == 'assigned';
    final Color badgeColor = isDone
        ? colorScheme.primary
        : (isInProgress ? colorScheme.secondary : colorScheme.error);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.jobCard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  job.status.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Text(
                  job.customer.isNotEmpty ? job.customer[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      job.vehicle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (job.dateAssigned.isNotEmpty)
                Text(
                  job.dateAssigned,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          if (job.total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(badgeColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${job.done}/${job.total} tasks completed',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                  ),
                ),
                Text(
                  '$progressPct%',
                  style: textTheme.labelSmall?.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
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
