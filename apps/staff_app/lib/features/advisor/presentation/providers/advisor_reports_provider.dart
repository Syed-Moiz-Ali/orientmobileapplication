import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';

enum ReportRange { today, week, month }

class StatusCount {
  final String label;
  final int count;
  final Color color;
  const StatusCount(this.label, this.count, this.color);
}

class AdvisorReportData {
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;
  final int inProgressJobs;
  final int cancelledJobs;
  final double avgCompletionTime;
  final List<StatusCount> statusBreakdown;
  final List<int> weeklyActivity;
  final List<String> weekLabels;

  const AdvisorReportData({
    this.totalJobs = 0,
    this.completedJobs = 0,
    this.pendingJobs = 0,
    this.inProgressJobs = 0,
    this.cancelledJobs = 0,
    this.avgCompletionTime = 0,
    this.statusBreakdown = const [],
    this.weeklyActivity = const [],
    this.weekLabels = const [],
  });
}

final advisorReportRangeProvider = StateProvider<ReportRange>(
  (ref) => ReportRange.week,
);

/// Report data loaded from the backend (ReportResponse). Falls back to empty
/// data on failure — never fabricated numbers.
final advisorReportDataProvider = FutureProvider<AdvisorReportData>((
  ref,
) async {
  ref.watch(advisorRefreshProvider);
  ref.watch(advisorReportRangeProvider);
  final range = ref.watch(advisorReportRangeProvider);
  final remote = ref.read(advisorRemoteDataSourceProvider);
  try {
    final r = await remote.getReports(_rangeParam(range));
    return AdvisorReportData(
      totalJobs: r.totalJobs,
      completedJobs: r.completedJobs,
      pendingJobs:
          r.totalJobs - r.completedJobs - r.inProgressJobs - r.cancelledJobs,
      inProgressJobs: r.inProgressJobs,
      cancelledJobs: r.cancelledJobs,
      statusBreakdown: [
        StatusCount('Completed', r.completedJobs, const Color(0xFF16A34A)),
        StatusCount('In Progress', r.inProgressJobs, const Color(0xFF1B9AAA)),
        StatusCount('Cancelled', r.cancelledJobs, const Color(0xFFDC2626)),
      ],
      weeklyActivity: r.weeklyActivity.map((w) => w.count).toList(),
      weekLabels: r.weeklyActivity.map((w) => w.day).toList(),
    );
  } catch (_) {
    return const AdvisorReportData();
  }
});

String _rangeParam(ReportRange range) {
  switch (range) {
    case ReportRange.today:
      return 'today';
    case ReportRange.week:
      return 'week';
    case ReportRange.month:
      return 'month';
  }
}
