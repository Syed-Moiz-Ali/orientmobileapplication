import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

/// Shared Technician presentation primitives.
///
/// Phase 10: home-grammar composition for the execution console. Everything
/// here is presentation-only: every value rendered is supplied by the caller
/// from real provider state, and status colours resolve through the active
/// theme ([context.semanticColors]) — never through the frozen entity
/// palette getters, which stay byte-identical domain contracts.
///
/// What remains here is technician-domain composition with no shared
/// counterpart: the job summary row, the plate chip, the stopwatch readout
/// and the status side-colour mapping used by the Today/Jobs queues.

/// Canonical Technician job status as a shared pill.
///
/// Sentence-case caller labels verbatim (C16) — the frozen `TechJobStatus.label`
/// values (`Delayed`, `Pending`, …) render as-is, never uppercased.
///
/// The status is always written as text as well as tinted, so the state never
/// depends on colour alone — a requirement for bright workshop environments.
StatusPill technicianStatusPill(TechJobStatus status) {
  final label = status.label;
  return switch (status) {
    TechJobStatus.inProgress => StatusPill.inProgress(label),
    TechJobStatus.completed => StatusPill.success(label, showDot: true),
    TechJobStatus.qcReview => StatusPill.info(label, showDot: true),
    TechJobStatus.delayed => StatusPill.danger(label, showDot: true),
    TechJobStatus.pending => StatusPill.warning(label, showDot: true),
  };
}

/// Theme-resolved side colour for a job status.
///
/// Presentation-side mapping of the frozen [TechJobStatus] taxonomy onto the
/// active theme. The entity's own palette getters are domain contracts and
/// are never read here, so light/dark parity holds by construction.
Color techStatusSideColor(BuildContext context, TechJobStatus status) {
  final semantic = context.semanticColors;
  return switch (status) {
    TechJobStatus.inProgress => Theme.of(context).colorScheme.primary,
    TechJobStatus.completed => semantic.success.base,
    TechJobStatus.qcReview => semantic.info.base,
    TechJobStatus.delayed => semantic.danger.base,
    TechJobStatus.pending => semantic.warning.base,
  };
}

