import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_metric_card.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_section_header.dart';

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
        padding: EdgeInsets.fromLTRB(context.pagePadding.left, 18, context.pagePadding.right, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TechnicianSectionHeader(
              eyebrow: 'WORK ORDERS',
              title: 'Jobs for this shift',
              subtitle: 'Prioritize vehicles, track progress, and move work forward.',
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final colors = Theme.of(context).colorScheme;
                final cards = [
                  TechnicianMetricCard(
                    value: '${notifier.totalJobs}',
                    label: 'Assigned',
                    icon: Icons.assignment_outlined,
                    color: colors.primary,
                    compact: true,
                  ),
                  TechnicianMetricCard(
                    value: '${notifier.inProgressJobs}',
                    label: 'Active',
                    icon: Icons.play_circle_outline_rounded,
                    color: colors.secondary,
                    compact: true,
                  ),
                  TechnicianMetricCard(
                    value: '${notifier.completedJobs}',
                    label: 'Done',
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFF0F9D73),
                    compact: true,
                  ),
                  TechnicianMetricCard(
                    value: '${notifier.delayedJobs}',
                    label: 'Delayed',
                    icon: Icons.schedule_rounded,
                    color: colors.error,
                    compact: true,
                  ),
                ];
                if (constraints.maxWidth >= 520) {
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
            const SizedBox(height: 18),
            _JobsToolbar(state: state, notifier: notifier),
            const SizedBox(height: 20),
            if (state.dashboardError.isNotEmpty) ...[
              _SavedDataNotice(message: state.dashboardError),
              const SizedBox(height: 12),
            ],
            if (jobs.isEmpty)
              _JobsEmpty(
                filtered: state.searchQuery.isNotEmpty || state.selectedFilter != 'All Status',
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
                    onStatusChanged: (newStatus) {
                      HapticFeedback.selectionClick();
                      notifier.updateJobStatus(job, newStatus);
                    },
                    onTaskAction: () {
                      final running = job.tasks.where((t) => t.status == TaskStatus.inProgress).firstOrNull;
                      final pending = job.tasks.where((t) => t.status == TaskStatus.pending).firstOrNull;
                      HapticFeedback.mediumImpact();
                      if (running != null) {
                        notifier.completeTask(job, running);
                      } else if (pending != null) {
                        notifier.startTask(job, pending);
                      }
                    },
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
    context
        .push(AppRoutes.technicianJobDetail, extra: job)
        .whenComplete(() => ref.read(technicianDashboardProvider.notifier).closeJob());
  }
}

class _JobsToolbar extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;

  const _JobsToolbar({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: notifier.filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = notifier.filterOptions[index];
              final selected = state.selectedFilter == filter;
              return _JobFilterPill(
                label: filter,
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.updateFilter(filter);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JobFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _JobFilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Filter jobs by $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected ? colors.primary : colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? colors.primary : colors.outlineVariant),
            ),
            child: Center(
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TechJobStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(color: status.color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _JobQueueCard extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onTap;
  final ValueChanged<TechJobStatus> onStatusChanged;
  final VoidCallback onTaskAction;

  const _JobQueueCard({
    required this.job,
    required this.onTap,
    required this.onStatusChanged,
    required this.onTaskAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final done = job.completedTasks;
    final total = job.tasks.length;

    final running = job.tasks.where((t) => t.status == TaskStatus.inProgress).firstOrNull;
    final pending = job.tasks.where((t) => t.status == TaskStatus.pending).firstOrNull;
    final nextTask = running ?? pending;

    return Semantics(
      button: true,
      label: '${job.jobCardNo}, ${job.vehicleBrand} ${job.vehicleModel}, ${job.status.label}',
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: job.status.color, width: 4)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.jobCardNo,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Text(job.dateOfWork, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
                    const SizedBox(width: 8),
                    PopupMenuButton<TechJobStatus>(
                      tooltip: 'Update job status',
                      onSelected: onStatusChanged,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_horiz_rounded, color: colors.onSurfaceVariant),
                      itemBuilder: (context) =>
                          TechJobStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.label))).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: job.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.car_repair_rounded, color: job.status.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          if (job.plateNumber.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: colors.outlineVariant),
                              ),
                              child: Text(
                                job.plateNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            )
                          else
                            Text(
                              'Plate unavailable',
                              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          if (job.customerName.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              job.customerPhone.isEmpty
                                  ? job.customerName
                                  : '${job.customerName} · ${job.customerPhone}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: job.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.checklist_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        total == 0 ? 'No tasks recorded' : '$done of $total tasks finished',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${(job.progressPercent * 100).toInt()}%',
                      style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: job.progressPercent,
                    minHeight: 7,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(job.status.color),
                  ),
                ),
                if (nextTask != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: colors.outlineVariant)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          running != null ? Icons.play_circle_filled_rounded : Icons.schedule_rounded,
                          size: 16,
                          color: running != null ? colors.primary : colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            nextTask.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: onTaskAction,
                          icon: Icon(running != null ? Icons.check_rounded : Icons.play_arrow_rounded, size: 14),
                          label: Text(running != null ? 'Done' : 'Start'),
                          style: FilledButton.styleFrom(
                            backgroundColor: running != null ? const Color(0xFF0F9D73) : colors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 40),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ],
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
      decoration: BoxDecoration(color: colors.tertiaryContainer, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.onTertiaryContainer),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onTertiaryContainer, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
