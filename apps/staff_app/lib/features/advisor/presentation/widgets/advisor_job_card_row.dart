import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_status.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// A job card rendered in the shared divider-row grammar (home + jobs list):
/// status dot 8px + customer 15/600 + plate pill + job mono 12 LTR +
/// status pill right + time muted 12 + chevron. 72px rows with 1px dividers —
/// never cards-per-row. Identifiers, plates and times stay LTR in both
/// locales. The urgent microcopy ("Due today") and selection highlight are
/// opt-in so the home assigned list and the jobs work list share one row.
class AdvisorJobCardRow extends StatelessWidget {
  final JobCardEntity jc;
  final void Function(JobCardEntity) onTap;

  /// Optional contextual overflow action (e.g. a quick job-card preview).
  /// When null the row shows a plain chevron affordance.
  final VoidCallback? onMore;

  /// Shows the localized "Due today" microcopy under the time for urgent rows.
  final bool showDueToday;

  /// Desktop/master-detail selection highlight.
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
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final split = _splitVehiclePlate(jc.vehicleInfo);
    // Compact density exception: StatusPill never truncates its label (shared
    // widget, frozen), so at 320px/1.3x its intrinsic width overflows. Reclaim
    // the room here with tighter row padding/gaps on compact only.
    final compact = context.adaptive.pick(compact: true, medium: false);
    final hPad = compact ? AppDimensions.s8 : AppDimensions.s16;
    final dotGap = compact ? AppDimensions.s8 : AppDimensions.s12;
    final timeGap = compact ? AppDimensions.s8 : AppDimensions.s12;
    // Small-mobile exception (<360px): the right time column (time + "Due
    // today") squeezes the pill past overflow, so the meta stacks into a
    // third line under the texts. 390px+ keeps the spec grammar untouched.
    final stackMeta =
        context.deviceClass == AppDeviceClass.smallMobile;

    return Semantics(
      button: true,
      label: '${jc.customerName}, ${jc.id}',
      child: Material(
        color: selected ? semantic.selectedSurface : Colors.transparent,
        child: InkWell(
          onTap: () => onTap(jc),
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: AppDimensions.s12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _statusDotColor(context, jc.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: dotGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                jc.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle(
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s8),
                            Flexible(child: advisorStatusPill(t, jc.status)),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s4),
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
                              child: Text(
                                split.vehicle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  jc.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.mono(
                                    color: colors.onSurfaceVariant,
                                  ).copyWith(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (stackMeta) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    jc.time,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (showDueToday) ...[
                                Text(
                                  ' · ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    t.advisorDueToday,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: semantic.warning.ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!stackMeta) ...[
                    SizedBox(width: timeGap),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          jc.time,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        if (showDueToday) ...[
                          const SizedBox(height: 2),
                          Text(
                            t.advisorDueToday,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: semantic.warning.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(width: AppDimensions.s4),
                  if (onMore == null)
                    DirectionalIcon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                    )
                  else
                    IconButton(
                      onPressed: onMore,
                      tooltip: t.advisorActionMore,
                      icon: const Icon(Icons.more_horiz_rounded),
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ),
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

Color _statusDotColor(BuildContext context, JobCardStatus status) {
  final semantic = context.semanticColors;
  return switch (status) {
    JobCardStatus.pending ||
    JobCardStatus.pendingApproval ||
    JobCardStatus.awaitingSupervisor ||
    JobCardStatus.waitingCustomerApproval =>
      semantic.warning.base,
    JobCardStatus.waitingParts => semantic.danger.base,
    JobCardStatus.qualityCheck => semantic.warning.base,
    JobCardStatus.inProgress => semantic.info.base,
    JobCardStatus.workAssigned ||
    JobCardStatus.inspected ||
    JobCardStatus.vehicleReceived =>
      semantic.info.base,
    JobCardStatus.completed ||
    JobCardStatus.approved ||
    JobCardStatus.delivered ||
    JobCardStatus.qualityCheckPassed =>
      semantic.success.base,
    JobCardStatus.cancelled => semantic.neutral.base,
  };
}