/// One high-touch row in an assigned-jobs queue (72px minimum, home
/// divider-row grammar: status bar + vehicle + LTR identifiers + status pill
/// + chevron, 1px dividers between rows — never cards-per-row).
///
/// Prioritises the scan-critical fields only: vehicle, plate, job reference,
/// start time and canonical status. The Jobs list opts into the real
/// task-progress line.
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
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final vehicle =
        '${job.vehicleBrand} ${job.vehicleModel}'.trim().isEmpty
        ? t.techVehicleFallback
        : '${job.vehicleBrand} ${job.vehicleModel}'.trim();

    return Semantics(
      button: true,
      label: 'Open ${job.jobCardNo}, $vehicle',
      child: Material(
        color: emphasised ? semantic.selectedSurface : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s12,
                vertical: AppDimensions.s12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: techStatusSideColor(context, job.status),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusPill,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vehicle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle(
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s8),
                            Flexible(
                              child: technicianStatusPill(job.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s4),
                        Row(
                          children: [
                            if (job.jobCardNo.isNotEmpty) ...[
                              Expanded(
                                flex: 2,
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    job.jobCardNo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.mono(
                                      color: colors.onSurfaceVariant,
                                    ).copyWith(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s6),
                            ],
                            if (job.plateNumber.isNotEmpty)
                              Flexible(
                                child: Container(
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
                                      job.plateNumber,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.mono(
                                        color: colors.onSurfaceVariant,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ),
                                ),
                              ),
                            if (job.startTime.isNotEmpty) ...[
                              const SizedBox(width: AppDimensions.s6),
                              Flexible(
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    t.techTodayStartsAt(job.startTime),
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
                            ],
                          ],
                        ),
                        if (showProgress && job.tasks.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.s4),
                          Row(
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: AppDimensions.iconXs,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppDimensions.s6),
                              Flexible(
                                child: Text(
                                  t.techJobsProgress(
                                    job.completedTasks,
                                    job.tasks.length,
                                  ),
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
                  const SizedBox(width: AppDimensions.s4),
                  DirectionalIcon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
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
    ].join(' · ');

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
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    jobCardNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w900,
                      fontFamily: AppFontFamilies.mono,
                    ),
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

/// Theme-resolved dot colour for an attendance state.
///
/// Presentation-side mapping of the frozen [AttendanceStatus] taxonomy. The
/// entity's own palette getters are domain contracts and are never read here.
Color techAttendanceColor(BuildContext context, AttendanceStatus status) {
  final semantic = context.semanticColors;
  return switch (status) {
    AttendanceStatus.working => semantic.success.base,
    AttendanceStatus.onBreak => semantic.warning.base,
    AttendanceStatus.notPunchedIn => semantic.neutral.base,
    AttendanceStatus.punchedOut => semantic.neutral.base,
  };
}

/// Canonical plate chip for the console (mono, LTR-locked, localized
/// fallback). Consolidates the two private copies previously kept in the
/// Today and Job Detail views.
class TechnicianPlateChip extends StatelessWidget {
  final String plate;

  const TechnicianPlateChip({super.key, required this.plate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final value = plate.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          value.isEmpty ? t.techPlateMissing : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mono(color: colors.onSurface).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Presentation-only stopwatch readout for a work task.
///
/// Display only: the elapsed time is derived from the recorded `startTime`
/// (`HH:mm` today, written by the frozen `startTask` provider call) and the
/// wall clock. No timer, labour or handoff logic lives here — Start / Hold /
/// Complete keep calling the exact same notifier methods.
///
/// States: running (ticking `HH:MM:SS` mono tabular + Live dot), paused
/// (static start + Paused chip — no pause instant is recorded anywhere, so
/// nothing ticks), done (static `start – end` range), idle (empty).
class TechnicianStopwatch extends StatefulWidget {
  final WorkTaskEntity task;

  /// When false the readout never ticks (deterministic stills for goldens).
  final bool ticking;

  const TechnicianStopwatch({super.key, required this.task, this.ticking = true});

  @override
  State<TechnicianStopwatch> createState() => _TechnicianStopwatchState();
}

class _TechnicianStopwatchState extends State<TechnicianStopwatch> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(covariant TechnicianStopwatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.status != widget.task.status ||
        oldWidget.task.startTime != widget.task.startTime ||
        oldWidget.ticking != widget.ticking) {
      _arm();
    }
  }

  void _arm() {
    _timer?.cancel();
    _timer = null;
    if (widget.ticking && widget.task.status == TaskStatus.inProgress) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final task = widget.task;
    final running = task.status == TaskStatus.inProgress;
    final held = task.status == TaskStatus.onHold;
    final done =
        task.status == TaskStatus.completed && task.startTime != null;

    if (task.startTime == null && !done) {
      return const SizedBox.shrink();
    }

    final elapsed = task.startTime == null
        ? Duration.zero
        : _elapsedSince(task.startTime!);
    final elapsedText = _formatHms(elapsed);

    final Color tone;
    final String stateLabel;
    if (done) {
      tone = semantic.success.base;
      stateLabel = '';
    } else if (running) {
      tone = colors.primary;
      stateLabel = t.techDetailElapsed;
    } else if (held) {
      tone = semantic.warning.base;
      stateLabel = t.techDetailPaused;
    } else {
      tone = colors.onSurfaceVariant;
      stateLabel = '';
    }

    return Semantics(
      container: true,
      label: done
          ? '${task.startTime} – ${task.endTime ?? ''}'
          : running
          ? '${t.techDetailElapsed} $elapsedText'
          : '${t.techDetailPaused}, ${task.startTime}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (running || held) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppDimensions.s6),
          ],
          if (stateLabel.isNotEmpty) ...[
            // C16: localized "Elapsed"/"Paused" verbatim — never uppercased.
            Text(
              stateLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tone,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: AppDimensions.s6),
          ],
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              done
                  ? '${task.startTime} – ${task.endTime ?? ''}'
                  : running
                  ? elapsedText
                  : task.startTime ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.mono(color: colors.onSurface).copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wall-clock elapsed since today's `HH:mm` start. Clamped at zero so a
/// future-dated stamp (clock skew, midnight rollover) never shows negative.
Duration _elapsedSince(String startHm) {
  final parts = startHm.split(':');
  if (parts.length != 2) return Duration.zero;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return Duration.zero;
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day, hour, minute);
  final diff = now.difference(start);
  return diff.isNegative ? Duration.zero : diff;
}

String _formatHms(Duration elapsed) {
  final h = elapsed.inHours;
  final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}
