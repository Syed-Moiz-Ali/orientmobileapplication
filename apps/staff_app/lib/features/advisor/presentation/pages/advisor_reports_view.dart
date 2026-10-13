import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Reports tab: range control, hero metric strip, activity and distribution
/// charts, and export — all on the shared chart language.
class AdvisorReportsView extends ConsumerWidget {
  const AdvisorReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    final report = ref.watch(advisorReportDataProvider);
    final data = report.value ?? const AdvisorReportData();
    final range = ref.watch(advisorReportRangeProvider);

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          context.pagePadding.top,
          context.pagePadding.right,
          100,
        ),
        children: [
          Text(
            t.advisorReportsTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          SegmentedButton<ReportRange>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ReportRange.today,
                label: Text(t.advisorRangeToday),
              ),
              ButtonSegment(
                value: ReportRange.week,
                label: Text(t.advisorRangeWeek),
              ),
              ButtonSegment(
                value: ReportRange.month,
                label: Text(t.advisorRangeMonth),
              ),
            ],
            selected: {range},
            onSelectionChanged: (s) =>
                ref.read(advisorReportRangeProvider.notifier).state = s.first,
          ),
          if (report.isLoading) ...[
            const SizedBox(height: AppDimensions.s16),
            const AppSkeleton.chart(height: 200),
          ],
          if (report.hasError) ...[
            const SizedBox(height: AppDimensions.s20),
            AppInfoPanel.danger(
              message: t.advisorReportUnavailable,
              action: TextButton(
                onPressed: () => ref.invalidate(advisorReportDataProvider),
                child: Text(t.advisorActionRefreshJobCard),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppDimensions.s20),
            _summaryStrip(context, t, data),
            const SizedBox(height: AppDimensions.s28),
            SectionHeader(
              title: t.advisorJobActivity,
              leadingIcon: Icons.bar_chart_rounded,
            ),
            _barChartSection(context, t, data),
            const SizedBox(height: AppDimensions.s28),
            SectionHeader(
              title: t.advisorStatusAllocation,
              leadingIcon: Icons.pie_chart_outline_rounded,
            ),
            _distributionSection(context, t, data),
            const SizedBox(height: AppDimensions.s32),
            PrimaryButton(
              label: t.advisorExportCsv,
              icon: Icons.download_rounded,
              onPressed: () => _exportCsv(context, data),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryStrip(
    BuildContext context,
    StaffLocalizations t,
    AdvisorReportData data,
  ) {
    final tiles = <Widget>[
      AppKpiCard.compact(
        label: t.advisorReportTotalJobs,
        value: '${data.totalJobs}',
        icon: Icons.assignment_outlined,
      ),
      AppKpiCard.compact(
        label: t.advisorReportCompleted,
        value: '${data.completedJobs}',
        icon: Icons.verified_outlined,
        semanticState: KpiSemanticState.success,
      ),
      AppKpiCard.compact(
        label: t.advisorReportInProgress,
        value: '${data.inProgressJobs}',
        icon: Icons.build_circle_outlined,
        semanticState: KpiSemanticState.info,
      ),
      AppKpiCard.compact(
        label: t.advisorReportCancelled,
        value: '${data.cancelledJobs}',
        icon: Icons.cancel_outlined,
        semanticState: KpiSemanticState.danger,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppDimensions.cardGap;
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }

  Widget _barChartSection(
    BuildContext context,
    StaffLocalizations t,
    AdvisorReportData data,
  ) {
    final chart = AppChartTheme.of(context);
    final activity = data.weeklyActivity;
    final hasData = activity.any((v) => v > 0);
    if (!hasData) {
      return AppCard.standard(
        child: AppChartPlaceholder(title: t.advisorJobActivity, height: 180),
      );
    }
    final maxVal = activity.reduce(max);

    return AppCard.standard(
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxVal * 1.2).ceilToDouble(),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.weekLabels.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.s8),
                      child: Text(
                        data.weekLabels[i],
                        style: chart.axisLabelStyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: chart.gridlineColor,
                strokeWidth: chart.gridlineWidth,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: activity.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.toDouble(),
                    color: chart.palette.first,
                    width: 14,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _distributionSection(
    BuildContext context,
    StaffLocalizations t,
    AdvisorReportData data,
  ) {
    final chart = AppChartTheme.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final total = data.statusBreakdown.fold<int>(0, (s, e) => s + e.count);
    if (data.statusBreakdown.isEmpty || total == 0) {
      return AppCard.standard(
        child: AppChartPlaceholder(
          title: t.advisorStatusAllocation,
          height: 180,
        ),
      );
    }

    return AppCard.standard(
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: data.statusBreakdown.asMap().entries.map((e) {
                  final p = total > 0 ? e.value.count / total : 0.0;
                  return PieChartSectionData(
                    value: p * 100,
                    color: chart.seriesColor(e.key),
                    radius: 26,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s18),
          Expanded(
            child: Column(
              children: data.statusBreakdown.asMap().entries.map((e) {
                final s = e.value;
                final p = total > 0 ? s.count / total * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.s6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: chart.seriesColor(e.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s8),
                      Expanded(
                        child: Text(
                          s.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${s.count} (${p.round()}%)',
                        style: AppTextStyles.mono(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, AdvisorReportData data) async {
    final buffer = StringBuffer()
      ..writeln('Status,Count')
      ..writeln('Total Jobs,${data.totalJobs}')
      ..writeln('Completed,${data.completedJobs}')
      ..writeln('In Progress,${data.inProgressJobs}')
      ..writeln('Cancelled,${data.cancelledJobs}');
    await Share.share(buffer.toString(), subject: 'Advisor Report');
  }
}
