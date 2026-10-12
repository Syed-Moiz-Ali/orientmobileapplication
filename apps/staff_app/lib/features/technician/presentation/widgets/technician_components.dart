import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

/// Shared Technician presentation primitives.
///
/// These carry no business logic and no fabricated data: every value they
/// render is supplied by the caller from real state. They exist so Today,
/// Jobs and the Job Detail phase can describe the workshop floor the same way.

/// Section heading for the Technician workspace: a small operational eyebrow,
/// a clear title and an optional contextual action.
class TechnicianSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TechnicianSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppDimensions.r3),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

/// Canonical Technician job status as a compact pill.
///
/// The status is always written as text as well as tinted, so the state never
/// depends on colour alone — a requirement for bright workshop environments.
class TechnicianStatusPill extends StatelessWidget {
  final TechJobStatus status;

  const TechnicianStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: status.label.toUpperCase(),
      showDot: true,
      bg: status.color.withValues(alpha: 0.14),
      fg: status.color,
    );
  }
}

/// Task-derived repair progress.
///
/// Progress is only ever `completed / total` from the real task list. With zero
/// tasks nothing is shown, so a job can never display decorative 0% progress.
class TechnicianTaskProgress extends StatelessWidget {
  final int completed;
  final int total;

  const TechnicianTaskProgress({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (total <= 0) return const SizedBox.shrink();

    final label = '$completed of $total tasks completed';

    return Semantics(
      label: label,
      value: '$completed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            child: LinearProgressIndicator(
              value: completed / total,
              minHeight: 8,
              backgroundColor: colors.outlineVariant,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
                TechnicianStatusPill(status: job.status),
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

/// Compact, truthful empty/blank state for a Technician surface.
class TechnicianEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const TechnicianEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.s18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            ),
            child: Icon(
              icon,
              size: AppDimensions.iconMd,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimensions.s16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppDimensions.touchTarget),
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
