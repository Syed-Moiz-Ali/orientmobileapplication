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
          ? const AppSkeleton.page()
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
                // Phase 07.1: bespoke _FilterStrip/_FilterChip migrated to
                // AppFilterBar (same options + single-select contract; the
                // "All" chip now localizes via the shared bar).
                AppFilterBar(
                  options: const [
                    'Inspection',
                    'Pre-Request',
                    'Estimation',
                    'Approval',
                    'Parts',
                    'WIP',
                    'Completed',
                    'Cancelled',
                  ],
                  selected: _stageLabel(state.filterStage),
                  onSelected: (label) => ref
                      .read(jobStatusProvider.notifier)
                      .setFilter(_stageFor(label)),
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

/// Phase 07.1: stage ↔ label mapping for the centralized [AppFilterBar]
/// (replaces the deleted bespoke `_FilterStrip`/`_FilterChip`; labels
/// unchanged).
String? _stageLabel(JobStage? stage) => switch (stage) {
      null => null,
      JobStage.waitingInspection => 'Inspection',
      JobStage.waitingPreRequest => 'Pre-Request',
      JobStage.waitingEstimation => 'Estimation',
      JobStage.waitingApproval => 'Approval',
      JobStage.waitingParts => 'Parts',
      JobStage.wip => 'WIP',
      JobStage.completed => 'Completed',
      JobStage.cancelled => 'Cancelled',
      _ => null,
    };

JobStage? _stageFor(String? label) => switch (label) {
      'Inspection' => JobStage.waitingInspection,
      'Pre-Request' => JobStage.waitingPreRequest,
      'Estimation' => JobStage.waitingEstimation,
      'Approval' => JobStage.waitingApproval,
      'Parts' => JobStage.waitingParts,
      'WIP' => JobStage.wip,
      'Completed' => JobStage.completed,
      'Cancelled' => JobStage.cancelled,
      _ => null,
    };

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
          AppLinearProgress(
            value: _progress(job.stage),
            color: _progressColor(context, job.stage),
            trackColor: colorScheme.surfaceContainerLow,
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

  // Phase 07.1: progress ink resolves through the theme (the three hardcoded
  // hex literals are deleted) — same stage → tone contract as _StatusLabel.
  Color _progressColor(BuildContext context, JobStage s) {
    final semantic = context.semanticColors;
    return switch (s) {
      JobStage.completed || JobStage.invoice || JobStage.gatePassOut =>
        semantic.success.base,
      JobStage.cancelled => semantic.danger.base,
      _ => Theme.of(context).colorScheme.primary,
    };
  }
}

/// Phase 07.1: bespoke pill migrated to the shared [StatusPill] tone
/// constructors (the eight hardcoded hex literals are deleted) — same
/// stage → tone contract as `_progressColor`.
class _StatusLabel extends StatelessWidget {
  final JobStage stage;

  const _StatusLabel({required this.stage});

  @override
  Widget build(BuildContext context) {
    final label = _label(stage).toUpperCase();
    return switch (stage) {
      JobStage.completed || JobStage.invoice || JobStage.gatePassOut =>
        StatusPill.success(label, showDot: true),
      JobStage.cancelled => StatusPill.danger(label, showDot: true),
      JobStage.wip => StatusPill.inProgress(label),
      _ => StatusPill.warning(label, showDot: true),
    };
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
