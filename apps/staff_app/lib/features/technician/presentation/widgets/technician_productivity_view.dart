import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';

/// Technician Productivity — "what work have I completed / progressed through?".
///
/// Every figure is a real count from the technician's loaded work or the
/// workshop's own today figure: no efficiency score, ranking, target, average
/// repair time or chart, because the loaded data cannot honestly produce them.
class TechnicianProductivityView extends ConsumerWidget {
  const TechnicianProductivityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final summary = _SummaryColumn(
      tasksCompleted: tasksCompleted,
      tasksTotal: tasks.length,
      completedToday: completedToday,
      jobs: jobs,
    );
    final shift = _ShiftColumn(
      status: state.attendanceStatus,
      summary: state.attendanceSummary,
      notifier: notifier,
      onPunchIn: notifier.punchIn,
      onStartBreak: notifier.startBreak,
      onEndBreak: notifier.endBreak,
      onPunchOut: notifier.punchOut,
    );

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        maxContentWidth: 1180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: "Today's productivity",
              subtitle: 'TODAY',
            ),
            const SizedBox(height: AppDimensions.s16),
            if (showSkeleton)
              const _ProductivitySkeleton()
            else if (firstLoadError)
              Semantics(
                liveRegion: true,
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: "We couldn't load your productivity",
                  message: 'Check your connection and try again.',
                  actionLabel: 'Retry',
                  onAction: notifier.refresh,
                ),
              )
            else if (empty)
              const EmptyState(
                icon: Icons.insights_outlined,
                title: 'No productivity data yet',
                message:
                    'Completed work will appear here as you progress through '
                    'your assigned jobs.',
              )
            else ...[
              if (state.dashboardError.isNotEmpty) ...[
                _OfflineNotice(message: state.dashboardError),
                const SizedBox(height: AppDimensions.s16),
              ],
              AppSplitView(
                primaryFlex: 3,
                secondaryFlex: 2,
                spacing: AppDimensions.s24,
                primary: summary,
                secondary: shift,
              ),
            ],
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
                'WORK COMPLETED',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppDimensions.s10),
              Text(
                '$completedToday',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppDimensions.r4),
              Text(
                completedToday == 1
                    ? 'repair completed today'
                    : 'repairs completed today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (tasksTotal > 0) ...[
                const SizedBox(height: AppDimensions.s16),
                AppLinearProgress(
                  value: tasksCompleted / tasksTotal,
                  label: '$tasksCompleted of $tasksTotal tasks completed',
                ),
              ] else ...[
                const SizedBox(height: AppDimensions.s12),
                Text(
                  'No tasks recorded in your loaded work.',
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
          title: '${jobs.length} assigned',
          subtitle: 'YOUR QUEUE',
        ),
        const SizedBox(height: AppDimensions.s12),
        _BreakdownRow(
          label: 'In progress',
          count: _count(TechJobStatus.inProgress),
        ),
        _BreakdownRow(label: 'Pending', count: _count(TechJobStatus.pending)),
        _BreakdownRow(label: 'Delayed', count: _count(TechJobStatus.delayed)),
        _BreakdownRow(
          label: 'QC review',
          count: _count(TechJobStatus.qcReview),
        ),
        _BreakdownRow(
          label: 'Completed',
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
          Text(
            '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: status.label, subtitle: 'SHIFT'),
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
                label: 'Clocked in',
                value: summary.punchIn,
              ),
              _ShiftLine(
                icon: Icons.coffee_outlined,
                label: 'Break taken',
                value: summary.breakTime,
              ),
              _ShiftLine(
                icon: Icons.timelapse_rounded,
                label: 'Net hours',
                value: summary.workHours,
              ),
              _ShiftLine(
                icon: Icons.logout_rounded,
                label: 'Clocked out',
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
        return [wrap(onPunchIn, Icons.fingerprint_rounded, 'Start shift')];
      case AttendanceStatus.working:
        return [
          wrap(onStartBreak, Icons.coffee_rounded, 'Take break', filled: false),
          const SizedBox(height: AppDimensions.s8),
          wrap(onPunchOut, Icons.logout_rounded, 'End shift'),
        ];
      case AttendanceStatus.onBreak:
        return [wrap(onEndBreak, Icons.play_arrow_rounded, 'Resume shift')];
      case AttendanceStatus.punchedOut:
        return [
          Text(
            'Shift complete for today.',
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
          Text(
            value.isEmpty ? '--:--' : value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
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
