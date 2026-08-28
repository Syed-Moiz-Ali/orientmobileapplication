import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/job_detail_sheet.dart';

class TechnicianJobsView extends ConsumerWidget {
  const TechnicianJobsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(technicianRefreshProvider);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final jobs = notifier.filteredJobs;

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          18,
          context.pagePadding.right,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JobsHeader(
              total: notifier.totalJobs,
              inProgress: notifier.inProgressJobs,
              completed: notifier.completedJobs,
              delayed: notifier.delayedJobs,
            ),
            const SizedBox(height: 18),
            TextField(
              onChanged: notifier.updateSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search job, vehicle or plate',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => notifier.updateSearch(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: notifier.filterOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = notifier.filterOptions[index];
                  return ChoiceChip(
                    label: Text(filter),
                    selected: state.selectedFilter == filter,
                    showCheckmark: false,
                    onSelected: (_) => notifier.updateFilter(filter),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (state.dashboardError.isNotEmpty) ...[
              _SavedDataNotice(message: state.dashboardError),
              const SizedBox(height: 12),
            ],
            if (jobs.isEmpty)
              _JobsEmpty(
                filtered:
                    state.searchQuery.isNotEmpty ||
                    state.selectedFilter != 'All Status',
                onReset: () {
                  notifier.updateSearch('');
                  notifier.updateFilter('All Status');
                },
              )
            else
              ...jobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JobQueueCard(
                    job: job,
                    onTap: () => _openJob(context, ref, job),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openJob(BuildContext context, WidgetRef ref, TechnicianJobEntity job) {
    HapticFeedback.selectionClick();
    ref.read(technicianDashboardProvider.notifier).openJob(job);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDetailSheet(job: job),
    ).whenComplete(
      () => ref.read(technicianDashboardProvider.notifier).closeJob(),
    );
  }
}

class _JobsHeader extends StatelessWidget {
  final int total;
  final int inProgress;
  final int completed;
  final int delayed;

  const _JobsHeader({
    required this.total,
    required this.inProgress,
    required this.completed,
    required this.delayed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MY WORK QUEUE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Jobs for this shift',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Open a job to update tasks, notes, parts and status.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            final cards = [
              _QueueMetric(
                value: '$total',
                label: 'Assigned',
                icon: Icons.assignment_outlined,
                color: colors.primary,
              ),
              _QueueMetric(
                value: '$inProgress',
                label: 'Active',
                icon: Icons.play_circle_outline_rounded,
                color: colors.secondary,
              ),
              _QueueMetric(
                value: '$completed',
                label: 'Done',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF0F9D73),
              ),
              _QueueMetric(
                value: '$delayed',
                label: 'Delayed',
                icon: Icons.schedule_rounded,
                color: colors.error,
              ),
            ];
            if (!compact) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 10),
                  ],
                ],
              );
            }
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.45,
              children: cards,
            );
          },
        ),
      ],
    );
  }
}

class _QueueMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _QueueMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
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

class _JobQueueCard extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onTap;

  const _JobQueueCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final done = job.completedTasks;
    final total = job.tasks.length;
    return Semantics(
      button: true,
      label:
          '${job.jobCardNo}, ${job.vehicleBrand} ${job.vehicleModel}, ${job.status.label}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: job.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.car_repair_outlined,
                      color: job.status.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${job.vehicleBrand} ${job.vehicleModel}'
                                    .trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _JobStatus(status: job.status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${job.jobCardNo} • ${job.plateNumber.isEmpty ? 'No plate' : job.plateNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: colors.outline),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      total == 0
                          ? 'No tasks added'
                          : '$done of $total tasks complete',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      job.startTime.isEmpty ? job.dateOfWork : job.startTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: job.progressPercent,
                  minHeight: 7,
                  backgroundColor: colors.surfaceContainerHighest,
                  color: job.status.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobStatus extends StatelessWidget {
  final TechJobStatus status;

  const _JobStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _JobsEmpty extends StatelessWidget {
  final bool filtered;
  final VoidCallback onReset;

  const _JobsEmpty({required this.filtered, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: EmptyState(
        icon: filtered ? Icons.search_off_rounded : Icons.task_alt_rounded,
        title: filtered ? 'No matching jobs' : 'Your queue is clear',
        message: filtered
            ? 'Try another search or reset the status filter.'
            : 'New workshop assignments will appear here automatically.',
        actionLabel: filtered ? 'Reset filters' : null,
        onAction: filtered ? onReset : null,
      ),
    );
  }
}

class _SavedDataNotice extends StatelessWidget {
  final String message;

  const _SavedDataNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.onTertiaryContainer),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
