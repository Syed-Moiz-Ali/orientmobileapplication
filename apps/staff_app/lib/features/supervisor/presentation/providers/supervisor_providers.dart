import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/data/datasources/supervisor_remote_datasource.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';

final supervisorRemoteDataSourceProvider = Provider<SupervisorRemoteDataSource>((ref) {
  return SupervisorRemoteDataSource(ref.read(apiClientProvider));
});

class SupervisorDashboardState {
  final int selectedIndex;
  final bool isDashboardLoading;
  final bool isAssignWorkLoading;
  final bool isWorkListLoading;
  final String searchQuery;
  final String jobCardSearch;
  final List<WorkAssignmentEntity> assignmentRows;
  final int nextRowId;

  SupervisorDashboardState({
    this.selectedIndex = 0,
    this.isDashboardLoading = false,
    this.isAssignWorkLoading = false,
    this.isWorkListLoading = false,
    this.searchQuery = '',
    this.jobCardSearch = '',
    List<WorkAssignmentEntity>? assignmentRows,
    this.nextRowId = 2,
  }) : assignmentRows = assignmentRows ?? [WorkAssignmentEntity(id: 1)];

  SupervisorDashboardState copyWith({
    int? selectedIndex,
    bool? isDashboardLoading,
    bool? isAssignWorkLoading,
    bool? isWorkListLoading,
    String? searchQuery,
    String? jobCardSearch,
    List<WorkAssignmentEntity>? assignmentRows,
    int? nextRowId,
  }) {
    return SupervisorDashboardState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isDashboardLoading: isDashboardLoading ?? this.isDashboardLoading,
      isAssignWorkLoading: isAssignWorkLoading ?? this.isAssignWorkLoading,
      isWorkListLoading: isWorkListLoading ?? this.isWorkListLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      jobCardSearch: jobCardSearch ?? this.jobCardSearch,
      assignmentRows: assignmentRows ?? this.assignmentRows,
      nextRowId: nextRowId ?? this.nextRowId,
    );
  }
}

class SupervisorDashboardNotifier extends Notifier<SupervisorDashboardState> {
  SupervisorRemoteDataSource? _remote;
  List<SupervisorKpiEntity> _kpis = [];
  List<AdvisorJobEntity> _advisorJobData = [];
  List<JobTypeEntity> _jobTypes = [];
  List<RevenueMetricEntity> _revenueMetrics = [];
  List<PendingStatusEntity> _pendingStatuses = [];
  List<String> _departments = [];
  List<String> _technicians = [];
  final List<AssignedJobEntity> _allJobs = [];

  @override
  SupervisorDashboardState build() {
    _remote = ref.read(supervisorRemoteDataSourceProvider);
    _loadAssignmentsFromHive();
    _loadRemoteData();
    return SupervisorDashboardState();
  }

  List<SupervisorKpiEntity> get kpis => _kpis;
  List<AdvisorJobEntity> get advisorJobData => _advisorJobData;
  List<JobTypeEntity> get jobTypes => _jobTypes;
  List<RevenueMetricEntity> get revenueMetrics => _revenueMetrics;
  List<PendingStatusEntity> get pendingStatuses => _pendingStatuses;
  List<String> get departments => _departments;
  List<String> get technicians => _technicians;
  List<AssignedJobEntity> get jobs => _allJobs;
  int get totalAssigned => _allJobs.length;
  int get inProgressCount => _allJobs.where((j) => j.status == 'In Progress').length;
  int get completedCount => _allJobs.where((j) => j.status == 'Completed').length;

