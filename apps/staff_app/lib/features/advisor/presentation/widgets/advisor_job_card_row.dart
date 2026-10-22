import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// One job card in the advisor jobs register (GROUP-B list rebuild).
///
/// Borderless card grammar (C16): the advisor recognizes customer + vehicle
/// first (title, wraps to 2 lines, never truncated), then ONE status chip
/// (sentence-case shared vocabulary), then the meta sentence, with the job id
/// as small LTR mono meta — never the title. Full labels survive 320px +
/// 1.3x + ar (the old divider row truncated pills mid-word at 360px).
/// Identifiers, plates and times stay LTR in both locales. The "Due today"
/// microcopy and selection treatment are opt-in.
class AdvisorJobCardRow extends StatelessWidget {
  final JobCardEntity jc;
  final void Function(JobCardEntity) onTap;

  /// Optional contextual overflow action (e.g. a quick job-card preview).
  /// When null the card shows its tappable chevron affordance.
  final VoidCallback? onMore;

  /// Shows the localized "Due today" microcopy under the time for urgent rows.
  final bool showDueToday;

  /// Master/detail selection highlight (bordered treatment when true).
  final bool selected;

  const AdvisorJobCardRow({
    super.key,
    required this.jc,
    required this.onTap,
    this.onMore,
    this.showDueToday = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final split = _splitVehiclePlate(jc.vehicleInfo);
    final sentence = showDueToday && jc.time.trim().isNotEmpty
        ? '${t.advisorDueToday} · ${jc.time}'
        : jc.time;
    final timeShown = sentence.trim().isEmpty ? '--' : sentence;

    return Semantics(
      button: true,
      label: '${jc.customerName}, ${jc.id}',
      child: AppSurfaceCard(
        outlined: selected,
        onTap: () => onTap(jc),
        showChevron: onMore == null,
        semanticLabel: '${jc.customerName}, ${jc.id}',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Recognized name first: customer + vehicle (wraps, never
                  // amputates a person's name — U5).
                  Text(
                    '${jc.customerName} · ${split.vehicle}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s8),
                  // ONE status chip from the shared taxonomy (sentence case).
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: advisorStatusChip(t, jc.status),
                  ),
                  const SizedBox(height: AppDimensions.s8),
                  // Meta sentence: time first (secondary text may ellipsize).
                  Row(
                    children: [
                      if (split.plate != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.s6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXs,
                            ),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              split.plate!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.mono(
                                color: colors.onSurfaceVariant,
                              ).copyWith(fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s6),
                      ],
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            timeShown,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  // Id is small meta (LTR mono, tabular), never the title.
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
            if (onMore != null) ...[
              const SizedBox(width: AppDimensions.s8),
              IconButton(
                onPressed: onMore,
                tooltip: t.advisorActionMore,
                icon: const Icon(Icons.more_horiz_rounded),
                color: colors.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Splits local-first `vehicleInfo` ("Make Model · PLATE") into vehicle +
/// plate. Server cards without a separator yield (full, null): no fabricated
/// plate.
({String vehicle, String? plate}) _splitVehiclePlate(String vehicleInfo) {
  final parts = vehicleInfo.split('·');
  if (parts.length >= 2) {
    final plate = parts.sublist(1).join('·').trim();
    return (
      vehicle: parts.first.trim(),
      plate: plate.isEmpty ? null : plate,
    );
  }
  return (vehicle: vehicleInfo, plate: null);
}
