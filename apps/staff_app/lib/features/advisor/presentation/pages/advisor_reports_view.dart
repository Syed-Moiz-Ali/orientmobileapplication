import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';

class AdvisorReportsView extends ConsumerWidget {
  const AdvisorReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(advisorReportDataProvider);
    final data = dataAsync.value ?? const AdvisorReportData();
    final range = ref.watch(advisorReportRangeProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async {
            ref.read(advisorRefreshProvider.notifier).state++;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, range, ref),
                const SizedBox(height: 20),
                _summaryRow(data),
                const SizedBox(height: 24),
                _sectionLabel('Job Status Breakdown'),
                const SizedBox(height: 12),
                _pieChartSection(data),
                const SizedBox(height: 24),
                _sectionLabel('Weekly Activity'),
                const SizedBox(height: 12),
                _barChartSection(data),
                const SizedBox(height: 24),
                _sectionLabel('Status Summary'),
                const SizedBox(height: 12),
                _statusList(data),
                const SizedBox(height: 24),
                _exportButton(context, data),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ReportRange range, WidgetRef ref) {
    return Row(
      children: [
        const Text(
          'Reports',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.r10),
            border: Border.all(color: AppColors.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ReportRange>(
              value: range,
              isDense: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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

  Widget _summaryRow(AdvisorReportData data) {
    return Row(
      children: [
        _summaryCard(
          'Total Jobs',
          '${data.totalJobs}',
          AppColors.accent,
          AppColors.accent.withValues(alpha: 0.12),
          Icons.assignment_outlined,
        ),
        const SizedBox(width: 8),
        _summaryCard(
          'Completed',
          '${data.completedJobs}',
          AppColors.success,
          AppColors.successBg,
          Icons.verified_outlined,
        ),
        const SizedBox(width: 8),
        _summaryCard(
          'In Progress',
          '${data.inProgressJobs}',
          AppColors.warning,
          AppColors.warningBg,
          Icons.build_circle_outlined,
        ),
        const SizedBox(width: 8),
        _summaryCard(
          'Cancelled',
          '${data.cancelledJobs}',
          AppColors.danger,
          AppColors.dangerBg,
          Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    String count,
    Color color,
    Color bg,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppDimensions.r7),
              ),
              child: Center(child: Icon(icon, size: 14, color: color)),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.text3,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppDimensions.r2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _pieChartSection(AdvisorReportData data) {
    final total = data.statusBreakdown.fold<int>(0, (s, e) => s + e.count);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                startDegreeOffset: -90,
                sections: data.statusBreakdown.map((s) {
                  final p = total > 0 ? s.count / total : 0.0;
                  return PieChartSectionData(
                    value: p * 100,
                    color: s.color,
                    radius: p > 0.15 ? 34 : 28,
                    title: p > 0.08 ? '${(p * 100).round()}%' : '',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.statusBreakdown.map((s) {
                final p = total > 0 ? s.count / total * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(AppDimensions.r3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                      Text(
                        '${s.count} (${p.round()}%)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3,
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

  Widget _barChartSection(AdvisorReportData data) {
    final activity = data.weeklyActivity;
    final maxVal = activity.isEmpty ? 1 : activity.reduce(max);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.line),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxVal * 1.3).ceilToDouble(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (g, gs, b, bi) => null,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.text3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text3,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: (maxVal * 1.3 / 4).ceilToDouble().clamp(
                1,
                double.infinity,
              ),
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.line, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.weeklyActivity
                .asMap()
                .entries
                .map(
                  (e) => BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: AppColors.accent,
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _statusList(AdvisorReportData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _statusRow(
            'Total Jobs',
            '${data.totalJobs}',
            AppColors.textPrimary,
            Icons.assignment_outlined,
            AppColors.gray100,
          ),
          _divider(),
          _statusRow(
            'In Progress',
            '${data.inProgressJobs}',
            AppColors.accent,
            Icons.build_circle_outlined,
            AppColors.accent.withValues(alpha: 0.1),
          ),
          _divider(),
          _statusRow(
            'Pending',
            '${data.pendingJobs}',
            AppColors.warning,
            Icons.hourglass_empty,
            AppColors.warningBg,
          ),
          _divider(),
          _statusRow(
            'Completed',
            '${data.completedJobs}',
            AppColors.success,
            Icons.verified_outlined,
            AppColors.successBg,
          ),
          _divider(),
          _statusRow(
            'Cancelled',
            '${data.cancelledJobs}',
            AppColors.danger,
            Icons.cancel_outlined,
            AppColors.dangerBg,
          ),
        ],
      ),
    );
  }

  Widget _statusRow(
    String label,
    String count,
    Color color,
    IconData icon,
    Color bg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.rPill),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    color: AppColors.line,
    indent: 16,
    endIndent: 16,
  );

  Widget _exportButton(BuildContext context, AdvisorReportData data) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _exportCsv(context, data),
        icon: const Icon(Icons.download_rounded, size: 20),
        label: const Text(
          'Export Report',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.r14),
          ),
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, AdvisorReportData data) async {
    final buffer = StringBuffer()
      ..writeln('Status,Count')
      ..writeln('Total Jobs,${data.totalJobs}')
      ..writeln('In Progress,${data.inProgressJobs}')
      ..writeln('Pending,${data.pendingJobs}')
      ..writeln('Completed,${data.completedJobs}')
      ..writeln('Cancelled,${data.cancelledJobs}')
      ..writeln()
      ..writeln('Day,Activity');
    for (var i = 0; i < data.weeklyActivity.length; i++) {
      final label = i < data.weekLabels.length
          ? data.weekLabels[i]
          : 'Day ${i + 1}';
      buffer.writeln('$label,${data.weeklyActivity[i]}');
    }
    try {
      await Share.share(buffer.toString(), subject: 'Advisor Report');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export failed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
