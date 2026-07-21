import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/features/supervisor/domain/entities/supervisor_entities.dart';

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
  @override
  SupervisorDashboardState build() {
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
      assignmentRows: [
        ...state.assignmentRows,
        WorkAssignmentEntity(id: state.nextRowId),
      ],
      nextRowId: state.nextRowId + 1,
    );
  }

  void removeAssignmentRow(int id) {
    if (state.assignmentRows.length <= 1) return;
    state = state.copyWith(
      assignmentRows:
          state.assignmentRows.where((r) => r.id != id).toList(),
    );
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
    state = state.copyWith(isAssignWorkLoading: false);
  }

  List<SupervisorKpiEntity> get kpis => const [
        SupervisorKpiEntity(
          icon: Icons.description_outlined,
          color: Color(0xFF1F6FEB),
          value: '24',
          label: 'Total Job Cards Pending',
          sub: '+4 from yesterday',
        ),
        SupervisorKpiEntity(
          icon: Icons.calendar_month_outlined,
          color: Color(0xFF238636),
          value: '8',
          label: 'Today Delivery Job Cards',
          sub: 'On schedule',
        ),
        SupervisorKpiEntity(
          icon: Icons.groups_2_outlined,
          color: Color(0xFF8957E5),
          value: '18',
          label: 'Total Advisors Present',
          sub: '2 out of 20',
        ),
        SupervisorKpiEntity(
          icon: Icons.engineering_outlined,
          color: Color(0xFFFF7B00),
          value: '3',
          label: 'Total Idle Technicians',
          sub: 'Assign them now',
        ),
        SupervisorKpiEntity(
          icon: Icons.assignment_outlined,
          color: Color(0xFFDA3633),
          value: '12',
          label: 'Waiting to Assign Stock',
          sub: 'Requires attention',
        ),
      ];

  List<AdvisorJobEntity> get advisorJobData => const [
        AdvisorJobEntity(name: 'John Smith', count: 20),
        AdvisorJobEntity(name: 'Sarah Lee', count: 13),
        AdvisorJobEntity(name: 'Mike Anwar', count: 18),
        AdvisorJobEntity(name: 'Emma Wilson', count: 10),
      ];

  List<JobTypeEntity> get jobTypes => const [
        JobTypeEntity(label: 'Regular Service', count: 38, color: Color(0xFF1F6FEB)),
        JobTypeEntity(label: 'Insurance', count: 28, color: Color(0xFF238636)),
        JobTypeEntity(label: 'Contract', count: 15, color: Color(0xFFE3B341)),
      ];

  List<RevenueMetricEntity> get revenueMetrics => const [
        RevenueMetricEntity(
          icon: Icons.trending_up_rounded,
          amount: '\$45,280',
          label: 'Total Revenue',
          change: '+12.4%',
        ),
        RevenueMetricEntity(
          icon: Icons.store_rounded,
          amount: '\$18,920',
          label: 'Service Revenue',
          change: '+8.2%',
        ),
        RevenueMetricEntity(
          icon: Icons.build_rounded,
          amount: '\$8,450',
          label: 'Parts Revenue',
          change: '+3.1%',
        ),
        RevenueMetricEntity(
          icon: Icons.people_rounded,
          amount: '\$12,680',
          label: 'Labour Revenue',
          change: '+24.3%',
        ),
        RevenueMetricEntity(
          icon: Icons.attach_money_rounded,
          amount: '\$5,230',
          label: 'Other Revenue',
          change: '+18.7%',
        ),
      ];

  List<PendingStatusEntity> get pendingStatuses => const [
        PendingStatusEntity(
          icon: Icons.access_time_rounded,
          color: Color(0xFFE3B341),
          count: '10',
          label: 'Waiting for Parts',
        ),
        PendingStatusEntity(
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF238636),
          count: '2',
          label: 'Job Completed Not Invoiced',
        ),
        PendingStatusEntity(
          icon: Icons.search_rounded,
          color: Color(0xFFDA3633),
          count: '4',
          label: 'Waiting for Inspection',
        ),
        PendingStatusEntity(
          icon: Icons.thumb_up_outlined,
          color: Color(0xFF8957E5),
          count: '6',
          label: 'Waiting for Approval',
        ),
      ];

  final List<String> departments = const [
    'Engine',
    'Body & Paint',
    'Electrical',
    'Tyres & Alignment',
    'AC & Cooling',
    'Transmission',
    'General Service',
  ];

  final List<String> technicians = const [
    'Ali Hassan',
    'Ravi Kumar',
    'Mohammed Salim',
    'David Osei',
    'James Patel',
  ];

  final List<AssignedJobEntity> _allJobs = const [
    AssignedJobEntity(
      jobCard: 'JC-2025-001',
      customer: 'John Anderson',
      vehicle: 'Toyota Camry 2023',
      dateAssigned: '4/20/2026',
      done: 2,
      total: 4,
      status: 'In Progress',
    ),
    AssignedJobEntity(
      jobCard: 'JC-2025-002',
      customer: 'Sarah Williams',
      vehicle: 'Honda City 7025',
      dateAssigned: '4/21/2026',
      done: 3,
      total: 3,
      status: 'Completed',
    ),
    AssignedJobEntity(
      jobCard: 'JC-2025-003',
      customer: 'Michael Brown',
      vehicle: 'BMW 35 2025',
      dateAssigned: '4/22/2026',
      done: 0,
      total: 5,
      status: 'Pending',
    ),
  ];

  List<AssignedJobEntity> get jobs => _allJobs;

  int get totalAssigned => _allJobs.length;
  int get inProgressCount =>
      _allJobs.where((j) => j.status == 'In Progress').length;
  int get completedCount =>
      _allJobs.where((j) => j.status == 'Completed').length;

  void onNewAssignment() {
    selectTab(1);
  }

  Future<void> refreshDashboard() => _loadDashboard();

  Future<void> _loadDashboard() async {
    state = state.copyWith(isDashboardLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isDashboardLoading: false);
  }
}

final supervisorDashboardProvider =
    NotifierProvider<SupervisorDashboardNotifier, SupervisorDashboardState>(
  SupervisorDashboardNotifier.new,
);
