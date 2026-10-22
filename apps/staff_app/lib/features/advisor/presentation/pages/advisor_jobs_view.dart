import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_job_card_row.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_job_card_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_search_sheet.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Jobs tab: a work-management surface — search first, a status filter rail,
/// then either a scrollable work list (compact) or a master–detail job matrix
/// (tablet/desktop). Selection, routing and the back stack stay with the
/// caller; the wide layout only previews the selected job card.
class AdvisorJobsListView extends ConsumerStatefulWidget {
  final void Function(JobCardEntity) onJobCard;
  const AdvisorJobsListView({super.key, required this.onJobCard});
  @override
  ConsumerState<AdvisorJobsListView> createState() =>
      _AdvisorJobsListViewState();
}

class _AdvisorJobsListViewState extends ConsumerState<AdvisorJobsListView> {
  JobCardEntity? _selected;

  /// Session-only recent searches (presentation state): the header search
  /// icon opens the shared AdvisorSearchSheet with these recents.
  final List<String> _searchRecents = <String>[];

  void _rememberSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _searchRecents.remove(q);
      _searchRecents.insert(0, q);
      if (_searchRecents.length > 5) {
        _searchRecents.removeRange(5, _searchRecents.length);
      }
    });
  }

  // U1: the header search icon is the ONE search path on this tab. The
  // existing AdvisorSearchSheet (same id/customer/vehicle predicate, session
  // recents, scan CTA inside, autofocus, Enter = top hit) presents
  // full-screen — same pattern as the advisor home header. No new routes.
  void _showSearch() {
    HapticFeedback.selectionClick();
    final size = MediaQuery.sizeOf(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SizedBox.fromSize(
          size: size,
          child: ColoredBox(
            color: Theme.of(sheetContext).colorScheme.surface,
            child: SingleChildScrollView(
              child: AdvisorSearchSheet(
                recents: _searchRecents,
                onRemember: _rememberSearch,
                onScan: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.scanVehicle);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickCard(JobCardEntity jc) {
    HapticFeedback.mediumImpact();
    showAppBottomSheet<void>(
      context,
      child: AdvisorJobCardSheet(
        jc: jc,
        onOpen: () {
          Navigator.pop(context);
          widget.onJobCard(jc);
        },
      ),
    );
  }

  List<String> _filterKeys(StaffLocalizations t) => [
    'intake',
    'inspection',
    'approved',
    'wip',
    'ready',
  ];

  String _filterLabel(StaffLocalizations t, String key) => switch (key) {
    'intake' => t.advisorFilterIntake,
    'inspection' => t.advisorFilterInspection,
    'approved' => t.advisorFilterApproved,
    'wip' => t.advisorFilterWip,
    'ready' => t.advisorFilterReady,
    _ => t.advisorFilterAll,
  };

  List<JobCardEntity> _sorted(List<JobCardEntity> input, String sort) {
    switch (sort) {
      case 'customer':
        final list = input.toList()
          ..sort(
            (a, b) => a.customerName.toLowerCase().compareTo(
              b.customerName.toLowerCase(),
            ),
          );
        return list;
      case 'oldest':
        // The repository's canonical order is newest-first (server order), so
        // oldest-first is its reversal. No timestamp parsing is invented.
        return input.reversed.toList();
      case 'newest':
      default:
        return input.toList();
    }
  }

  void _clearAllFilters() {
    ref.read(_jobsSearchProvider.notifier).state = '';
    ref.read(_jobsFilterProvider.notifier).state = null;
  }

  /// Header count subtitle (count once, in the subtitle — never a badge AND a
  /// label). Zero renders as words (U11: zero shows as 0, never "-").
  String _countSubtitle(StaffLocalizations t, int count) {
    if (count == 0) return t.advisorJobsCountNone;
    if (count == 1) return t.advisorJobsCountOne;
    return t.advisorJobsCountMany(count);
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;

    final jobsAsync = ref.watch(advisorRecentJobCardsProvider);
    final bookingsAsync = ref.watch(advisorAssignedBookingsProvider);
    final jobCards = jobsAsync.valueOrNull ?? const <JobCardEntity>[];
    final selectedFilter = ref.watch(_jobsFilterProvider);
    final sort = ref.watch(_jobsSortProvider);
    final isLoading = jobsAsync.isLoading || bookingsAsync.isLoading;
    final hasError = jobsAsync.hasError || bookingsAsync.hasError;

    final query = ref.watch(_jobsSearchProvider).toLowerCase();
    final bookingsForChrome =
        ref.watch(advisorAssignedBookingsProvider).valueOrNull ??
        const <AdvisorBookingResponse>[];
    // Calm empty: collapse decorative rail + sort only when the register is
    // truly empty (loaded, no error, no cards, no bookings, no filter). The
    // no-match branch keeps its rail + Clear affordance.
    final collapseChrome =
        !isLoading &&
        !hasError &&
        jobCards.isEmpty &&
        bookingsForChrome.isEmpty &&
        query.isEmpty &&
        selectedFilter == null;
    final visible = _sorted(
      jobCards.where((jc) {
        final matchesFilter =
            selectedFilter == null ||
            advisorStatusFilterKey(jc.status) == selectedFilter;
        final matchesSearch =
            query.isEmpty ||
            jc.id.toLowerCase().contains(query) ||
            jc.customerName.toLowerCase().contains(query) ||
            jc.vehicleInfo.toLowerCase().contains(query);
        return matchesFilter && matchesSearch;
      }).toList(),
      sort,
    );
    final counts = <String, int>{
      for (final key in _filterKeys(t))
        _filterLabel(t, key): jobCards
            .where((jc) => advisorStatusFilterKey(jc.status) == key)
            .length,
    };
    final sortLabels = [
      t.advisorSortNewest,
      t.advisorSortOldest,
      t.advisorSortCustomer,
    ];
    final sortLabel = switch (sort) {
      'oldest' => t.advisorSortOldest,
      'customer' => t.advisorSortCustomer,
      _ => t.advisorSortNewest,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding.left,
            context.pagePadding.top,
            context.pagePadding.right,
            AppDimensions.s8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // U1: the header search icon is the one search path, top-right
              // on the same row (plain Row, RTL-mirrored). Shown only when
              // the register is big enough to need find-aids — the one
              // sanctioned progressive-disclosure exception (> 5).
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.advisorJobsTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.s4),
                        Text(
                          _countSubtitle(t, visible.length),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (jobCards.length > 5) ...[
                    const SizedBox(width: AppDimensions.s8),
                    AppIconButton(
                      icon: Icons.search_rounded,
                      onPressed: _showSearch,
                      tooltip: t.advisorSearchTitle,
                    ),
                  ],
                ],
              ),
              // Stale-data notice only: first-load failure owns the surface
              // below (AppErrorState), so the message never appears twice.
              if (hasError && jobCards.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s8),
                AppBanner(
                  kind: AppBannerKind.warning,
                  message: t.advisorDataError,
                  actionLabel: t.advisorActionRefreshJobCard,
                  onAction: () {
                    ref.invalidate(advisorRecentJobCardsProvider);
                    ref.invalidate(advisorAssignedBookingsProvider);
                  },
                ),
              ],
            ],
          ),
        ),
        if (!collapseChrome) ...[
          const SizedBox(height: AppDimensions.s8),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding.left,
            ),
            child: AppFilterBar(
              options: [for (final key in _filterKeys(t)) _filterLabel(t, key)],
              selected: selectedFilter == null
                  ? null
                  : _filterLabel(t, selectedFilter),
              counts: counts,
              onSelected: (label) {
                HapticFeedback.selectionClick();
                if (label == null) {
                  ref.read(_jobsFilterProvider.notifier).state = null;
                  return;
                }
                final hit = _filterKeys(
                  t,
                ).where((k) => _filterLabel(t, k) == label).firstOrNull;
                ref.read(_jobsFilterProvider.notifier).state = hit;
              },
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
          // Compact sort row: label inline + control on one line (saves the
          // label-above height so the first card sits above the fold).
          // Same options, same behavior, same 3-tap budget.
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding.left,
            ),
            child: Row(
              children: [
                Text(
                  t.advisorSortLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: AppDropdownButton(
                    value: sortLabel,
                    items: sortLabels,
                    isExpanded: true,
                    onChanged: (label) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(_jobsSortProvider.notifier)
                          .state = switch (label) {
                        _ when label == t.advisorSortOldest => 'oldest',
                        _ when label == t.advisorSortCustomer => 'customer',
                        _ => 'newest',
                      };
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s8),
        ] else ...[
          const SizedBox(height: AppDimensions.s8),
        ],
        Expanded(
          child: _buildSurface(
            t,
            jobCards,
            visible,
            query,
            selectedFilter,
            sort,
            isLoading,
            hasError,
          ),
        ),
      ],
    );
  }

  Widget _buildSurface(
    StaffLocalizations t,
    List<JobCardEntity> allCards,
    List<JobCardEntity> visible,
    String query,
    String? filter,
    String sort,
    bool isLoading,
    bool hasError,
  ) {
    final bookings =
        ref.watch(advisorAssignedBookingsProvider).valueOrNull ??
        const <AdvisorBookingResponse>[];
    final showBookings =
        query.isEmpty && filter == null && bookings.isNotEmpty;

    if (isLoading && allCards.isEmpty) {
      // Skeleton mirrors the final layout (no full-screen spinner for
      // content areas — C10). The thin progress bar is gone: loading owns
      // no permanent chrome.
      if (context.isCompact) {
        return ListView(
          padding: EdgeInsets.fromLTRB(
            context.pagePadding.left,
            AppDimensions.s8,
            context.pagePadding.right,
            (AppDimensions.s64 + AppDimensions.s24),
          ),
          children: const [
            AppShimmerSkeleton.card(height: 168),
            SizedBox(height: AppDimensions.s12),
            AppShimmerSkeleton.card(height: 168),
            SizedBox(height: AppDimensions.s12),
            AppShimmerSkeleton.card(height: 168),
          ],
        );
      }
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: AppTable<JobCardEntity>(
          columns: _columns(t),
          items: const [],
          cells: (context, jc) => const [],
          isLoading: true,
          skeletonRows: 6,
        ),
      );
    }

    if (hasError && allCards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s16,
        ),
        children: [
          AppErrorState(
            title: t.advisorDataError,
            message: t.advisorOfflineNotice,
            onRetry: () {
              ref.invalidate(advisorRecentJobCardsProvider);
              ref.invalidate(advisorAssignedBookingsProvider);
            },
            // Same retry label as before (verbatim copy, same invalidate).
            retryLabel: t.advisorActionRefreshJobCard,
          ),
        ],
      );
    }

    if (visible.isEmpty && !showBookings) {
      final hasQuery = query.isNotEmpty || filter != null;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.s32,
          horizontal: AppDimensions.s24,
        ),
        children: [
          if (hasQuery) ...[
            _JobsNoMatch(onClear: _clearAllFilters),
          ] else ...[
            AppEmptyState(
              icon: Icons.assignment_outlined,
              title: t.advisorNoJobs,
              message: t.advisorNoJobsHint,
              actionLabel: t.advisorActionNewJobTitle,
              onAction: () => context.push(AppRoutes.vehicleCustomer),
            ),
          ],
        ],
      );
    }

    if (context.isCompact) return _buildCompactList(t, visible, bookings, showBookings);

    // Wide layouts: master–detail work matrix with a sortable table (sticky
    // header via maxHeight). Selection is local; opening the full job card
    // still routes through the caller's push navigation.
    return AppMasterDetailScaffold(
      detailOpen: _selected != null,
      masterMinWidth: 440,
      masterMaxWidth: 720,
      placeholder: _JobPreviewPlaceholder(key: const ValueKey('jobs-preview')),
      master: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBookings) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.s16,
                AppDimensions.s8,
                AppDimensions.s16,
                0,
              ),
              child: _buildAssignedBookingsSection(t, bookings),
            ),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: LayoutBuilder(
                builder: (context, constraints) => AppTable<JobCardEntity>(
                  columns: _columns(t, sortable: true),
                  // Row flexes mirror the column flexes (column.flex drives
                  // the header only; rows default to equal shares).
                  cellFlex: const [3, 2, 2, 4, 2],
                  items: visible,
                    // Sticky header via a bounded body. The 4px guard absorbs
                    // sub-pixel rounding between the expanded pane and the
                    // table's internal header so the fit never overflows.
                    maxHeight: (constraints.maxHeight - 4).clamp(
                      200.0,
                      constraints.maxHeight,
                    ),
                  sortIndex: switch (sort) {
                    'customer' => 0,
                    'oldest' || 'newest' => 4,
                    _ => null,
                  },
                  sortAscending: sort != 'newest',
                  onSort: (index) {
                    HapticFeedback.selectionClick();
                    if (index == 0) {
                      ref.read(_jobsSortProvider.notifier).state = 'customer';
                    } else if (index == 4) {
                      ref.read(_jobsSortProvider.notifier).state =
                          sort == 'newest' ? 'oldest' : 'newest';
                    }
                  },
                  isSelected: (jc) => _selected?.id == jc.id,
                  onRowTap: (jc) {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = jc);
                  },
                  // No leading avatar in the dense matrix: the preview pane
                  // carries identity, and the width serves data columns.
                  // No kebab either: tap selects into the preview pane with
                  // its Open CTA, and the compact list keeps the sheet
                  // overflow. Both buy room for identifiers and pills.
                    cells: (context, jc) => [
                      AppTableCell.text(context, jc.customerName),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          jc.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mono(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    AppTableCell.text(context, jc.vehicleInfo),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: advisorStatusChip(t, jc.status),
                    ),
                    // Local-first cards carry the magic string 'Pending sync'
                    // as time (provider payload, unchanged): present the
                    // localized sync copy, never raw English, never '--'.
                    AppTableCell.text(
                      context,
                      jc.time.trim() == 'Pending sync'
                          ? SharedCoreL10n.of(context).pendingSyncNotSent
                          : jc.time,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      detail: _selected == null
          ? _JobPreviewPlaceholder()
          : _JobPreviewPane(
              jc: _selected!,
              onOpen: () => widget.onJobCard(_selected!),
            ),
    );
  }

  // Status owns the widest share: single-word chips must fit on one line
  // (vehicle wraps at word gaps instead — legal; mid-word breaks are not).
  List<AppTableColumn> _columns(StaffLocalizations t, {bool sortable = false}) => [
    AppTableColumn(label: t.advisorJobsColumnCustomer, flex: 3, sortable: sortable),
    AppTableColumn(label: t.advisorJobsColumnJobCard, flex: 2),
    AppTableColumn(label: t.advisorFieldVehicle, flex: 2),
    AppTableColumn(label: t.advisorJobsColumnStatus, flex: 4),
    AppTableColumn(label: t.advisorJobsColumnTime, flex: 2, sortable: sortable),
  ];

  Widget _buildCompactList(
    StaffLocalizations t,
    List<JobCardEntity> visible,
    List<AdvisorBookingResponse> bookings,
    bool showBookings,
  ) {
    // Compact: whitespace-separated borderless cards (C16 — shadow in
    // light, shared border in dark, never a bordered container). No plate
    // field exists on JobCardEntity, so the card splits local-first
    // vehicleInfo ("Model · PLATE") and never invents data.
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s4,
          context.pagePadding.right,
          (AppDimensions.s64 + AppDimensions.s24),
        ),
        itemCount: visible.length + (showBookings ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.s12),
        itemBuilder: (context, index) {
          if (showBookings && index == 0) {
            return _buildAssignedBookingsSection(t, bookings);
          }
          final jc = visible[showBookings ? index - 1 : index];
          return AdvisorJobCardRow(
            jc: jc,
            onTap: widget.onJobCard,
            onMore: () => _showQuickCard(jc),
          );
        },
      ),
    );
  }

  Widget _buildAssignedBookingsSection(
    StaffLocalizations t,
    List<AdvisorBookingResponse> bookings,
  ) {
    // Intake queue: borderless card with ONE status chip and a direct
    // per-row Check In action (the row's frequent action — one filled
    // action per row, no section-level CTA). Same copy/routes/extras, same
    // cap of 3 rows. Compact padding keeps the first job card above the
    // fold at 360x800 (tokens only).
    return AppSurfaceCard(
      outlined: false,
      padding: const EdgeInsets.all(AppDimensions.s16),
      headerTitle: t.advisorAssignedIntakeQueue,
      headerTrailing: AppStatusChip(
        kind: AppStatusKind.info,
        label: t.advisorPendingCount(bookings.length),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final b in bookings.take(3))
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.s8),
              child: _BookingRow(
                booking: b,
                onCheckIn: () => context.push(
                  AppRoutes.advisorCheckIn,
                  extra: {
                    'bookingId': '${b.id}',
                    'customerName': b.customerName,
                    'vehicleInfo': b.vehicleName,
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One assigned-booking row: car glyph + service/vehicle + customer/date +
/// the direct Check In action (48dp target, no menu dive).
class _BookingRow extends StatelessWidget {
  final AdvisorBookingResponse booking;
  final VoidCallback onCheckIn;

  const _BookingRow({required this.booking, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Row(
      children: [
        Icon(
          Icons.directions_car_rounded,
          size: AppDimensions.iconMd,
          color: colors.primary,
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${booking.serviceType} · ${booking.vehicleName}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              // Wrap-aware at 1.3x: the whole date stays visible (never
              // `2026-1…` truncation). Wraps to 2 lines instead of clipping.
              Text(
                '${booking.customerName} · ${booking.bookingDate}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        AppPillButton.primary(
          label: t.advisorActionCheckIn,
          size: AppPillButtonSize.small,
          isExpanded: false,
          onPressed: () {
            HapticFeedback.selectionClick();
            onCheckIn();
          },
        ),
      ],
    );
  }
}

/// Filter-no-match state (vehicles-list precedent): one sentence + one Clear
/// control that clears search AND filter. No new keys.
class _JobsNoMatch extends StatelessWidget {
  final VoidCallback onClear;

  const _JobsNoMatch({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.advisorNoMatchingJobs,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onClear();
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(0, AppDimensions.touchTarget),
              ),
              child: Text(SharedCoreL10n.of(context).filterBarClear),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobPreviewPlaceholder extends StatelessWidget {
  const _JobPreviewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.preview_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppDimensions.s12),
              Text(
                t.advisorJobsSelectPrompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobPreviewPane extends StatelessWidget {
  final JobCardEntity jc;
  final VoidCallback onOpen;
  const _JobPreviewPane({required this.jc, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.s24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: jc.customerName,
                size: AppAvatarSize.small,
                semanticLabel: jc.customerName,
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jc.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        jc.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mono(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              advisorStatusChip(t, jc.status),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          // Same identity fields as verbose rows; mono values stay LTR.
          // Blank values use honest empty-state copy (never '--'); the
          // local-first magic time maps to the localized sync copy.
          AppSurfaceCard(
            outlined: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDataRow(
                  label: t.advisorFieldVehicle,
                  value: _shownValue(
                    context,
                    jc.vehicleInfo,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                AppDataRow(
                  label: t.advisorFieldTechnician,
                  value: _shownValue(
                    context,
                    jc.technician,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                AppDataRow(
                  label: t.advisorFieldCreated,
                  value: jc.time.trim() == 'Pending sync'
                      ? SharedCoreL10n.of(context).pendingSyncNotSent
                      : _shownValue(context, jc.time),
                ),
                if (jc.odometer != null) ...[
                  const SizedBox(height: AppDimensions.s12),
                  AppDataRow(
                    label: t.advisorFieldOdometer,
                    value: '',
                    valueWidget: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        t.advisorOdometerValue('${jc.odometer}'),
                        textAlign: TextAlign.end,
                        style: AppTextStyles.mono(color: colors.onSurface),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s20),
          AppPillButton.primary(
            label: t.advisorActionOpenJob,
            icon: Icons.open_in_new_rounded,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}

/// Blank display values use honest empty-state copy (never '--', never
/// invented data). Existing shared `commonNoData` covers the empty case.
String _shownValue(BuildContext context, String value) =>
    value.trim().isEmpty ? SharedCoreL10n.of(context).commonNoData : value;

final _jobsSearchProvider = StateProvider<String>((ref) => '');
final _jobsFilterProvider = StateProvider<String?>((ref) => null);
final _jobsSortProvider = StateProvider<String>((ref) => 'newest');
