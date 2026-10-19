import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/accounts_receivable.dart';
import 'package:owner_app/features/dashboard/presentation/providers/ar_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_status_ui.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Presentation-only bucket derivation over the frozen summary. Critical is
/// the honest sum of the two 60+ day server buckets — never a threshold of
/// our own invention.
double _criticalOf(ARSummary s) => s.days61to90 + s.days90plus;

/// Debtor ledger (O9): aging buckets (Current 0–30 / Overdue 31–60 /
/// Critical 60+) over frozen summary figures, then the customer ledger as a
/// sortable table (record rows on compact). Rows open the billing-contact
/// sheet — the collector note the endpoint supports (contact person +
/// phone, verbatim). No collection actions exist, so none are offered.
class AccountsReceivableView extends ConsumerStatefulWidget {
  const AccountsReceivableView({super.key});

  @override
  ConsumerState<AccountsReceivableView> createState() =>
      _AccountsReceivableViewState();
}

class _AccountsReceivableViewState
    extends ConsumerState<AccountsReceivableView> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String? _bucket;
  int? _sortIndex;
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _inBucket(ARRecord r) => switch (_bucket) {
        'current' => r.aging == AgingBucket.days0to30,
        'overdue' => r.aging == AgingBucket.days31to60,
        'critical' => r.aging == AgingBucket.days61to90 ||
            r.aging == AgingBucket.days90plus,
        _ => true,
      };

  List<ARRecord> _visible(List<ARRecord> records) {
    var out = records.where(_inBucket).toList();
    if (_sortIndex != null) {
      final Comparator<ARRecord> cmp = switch (_sortIndex) {
        1 => (a, b) => a.customer.compareTo(b.customer),
        2 => (a, b) => a.outstanding.compareTo(b.outstanding),
        _ => (a, b) => a.arId.compareTo(b.arId),
      };
      out.sort((a, b) => _sortAscending ? cmp(a, b) : cmp(b, a));
    }
    return out;
  }

  void _openContact(ARRecord record) {
    HapticFeedback.selectionClick();
    final t = OwnerLocalizations.of(context)!;
    showAppModalSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s20,
            AppDimensions.s8,
            AppDimensions.s20,
            AppDimensions.s20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: SectionHeader(
                  title: t.ownerArContact,
                  padding: const EdgeInsets.only(bottom: AppDimensions.s12),
                ),
              ),
              _ContactLine(
                icon: Icons.person_outline_rounded,
                label: record.customer,
                value: record.contactPerson,
              ),
              const SizedBox(height: AppDimensions.s8),
              _ContactLine(
                icon: Icons.phone_outlined,
                label: record.contactPerson.isEmpty
                    ? record.customer
                    : record.contactPerson,
                value: record.phone,
                mono: true,
              ),
              const SizedBox(height: AppDimensions.s8),
              _ContactLine(
                icon: Icons.receipt_long_outlined,
                label: record.arId,
                value: formatAed2(
                  AppFormatters.of(sheetContext),
                  record.outstanding,
                ),
                mono: true,
              ),
              const SizedBox(height: AppDimensions.s16),
              SecondaryButton(
                label: MaterialLocalizations.of(context).closeButtonLabel,
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final formatters = AppFormatters.of(context);
    final state = ref.watch(accountsReceivableProvider);
    final notifier = ref.read(accountsReceivableProvider.notifier);

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final buckets = <String>[t.ownerArCurrent, t.ownerArOverdue, t.ownerArCritical];
    final bucketKey = _bucket == null
        ? null
        : buckets[['current', 'overdue', 'critical'].indexOf(_bucket!)];

    final items = _visible(state.filteredRecords);
    final filtering =
        state.searchQuery.isNotEmpty || _bucket != null;

    return WorkspaceSearchShortcuts(
      onSearch: () => _searchFocus.requestFocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerArTitle,
          subtitle: t.ownerArSubtitle(
            formatAed2(formatters, state.summary.totalOutstanding),
          ),
          showBack: true,
          showOfflineStatus: true,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimensions.s16),
                child: StatusPill.neutral(
                  t.ownerArCount(state.filteredRecords.length),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: state.isLoading && state.records.isEmpty
              ? const AppSkeleton.page()
              : AppResponsivePage(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BucketStrip(
                        current: state.summary.days0to30,
                        overdue: state.summary.days31to60,
                        critical: _criticalOf(state.summary),
                      ),
                      const SizedBox(height: AppDimensions.s16),
                      AppSearchField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        hintText: t.ownerArSearchHint,
                        onChanged: notifier.onSearch,
                        onClear: () {
                          _searchCtrl.clear();
                          notifier.onSearch('');
                        },
                      ),
                      const SizedBox(height: AppDimensions.s12),
                      AppFilterBar(
                        options: buckets,
                        selected: bucketKey,
                        onSelected: (label) => setState(() {
                          if (label == null) {
                            _bucket = null;
                          } else if (label == t.ownerArCurrent) {
                            _bucket = _bucket == 'current' ? null : 'current';
                          } else if (label == t.ownerArOverdue) {
                            _bucket = _bucket == 'overdue' ? null : 'overdue';
                          } else if (label == t.ownerArCritical) {
                            _bucket =
                                _bucket == 'critical' ? null : 'critical';
                          }
                        }),
                      ),
                      const SizedBox(height: AppDimensions.s12),
                      AppTable<ARRecord>(
                        columns: [
                          AppTableColumn(
                            label: t.ownerArRef,
                            flex: 2,
                            sortable: true,
                          ),
                          AppTableColumn(
                            label: t.ownerArCustomer,
                            flex: 3,
                            sortable: true,
                          ),
                          AppTableColumn(
                            label: t.ownerArAmount,
                            flex: 2,
                            numeric: true,
                            sortable: true,
                          ),
                          AppTableColumn(label: t.ownerArAge, flex: 2),
                        ],
                        items: items,
                        cells: (context, r) => [
                          AppTableCell.custom(
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                r.arId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.mono(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            AlignmentDirectional.centerStart,
                          ),
                          AppTableCell.text(context, r.customer),
                          AppTableCell.numeric(
                            context,
                            formatAed2(formatters, r.outstanding),
                          ),
                          AppTableCell.custom(
                            _AgePill(aging: r.aging),
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
                        onRowTap: _openContact,
                        emptyMessage: t.ownerArEmpty,
                        isNoMatch: filtering && items.isEmpty,
                        noMatchMessage: t.ownerArNoMatch,
                        maxHeight: wide ? 560 : null,
                        compactBuilder: (context, r) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimensions.s8),
                          child: AppRecordRow(
                            identifier: r.arId,
                            title: r.customer,
                            subtitle:
                                '${r.invoiceDate} · ${r.dueDate}',
                            metadata: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    formatAed2(
                                        formatters, r.outstanding),
                                    style: AppTextStyles.mono(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ).copyWith(
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.s6),
                                Align(
                                  alignment:
                                      AlignmentDirectional.centerStart,
                                  child: _AgePill(aging: r.aging),
                                ),
                              ],
                            ),
                            onTap: () => _openContact(r),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.s32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Aging buckets: current / overdue / critical tones from the frozen
/// summary. Critical sums the two 60+ server buckets (display derivation).
class _BucketStrip extends StatelessWidget {
  final double current;
  final double overdue;
  final double critical;

  const _BucketStrip({
    required this.current,
    required this.overdue,
    required this.critical,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final semantic = context.semanticColors;
    final formatters = AppFormatters.of(context);
    final adaptive = context.adaptive;
    final buckets = <_Bucket>[
      _Bucket(
        label: t.ownerArCurrent,
        range: t.ownerArAge030,
        amount: current,
        tone: semantic.success,
      ),
      _Bucket(
        label: t.ownerArOverdue,
        range: t.ownerArAge3160,
        amount: overdue,
        tone: semantic.warning,
      ),
      _Bucket(
        label: t.ownerArCritical,
        range: t.ownerArAge61,
        amount: critical,
        tone: semantic.danger,
      ),
    ];
    return AppAdaptiveGrid(
      columns: adaptive.pick(compact: 3, medium: 3, expanded: 3, large: 3),
      minChildWidth: 100,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.pick(
        compact: 0.92,
        medium: 1.4,
        expanded: 1.6,
        large: 1.7,
      ),
      children: [
        for (final b in buckets)
          Container(
            padding: const EdgeInsets.all(AppDimensions.s12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.8),
              ),
              boxShadow: AppDimensions.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: b.tone.base,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Expanded(
                      child: Text(
                        b.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  b.range,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    formatAed2(formatters, b.amount),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(color: b.tone.base).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bucket {
  final String label;
  final String range;
  final double amount;
  final AppStatusColors tone;

  const _Bucket({
    required this.label,
    required this.range,
    required this.amount,
    required this.tone,
  });
}

/// Age pill: success <31d, warning <61d, danger beyond. Same contract as
/// the bucket strip; theme roles only.
class _AgePill extends StatelessWidget {
  final AgingBucket aging;

  const _AgePill({required this.aging});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    return switch (aging) {
      AgingBucket.days0to30 =>
        StatusPill.success(t.ownerArAge030pill, showDot: true),
      AgingBucket.days31to60 =>
        StatusPill.warning(t.ownerArAge3160pill, showDot: true),
      AgingBucket.days61to90 =>
        StatusPill.danger(t.ownerArAge6190pill, showDot: true),
      AgingBucket.days90plus =>
        StatusPill.danger(t.ownerArAge90pill, showDot: true),
    };
  }
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  const _ContactLine({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: colors.primary),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Flexible(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (mono
                      ? AppTextStyles.mono(color: colors.onSurface)
                      : theme.textTheme.bodyMedium!
                          .copyWith(color: colors.onSurface))
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}
