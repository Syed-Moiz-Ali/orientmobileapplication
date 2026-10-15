import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Jobs — "what work is assigned to me, and which job should I open?".
///
/// A scanning surface for the technician's queue, deliberately distinct from
/// Today (execution). One search, canonical status filters, a compact and lazy
/// job list, and no per-row operational buttons — those live in Job Detail.
class TechnicianJobsView extends ConsumerWidget {
  const TechnicianJobsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(technicianRefreshProvider);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final allJobs = notifier.allJobs;
    final jobs = notifier.filteredJobs;

    final hasJobs = allJobs.isNotEmpty;
    final firstLoadError =
        allJobs.isEmpty && !state.isLoading && state.dashboardError.isNotEmpty;
    final showSkeleton = state.isLoading && allJobs.isEmpty;
    final filtering =
        state.searchQuery.isNotEmpty || state.selectedFilter != 'All';

    return RefreshIndicator(
      onRefresh: notifier.refresh,
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
                context: context,
                ref: ref,
                notifier: notifier,
                jobs: jobs,
                showSkeleton: showSkeleton,
                firstLoadError: firstLoadError,
                hasJobs: hasJobs,
                filtering: filtering,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body({
    required BuildContext context,
    required WidgetRef ref,
    required TechnicianNotifier notifier,
    required List<TechnicianJobEntity> jobs,
    required bool showSkeleton,
    required bool firstLoadError,
    required bool hasJobs,
    required bool filtering,
  }) {
    if (showSkeleton) {
      return _scrollable(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AppSkeleton.card(height: 96),
            SizedBox(height: AppDimensions.s10),
            AppSkeleton.card(height: 96),
            SizedBox(height: AppDimensions.s10),
            AppSkeleton.card(height: 96),
          ],
        ),
      );
    }
    if (firstLoadError) {
      return _scrollable(
        Semantics(
          liveRegion: true,
          child: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: "We couldn't load your jobs",
            message: 'Check your connection and try again.',
            actionLabel: 'Retry',
            onAction: notifier.refresh,
          ),
        ),
      );
    }
    if (!hasJobs) {
      return _scrollable(
        EmptyState(
          icon: Icons.assignment_outlined,
          title: 'No assigned jobs',
          message: 'There are no jobs assigned to you right now.',
          actionLabel: 'Refresh',
          onAction: notifier.refresh,
        ),
      );
    }
    if (jobs.isEmpty) {
      return _scrollable(
        EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matching jobs',
          message: 'No jobs match your search and filter.',
          actionLabel: 'Clear filters',
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
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s10),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return TechnicianJobSummary(
          job: job,
          showProgress: true,
          emphasised: job.status == TechJobStatus.inProgress,
          onTap: () => _openJob(context, ref, job),
        );
      },
    );
  }

  Widget _scrollable(Widget child) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.only(bottom: AppDimensions.s24),
    children: [child],
  );

  void _openJob(BuildContext context, WidgetRef ref, TechnicianJobEntity job) {
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
    // Phase 07.1: bespoke _JobFilterChip migrated to the centralized
    // AppFilterBar (same options + live counts; the shared bar scrolls
    // horizontally instead of wrapping — verified no-overflow at 320 px).
    final options = notifier.filterOptions.where((f) => f != 'All').toList();
    // The shared bar localizes its own "All" chip, so the All count is keyed
    // by the localized label (provider state stays English-canonical).
    final counts = <String, int>{
      SharedCoreL10n.of(context).filterBarAll: allJobs.length,
      for (final filter in options)
        filter: allJobs.where((job) => job.status.label == filter).length,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          hintText: 'Search jobs',
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
          countSemantics: (label, count) => 'Filter jobs: $label, $count jobs',
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
