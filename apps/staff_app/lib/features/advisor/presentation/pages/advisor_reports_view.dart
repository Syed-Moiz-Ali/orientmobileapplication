import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';

class AdvisorReportsView extends ConsumerWidget {
  const AdvisorReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final report = ref.watch(advisorReportDataProvider);
    final data = report.value ?? const AdvisorReportData();
    final range = ref.watch(advisorReportRangeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          onRefresh: () async =>
              ref.read(advisorRefreshProvider.notifier).state++,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, range, ref),
                if (report.isLoading) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(minHeight: 3),
                ],
                if (report.hasError) ...[
                  const SizedBox(height: 18),
                  _ReportNotice(
                    onRetry: () => ref.invalidate(advisorReportDataProvider),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  _summaryRow(context, data),
                  const SizedBox(height: 28),
                  _sectionLabel(context, 'Throughput Analytics'),
                  const SizedBox(height: 12),
                  _barChartSection(context, data),
                  const SizedBox(height: 28),
                  _sectionLabel(context, 'Status Allocation'),
                  const SizedBox(height: 12),
                  _pieChartSection(context, data),
                  const SizedBox(height: 32),
                  _exportButton(context, data),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ReportRange range, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Advisor Analytics',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReportRange>(
              value: range,
              dropdownColor: colorScheme.surface,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              items: const [
                DropdownMenuItem(
                  value: ReportRange.today,
                  child: Text('Today'),
                ),
                DropdownMenuItem(
                  value: ReportRange.week,
                  child: Text('This Week'),
                ),
                DropdownMenuItem(
                  value: ReportRange.month,
                  child: Text('This Month'),
                ),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(advisorReportRangeProvider.notifier).state = v;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(BuildContext context, AdvisorReportData data) {
    final colorScheme = Theme.of(context).colorScheme;

    final cards = [
      _summaryCard(
        context,
        'Total jobs',
        '${data.totalJobs}',
        colorScheme.primary,
        Icons.assignment_outlined,
      ),
      _summaryCard(
        context,
        'Completed',
        '${data.completedJobs}',
        const Color(0xFF10B981),
        Icons.verified_outlined,
      ),
      _summaryCard(
        context,
        'In progress',
        '${data.inProgressJobs}',
        colorScheme.secondary,
        Icons.build_circle_outlined,
      ),
      _summaryCard(
        context,
        'Cancelled',
        '${data.cancelledJobs}',
        colorScheme.error,
        Icons.cancel_outlined,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        crossAxisCount: constraints.maxWidth >= 640 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: constraints.maxWidth >= 640 ? 1.25 : 1.55,
        children: cards,
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 18,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _pieChartSection(BuildContext context, AdvisorReportData data) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = data.statusBreakdown.fold<int>(0, (s, e) => s + e.count);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: data.statusBreakdown.map((s) {
                  final p = total > 0 ? s.count / total : 0.0;
                  return PieChartSectionData(
                    value: p * 100,
                    color: s.color,
                    radius: 26,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: data.statusBreakdown.map((s) {
                final p = total > 0 ? s.count / total * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${s.count} (${p.round()}%)',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
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

  Widget _barChartSection(BuildContext context, AdvisorReportData data) {
    final colorScheme = Theme.of(context).colorScheme;
    final activity = data.weeklyActivity;
    final maxVal = activity.isEmpty ? 1 : activity.reduce(max);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SizedBox(
        height: 160,
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
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data.weekLabels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: activity.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.toDouble(),
                    color: colorScheme.primary,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _exportButton(BuildContext context, AdvisorReportData data) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _exportCsv(context, data),
        icon: const Icon(Icons.download_rounded, size: 18),
        label: const Text(
          'Export Telemetry Report',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
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

class _ReportNotice extends StatelessWidget {
  final VoidCallback onRetry;

  const _ReportNotice({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Report data is unavailable right now. Your job data has not been replaced with zeros.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Retry',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
