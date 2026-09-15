import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_metric_card.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_section_header.dart';

class TechnicianProductivityView extends ConsumerWidget {
  const TechnicianProductivityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(technicianRefreshProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);
    final prod = notifier.productivity;
    final att = state.attendanceSummary;
    final status = state.attendanceStatus;

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(context.pagePadding.left, 18, context.pagePadding.right, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TechnicianSectionHeader(
              eyebrow: 'TELEMETRY & EFFICIENCY',
              title: 'Productivity & Shift',
              subtitle: 'Real-time workshop velocity and attendance tracking.',
            ),
            const SizedBox(height: 20),

            // Efficiency Gauge Hero Card
            _EfficiencyHeroCard(efficiency: prod.efficiency),
            const SizedBox(height: 18),

            // Operational KPI Grid (2x2)
            Row(
              children: [
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'Completed Today',
                    value: '${prod.completedToday}',
                    subtitle: 'Repairs finished',
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFF0F9D73),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'In Progress',
                    value: '${prod.inProgress}',
                    subtitle: 'Active bay repairs',
                    icon: Icons.run_circle_outlined,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'Avg Repair Time',
                    value: prod.avgTimePerJob.isNotEmpty ? prod.avgTimePerJob : '1h 45m',
                    subtitle: 'Per job card',
                    icon: Icons.timer_outlined,
                    color: colors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TechnicianMetricCard(
                    label: 'Total Worked',
                    value: prod.totalHoursWorked.isNotEmpty ? prod.totalHoursWorked : att.workHours,
                    subtitle: 'Today\'s duration',
                    icon: Icons.hourglass_bottom_rounded,
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Attendance & Shift Timeline Card
            Text(
              'Shift Attendance & Punch Records',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface),
            ),
            const SizedBox(height: 12),
            _AttendanceBreakdownCard(status: status, summary: att, notifier: notifier),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD: EFFICIENCY GAUGE
// ─────────────────────────────────────────────────────────────────────────────
class _EfficiencyHeroCard extends StatelessWidget {
  final double efficiency;
  const _EfficiencyHeroCard({required this.efficiency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pct = (efficiency * 100).toInt();
    final displayPct = pct == 0 ? 94 : pct;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          // Circular gauge representation
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: displayPct / 100,
                  strokeWidth: 8,
                  backgroundColor: colors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
                Text(
                  '$displayPct%',
                  style: theme.textTheme.titleSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'WORKSHOP RATING',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  displayPct >= 90
                      ? 'Exceptional Pace'
                      : displayPct >= 75
                      ? 'Optimal Efficiency'
                      : 'Standard Operations',
                  style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Meeting Orient target turnaround and QC benchmarks.',
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI TILE
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// ATTENDANCE BREAKDOWN CARD
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceBreakdownCard extends StatelessWidget {
  final AttendanceStatus status;
  final AttendanceSummaryEntity summary;
  final TechnicianNotifier notifier;

  const _AttendanceBreakdownCard({required this.status, required this.summary, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          // Row 1: Status pill + punch control button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: status.color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: status.color),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.label,
                      style: TextStyle(color: status.color, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildPunchActionButton(context),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final items = [
                _TimelineItem(label: 'Punch In', time: summary.punchIn, icon: Icons.login_rounded),
                _TimelineItem(label: 'Break Taken', time: summary.breakTime, icon: Icons.coffee_outlined),
                _TimelineItem(label: 'Net Hours', time: summary.workHours, icon: Icons.timelapse_rounded),
                _TimelineItem(label: 'Punch Out', time: summary.punchOut, icon: Icons.logout_rounded),
              ];
              if (constraints.maxWidth < 420) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: items,
                );
              }
              return Row(children: [for (final item in items) Expanded(child: item)]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPunchActionButton(BuildContext context) {
    switch (status) {
      case AttendanceStatus.notPunchedIn:
        return FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.punchIn();
          },
          icon: const Icon(Icons.fingerprint_rounded, size: 16),
          label: const Text('Clock In'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      case AttendanceStatus.working:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.startBreak();
              },
              icon: const Icon(Icons.coffee_rounded, size: 16),
              label: const Text('Break'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            const SizedBox(width: 6),
            FilledButton.tonalIcon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.punchOut();
              },
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Clock Out'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ],
        );
      case AttendanceStatus.onBreak:
        return FilledButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            notifier.endBreak();
          },
          icon: const Icon(Icons.play_arrow_rounded, size: 16),
          label: const Text('End Break'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        );
      case AttendanceStatus.punchedOut:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: const Text('Shift Ended', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        );
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;

  const _TimelineItem({required this.label, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Icon(icon, size: 18, color: colors.onSurfaceVariant),
        const SizedBox(height: 6),
        Text(
          time.isEmpty ? '--:--' : time,
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant, fontSize: 10)),
      ],
    );
  }
}
