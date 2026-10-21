import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Opens the floor search sheet: a full-screen search over the already
/// derived floor data (no new routes, no logic changes). Results reuse the
/// tile tap contract — tapping a result selects the bay and opens the same
/// assign sheet.
Future<void> showSupervisorFloorSearch(
  BuildContext context, {
  required List<SupervisorBay> bays,
  required ValueChanged<SupervisorBay> onSelect,
}) {
  return showAppModalSheet<void>(
    context: context,
    title: StaffLocalizations.of(context)!.svSearchTitle,
    builder: (_) => _FloorSearchSheet(bays: bays, onSelect: onSelect),
  );
}

/// Presentation-only bay search: filters the derived [SupervisorBay] list by
/// bay code, job ref or title (case-insensitive). Mirrors the tile content so
/// the sheet can never promise a bay the board does not show.
class _FloorSearchSheet extends StatefulWidget {
  final List<SupervisorBay> bays;
  final ValueChanged<SupervisorBay> onSelect;

  const _FloorSearchSheet({required this.bays, required this.onSelect});

  @override
  State<_FloorSearchSheet> createState() => _FloorSearchSheetState();
}

class _FloorSearchSheetState extends State<_FloorSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<SupervisorBay> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.bays;
    return widget.bays.where((b) {
      return bayCode(b.number).toLowerCase().contains(q) ||
          b.ref.toLowerCase().contains(q) ||
          b.title.toLowerCase().contains(q);
    }).toList();
  }

  String _stateLabel(BuildContext context, SupervisorBayState state) {
    final t = StaffLocalizations.of(context)!;
    return switch (state) {
      SupervisorBayState.occupied => t.svBayOccupied,
      SupervisorBayState.partsDelay => t.svBayPartsDelay,
      SupervisorBayState.qc => t.svBayQc,
      SupervisorBayState.idle => t.svBayIdle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
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
            hintText: t.svSearchHint,
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
                  child: Text(
                    t.svFloorNoMatch,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final bay = results[index];
                    final tone = supervisorBayTone(context, bay.state);
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        widget.onSelect(bay);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: tone.base,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s10),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                bayCode(bay.number),
                                style: supervisorMono(context),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s10),
                            Expanded(
                              child: Text(
                                bay.hasJob ? bay.title : _stateLabel(
                                  context,
                                  bay.state,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.onSurface,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
