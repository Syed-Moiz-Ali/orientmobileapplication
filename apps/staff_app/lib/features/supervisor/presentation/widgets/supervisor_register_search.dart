import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Opens the register search sheet: a full-screen search over the jobs
/// register (no new routes, no logic changes). Same 4-field inline predicate
/// over [AssignedJobEntity] the Jobs tab filter used (jobCard / customer /
/// vehicle / status, case-insensitive); a result opens the same assign sheet
/// a register entry opens.
Future<void> showSupervisorRegisterSearch(
  BuildContext context, {
  required List<AssignedJobEntity> jobs,
  required ValueChanged<AssignedJobEntity> onSelect,
}) {
  return showAppModalSheet<void>(
    context: context,
    title: StaffLocalizations.of(context)!.svJobsTitle,
    builder: (_) => _RegisterSearchSheet(jobs: jobs, onSelect: onSelect),
  );
}

/// Presentation-only register search: filters the [AssignedJobEntity] list
/// with the verbatim Jobs-tab predicate so the sheet can never promise a
/// record the register does not show.
class _RegisterSearchSheet extends StatefulWidget {
  final List<AssignedJobEntity> jobs;
  final ValueChanged<AssignedJobEntity> onSelect;

  const _RegisterSearchSheet({required this.jobs, required this.onSelect});

  @override
  State<_RegisterSearchSheet> createState() => _RegisterSearchSheetState();
}

class _RegisterSearchSheetState extends State<_RegisterSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<AssignedJobEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.jobs;
    return widget.jobs.where((j) {
      return j.jobCard.toLowerCase().contains(q) ||
          j.customer.toLowerCase().contains(q) ||
          j.vehicle.toLowerCase().contains(q) ||
          j.status.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final coreT = SharedCoreL10n.of(context);
    final results = _results();
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
            hintText: t.svJobsSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppDimensions.s20),
                  child: AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: coreT.commonNoResults,
                    message: t.svJobsNoMatch,
                    actionLabel: coreT.filterBarClear,
                    onAction: () => setState(() {
                      _ctrl.clear();
                      _query = '';
                    }),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final job = results[index];
                    return _RegisterRow(
                      job: job,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        widget.onSelect(job);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Borderless divider row mirroring the register identity (vehicle‖customer +
/// jobCard mono LTR + status pill). Display + tap only — tapping opens the
/// same assign sheet the register entry opens.
class _RegisterRow extends StatelessWidget {
  final AssignedJobEntity job;
  final VoidCallback onTap;

  const _RegisterRow({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.vehicle.isNotEmpty ? job.vehicle : job.customer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                supervisorStatusPill(job.status),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    job.jobCard,
                    style: supervisorMono(
                      context,
                      color: context.colors.onSurfaceVariant,
                    ).copyWith(fontSize: 11),
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                Expanded(
                  child: Text(
                    job.customer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
