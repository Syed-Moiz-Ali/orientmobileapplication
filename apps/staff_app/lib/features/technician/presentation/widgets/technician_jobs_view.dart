import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Jobs — "what work is assigned to me, and which job should I open?".
///
/// Phase 10 scanning surface: one search, canonical status filters, an
/// urgent-first queue of 72px high-touch rows (job + vehicle + plate pill +
/// start-time pill + status), closing with freshness. No per-row operational
/// buttons — those live in Job Detail.
class TechnicianJobsView extends ConsumerStatefulWidget {
  /// Fixed freshness instant for deterministic golden stills. Production
  /// passes nothing and the footer reads the live clock.
  final DateTime? fixedRefreshAt;

  const TechnicianJobsView({super.key, this.fixedRefreshAt});

  @override
  ConsumerState<TechnicianJobsView> createState() =>
      _TechnicianJobsViewState();
}

class _TechnicianJobsViewState extends ConsumerState<TechnicianJobsView> {
  late DateTime _lastRefresh;

  @override
  void initState() {
    super.initState();
    _lastRefresh = widget.fixedRefreshAt ?? DateTime.now();
  }

  Future<void> _refresh(TechnicianNotifier notifier) async {
    await notifier.refresh();
    if (mounted) setState(() => _lastRefresh = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(technicianRefreshProvider);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final allJobs = notifier.allJobs;
    final jobs = _urgentFirst(notifier.filteredJobs);

    final hasJobs = allJobs.isNotEmpty;
    final firstLoadError =
        allJobs.isEmpty && !state.isLoading && state.dashboardError.isNotEmpty;
    final showSkeleton = state.isLoading && allJobs.isEmpty;
    final filtering =
        state.searchQuery.isNotEmpty || state.selectedFilter != 'All';

    return RefreshIndicator(
      onRefresh: () => _refresh(notifier),
      child: AppResponsivePage(
        scrollable: false,
        maxContentWidth: 1180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasJobs) ...[
              _JobsToolbar(state: state, notifier: notifier, allJobs: allJobs),
              const SizedBox(height: AppDimensions.s16),
              if (state.dashboardError.isNotEmpty) ...[
                _SavedDataNotice(message: state.dashboardError),
                const SizedBox(height: AppDimensions.s12),
              ],
            ],
            Expanded(
              child: _body(
                notifier: notifier,
                jobs: jobs,
                showSkeleton: showSkeleton,
                firstLoadError: firstLoadError,
                hasJobs: hasJobs,
                filtering: filtering,
              ),
            ),
            _FreshnessFooter(lastRefresh: _lastRefresh),
            const SizedBox(height: AppDimensions.s8),
          ],
        ),
      ),
    );
  }

  /// Urgent-first ordering replaces queue position guessing: delayed and
  /// running work sorts above pending, which sorts above review and done.
  /// Filter/search matching is untouched — this only orders the matches.
  List<TechnicianJobEntity> _urgentFirst(List<TechnicianJobEntity> jobs) {
    int rank(TechnicianJobEntity job) => switch (job.status) {
      TechJobStatus.delayed => 0,
      TechJobStatus.inProgress => 1,
      TechJobStatus.pending => 2,
      TechJobStatus.qcReview => 3,
      TechJobStatus.completed => 4,
    };
    final sorted = List<TechnicianJobEntity>.from(jobs);
    sorted.sort((a, b) => rank(a).compareTo(rank(b)));
    return sorted;
  }

  Widget _body({
    required TechnicianNotifier notifier,
    required List<TechnicianJobEntity> jobs,
    required bool showSkeleton,
    required bool firstLoadError,
    required bool hasJobs,
    required bool filtering,
  }) {
    final t = StaffLocalizations.of(context)!;
    if (showSkeleton) {
      return _scrollable(const AppSkeleton.listRows(rows: 4));
    }
    if (firstLoadError) {
      return _scrollable(
        Semantics(
          liveRegion: true,
          child: EmptyState.error(
            message: t.techJobsLoadError,
            onRetry: () => _refresh(notifier),
          ),
        ),
      );
    }
    if (!hasJobs) {
      return _scrollable(
        EmptyState(
          icon: Icons.assignment_outlined,
          title: t.techJobsEmpty,
          message: t.techJobsEmptyHint,
          actionLabel: t.techTodayRefresh,
          onAction: () => _refresh(notifier),
        ),
      );
    }
    if (jobs.isEmpty) {
      return _scrollable(
        EmptyState.noMatch(
          message: filtering
              ? t.techJobsNoMatchHint
              : t.techJobsNoMatch,
          title: t.techJobsNoMatch,
          actionLabel: t.techJobsClearFilters,
          onAction: () {
            notifier.updateSearch('');
            notifier.updateFilter('All');
          },
        ),
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppDimensions.s24),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return TechnicianJobSummary(
          job: job,
          showProgress: true,
          emphasised: job.status == TechJobStatus.inProgress,
          onTap: () => _openJob(job),
        );
      },
    );
  }

  Widget _scrollable(Widget child) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.only(bottom: AppDimensions.s24),
    children: [child],
  );

  void _openJob(TechnicianJobEntity job) {
    HapticFeedback.selectionClick();
    ref.read(technicianDashboardProvider.notifier).openJob(job);
    context
        .push(AppRoutes.technicianJobDetail, extra: job)
        .whenComplete(
          () => ref.read(technicianDashboardProvider.notifier).closeJob(),
        );
  }
}

/// Search + canonical status filters with live counts from the loaded queue.
class _JobsToolbar extends StatelessWidget {
  final TechnicianState state;
  final TechnicianNotifier notifier;
  final List<TechnicianJobEntity> allJobs;

  const _JobsToolbar({
    required this.state,
    required this.notifier,
    required this.allJobs,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    // The shared bar localizes its own "All" chip, so the All count is keyed
    // by the localized label (provider state stays English-canonical).
    final options = notifier.filterOptions.where((f) => f != 'All').toList();
    final counts = <String, int>{
      SharedCoreL10n.of(context).filterBarAll: allJobs.length,
      for (final filter in options)
        filter: allJobs.where((job) => job.status.label == filter).length,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          hintText: t.techJobsSearch,
          onChanged: notifier.updateSearch,
          onClear: () => notifier.updateSearch(''),
        ),
        const SizedBox(height: AppDimensions.s12),
        AppFilterBar(
          options: options,
          selected: state.selectedFilter == 'All'
              ? null
              : state.selectedFilter,
          counts: counts,
          countSemantics: (label, count) =>
              t.techJobsFilterSemantics(label, count),
          onSelected: (value) {
            HapticFeedback.selectionClick();
            notifier.updateFilter(value ?? 'All');
          },
        ),
      ],
    );
  }
}

class _SavedDataNotice extends StatelessWidget {
  final String message;

  const _SavedDataNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.onTertiaryContainer),
            const SizedBox(width: AppDimensions.s10),
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
      ),
    );
  }
}

class _FreshnessFooter extends StatelessWidget {
  final DateTime lastRefresh;
  const _FreshnessFooter({required this.lastRefresh});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final time = intl.DateFormat('HH:mm').format(lastRefresh);
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          t.techTodayUpdated(time),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
