import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';

class JobStatusView extends ConsumerStatefulWidget {
  const JobStatusView({super.key});

  @override
  ConsumerState<JobStatusView> createState() => _JobStatusViewState();
}

class _JobStatusViewState extends ConsumerState<JobStatusView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(jobStatusProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Live Job Pipeline',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppDimensions.r16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: TextField(
                      onChanged: (q) => ref.read(jobStatusProvider.notifier).onSearch(q),
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search by job card #, customer, or vehicle...',
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                _FilterStrip(
                  currentStage: state.filterStage,
                  onFilter: (s) => ref.read(jobStatusProvider.notifier).setFilter(s),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: state.filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No job cards in this stage',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: state.filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _JobStatusItem(job: state.filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  final JobStage? currentStage;
  final void Function(JobStage?) onFilter;

  const _FilterStrip({required this.currentStage, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final stages = <(String, JobStage?)>[
      ('All Jobs', null),
      ('Inspection', JobStage.waitingInspection),
      ('Pre-Request', JobStage.waitingPreRequest),
      ('Estimation', JobStage.waitingEstimation),
      ('Approval', JobStage.waitingApproval),
      ('Parts', JobStage.waitingParts),
      ('WIP', JobStage.wip),
      ('Completed', JobStage.completed),
      ('Cancelled', JobStage.cancelled),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, stage) = stages[i];
          return _FilterChip(
            label: label,
            selected: currentStage == stage,
            onTap: () => onFilter(stage),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.rPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.rPill),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _JobStatusItem extends StatelessWidget {
  final JobStatus job;

  const _JobStatusItem({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                job.jobCardId,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  fontFamily: AppFontFamilies.mono,
                ),
              ),
              const Spacer(),
              _StatusLabel(stage: job.stage),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            job.customerName,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${job.vehicleInfo} • Specialist: ${job.assignedTo}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.rPill),
            child: LinearProgressIndicator(
              value: _progress(job.stage),
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation(_progressColor(job.stage)),
            ),
          ),
        ],
      ),
    );
  }

  double _progress(JobStage s) => switch (s) {
        JobStage.waitingInspection => 0.1,
        JobStage.waitingPreRequest => 0.2,
        JobStage.waitingEstimation => 0.3,
        JobStage.waitingApproval => 0.4,
        JobStage.waitingParts => 0.5,
        JobStage.wip => 0.65,
        JobStage.completed => 0.85,
        JobStage.invoice => 0.95,
        JobStage.gatePassOut => 1.0,
        JobStage.cancelled => 0.0,
      };

  Color _progressColor(JobStage s) => switch (s) {
        JobStage.completed || JobStage.invoice || JobStage.gatePassOut => const Color(0xFF10B981),
        JobStage.cancelled => const Color(0xFFEF4444),
        _ => const Color(0xFF3B82F6),
      };
}

class _StatusLabel extends StatelessWidget {
  final JobStage stage;

  const _StatusLabel({required this.stage});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (stage) {
      JobStage.completed || JobStage.invoice || JobStage.gatePassOut => (
          const Color(0xFF10B981).withValues(alpha: 0.12),
          const Color(0xFF10B981),
        ),
      JobStage.cancelled => (
          const Color(0xFFEF4444).withValues(alpha: 0.12),
          const Color(0xFFEF4444),
        ),
      JobStage.wip => (
          const Color(0xFF3B82F6).withValues(alpha: 0.12),
          const Color(0xFF3B82F6),
        ),
      _ => (
          const Color(0xFFD97706).withValues(alpha: 0.12),
          const Color(0xFFD97706),
        ),
    };

    return StatusPill(
      label: _label(stage).toUpperCase(),
      showDot: true,
      bg: bg,
      fg: fg,
    );
  }

  String _label(JobStage s) => switch (s) {
        JobStage.waitingInspection => 'Inspection',
        JobStage.waitingPreRequest => 'Pre-Request',
        JobStage.waitingEstimation => 'Estimation',
        JobStage.waitingApproval => 'Approval',
        JobStage.waitingParts => 'Parts',
        JobStage.wip => 'WIP',
        JobStage.completed => 'Completed',
        JobStage.invoice => 'Invoice',
        JobStage.gatePassOut => 'Gate Pass',
        JobStage.cancelled => 'Cancelled',
      };
}
