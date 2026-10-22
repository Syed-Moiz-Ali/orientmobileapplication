import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_status_ui.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Opens the register search as a full sheet over the SAME provider predicate
/// as the register list (no new routes, no logic changes). Typing in the
/// sheet writes straight through `JobCardsNotifier.onSearch` — the exact
/// target the removed inline field used — so the sheet can never promise a
/// job the register does not show. Tapping a result closes the sheet and
/// reuses the register's `_openJob` contract (selection + push audit).
Future<void> showJobCardsSearchSheet(
  BuildContext context, {
  required ValueChanged<JobCard> onSelect,
}) {
  return showAppModalSheet<void>(
    context: context,
    title: OwnerLocalizations.of(context)!.ownerRegTitle,
    builder: (_) => _JobCardsSearchSheet(onSelect: onSelect),
  );
}

/// Presentation-only sheet search: the provider owns the predicate; this
/// widget only renders the field + the live `filtered` list.
class _JobCardsSearchSheet extends ConsumerStatefulWidget {
  final ValueChanged<JobCard> onSelect;

  const _JobCardsSearchSheet({required this.onSelect});

  @override
  ConsumerState<_JobCardsSearchSheet> createState() =>
      _JobCardsSearchSheetState();
}

class _JobCardsSearchSheetState extends ConsumerState<_JobCardsSearchSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: ref.read(jobCardsProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    ref.read(jobCardsProvider.notifier).onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final state = ref.watch(jobCardsProvider);
    final notifier = ref.read(jobCardsProvider.notifier);
    final results = state.filtered;
    final isFiltering =
        state.searchQuery.isNotEmpty || state.activeFilter != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppDimensions.s20,
            AppDimensions.s4,
            AppDimensions.s20,
            AppDimensions.s12,
          ),
          child: AppSearchField(
            controller: _ctrl,
            autofocus: true,
            hintText: t.ownerRegSearchHint,
            onChanged: notifier.onSearch,
            onClear: _clear,
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppDimensions.s20),
                  child: AppTableEmpty(
                    message: isFiltering
                        ? t.ownerRegNoMatch
                        : t.ownerRegEmpty,
                    isNoMatch: isFiltering,
                    action: isFiltering
                        ? TextButton(
                            onPressed: _clear,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(
                                0,
                                AppDimensions.touchTarget,
                              ),
                            ),
                            child: Text(
                              SharedCoreL10n.of(context).filterBarClear,
                            ),
                          )
                        : null,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsetsDirectional.only(
                    start: AppDimensions.s20,
                    end: AppDimensions.s20,
                    bottom: AppDimensions.s20,
                  ),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (context, index) =>
                      _SheetResultRow(job: results[index], onSelect: widget.onSelect),
                ),
        ),
      ],
    );
  }
}

/// Sheet result row: customer/vehicle title → status pill → meta, ref small
/// mono LAST (same hierarchy as the register cards, frameless — the sheet
/// is the surface).
class _SheetResultRow extends StatelessWidget {
  final JobCard job;
  final ValueChanged<JobCard> onSelect;

  const _SheetResultRow({required this.job, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatters = AppFormatters.of(context);

    return Semantics(
      button: true,
      label: '${job.customerName}, ${job.vehicle} ${job.plateNumber}',
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop();
          onSelect(job);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.s12,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.touchTarget,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s8),
                    jobStatusPill(context, t, job.status, showDot: false),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${job.vehicle} · ${job.plateNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
                Row(
                  children: [
                    Expanded(
                      child: Directionality(
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
                    ),
                    const SizedBox(width: AppDimensions.s8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        job.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mono(
                          color: colors.onSurfaceVariant,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
