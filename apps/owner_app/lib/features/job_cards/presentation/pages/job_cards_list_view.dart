import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_search_sheet.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_status_ui.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Lifecycle milestone ↔ status mapping for the centralized filter chips.
/// Presentation-only (the frozen `setFilter` still receives real statuses);
/// milestones without jobs simply render the empty state.
String? _labelFor(OwnerLocalizations t, JobCardStatus? status) =>
    switch (status) {
      null => null,
      JobCardStatus.vehicleReceived => t.ownerRegIntake,
      JobCardStatus.inspected => t.ownerRegInspect,
      JobCardStatus.inProgress => t.ownerRegWip,
      JobCardStatus.qualityCheck => t.ownerRegQc,
      JobCardStatus.completed => t.ownerRegReady,
      JobCardStatus.delivered => t.ownerRegInvoiced,
      _ => null,
    };

JobCardStatus? _statusFor(OwnerLocalizations t, String? label) {
  if (label == null) return null;
  if (label == t.ownerRegIntake) return JobCardStatus.vehicleReceived;
  if (label == t.ownerRegInspect) return JobCardStatus.inspected;
  if (label == t.ownerRegWip) return JobCardStatus.inProgress;
  if (label == t.ownerRegQc) return JobCardStatus.qualityCheck;
  if (label == t.ownerRegReady) return JobCardStatus.completed;
  if (label == t.ownerRegInvoiced) return JobCardStatus.delivered;
  return null;
}

/// Job register (O5): searchable, filterable, sortable audit table over the
/// frozen job-cards provider. The header search icon opens the register
/// filter as a full sheet over the same provider predicate (U1/C16: no inline
/// search field in the page); compact renders borderless rows (C16: shadow/
/// flat + whitespace, no card-in-card); tablet shows the full table; desktop
/// adds a side preview pane (rows select, the pane opens) instead of a
/// stretched phone list. Money renders fixed-decimal tabular via
/// [formatAed2] (Latin `AED` both locales, LTR-locked); plates stay LTR.
class JobCardsListView extends ConsumerStatefulWidget {
  const JobCardsListView({super.key});

  @override
  ConsumerState<JobCardsListView> createState() => _JobCardsListViewState();
}

class _JobCardsListViewState extends ConsumerState<JobCardsListView> {
  int? _sortIndex;
  bool _sortAscending = true;
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final state = ref.watch(jobCardsProvider);
    final notifier = ref.read(jobCardsProvider.notifier);

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final items = _sorted(state.filtered);
    final isFiltering =
        state.searchQuery.isNotEmpty || state.activeFilter != null;
    final options = <String>[
      t.ownerRegIntake,
      t.ownerRegInspect,
      t.ownerRegWip,
      t.ownerRegQc,
      t.ownerRegReady,
      t.ownerRegInvoiced,
    ];
    final counts = <String, int>{
      for (final label in options)
        label: state.all
            .where((jc) => jc.status == _statusFor(t, label))
            .length,
    };
    JobCard? selected;
    for (final jc in state.all) {
      if (jc.id == _selectedId) {
        selected = jc;
        break;
      }
    }
    final previewed = selected;

