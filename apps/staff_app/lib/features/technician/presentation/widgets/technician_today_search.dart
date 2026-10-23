import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Opens the today search sheet: a full-screen search over the already
/// loaded technician jobs (no new routes, no logic changes). Result taps reuse
/// the queue-row contract — tapping a result opens the same job dossier.
Future<void> showTechnicianTodaySearch(
  BuildContext context, {
  required List<TechnicianJobEntity> jobs,
  required ValueChanged<TechnicianJobEntity> onSelect,
}) {
  return showAppModalSheet<void>(
    context: context,
    title: StaffLocalizations.of(context)!.techJobsSearch,
    builder: (_) => _TodaySearchSheet(jobs: jobs, onSelect: onSelect),
  );
}

/// Presentation-only job search: filters the loaded [TechnicianJobEntity]
/// list by reference, vehicle, customer or plate (case-insensitive, plates
/// compared without punctuation). Mirrors the provider's filter fields so the
/// sheet can never promise a job the board does not show.
class _TodaySearchSheet extends StatefulWidget {
  final List<TechnicianJobEntity> jobs;
  final ValueChanged<TechnicianJobEntity> onSelect;

  const _TodaySearchSheet({required this.jobs, required this.onSelect});

  @override
  State<_TodaySearchSheet> createState() => _TodaySearchSheetState();
}

class _TodaySearchSheetState extends State<_TodaySearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static String _normalizedPlate(String value) =>
      value.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();

  List<TechnicianJobEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.jobs;
    return widget.jobs.where((j) {
      return j.jobCardNo.toLowerCase().contains(q) ||
          j.vehicleBrand.toLowerCase().contains(q) ||
          j.vehicleModel.toLowerCase().contains(q) ||
          j.customerName.toLowerCase().contains(q) ||
          (q.isNotEmpty &&
              _normalizedPlate(j.plateNumber).contains(
                _normalizedPlate(q),
              ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final coreT = SharedCoreL10n.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.techJobsSearch,
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
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.techJobsNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        t.techJobsNoMatchHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppPillButton.secondary(
                        label: coreT.filterBarClear,
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final job = results[index];
                    return TechnicianJobSummary(
                      job: job,
                      showProgress: true,
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
