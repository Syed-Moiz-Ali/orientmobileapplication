import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Active-jobs floor register: search + status filter over borderless divider
/// rows (home grammar), with a slim inline summary. Presentation only.
class SupervisorJobsTab extends ConsumerStatefulWidget {
  final VoidCallback onOpenAssign;
  const SupervisorJobsTab({super.key, required this.onOpenAssign});

  @override
  ConsumerState<SupervisorJobsTab> createState() => _SupervisorJobsTabState();
}

class _SupervisorJobsTabState extends ConsumerState<SupervisorJobsTab> {
  String _query = '';
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final allJobs = notifier.jobs;

    final q = _query.trim().toLowerCase();
    final searched = q.isEmpty
        ? allJobs
        : allJobs
              .where(
                (j) =>
                    j.jobCard.toLowerCase().contains(q) ||
                    j.customer.toLowerCase().contains(q) ||
                    j.vehicle.toLowerCase().contains(q) ||
                    j.status.toLowerCase().contains(q),
              )
              .toList();
    final filtered = _filter == null
        ? searched
        : searched.where((j) => _bucket(j.status) == _filter).toList();

    final inProgress = allJobs.where((j) => _bucket(j.status) == t.svJobsInProgress).length;
    final completed = allJobs.where((j) => _bucket(j.status) == t.svJobsCompleted).length;
    final waiting = allJobs.where((j) => _bucket(j.status) == t.svBayPartsDelay).length;

    final loading = state.isDashboardLoading && allJobs.isEmpty;
    final isNoMatch = (_query.trim().isNotEmpty || _filter != null) &&
        filtered.isEmpty &&
        allJobs.isNotEmpty;

    return RefreshIndicator(
      onRefresh: notifier.refreshDashboard,
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppPageHeader(
              title: t.svJobsTitle,
              subtitle: t.svJobsSubtitle(allJobs.length),
              leading: const Icon(Icons.assignment_outlined),
              primaryAction: PrimaryButton(
                label: t.svJobsAssign,
                icon: Icons.engineering_rounded,
                isExpanded: false,
                onPressed: widget.onOpenAssign,
              ),
            ),
            const SizedBox(height: AppDimensions.s16),
            _JobsSummary(
              total: allJobs.length,
              inProgress: inProgress,
              completed: completed,
              waiting: waiting,
            ),
            const SizedBox(height: AppDimensions.s16),
            AppSearchField(
              hintText: t.svJobsSearchHint,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: AppDimensions.s12),
            AppFilterBar(
              options: [t.svJobsInProgress, t.svJobsCompleted, t.svBayPartsDelay],
              selected: _filter,
              counts: {
                t.svJobsInProgress: inProgress,
                t.svJobsCompleted: completed,
                t.svBayPartsDelay: waiting,
              },
              onSelected: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: AppDimensions.s16),
            if (state.dashboardError.isNotEmpty)
              AppInfoPanel.danger(
                message: t.svJobsError,
                action: TextButton(
                  onPressed: notifier.refreshDashboard,
                  child: Text(SharedCoreL10n.of(context).commonRetry),
                ),
              )
            else
              _JobsList(
                loading: loading,
                isNoMatch: isNoMatch,
                isEmpty: !loading && allJobs.isEmpty,
                jobs: filtered,
                onClear: () => setState(() {
                  _query = '';
                  _filter = null;
                }),
                onAssign: widget.onOpenAssign,
              ),
          ],
        ),
      ),
    );
  }

  String _bucket(String status) {
    final t = StaffLocalizations.of(context)!;
    return switch (supervisorStatusKind(status)) {
      SupervisorStatusKind.success => t.svJobsCompleted,
      SupervisorStatusKind.inProgress => t.svJobsInProgress,
      _ => t.svBayPartsDelay,
    };
  }
}

class _JobsSummary extends StatelessWidget {
  final int total;
  final int inProgress;
  final int completed;
  final int waiting;

  const _JobsSummary({
    required this.total,
    required this.inProgress,
    required this.completed,
    required this.waiting,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Wrap(
      spacing: AppDimensions.s16,
      runSpacing: AppDimensions.s8,
      children: [
        _Stat(label: t.svJobsTotal, value: total, tone: null),
        _Stat(label: t.svJobsInProgress, value: inProgress, tone: context.semanticColors.info),
        _Stat(label: t.svJobsCompleted, value: completed, tone: context.semanticColors.success),
        _Stat(label: t.svBayPartsDelay, value: waiting, tone: context.semanticColors.warning),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final AppStatusColors? tone;
  const _Stat({required this.label, required this.value, required this.tone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = tone?.base ?? context.colors.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tone != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.s6),
        ],
        Text(
          '$value',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: AppDimensions.s4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _JobsList extends StatelessWidget {
  final bool loading;
  final bool isNoMatch;
  final bool isEmpty;
  final List<AssignedJobEntity> jobs;
  final VoidCallback onClear;
  final VoidCallback onAssign;

  const _JobsList({
    required this.loading,
    required this.isNoMatch,
    required this.isEmpty,
    required this.jobs,
    required this.onClear,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    if (loading) {
      return const AppSkeleton.listRows(rows: 6);
    }
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
        child: EmptyState(
          icon: Icons.checklist_rounded,
          title: t.svJobsEmpty,
          message: t.svJobsEmptyMessage,
          actionLabel: t.svJobsAssign,
          onAction: onAssign,
        ),
      );
    }
    if (isNoMatch) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
        child: EmptyState.noMatch(
          message: t.svJobsNoMatch,
          actionLabel: SharedCoreL10n.of(context).filterBarClear,
          onAction: onClear,
        ),
      );
    }
    return Column(children: [for (final j in jobs) _JobRow(job: j)]);
  }
}

/// Borderless divider row: status colour rail + identity + progress + pill.
class _JobRow extends StatelessWidget {
  final AssignedJobEntity job;
  const _JobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tone = _tone(context, job.status);
    final progress = job.total > 0
        ? (job.done / job.total).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 44,
                margin: const EdgeInsetsDirectional.only(end: AppDimensions.s12),
                decoration: BoxDecoration(
                  color: tone.base,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.vehicle.isNotEmpty ? job.vehicle : job.customer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s8),
                        supervisorStatusPill(job.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            job.jobCard,
                            style: supervisorMono(
                              context,
                              color: context.colors.onSurfaceVariant,
                            ).copyWith(fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s8),
                        Expanded(
                          child: Text(
                            job.customer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (job.total > 0) ...[
                      const SizedBox(height: AppDimensions.s8),
                      Row(
                        children: [
                          Expanded(
                            child: AppLinearProgress(
                              value: progress,
                              color: tone.base,
                              height: 5,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.s10),
                          Text(
                            t.svJobsTasks(job.done, job.total),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }

  AppStatusColors _tone(BuildContext context, String status) =>
      supervisorStatusTone(context, status);
}