    // Wide keeps the real audit table (homogeneous 5-column matrix with
    // numeric sort). Hierarchy fixed vs the register cards: customer first,
    // ref small mono meta, status last. Presentation-only copy sort; the
    // provider list is never mutated.
    final table = AppTable<JobCard>(
      columns: [
        AppTableColumn(label: t.ownerRegCustomer, flex: 3, sortable: true),
        AppTableColumn(label: t.ownerRegPlate, flex: 2, sortable: true),
        AppTableColumn(label: t.ownerRegJob, flex: 2, sortable: true),
        AppTableColumn(
          label: t.ownerRegTotal,
          flex: 2,
          numeric: true,
          sortable: true,
        ),
        AppTableColumn(label: t.ownerRegStatus, flex: 2),
      ],
      items: items,
      cells: (context, jc) => [
        AppTableCell.text(context, jc.customerName),
        AppTableCell.custom(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              jc.plateNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AlignmentDirectional.centerStart,
        ),
        AppTableCell.custom(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              jc.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          AlignmentDirectional.centerStart,
        ),
        AppTableCell.numeric(context, formatAed2(AppFormatters.of(context), jc.amount)),
        AppTableCell.custom(
          jobStatusPill(context, t, jc.status, showDot: false),
          AlignmentDirectional.centerStart,
        ),
      ],
      sortIndex: _sortIndex,
      sortAscending: _sortAscending,
      onSort: (index) => setState(() {
        if (_sortIndex == index) {
          _sortAscending = !_sortAscending;
        } else {
          _sortIndex = index;
          _sortAscending = true;
        }
      }),
      onRowTap: (jc) {
        if (wide) {
          HapticFeedback.selectionClick();
          setState(() => _selectedId = jc.id);
        } else {
          _openJob(context, ref, jc);
        }
      },
      isSelected: (jc) => jc.id == _selectedId,
      isLoading: state.isLoading && state.all.isEmpty,
      emptyMessage: t.ownerRegEmpty,
      isNoMatch: isFiltering && items.isEmpty,
      noMatchMessage: t.ownerRegNoMatch,
      // Sticky header on desktop: the body scrolls inside a fixed height
      // with the header pinned; compact keeps the intrinsic page scroll.
      maxHeight: wide ? 560 : null,
    );

    return WorkspaceSearchShortcuts(
      onSearch: () => _openSearch(context, ref),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerRegTitle,
          subtitle: t.ownerRegSubtitle,
          showBack: true,
          // U1/C16 search-first: the header icon opens the register filter
          // as a full sheet over the same predicate; no inline field lives
          // in this page at any size.
          onSearch: () => _openSearch(context, ref),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimensions.s16),
                child: AppStatusChip(
                  label: t.ownerRegCount(items.length),
                  kind: AppStatusKind.neutral,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          // Page scroll owns the vertical axis; the desktop table pins its
          // own header inside a fixed height (maxHeight on wide only).
          child: AppPageFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFilterBar(
                  options: options,
                  selected: _labelFor(t, state.activeFilter),
                  counts: counts,
                  // U5: chips wrap at word/chip boundaries on compact/medium
                  // (never cut mid-word, Clear flows inline); the wide rail
                  // fits and keeps scrolling.
                  wrap: !wide,
                  onSelected: (label) =>
                      notifier.setFilter(_statusFor(t, label)),
                ),
                const SizedBox(height: AppDimensions.s12),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: table),
                      const SizedBox(width: AppDimensions.s24),
                      SizedBox(
                        width: 360,
                        child: _PreviewPane(
                          job: previewed,
                          onOpen: previewed == null
                              ? null
                              : () => _openJob(context, ref, previewed),
                        ),
                      ),
                    ],
                  )
                else
                  _compactList(
                    context,
                    t,
                    notifier,
                    items: items,
                    isFiltering: isFiltering,
                    isLoading: state.isLoading && state.all.isEmpty,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<JobCard> _sorted(List<JobCard> items) {
    final index = _sortIndex;
    if (index == null) return items;
    // Presentation-only ordering; the provider list is never mutated.
    // Column order is Customer/Plate/Job/Total(/Status).
    final Comparator<JobCard> cmp = switch (index) {
      0 => (a, b) => a.customerName.compareTo(b.customerName),
      1 => (a, b) => a.plateNumber.compareTo(b.plateNumber),
      2 => (a, b) => a.id.compareTo(b.id),
      3 => (a, b) => a.amount.compareTo(b.amount),
      _ => (a, b) => a.status.name.compareTo(b.status.name),
    };
    return List<JobCard>.of(items)
      ..sort((a, b) => _sortAscending ? cmp(a, b) : cmp(b, a));
  }

  void _openSearch(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    showJobCardsSearchSheet(
      context,
      onSelect: (jc) => _openJob(context, ref, jc),
    );
  }

  void _openJob(BuildContext context, WidgetRef ref, JobCard jc) {
    HapticFeedback.selectionClick();
    ref.read(selectedJobCardProvider.notifier).state = jc;
    context.push(AppRoutes.jobCardDetail);
  }

  /// Compact register list: borderless rows (C16 light: shadow/flat +
  /// whitespace, no wrapper frame, no card-in-card) with the fixed
  /// hierarchy customer/vehicle title → status pill → meta, ref small LAST.
  Widget _compactList(
    BuildContext context,
    OwnerLocalizations t,
    JobCardsNotifier notifier, {
    required List<JobCard> items,
    required bool isFiltering,
    required bool isLoading,
  }) {
    if (isLoading) {
      // Skeleton mirrors the card layout (same radii/heights/gaps).
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppShimmerSkeleton.card(height: 148),
          SizedBox(height: AppDimensions.s12),
          AppShimmerSkeleton.card(height: 148),
          SizedBox(height: AppDimensions.s12),
          AppShimmerSkeleton.card(height: 148),
        ],
      );
    }
    if (items.isEmpty) {
      return AppTableEmpty(
        message: isFiltering ? t.ownerRegNoMatch : t.ownerRegEmpty,
        isNoMatch: isFiltering,
        // 1-tap clear: the same search-reset + filter-reset the inline
        // affordances used to own, composed into one action.
        action: isFiltering
            ? TextButton(
                onPressed: () {
                  notifier.onSearch('');
                  notifier.setFilter(null);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, AppDimensions.touchTarget),
                ),
                child: Text(SharedCoreL10n.of(context).filterBarClear),
              )
            : null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppDimensions.s12),
          _RegisterJobCard(
            job: items[i],
            onTap: () => _openJob(context, ref, items[i]),
          ),
        ],
      ],
    );
  }
}

