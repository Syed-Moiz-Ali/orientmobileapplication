import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_job_card_row.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Jobs tab: search first, status filter chips, then the working list of job
/// cards rendered with the shared record-row grammar.
class AdvisorJobsListView extends ConsumerStatefulWidget {
  final void Function(JobCardEntity) onJobCard;
  const AdvisorJobsListView({super.key, required this.onJobCard});
  @override
  ConsumerState<AdvisorJobsListView> createState() =>
      _AdvisorJobsListViewState();
}

class _AdvisorJobsListViewState extends ConsumerState<AdvisorJobsListView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<(String, String)> _chips(StaffLocalizations t) => [
    ('all', t.advisorFilterAll),
    ('inProgress', t.advisorFilterInProgress),
    ('completed', t.advisorFilterCompleted),
    ('pending', t.advisorFilterPending),
    ('qc', t.advisorFilterQc),
    ('cancelled', t.advisorFilterCancelled),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    final jobsAsync = ref.watch(advisorRecentJobCardsProvider);
    final bookingsAsync = ref.watch(advisorAssignedBookingsProvider);
    final jobCards = jobsAsync.value ?? const <JobCardEntity>[];
    final selectedFilter = ref.watch(_jobsFilterProvider);
    final isLoading = jobsAsync.isLoading || bookingsAsync.isLoading;
    final hasError = jobsAsync.hasError || bookingsAsync.hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLoading && jobCards.isEmpty)
          const LinearProgressIndicator(minHeight: 3),
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding.left,
            context.pagePadding.top,
            context.pagePadding.right,
            AppDimensions.s12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.advisorJobsTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s12),
              if (hasError) ...[
                AppInfoPanel.danger(
                  message: t.advisorDataError,
                  action: TextButton(
                    onPressed: () {
                      ref.invalidate(advisorRecentJobCardsProvider);
                      ref.invalidate(advisorAssignedBookingsProvider);
                    },
                    child: Text(t.advisorActionRefreshJobCard),
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
              ],
              AppSearchField(
                controller: _searchCtrl,
                hintText: t.advisorJobsSearchHint,
                onChanged: (v) =>
                    ref.read(_jobsSearchProvider.notifier).state = v,
                onClear: () =>
                    ref.read(_jobsSearchProvider.notifier).state = '',
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
            itemCount: _chips(t).length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.s8),
            itemBuilder: (_, i) {
              final (key, label) = _chips(t)[i];
              final active = key == selectedFilter;
              return Center(
                child: ChoiceChip(
                  label: Text(label),
                  selected: active,
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    ref.read(_jobsFilterProvider.notifier).state = key;
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        Expanded(
          child: RefreshIndicator(
            color: colors.primary,
            backgroundColor: colors.surface,
            onRefresh: () async =>
                ref.read(advisorRefreshProvider.notifier).state++,
            child: _buildJobList(t, jobCards, selectedFilter, isLoading),
          ),
        ),
      ],
    );
  }

  Widget _buildJobList(
    StaffLocalizations t,
    List<JobCardEntity> allCards,
    String filter,
    bool isLoading,
  ) {
    final query = ref.watch(_jobsSearchProvider).toLowerCase();
    final bookings =
        ref.watch(advisorAssignedBookingsProvider).value ??
        const <AdvisorBookingResponse>[];
    final showBookings =
        query.isEmpty && filter == 'all' && bookings.isNotEmpty;

    final filtered = allCards.where((jc) {
      final matchesFilter =
          filter == 'all' || advisorStatusFilterKey(jc.status) == filter;
      final matchesSearch =
          query.isEmpty ||
          jc.id.toLowerCase().contains(query) ||
          jc.customerName.toLowerCase().contains(query) ||
          jc.vehicleInfo.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    if (isLoading && allCards.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s8,
          context.pagePadding.right,
          (AppDimensions.s64 + AppDimensions.s24),
        ),
        children: const [AppSkeleton.listRows(rows: 4)],
      );
    }

    if (filtered.isEmpty && !showBookings) {
      final hasQuery = query.isNotEmpty || filter != 'all';
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s32),
        children: [
          hasQuery
              ? EmptyState.noMatch(
                  icon: Icons.search_off_rounded,
                  message: t.advisorNoMatchingJobs,
                )
              : EmptyState(
                  icon: Icons.assignment_outlined,
                  title: t.advisorNoJobs,
                  message: t.advisorNoJobsHint,
                ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s8,
        context.pagePadding.right,
        (AppDimensions.s64 + AppDimensions.s24),
      ),
      itemCount: filtered.length + (showBookings ? 1 : 0),
      itemBuilder: (_, i) {
        if (showBookings && i == 0) {
          return _buildAssignedBookingsSection(t, bookings);
        }
        final index = showBookings ? i - 1 : i;
        if (index < 0 || index >= filtered.length) {
          return const SizedBox.shrink();
        }
        return AdvisorJobCardRow(jc: filtered[index], onTap: widget.onJobCard);
      },
    );
  }

  Widget _buildAssignedBookingsSection(
    StaffLocalizations t,
    List<AdvisorBookingResponse> bookings,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s14),
      child: AppCard.standard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.primary,
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    t.advisorAssignedIntakeQueue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                StatusPill.info(t.advisorPendingCount(bookings.length)),
              ],
            ),
            const SizedBox(height: AppDimensions.s12),
            ...bookings
                .take(3)
                .map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.s8),
                    child: AppRecordRow(
                      leading: Icon(
                        Icons.directions_car_rounded,
                        color: colors.primary,
                      ),
                      title: '${b.serviceType} · ${b.vehicleName}',
                      subtitle: '${b.customerName} · ${b.bookingDate}',
                      trailing: PrimaryButton(
                        label: t.advisorActionCheckIn,
                        isExpanded: false,
                        height: AppDimensions.touchTarget,
                        onPressed: () => context.push(
                          AppRoutes.advisorCheckIn,
                          extra: {
                            'bookingId': '${b.id}',
                            'customerName': b.customerName,
                            'vehicleInfo': b.vehicleName,
                          },
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

final _jobsSearchProvider = StateProvider<String>((ref) => '');
final _jobsFilterProvider = StateProvider<String>((ref) => 'all');
