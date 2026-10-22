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
    final core = SharedCoreL10n.of(context);
    final split = _splitVehiclePlate(jc.vehicleInfo);
    // Local-first cards carry the magic string 'Pending sync' as their time
    // slot (provider payload, unchanged). Presentation maps it to a localized
    // sync badge and keeps the time slot honest — never the raw English copy
    // inside localized UI, never '--'.
    final isPendingSync = jc.time.trim() == 'Pending sync';
    final sentence = showDueToday && !isPendingSync && jc.time.trim().isNotEmpty
        ? '${t.advisorDueToday} · ${jc.time}'
        : (isPendingSync ? '' : jc.time);
    final hasTime = sentence.trim().isNotEmpty;
    final hasMeta = split.plate != null || hasTime;

    return Semantics(
      button: true,
      label: '${jc.customerName}, ${jc.id}',
      child: AppSurfaceCard(
        outlined: selected,
        onTap: () => onTap(jc),
        showChevron: false,
        semanticLabel: '${jc.customerName}, ${jc.id}',
        // Compact inner padding keeps the first card above the fold at
        // 360x800 (tokens only).
        padding: const EdgeInsets.all(AppDimensions.s16),
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
                  // ONE status chip from the shared taxonomy (sentence case),
                  // then the separate sync state when the card is unsynced.
                  Wrap(
                    spacing: AppDimensions.s8,
                    runSpacing: AppDimensions.s8,
                    children: [
                      advisorStatusChip(t, jc.status),
                      if (isPendingSync)
                        AppStatusChip(
                          kind: AppStatusKind.warning,
                          label: core.pendingSyncNotSent,
                        ),
                    ],
                  ),
                  if (hasMeta) ...[
                    const SizedBox(height: AppDimensions.s8),
                    // Meta sentence: plate + time (secondary text may
                    // ellipsize; time never carries the sync copy).
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
                          if (hasTime)
                            const SizedBox(width: AppDimensions.s6),
                        ],
                        if (hasTime)
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                sentence,
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
                  ],
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
            const SizedBox(width: AppDimensions.s8),
            // Trailing affordances: 48dp overflow opens the quick preview
            // sheet; the directional chevron marks the card tap target.
            // Both mirror in RTL; taps never regress.
            if (onMore != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIconButton(
                    icon: Icons.more_vert_rounded,
                    onPressed: onMore,
                    tooltip: t.advisorActionMore,
                  ),
                  DirectionalIcon(
                    Icons.chevron_right_rounded,
                    size: AppDimensions.iconMd,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              )
            else
              DirectionalIcon(
                Icons.chevron_right_rounded,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
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
