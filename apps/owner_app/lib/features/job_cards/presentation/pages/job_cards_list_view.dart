import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
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
/// frozen job-cards provider. Compact renders divider rows with a filter
/// strip; tablet shows the full table; desktop adds a side preview pane
/// (rows select, the pane opens) instead of a stretched phone list. Money
/// renders fixed-decimal tabular via [formatAed2]; plates stay LTR.
class JobCardsListView extends ConsumerStatefulWidget {
  const JobCardsListView({super.key});

  @override
  ConsumerState<JobCardsListView> createState() => _JobCardsListViewState();
}

class _JobCardsListViewState extends ConsumerState<JobCardsListView> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  int? _sortIndex;
  bool _sortAscending = true;
  String? _selectedId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<JobCard> _sorted(List<JobCard> items) {
    final index = _sortIndex;
    if (index == null) return items;
    // Presentation-only ordering; the provider list is never mutated.
    final Comparator<JobCard> cmp = switch (index) {
      0 => (a, b) => a.id.compareTo(b.id),
      1 => (a, b) => a.plateNumber.compareTo(b.plateNumber),
      2 => (a, b) => a.customerName.compareTo(b.customerName),
      3 => (a, b) => a.amount.compareTo(b.amount),
      _ => (a, b) => a.status.name.compareTo(b.status.name),
    };
    return List<JobCard>.of(items)
      ..sort((a, b) => _sortAscending ? cmp(a, b) : cmp(b, a));
  }

  void _openJob(BuildContext context, WidgetRef ref, JobCard jc) {
    HapticFeedback.selectionClick();
    ref.read(selectedJobCardProvider.notifier).state = jc;
    context.push(AppRoutes.jobCardDetail);
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
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

    final table = AppTable<JobCard>(
      columns: [
        AppTableColumn(label: t.ownerRegJob, flex: 2, sortable: true),
        AppTableColumn(label: t.ownerRegPlate, flex: 2, sortable: true),
        AppTableColumn(label: t.ownerRegCustomer, flex: 3, sortable: true),
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
        AppTableCell.custom(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              jc.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(
                color: Theme.of(context).colorScheme.onSurface,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          AlignmentDirectional.centerStart,
        ),
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
        AppTableCell.text(context, jc.customerName),
        AppTableCell.numeric(context, formatAed2(formatters, jc.amount)),
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
      // Compact rows stack the status pill as a full-width block below the
      // total: a long pill beside the title is unshrinkable at 320px/1.3x
      // (shared row keeps its contract; the block always has bounded width
      // so the pill ellipsizes instead of clipping).
      compactBuilder: (context, jc) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.s8),
        child: AppRecordRow(
          identifier: jc.id,
          title: jc.customerName,
          subtitle: '${jc.vehicle} · ${jc.plateNumber}',
          metadata: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  formatAed2(formatters, jc.amount),
                  style: AppTextStyles.mono(
                    color: Theme.of(context).colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: AppDimensions.s6),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: jobStatusPill(context, t, jc.status, showDot: false),
              ),
            ],
          ),
          onTap: () => _openJob(context, ref, jc),
        ),
      ),
    );

    return WorkspaceSearchShortcuts(
      onSearch: () => _searchFocus.requestFocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerRegTitle,
          subtitle: t.ownerRegSubtitle,
          showBack: true,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimensions.s16),
                child: StatusPill.neutral(t.ownerRegCount(items.length)),
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
                AppSearchField(
                  controller: _searchCtrl,
                  focusNode: _searchFocus,
                  hintText: t.ownerRegSearchHint,
                  onChanged: notifier.onSearch,
                  onClear: () {
                    _searchCtrl.clear();
                    notifier.onSearch('');
                  },
                ),
                const SizedBox(height: AppDimensions.s12),
                AppFilterBar(
                  options: options,
                  selected: _labelFor(t, state.activeFilter),
                  counts: counts,
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
                  table,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop side preview: dossier-mini for the selected row; an explicit
/// prompt when nothing is selected yet. The pane never pushes — its single
/// CTA opens the full audit.
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
      return AppCard.standard(
        child: EmptyState(
          icon: Icons.preview_outlined,
          message: t.ownerRegSelectPrompt,
        ),
      );
    }

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    jc.id,
                    style: AppTextStyles.mono(color: colors.onSurface)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              jobStatusPill(context, t, jc.status, showDot: false),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
          Text(
            jc.customerName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              jc.vehicleDisplay,
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
          const SizedBox(height: AppDimensions.s16),
          PrimaryButton(
            label: t.ownerRegOpen,
            icon: Icons.arrow_forward_rounded,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}