  void selectTab(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  void updateSearch(String query) => state = state.copyWith(searchQuery: query);
  void updateJobCardSearch(String value) => state = state.copyWith(jobCardSearch: value);

  void addAssignmentRow() {
    state = state.copyWith(
      assignmentRows: [...state.assignmentRows, WorkAssignmentEntity(id: state.nextRowId)],
      nextRowId: state.nextRowId + 1,
    );
  }

  void removeAssignmentRow(int id) {
    if (state.assignmentRows.length <= 1) return;
    state = state.copyWith(assignmentRows: state.assignmentRows.where((r) => r.id != id).toList());
  }

  void updateAssignmentRow(int id, WorkAssignmentEntity updated) {
    final index = state.assignmentRows.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final updatedRows = [...state.assignmentRows];
    updatedRows[index] = updated;
    state = state.copyWith(assignmentRows: updatedRows);
  }

  Future<void> saveAndAssign() async {
    state = state.copyWith(isAssignWorkLoading: true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final local = GenericLocalDataSource(Hive.box<dynamic>('supervisor_assignments'));
    final queue = ref.read(syncQueueProvider);
    for (final row in state.assignmentRows) {
      final payload = {
        'id': row.id, 'description': row.description, 'department': row.department,
        'technicianName': row.technicianName, 'dateOfWork': row.dateOfWork,
        'statusPercent': row.statusPercent, 'stdTime': row.stdTime, 'remarks': row.remarks,
      };
      await local.save(row.id.toString(), payload);
      final op = SyncOperation(
        id: await IdGenerator.nextId('ASN'), entityType: 'work_assignment',
        entityId: row.id.toString(), changeType: ChangeType.create,
        payload: payload, timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await queue.enqueue(op);

      final jobCard = 'ASN-${row.id}';
      final jobStatus = row.statusPercent >= 100 ? 'Completed' : row.statusPercent > 0 ? 'In Progress' : 'Pending';
      final jobEntry = AssignedJobEntity(
        jobCard: jobCard,
        customer: row.technicianName.isEmpty ? 'Unassigned' : row.technicianName,
        vehicle: row.description.isEmpty ? 'No description' : row.description,
        dateAssigned: row.dateOfWork.isEmpty ? DateTime.now().toIso8601String().split('T').first : row.dateOfWork,
        done: row.statusPercent ~/ 10, total: 10, status: jobStatus,
      );
      _allJobs.insert(0, jobEntry);
      await local.save('job_$jobCard', {
        'jobCard': jobCard, 'customer': jobEntry.customer, 'vehicle': jobEntry.vehicle,
        'dateAssigned': jobEntry.dateAssigned, 'done': jobEntry.done,
        'total': jobEntry.total, 'status': jobEntry.status,
      });
    }
    state = state.copyWith(isAssignWorkLoading: false);
  }

  void onNewAssignment() => selectTab(1);

  Future<void> refreshDashboard() async {
    state = state.copyWith(isDashboardLoading: true);
    await _loadRemoteData();
    _loadAssignmentsFromHive();
    state = state.copyWith(isDashboardLoading: false);
  }

  Future<void> _loadRemoteData() async {
    final r = _remote;
    if (r == null) return;
    final kpiColors = [const Color(0xFF1F6FEB), const Color(0xFF238636), const Color(0xFF8957E5), const Color(0xFFFF7B00), const Color(0xFFDA3633)];
    final kpiIcons = [Icons.description_outlined, Icons.calendar_month_outlined, Icons.groups_2_outlined, Icons.engineering_outlined, Icons.assignment_outlined];
    final revenueIcons = [Icons.trending_up_rounded, Icons.store_rounded, Icons.build_rounded, Icons.people_rounded, Icons.attach_money_rounded];
    final statusColors = [const Color(0xFFE3B341), const Color(0xFF238636), const Color(0xFFDA3633), const Color(0xFF8957E5)];
    final statusIcons = [Icons.access_time_rounded, Icons.check_circle_outline_rounded, Icons.search_rounded, Icons.thumb_up_outlined];
    final jobColors = [const Color(0xFF1F6FEB), const Color(0xFF238636), const Color(0xFFE3B341)];

    final results = await Future.wait([
      r.getKpis(), r.getAdvisorJobs(), r.getJobTypes(), r.getRevenueMetrics(),
      r.getPendingStatuses(), r.getDepartments(), r.getTechnicians(), r.getAssignedJobs(),
    ]);

    _kpis = (results[0] as List).asMap().entries.map((e) => SupervisorKpiEntity(
      icon: kpiIcons[e.key < kpiIcons.length ? e.key : 0], color: kpiColors[e.key < kpiColors.length ? e.key : 0],
      value: (e.value as KpiResponse).value, label: (e.value as KpiResponse).label, sub: (e.value as KpiResponse).sub,
    )).toList();

    _advisorJobData = (results[1] as List).map((e) => AdvisorJobEntity(name: (e as AdvisorJobCountResponse).name, count: e.count.toDouble())).toList();

    _jobTypes = (results[2] as List).asMap().entries.map((e) => JobTypeEntity(
      label: (e.value as JobTypeResponse).label, count: (e.value as JobTypeResponse).count,
      color: jobColors[e.key < jobColors.length ? e.key : 0],
    )).toList();

    _revenueMetrics = (results[3] as List).asMap().entries.map((e) => RevenueMetricEntity(
      icon: revenueIcons[e.key < revenueIcons.length ? e.key : 0],
      amount: (e.value as RevenueMetricResponse).amount, label: (e.value as RevenueMetricResponse).label,
      change: (e.value as RevenueMetricResponse).change,
    )).toList();

    _pendingStatuses = (results[4] as List).asMap().entries.map((e) => PendingStatusEntity(
      icon: statusIcons[e.key < statusIcons.length ? e.key : 0], color: statusColors[e.key < statusColors.length ? e.key : 0],
      count: (e.value as PendingStatusResponse).count, label: (e.value as PendingStatusResponse).label,
    )).toList();

    _departments = (results[5] as List).cast<String>();
    _technicians = (results[6] as List).cast<String>();
    _allJobs.clear();
    _allJobs.addAll((results[7] as List).map((e) => AssignedJobEntity(
      jobCard: (e as SupervisorAssignedJob).jobCard, customer: e.customer, vehicle: e.vehicle,
      dateAssigned: e.dateAssigned, done: e.done, total: e.total, status: e.status,
    )));
  }

  void _loadAssignmentsFromHive() {
    try {
      final box = Hive.box<dynamic>('supervisor_assignments');
      final savedAssignments = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['id'] != null && v['description'] != null)
          .map((v) => WorkAssignmentEntity.fromMap(v)).toList();
      if (savedAssignments.isNotEmpty) state = state.copyWith(assignmentRows: savedAssignments);
      final savedJobs = box.values.whereType<Map>().map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['jobCard'] != null && v['jobCard'].toString().startsWith('ASN-'))
          .map((v) => AssignedJobEntity(
            jobCard: v['jobCard'] as String? ?? '', customer: v['customer'] as String? ?? '',
            vehicle: v['vehicle'] as String? ?? '', dateAssigned: v['dateAssigned'] as String? ?? '',
            done: v['done'] as int? ?? 0, total: v['total'] as int? ?? 10, status: v['status'] as String? ?? 'Pending',
          )).toList();
      if (savedJobs.isNotEmpty) {
        _allJobs.removeWhere((j) => j.jobCard.startsWith('ASN-'));
        _allJobs.addAll(savedJobs);
      }
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to load supervisor jobs from Hive', error: e, stackTrace: st);
    }
  }
}

final supervisorDashboardProvider = NotifierProvider<SupervisorDashboardNotifier, SupervisorDashboardState>(
  SupervisorDashboardNotifier.new,
);
