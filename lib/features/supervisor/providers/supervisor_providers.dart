import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/helpers/id_generator.dart';
import 'package:orientmobileapplication/core/local/repositories/generic_local_datasource.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';
import 'package:orientmobileapplication/core/local/sync/sync_providers.dart';
import 'package:orientmobileapplication/features/supervisor/data/datasources/supervisor_mock_datasource.dart';
import 'package:orientmobileapplication/features/supervisor/domain/entities/supervisor_entities.dart';

final supervisorMockDataSourceProvider = Provider<SupervisorMockDataSource>((ref) => SupervisorMockDataSource());

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
  late final SupervisorMockDataSource _dataSource;

  @override
  SupervisorDashboardState build() {
    _dataSource = ref.read(supervisorMockDataSourceProvider);
    _loadDashboard();
    return SupervisorDashboardState();
  }

  void selectTab(int index) {
    if (state.selectedIndex == index) return;
    state = state.copyWith(selectedIndex: index);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateJobCardSearch(String value) {
    state = state.copyWith(jobCardSearch: value);
  }

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
        'id': row.id,
        'description': row.description,
        'department': row.department,
        'technicianName': row.technicianName,
        'dateOfWork': row.dateOfWork,
        'statusPercent': row.statusPercent,
        'stdTime': row.stdTime,
        'remarks': row.remarks,
      };
      await local.save(row.id.toString(), payload);
      final op = SyncOperation(
        id: await IdGenerator.nextId('ASN'),
        entityType: 'work_assignment',
        entityId: row.id.toString(),
        changeType: ChangeType.create,
        payload: payload,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await queue.enqueue(op);

      final jobCard = 'ASN-${row.id}';
      final jobStatus = row.statusPercent >= 100
          ? 'Completed'
          : row.statusPercent > 0
              ? 'In Progress'
              : 'Pending';
      final jobEntry = AssignedJobEntity(
        jobCard: jobCard,
        customer: row.technicianName.isEmpty ? 'Unassigned' : row.technicianName,
        vehicle: row.description.isEmpty ? 'No description' : row.description,
        dateAssigned: row.dateOfWork.isEmpty ? DateTime.now().toIso8601String().split('T').first : row.dateOfWork,
        done: row.statusPercent ~/ 10,
        total: 10,
        status: jobStatus,
      );
      _allJobs.insert(0, jobEntry);
      await local.save('job_$jobCard', {
        'jobCard': jobCard,
        'customer': jobEntry.customer,
        'vehicle': jobEntry.vehicle,
        'dateAssigned': jobEntry.dateAssigned,
        'done': jobEntry.done,
        'total': jobEntry.total,
        'status': jobEntry.status,
      });
    }

    state = state.copyWith(isAssignWorkLoading: false);
  }

  List<SupervisorKpiEntity> get kpis => _dataSource.kpis;
  List<AdvisorJobEntity> get advisorJobData => _dataSource.advisorJobData;
  List<JobTypeEntity> get jobTypes => _dataSource.jobTypes;
  List<RevenueMetricEntity> get revenueMetrics => _dataSource.revenueMetrics;
  List<PendingStatusEntity> get pendingStatuses => _dataSource.pendingStatuses;
  List<String> get departments => _dataSource.departments;
  List<String> get technicians => _dataSource.technicians;

  late final List<AssignedJobEntity> _allJobs = List.of(_dataSource.initialJobs);

  List<AssignedJobEntity> get jobs => _allJobs;

  int get totalAssigned => _allJobs.length;
  int get inProgressCount => _allJobs.where((j) => j.status == 'In Progress').length;
  int get completedCount => _allJobs.where((j) => j.status == 'Completed').length;

  void onNewAssignment() {
    selectTab(1);
  }

  Future<void> refreshDashboard() => _loadDashboard();

  Future<void> _loadDashboard() async {
    state = state.copyWith(isDashboardLoading: true);
    await Future.delayed(const Duration(milliseconds: 200));
    _loadAssignmentsFromHive();
    state = state.copyWith(isDashboardLoading: false);
  }

  void _loadAssignmentsFromHive() {
    try {
      final box = Hive.box<dynamic>('supervisor_assignments');
      final savedAssignments = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['id'] != null && v['description'] != null)
          .map((v) => WorkAssignmentEntity.fromMap(v))
          .toList();
      if (savedAssignments.isNotEmpty) {
        state = state.copyWith(assignmentRows: savedAssignments);
      }
      final savedJobs = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['jobCard'] != null && v['jobCard'].toString().startsWith('ASN-'))
          .map((v) => AssignedJobEntity(
                jobCard: v['jobCard'] as String? ?? '',
                customer: v['customer'] as String? ?? '',
                vehicle: v['vehicle'] as String? ?? '',
                dateAssigned: v['dateAssigned'] as String? ?? '',
                done: v['done'] as int? ?? 0,
                total: v['total'] as int? ?? 10,
                status: v['status'] as String? ?? 'Pending',
              ))
          .toList();
      if (savedJobs.isNotEmpty) {
        _allJobs.removeWhere((j) => j.jobCard.startsWith('ASN-'));
        _allJobs.addAll(savedJobs);
      }
    } catch (_) {}
  }
}

final supervisorDashboardProvider = NotifierProvider<SupervisorDashboardNotifier, SupervisorDashboardState>(
  SupervisorDashboardNotifier.new,
);