/// Compact register row: borderless surface (C16 light: `outlined: false` =
/// soft shadow, no border; dark keeps its border per the atom contract) with
/// the fixed hierarchy — customer title → status pill → vehicle·plate meta →
/// tabular total → JC ref small meta LAST.
class _RegisterJobCard extends StatelessWidget {
  final JobCard job;
  final VoidCallback onTap;

  const _RegisterJobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatters = AppFormatters.of(context);

    return AppSurfaceCard(
      outlined: false,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  job.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: jobStatusPill(
                    context,
                    t,
                    job.status,
                    showDot: false,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
                Text(
                  '${job.vehicle} · ${job.plateNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    formatAed2(formatters, job.amount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(
                      color: colors.onSurface,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    job.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(
                      color: colors.onSurfaceVariant,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          DirectionalIcon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}

/// Desktop side preview: dossier-mini for the selected row; an explicit
/// prompt when nothing is selected yet. The pane never pushes — its single
/// CTA opens the job audit.
class _PreviewPane extends StatelessWidget {
  final JobCard? job;
  final VoidCallback? onOpen;

  const _PreviewPane({required this.job, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatters = AppFormatters.of(context);
    final jc = job;

    if (jc == null) {
      return AppSurfaceCard(
        outlined: false,
        child: AppEmptyState(
          icon: Icons.preview_outlined,
          title: t.ownerRegTitle,
          message: t.ownerRegSelectPrompt,
        ),
      );
    }

    return AppSurfaceCard(
      outlined: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  jc.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              jobStatusPill(context, t, jc.status, showDot: false),
            ],
          ),
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${jc.vehicle} · ${jc.plateNumber}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppDimensions.s12),
          Row(
            children: [
              Text(
                t.ownerRegTotal,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  formatAed2(formatters, jc.amount),
                  style: AppTextStyles.mono(color: colors.onSurface)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              jc.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(
                color: colors.onSurfaceVariant,
              ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          AppPillButton.primary(
            label: t.ownerRegOpen,
            icon: Icons.arrow_forward_rounded,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}
