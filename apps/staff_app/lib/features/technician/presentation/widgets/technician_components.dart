import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

/// Shared Technician presentation primitives.
///
/// Phase 07.1: the bespoke `TechnicianSectionHeader`, `TechnicianStatusPill`,
/// `TechnicianTaskProgress` and `TechnicianEmptyState` are deleted — call
/// sites compose the shared `SectionHeader`, `StatusPill`, `AppLinearProgress`
/// and `EmptyState` (same copy + behavior). What remains here
/// (`TechnicianJobSummary`, …) is technician-domain composition with no shared
/// counterpart.
///
/// These carry no business logic and no fabricated data: every value they
/// render is supplied by the caller from real state. They exist so Today,
/// Jobs and the Job Detail phase can describe the workshop floor the same way.

/// Canonical Technician job status as a shared pill.
///
/// The status is always written as text as well as tinted, so the state never
/// depends on colour alone — a requirement for bright workshop environments.
///
/// Phase 07.1: maps [TechJobStatus] onto the shared [StatusPill] tone
/// constructors (theme-resolved, no static palette).
StatusPill technicianStatusPill(TechJobStatus status) {
  final label = status.label.toUpperCase();
  return switch (status) {
    TechJobStatus.inProgress => StatusPill.inProgress(label),
    TechJobStatus.completed => StatusPill.success(label, showDot: true),
    TechJobStatus.qcReview => StatusPill.info(label, showDot: true),
    TechJobStatus.delayed => StatusPill.danger(label, showDot: true),
    TechJobStatus.pending => StatusPill.warning(label, showDot: true),
  };
}

/// One compact row in an assigned-jobs queue.
///
/// Prioritises the scan-critical fields only: vehicle, plate, job reference and
/// canonical status. Shared so the Jobs phase can reuse the exact same row.
class TechnicianJobSummary extends StatelessWidget {
  final TechnicianJobEntity job;
  final VoidCallback onTap;

  /// Adds the real task-progress line. Off by default so the compact Today
  /// queue is unchanged; the Jobs list opts in.
  final bool showProgress;

  /// Slightly stronger emphasis for the active job. Never the only signal — the
  /// status pill and text always carry the state too.
  final bool emphasised;

  const TechnicianJobSummary({
    super.key,
    required this.job,
    required this.onTap,
    this.showProgress = false,
    this.emphasised = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vehicle = '${job.vehicleBrand} ${job.vehicleModel}'.trim();
    final meta = [
      if (job.jobCardNo.isNotEmpty) job.jobCardNo,
      if (job.plateNumber.isNotEmpty) job.plateNumber,
    ].join(' \u00b7 ');

    return Semantics(
      button: true,
      label: 'Open ${job.jobCardNo}, ${vehicle.isEmpty ? 'vehicle' : vehicle}',
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.touchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: emphasised
                    ? colors.primary.withValues(alpha: 0.45)
                    : colors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: job.status.color,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPill,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vehicle.isEmpty ? 'Vehicle' : vehicle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.r3),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (showProgress && job.tasks.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.r4),
                        Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: AppDimensions.iconXs,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppDimensions.r4),
                            Flexible(
                              child: Text(
                                '${job.completedTasks} of ${job.tasks.length} tasks completed',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.s8),
                technicianStatusPill(job.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact job context shown inside a contextual Technician flow, so the
/// technician always sees which job a parts request or escalation belongs to
/// without re-selecting it.
class TechnicianJobContext extends StatelessWidget {
  final String jobCardNo;
  final String vehicleLabel;
  final String plateNumber;

  const TechnicianJobContext({
    super.key,
    required this.jobCardNo,
    this.vehicleLabel = '',
    this.plateNumber = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final vehicle = vehicleLabel.trim();
    final plate = plateNumber.trim();
    final meta = [
      if (vehicle.isNotEmpty) vehicle,
      if (plate.isNotEmpty) plate,
    ].join(' \u00b7 ');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s12,
        vertical: AppDimensions.s10,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.build_circle_outlined,
            size: AppDimensions.iconSm,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobCardNo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontFamily: AppFontFamilies.mono,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.r2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
