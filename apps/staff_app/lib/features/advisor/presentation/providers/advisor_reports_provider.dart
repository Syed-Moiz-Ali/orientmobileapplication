import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
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

final advisorReportRangeProvider = StateProvider<ReportRange>((ref) => ReportRange.week);

final advisorReportDataProvider = Provider<AdvisorReportData>((ref) {
  ref.watch(advisorRefreshProvider);
  ref.watch(advisorReportRangeProvider);

  final box = Hive.box<dynamic>('inspections');
  final allData = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  final jobData = allData.where((m) => m['type'] == 'vehicle_customer').toList();

  if (jobData.isEmpty) {
    return AdvisorReportData(
      totalJobs: 3,
      completedJobs: 1,
      pendingJobs: 1,
      inProgressJobs: 1,
      statusBreakdown: [
        StatusCount('In Progress', 1, const Color(0xFF1B9AAA)),
        StatusCount('Pending', 1, const Color(0xFFD97706)),
        StatusCount('Completed', 1, const Color(0xFF16A34A)),
      ],
      weeklyActivity: [4, 6, 3, 7, 5, 8, 2],
      weekLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    );
  }

  final statuses = <String, int>{};
  for (final d in jobData) {
    final s = d['status'] as String? ?? 'inProgress';
    statuses[s] = (statuses[s] ?? 0) + 1;
  }

  final statusColors = <String, Color>{
    'inProgress': const Color(0xFF1B9AAA),
    'pendingApproval': const Color(0xFFD97706),
    'completed': const Color(0xFF16A34A),
    'waitingParts': const Color(0xFF7C3AED),
    'qualityCheck': const Color(0xFF2563EB),
    'cancelled': const Color(0xFFDC2626),
  };

  const statusLabels = <String, String>{
    'inProgress': 'In Progress',
    'pendingApproval': 'Pending',
    'completed': 'Completed',
    'waitingParts': 'Waiting Parts',
    'qualityCheck': 'QC Check',
    'cancelled': 'Cancelled',
  };

  final breakdown = statuses.entries.map((e) => StatusCount(
    statusLabels[e.key] ?? e.key,
    e.value,
    statusColors[e.key] ?? const Color(0xFF94A3B8),
  )).toList();

  return AdvisorReportData(
    totalJobs: jobData.length,
    completedJobs: statuses['completed'] ?? 0,
    pendingJobs: (statuses['pendingApproval'] ?? 0) + (statuses['waitingParts'] ?? 0),
    inProgressJobs: (statuses['inProgress'] ?? 0) + (statuses['qualityCheck'] ?? 0),
    cancelledJobs: statuses['cancelled'] ?? 0,
    statusBreakdown: breakdown,
    weeklyActivity: [4, 6, 3, 7, 5, 8, 2],
    weekLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  );
});

