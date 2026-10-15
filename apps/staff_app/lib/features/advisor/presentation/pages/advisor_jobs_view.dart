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
  final _searchCtrl = TextEditingController();
  JobCardEntity? _selected;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showQuickCard(JobCardEntity jc) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => AdvisorJobCardSheet(
        jc: jc,
        onOpen: () {
          Navigator.pop(sheetContext);
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
    _searchCtrl.clear();
    ref.read(_jobsSearchProvider.notifier).state = '';
    ref.read(_jobsFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    final jobsAsync = ref.watch(advisorRecentJobCardsProvider);
    final bookingsAsync = ref.watch(advisorAssignedBookingsProvider);
    final jobCards = jobsAsync.valueOrNull ?? const <JobCardEntity>[];
    final selectedFilter = ref.watch(_jobsFilterProvider);
    final sort = ref.watch(_jobsSortProvider);
    final isLoading = jobsAsync.isLoading || bookingsAsync.isLoading;
    final hasError = jobsAsync.hasError || bookingsAsync.hasError;

    final query = ref.watch(_jobsSearchProvider).toLowerCase();
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.advisorJobsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (!isLoading && jobCards.isNotEmpty)
                    StatusPill.neutral('${visible.length}'),
                ],
              ),
              const SizedBox(height: AppDimensions.s8),
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
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.pagePadding.left,
          ),
          child: AppDropdownButton(
            label: t.advisorSortLabel,
            value: sortLabel,
            items: sortLabels,
            isExpanded: true,
            onChanged: (label) {
              HapticFeedback.selectionClick();
              ref.read(_jobsSortProvider.notifier).state = switch (label) {
                _ when label == t.advisorSortOldest => 'oldest',
                _ when label == t.advisorSortCustomer => 'customer',
                _ => 'newest',
              };
            },
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
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
      if (context.isCompact) {
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
            EmptyState.noMatch(
              icon: Icons.search_off_rounded,
              message: t.advisorNoMatchingJobs,
            ),
            const SizedBox(height: AppDimensions.s16),
            Center(
              child: TextButton(
                onPressed: _clearAllFilters,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, AppDimensions.touchTarget),
                ),
                child: Text(SharedCoreL10n.of(context).filterBarClear),
              ),
            ),
          ] else ...[
            EmptyState(
              icon: Icons.assignment_outlined,
              title: t.advisorNoJobs,
              message: t.advisorNoJobsHint,
            ),
            const SizedBox(height: AppDimensions.s16),
            Center(
              child: PrimaryButton(
                label: t.advisorActionNewJobTitle,
                icon: Icons.add_rounded,
                isExpanded: false,
                onPressed: () =>
                    context.push(AppRoutes.vehicleCustomer),
              ),
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
                      child: advisorStatusPill(t, jc.status),
                    ),
                    AppTableCell.text(context, jc.time),
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

  List<AppTableColumn> _columns(StaffLocalizations t, {bool sortable = false}) => [
    AppTableColumn(label: t.advisorJobsColumnCustomer, flex: 3, sortable: sortable),
    AppTableColumn(label: t.advisorJobsColumnJobCard, flex: 2),
    AppTableColumn(label: t.advisorFieldVehicle, flex: 3),
    AppTableColumn(label: t.advisorJobsColumnStatus, flex: 2),
    AppTableColumn(label: t.advisorJobsColumnTime, flex: 2, sortable: sortable),
  ];

  Widget _buildCompactList(
    StaffLocalizations t,
    List<JobCardEntity> visible,
    List<AdvisorBookingResponse> bookings,
    bool showBookings,
  ) {
    // Compact: divider rows in the shared grammar (status dot + customer +
    // plate + job mono LTR + pill + time + overflow → JobCardSheet). No plate
    // field exists on JobCardEntity, so the row splits local-first
    // vehicleInfo ("Model · PLATE") and never invents data.
    final colors = Theme.of(context).colorScheme;
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s8,
          context.pagePadding.right,
          (AppDimensions.s64 + AppDimensions.s24),
        ),
        children: [
          if (showBookings) _buildAssignedBookingsSection(t, bookings),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colors.outlineVariant),
                bottom: BorderSide(color: colors.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: colors.outlineVariant),
                  AdvisorJobCardRow(
                    jc: visible[i],
                    onTap: widget.onJobCard,
                    onMore: () => _showQuickCard(visible[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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

class _JobAvatar extends StatelessWidget {
  final JobCardEntity jc;
  const _JobAvatar({required this.jc});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 15,
      backgroundColor: colors.primary.withValues(alpha: 0.12),
      child: Text(
        jc.customerName.isNotEmpty ? jc.customerName[0] : 'C',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w800,
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
              _JobAvatar(jc: jc),
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
                    Text(
                      jc.id,
                      style: AppTextStyles.mono(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              advisorStatusPill(t, jc.status),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          AppCard.standard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _JobPreviewTile(
                  icon: Icons.directions_car_outlined,
                  label: t.advisorFieldVehicle,
                  value: jc.vehicleInfo,
                ),
                _JobPreviewTile(
                  icon: Icons.engineering_outlined,
                  label: t.advisorFieldTechnician,
                  value: jc.technician,
                ),
                _JobPreviewTile(
                  icon: Icons.schedule_outlined,
                  label: t.advisorFieldCreated,
                  value: jc.time,
                ),
                if (jc.odometer != null)
                  _JobPreviewTile(
                    icon: Icons.speed_rounded,
                    label: t.advisorFieldOdometer,
                    value: t.advisorOdometerValue('${jc.odometer}'),
                    mono: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s20),
          PrimaryButton(
            label: t.advisorActionOpenJob,
            icon: Icons.open_in_new_rounded,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}

/// Compact label/value line used in the master–detail preview pane.
class _JobPreviewTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  const _JobPreviewTile({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final shown = value.trim().isEmpty ? '--' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s12),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSm,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Text(
              shown,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: mono
                  ? AppTextStyles.mono(color: colors.onSurface)
                  : theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

final _jobsSearchProvider = StateProvider<String>((ref) => '');
final _jobsFilterProvider = StateProvider<String?>((ref) => null);
final _jobsSortProvider = StateProvider<String>((ref) => 'newest');
