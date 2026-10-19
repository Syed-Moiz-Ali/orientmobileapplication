import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_status_ui.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Presentation-only stage derivation over the frozen status list.
int _countFor(List<JobStatus> items, bool Function(JobStatus) test) =>
    items.where(test).length;

bool _isPre(JobStage s) =>
    s == JobStage.waitingInspection ||
    s == JobStage.waitingPreRequest ||
    s == JobStage.waitingEstimation ||
    s == JobStage.waitingApproval;

bool _isDone(JobStage s) =>
    s == JobStage.completed ||
    s == JobStage.invoice ||
    s == JobStage.gatePassOut;

/// Live board (O7): stage-count pods, freshness stamp with 60s auto-refresh
/// and a stale banner (data older than 5 minutes is never shown silently),
/// then the searchable/filterable stage list. Desktop renders the dense
/// table; compact renders divider rows via the table fallback. All counts
/// derive from the frozen provider list; the clock state is page-local.
class JobStatusView extends ConsumerStatefulWidget {
  const JobStatusView({super.key});

  @override
  ConsumerState<JobStatusView> createState() => _JobStatusViewState();
}

class _JobStatusViewState extends ConsumerState<JobStatusView> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _timer;
  DateTime? _lastRefresh;

  static const _staleAfter = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _lastRefresh = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted) return;
      _refresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(jobStatusProvider);
    if (mounted) setState(() => _lastRefresh = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    final state = ref.watch(jobStatusProvider);
    final notifier = ref.read(jobStatusProvider.notifier);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final stages = <String>[
      t.ownerStgInspect,
      t.ownerStgPreReq,
      t.ownerStgEstimate,
      t.ownerStgApproval,
      t.ownerStgParts,
      t.ownerStgWip,
      t.ownerStgComplete,
      t.ownerStgCancel,
    ];

    final stamp = _lastRefresh;
    final stale = stamp != null &&
        DateTime.now().difference(stamp) > _staleAfter;

    return WorkspaceSearchShortcuts(
      onSearch: () => _searchFocus.requestFocus(),
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: WorkspaceAppBar(
          title: t.ownerStTitle,
          subtitle: t.ownerStSubtitle,
          showBack: true,
          showOfflineStatus: true,
          actions: [
            if (stamp != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.s16),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      t.ownerStUpdated(formatters.relativeTime(stamp)),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: state.isLoading && state.items.isEmpty
              ? const AppSkeleton.page()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: colors.primary,
                  child: AppResponsivePage(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (stale)
                          AppInfoPanel.warning(
                            message: t.ownerStStale,
                            action: TextButton(
                              onPressed: _refresh,
                              child: Text(
                                MaterialLocalizations.of(context)
                                    .refreshIndicatorSemanticLabel,
                              ),
                            ),
                          ),
                        if (stale)
                          const SizedBox(height: AppDimensions.s12),
                        _StagePods(items: state.items),
                        const SizedBox(height: AppDimensions.s16),
                        AppSearchField(
                          controller: _searchCtrl,
                          focusNode: _searchFocus,
                          hintText: t.ownerStSearchHint,
                          onChanged: (q) => notifier.onSearch(q),
                          onClear: () {
                            _searchCtrl.clear();
                            notifier.onSearch('');
                          },
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        AppFilterBar(
                          options: stages,
                          selected: _stageLabel(t, state.filterStage),
                          onSelected: (label) =>
                              notifier.setFilter(_stageFor(t, label)),
                        ),
                        const SizedBox(height: AppDimensions.s12),
                        _StatusTable(
                          items: state.filtered,
                          maxHeight: wide ? 520 : null,
                        ),
                        const SizedBox(height: AppDimensions.s32),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Phase 07.1: stage ↔ label mapping for the centralized [AppFilterBar].
/// Labels now localize; the frozen `setFilter` still receives real stages.
String? _stageLabel(OwnerLocalizations t, JobStage? stage) => switch (stage) {
      null => null,
      JobStage.waitingInspection => t.ownerStgInspect,
      JobStage.waitingPreRequest => t.ownerStgPreReq,
      JobStage.waitingEstimation => t.ownerStgEstimate,
      JobStage.waitingApproval => t.ownerStgApproval,
      JobStage.waitingParts => t.ownerStgParts,
      JobStage.wip => t.ownerStgWip,
      JobStage.completed => t.ownerStgComplete,
      JobStage.cancelled => t.ownerStgCancel,
      _ => null,
    };

JobStage? _stageFor(OwnerLocalizations t, String? label) {
  if (label == null) return null;
  if (label == t.ownerStgInspect) return JobStage.waitingInspection;
  if (label == t.ownerStgPreReq) return JobStage.waitingPreRequest;
  if (label == t.ownerStgEstimate) return JobStage.waitingEstimation;
  if (label == t.ownerStgApproval) return JobStage.waitingApproval;
  if (label == t.ownerStgParts) return JobStage.waitingParts;
  if (label == t.ownerStgWip) return JobStage.wip;
  if (label == t.ownerStgComplete) return JobStage.completed;
  if (label == t.ownerStgCancel) return JobStage.cancelled;
  return null;
}

/// Stage-count pods: intake queue, active WIP, done and attention — derived
/// from the live list, no deltas fabricated (counts only, never trends).
class _StagePods extends StatelessWidget {
  final List<JobStatus> items;

  const _StagePods({required this.items});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    final adaptive = context.adaptive;
    final pods = <_Pod>[
      _Pod(
        label: t.ownerStPodQueue,
        count: _countFor(items, (j) => _isPre(j.stage)),
        icon: Icons.inbox_rounded,
      ),
      _Pod(
        label: t.ownerStPodActive,
        count: _countFor(items, (j) => j.stage == JobStage.wip),
        icon: Icons.engineering_rounded,
      ),
      _Pod(
        label: t.ownerStPodDone,
        count: _countFor(items, (j) => _isDone(j.stage)),
        icon: Icons.check_circle_rounded,
      ),
      _Pod(
        label: t.ownerStPodAttention,
        count: _countFor(items, (j) => j.stage == JobStage.cancelled),
        icon: Icons.warning_amber_rounded,
      ),
    ];

    return AppAdaptiveGrid(
      columns: adaptive.pick(compact: 2, medium: 4, expanded: 4, large: 4),
      minChildWidth: 140,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.pick(
        compact: 1.6,
        medium: 1.5,
        expanded: 1.7,
        large: 1.8,
      ),
      children: [
        for (final pod in pods)
          AppCard.standard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(pod.icon,
                    size: AppDimensions.iconSm,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: AppDimensions.s6),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    formatters.group(pod.count),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ),
                Text(
                  pod.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Pod {
  final String label;
  final int count;
  final IconData icon;

  const _Pod({required this.label, required this.count, required this.icon});
}

class _StatusTable extends StatelessWidget {
  final List<JobStatus> items;
  final double? maxHeight;

  const _StatusTable({required this.items, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);

    return AppTable<JobStatus>(
      columns: [
        AppTableColumn(label: t.ownerRegJob, flex: 2),
        AppTableColumn(label: t.ownerRegCustomer, flex: 3),
        AppTableColumn(label: t.ownerRegStatus, flex: 2),
        AppTableColumn(label: t.ownerRegTotal, flex: 2),
      ],
      items: items,
      cells: (context, job) => [
        AppTableCell.custom(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              job.jobCardId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(
                color: Theme.of(context).colorScheme.onSurface,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          AlignmentDirectional.centerStart,
        ),
        AppTableCell.text(context, job.customerName),
        AppTableCell.custom(
          _StagePill(stage: job.stage),
          AlignmentDirectional.centerStart,
        ),
        AppTableCell.numeric(
          context,
          formatAed2(formatters, job.estimatedAmount),
        ),
      ],
      emptyMessage: t.ownerStEmpty,
      maxHeight: maxHeight,
      compactBuilder: (context, job) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.s8),
        child: _StatusCard(job: job),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final JobStatus job;

  const _StatusCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatters = AppFormatters.of(context);
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    job.jobCardId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(color: colors.onSurface)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              _StagePill(stage: job.stage),
            ],
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            job.customerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${job.vehicleInfo} · ${job.assignedTo}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          Row(
            children: [
              Expanded(
                child: AppLinearProgress(
                  value: _progress(job.stage),
                  color: _progressColor(context, job.stage),
                  trackColor: colors.surfaceContainerLow,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  formatAed2(formatters, job.estimatedAmount),
                  style: AppTextStyles.mono(color: colors.onSurface)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
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

/// Shared stage → tone contract (same mapping the 07.1 migration locked,
/// now localized): done resolves success, cancelled danger, WIP the
/// operational pill, everything waiting resolves warning.
class _StagePill extends StatelessWidget {
  final JobStage stage;

  const _StagePill({required this.stage});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final label = _stageLabel(t, stage) ?? _fallbackLabel(t, stage);
    return switch (stage) {
      JobStage.completed || JobStage.invoice || JobStage.gatePassOut =>
        StatusPill.success(label.toUpperCase(), showDot: true),
      JobStage.cancelled => StatusPill.danger(label.toUpperCase(), showDot: true),
      JobStage.wip => StatusPill.inProgress(label.toUpperCase()),
      _ => StatusPill.warning(label.toUpperCase(), showDot: true),
    };
  }

  String _fallbackLabel(OwnerLocalizations t, JobStage s) => switch (s) {
        JobStage.invoice => t.ownerStgComplete,
        JobStage.gatePassOut => t.ownerStgComplete,
        _ => t.ownerStgWip,
      };
}
