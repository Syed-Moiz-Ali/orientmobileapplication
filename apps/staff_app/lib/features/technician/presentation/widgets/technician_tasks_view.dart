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

class TechnicianTasksView extends ConsumerStatefulWidget {
  const TechnicianTasksView({super.key});

  @override
  ConsumerState<TechnicianTasksView> createState() => _TechnicianTasksViewState();
}

class _TechnicianTasksViewState extends ConsumerState<TechnicianTasksView> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const _filters = ['All', 'In Progress', 'Pending', 'Completed'];

  @override
  Widget build(BuildContext context) {
    ref.watch(technicianRefreshProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final allTasks = notifier.allTasks;

    // Filter tasks
    final filtered = allTasks.where((item) {
      final task = item.task;
      final job = item.job;

      // Status filter
      final matchesStatus = switch (_selectedFilter) {
        'In Progress' => task.status == TaskStatus.inProgress,
        'Pending' => task.status == TaskStatus.pending,
        'Completed' => task.status == TaskStatus.completed,
        _ => true,
      };

      // Search filter
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          task.description.toLowerCase().contains(q) ||
          job.jobCardNo.toLowerCase().contains(q) ||
          job.vehicleBrand.toLowerCase().contains(q) ||
          job.vehicleModel.toLowerCase().contains(q) ||
          job.plateNumber.toLowerCase().contains(q);

      return matchesStatus && matchesSearch;
    }).toList();

    final inProgressCount = allTasks.where((i) => i.task.status == TaskStatus.inProgress).length;
    final pendingCount = allTasks.where((i) => i.task.status == TaskStatus.pending).length;
    final completedCount = allTasks.where((i) => i.task.status == TaskStatus.completed).length;

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(context.pagePadding.left, 18, context.pagePadding.right, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TechnicianSectionHeader(
              eyebrow: 'WORK ITEM EXECUTION',
              title: 'Individual Tasks',
              subtitle: 'Start, pause, or complete tasks with one tap.',
            ),
            const SizedBox(height: 16),

            // KPI metric summary row
            Row(
              children: [
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'Active',
                    value: '$inProgressCount',
                    color: colors.primary,
                    icon: Icons.play_circle_outline_rounded,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'Pending',
                    value: '$pendingCount',
                    color: colors.tertiary,
                    icon: Icons.hourglass_top_rounded,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'Done',
                    value: '$completedCount',
                    color: const Color(0xFF0F9D73),
                    icon: Icons.check_circle_outline_rounded,
                    compact: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search task, job card or vehicle...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final filter = _filters[i];
                  final isSelected = _selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedFilter = filter);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Tasks List
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Column(
                  children: [
                    Icon(Icons.task_alt_rounded, size: 48, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFilter == 'All' ? 'No assigned work tasks found' : 'No $_selectedFilter tasks right now',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Any tasks assigned to your bay will appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map((item) {
                final job = item.job;
                final task = item.task;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TaskExecutionCard(
                    job: job,
                    task: task,
                    onStart: () {
                      HapticFeedback.mediumImpact();
                      notifier.startTask(job, task);
                    },
                    onComplete: () {
                      HapticFeedback.mediumImpact();
                      notifier.completeTask(job, task);
                    },
                    onStatusChanged: (newStatus) {
                      HapticFeedback.selectionClick();
                      notifier.updateTaskStatus(job, task, newStatus);
                    },
                    onOpenJob: () {
                      HapticFeedback.selectionClick();
                      notifier.openJob(job);
                      context.push(AppRoutes.technicianJobDetail, extra: job).whenComplete(notifier.closeJob);
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METRIC CARD
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// TASK EXECUTION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TaskExecutionCard extends StatelessWidget {
  final TechnicianJobEntity job;
  final WorkTaskEntity task;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final ValueChanged<TaskStatus> onStatusChanged;
  final VoidCallback onOpenJob;

  const _TaskExecutionCard({
    required this.job,
    required this.task,
    required this.onStart,
    required this.onComplete,
    required this.onStatusChanged,
    required this.onOpenJob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDone = task.status == TaskStatus.completed;
    final isInProgress = task.status == TaskStatus.inProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInProgress ? colors.primary.withValues(alpha: 0.4) : colors.outlineVariant,
          width: isInProgress ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isInProgress ? colors.primary.withValues(alpha: 0.1) : colors.shadow.withValues(alpha: 0.04),
            blurRadius: isInProgress ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Job card pill & Vehicle plate + Open Job launcher
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.jobCardNo,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${job.vehicleBrand} ${job.vehicleModel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                tooltip: 'Open Job Card',
                onPressed: onOpenJob,
                visualDensity: VisualDensity.compact,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Task Description
          Text(task.description, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.3)),
          const SizedBox(height: 10),

          // Row 3: Timestamps
          Row(
            children: [
              _MiniTimestamp(
                icon: Icons.play_arrow_rounded,
                text: task.startTime != null ? 'Started: ${task.startTime}' : 'Not started',
                highlight: task.startTime != null,
              ),
              if (task.endTime != null) ...[
                const SizedBox(width: 8),
                _MiniTimestamp(icon: Icons.check_rounded, text: 'Ended: ${task.endTime}', highlight: true),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Row 4: Controls - Dropdown & Action Button
          Row(
            children: [
              // Dropdown for Status
              Expanded(
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TaskStatus>(
                      value: task.status,
                      isDense: true,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(14),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      onChanged: (val) {
                        if (val != null) onStatusChanged(val);
                      },
                      items: TaskStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s.label,
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Instant Action Button
              if (isDone)
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9D73).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0F9D73).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF0F9D73)),
                      SizedBox(width: 6),
                      Text(
                        'Completed',
                        style: TextStyle(color: Color(0xFF0F9D73), fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else if (isInProgress)
                FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Mark Done'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F9D73),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Start'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTimestamp extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;

  const _MiniTimestamp({required this.icon, required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: highlight ? colors.primary : colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: highlight ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
