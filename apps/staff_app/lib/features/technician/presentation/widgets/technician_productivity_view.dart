import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Technician Productivity — "what work have I completed / progressed through?".
///
/// Phase 10 composition: the dossier keeps real counts (repairs completed,
/// queue breakdown, shift record). On top, a workshop-figures strip renders
/// ONLY when the backend actually returned productivity figures (the same
/// condition the provider uses to adopt them): efficiency ratio, today's
/// progress bar and delayed-job attention. No history endpoint exists, so
/// there are no week bars and no deltas — a delta without history would be
/// fabricated. With no server figures and no loaded work, the honest empty
/// state shows instead.
class TechnicianProductivityView extends ConsumerWidget {
  const TechnicianProductivityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    ref.watch(technicianRefreshProvider);
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final jobs = notifier.allJobs;
    final tasks = notifier.allTasks;
    final tasksCompleted = tasks
        .where((entry) => entry.task.status == TaskStatus.completed)
        .length;
    final completedToday = notifier.productivity.completedToday;

    final firstLoadError =
        jobs.isEmpty && !state.isLoading && state.dashboardError.isNotEmpty;
    final showSkeleton = state.isLoading && jobs.isEmpty;
    final empty = jobs.isEmpty && completedToday == 0 && !state.isLoading;

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              title: t.techProdTitle,
              subtitle: t.techProdToday,
            ),
            const SizedBox(height: AppDimensions.s16),
            if (showSkeleton)
              const _ProductivitySkeleton()
            else if (firstLoadError)
              Semantics(
                liveRegion: true,
                child: EmptyState.error(
                  message: t.techProdLoadError,
                  onRetry: notifier.refresh,
                ),
              )
            else if (empty)
              EmptyState(
                icon: Icons.insights_outlined,
                title: t.techProdEmpty,
                message: t.techProdEmptyHint,
              )
            else ...[
              if (state.dashboardError.isNotEmpty) ...[
                _OfflineNotice(message: state.dashboardError),
                const SizedBox(height: AppDimensions.s16),
              ],
              if (_hasServerFigures(notifier)) ...[
                if (notifier.delayedJobs > 0) ...[
                  _DelayedAttention(count: notifier.delayedJobs),
                  const SizedBox(height: AppDimensions.s16),
                ],
                _WorkshopFiguresStrip(
                  completedToday: completedToday,
                  assigned: notifier.productivity.assignedJobs,
                  efficiency: notifier.productivity.efficiency,
                  avgTimePerJob: notifier.productivity.avgTimePerJob,
                  totalHoursWorked: notifier.productivity.totalHoursWorked,
                ),
                const SizedBox(height: AppDimensions.s20),
              ] else if (notifier.delayedJobs > 0) ...[
                _DelayedAttention(count: notifier.delayedJobs),
                const SizedBox(height: AppDimensions.s20),
              ],
              AppSplitView(
                primaryFlex: 3,
                secondaryFlex: 2,
                spacing: AppDimensions.s24,
                primary: _SummaryColumn(
                  tasksCompleted: tasksCompleted,
                  tasksTotal: tasks.length,
                  completedToday: completedToday,
                  jobs: jobs,
                ),
                secondary: _ShiftColumn(
                  status: state.attendanceStatus,
                  summary: state.attendanceSummary,
                  notifier: notifier,
                  onPunchIn: notifier.punchIn,
                  onStartBreak: notifier.startBreak,
                  onEndBreak: notifier.endBreak,
                  onPunchOut: notifier.punchOut,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Figure content only — not the bare assigned count, which harnesses and
  /// empty responses also carry. The strip renders exclusively from
  /// backend-returned figures, so a no-data pump stays a counts-only page.
  bool _hasServerFigures(TechnicianNotifier notifier) {
    final prod = notifier.productivity;
    return prod.efficiency > 0 ||
        prod.totalHoursWorked.isNotEmpty ||
        prod.avgTimePerJob.isNotEmpty;
  }
}

/// Workshop-figures strip (TrendStat grammar: eyebrow + big tabular value +
/// tone chip + progress bar + supporting lines). Rendered only with
/// backend-returned figures — never synthesized.
class _WorkshopFiguresStrip extends StatelessWidget {
  final int completedToday;
  final int assigned;
  final double efficiency;
  final String avgTimePerJob;
  final String totalHoursWorked;

  const _WorkshopFiguresStrip({
    required this.completedToday,
    required this.assigned,
    required this.efficiency,
    required this.avgTimePerJob,
    required this.totalHoursWorked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final percent = _efficiencyPercent(efficiency);
    final progress = assigned <= 0
        ? 0.0
        : (completedToday / assigned).clamp(0.0, 1.0);

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // C16: sentence-case ARB copy verbatim — never uppercased.
            t.techProdFigures,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppDimensions.s10),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$percent%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                height: 1,
                fontFeatures: const [
                  FontFeature.tabularFigures(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            t.techProdEfficiency,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.s14),
          AppLinearProgress(
            value: progress,
            label: t.techProdDayProgress,
            showPercentage: true,
          ),
          if (avgTimePerJob.isNotEmpty || totalHoursWorked.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Row(
              children: [
                if (totalHoursWorked.isNotEmpty)
                  Expanded(
                    child: _FigureLine(
                      label: t.techProdHoursLogged,
                      value: totalHoursWorked,
                    ),
                  ),
                if (avgTimePerJob.isNotEmpty)
                  Expanded(
                    child: _FigureLine(
                      label: t.techProdTimePerRepair,
                      value: avgTimePerJob,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int _efficiencyPercent(double value) {
    if (value <= 0) return 0;
    if (value <= 1.0) return (value * 100).round();
    return value.round().clamp(0, 100);
  }
}

class _FigureLine extends StatelessWidget {
  final String label;
  final String value;

  const _FigureLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Amber attention row for delayed work when no server strip is shown.
class _DelayedAttention extends StatelessWidget {
  final int count;
  const _DelayedAttention({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s12,
        ),
        decoration: BoxDecoration(
          color: semantic.warning.subtle,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: semantic.warning.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: AppDimensions.iconMd,
              color: semantic.warning.base,
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                t.techProdDelayedAlert(count),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: semantic.warning.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final int tasksCompleted;
  final int tasksTotal;
  final int completedToday;
  final List<TechnicianJobEntity> jobs;

  const _SummaryColumn({
    required this.tasksCompleted,
    required this.tasksTotal,
    required this.completedToday,
    required this.jobs,
  });

  int _count(TechJobStatus status) =>
      jobs.where((job) => job.status == status).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.s18),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.techProdWorkDone,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppDimensions.s10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$completedToday',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                completedToday == 1
                    ? t.techProdRepairOne
                    : t.techProdRepairMany,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (tasksTotal > 0) ...[
                const SizedBox(height: AppDimensions.s16),
                AppLinearProgress(
                  value: tasksCompleted / tasksTotal,
                  label: t.techTodayProgress(tasksCompleted, tasksTotal),
                ),
              ] else ...[
                const SizedBox(height: AppDimensions.s12),
                Text(
                  t.techProdNoTasks,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s20),
        SectionHeader(
          title: t.techProdAssigned(jobs.length),
          subtitle: t.techProdQueue,
        ),
        const SizedBox(height: AppDimensions.s12),
        _BreakdownRow(
          label: t.techProdInProgress,
          count: _count(TechJobStatus.inProgress),
        ),
        _BreakdownRow(
          label: t.techProdPending,
          count: _count(TechJobStatus.pending),
        ),
        _BreakdownRow(
          label: t.techProdDelayed,
          count: _count(TechJobStatus.delayed),
        ),
        _BreakdownRow(
          label: t.techProdQc,
          count: _count(TechJobStatus.qcReview),
        ),
        _BreakdownRow(
          label: t.techProdCompleted,
          count: _count(TechJobStatus.completed),
        ),
      ],
    );
  }
}

/// One real status count. The label always carries the meaning, so the state is
/// never conveyed by colour alone.
class _BreakdownRow extends StatelessWidget {
  final String label;
  final int count;

  const _BreakdownRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.s8),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s14,
        vertical: AppDimensions.s12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '$count',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact shift context with the real punch record and clock controls.
class _ShiftColumn extends StatelessWidget {
  final AttendanceStatus status;
  final AttendanceSummaryEntity summary;
  final TechnicianNotifier notifier;
  final VoidCallback onPunchIn;
  final VoidCallback onStartBreak;
  final VoidCallback onEndBreak;
  final VoidCallback onPunchOut;

  const _ShiftColumn({
    required this.status,
    required this.summary,
    required this.notifier,
    required this.onPunchIn,
    required this.onStartBreak,
    required this.onEndBreak,
    required this.onPunchOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: _attendanceLabel(t, status),
          subtitle: t.techProdShift,
        ),
        const SizedBox(height: AppDimensions.s12),
        Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShiftLine(
                icon: Icons.login_rounded,
                label: t.techProdClockedIn,
                value: summary.punchIn,
              ),
              _ShiftLine(
                icon: Icons.coffee_outlined,
                label: t.techProdBreakTaken,
                value: summary.breakTime,
              ),
              _ShiftLine(
                icon: Icons.timelapse_rounded,
                label: t.techProdNetHours,
                value: summary.workHours,
              ),
              _ShiftLine(
                icon: Icons.logout_rounded,
                label: t.techProdClockedOut,
                value: summary.punchOut,
              ),
              const SizedBox(height: AppDimensions.s12),
              ..._punchControls(context),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _punchControls(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    Widget wrap(
      VoidCallback onPressed,
      IconData icon,
      String label, {
      bool filled = true,
    }) {
      return SizedBox(
        height: AppDimensions.touchTarget,
        child: filled
            ? FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                },
                icon: Icon(icon, size: 18),
                label: Text(label),
              )
            : OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                },
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                ),
              ),
      );
    }

    switch (status) {
      case AttendanceStatus.notPunchedIn:
        return [wrap(onPunchIn, Icons.fingerprint_rounded, t.techShiftStart)];
      case AttendanceStatus.working:
        return [
          wrap(
            onStartBreak,
            Icons.coffee_rounded,
            t.techShiftBreak,
            filled: false,
          ),
          const SizedBox(height: AppDimensions.s8),
          wrap(onPunchOut, Icons.logout_rounded, t.techShiftEnd),
        ];
      case AttendanceStatus.onBreak:
        return [wrap(onEndBreak, Icons.play_arrow_rounded, t.techShiftResume)];
      case AttendanceStatus.punchedOut:
        return [
          Text(
            t.techProdShiftDone,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ];
    }
  }
}

class _ShiftLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ShiftLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.s6),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSm,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value.isEmpty ? '--:--' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _attendanceLabel(StaffLocalizations t, AttendanceStatus status) =>
    switch (status) {
      AttendanceStatus.working => t.techAttendanceWorking,
      AttendanceStatus.onBreak => t.techAttendanceOnBreak,
      AttendanceStatus.notPunchedIn => t.techAttendanceNotPunchedIn,
      AttendanceStatus.punchedOut => t.techAttendancePunchedOut,
    };

class _OfflineNotice extends StatelessWidget {
  final String message;

  const _OfflineNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.s12),
        decoration: BoxDecoration(
          color: colors.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.onTertiaryContainer),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductivitySkeleton extends StatelessWidget {
  const _ProductivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeleton.card(height: 150),
        SizedBox(height: AppDimensions.s20),
        AppSkeleton.card(height: 52),
        SizedBox(height: AppDimensions.s8),
        AppSkeleton.card(height: 52),
        SizedBox(height: AppDimensions.s8),
        AppSkeleton.card(height: 52),
      ],
    );
  }
}
