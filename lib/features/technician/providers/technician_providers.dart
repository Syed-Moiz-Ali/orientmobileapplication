import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:orientmobileapplication/features/technician/domain/entities/technician_entities.dart';

class TechnicianState {
  final int selectedTab;
  final bool isLoading;
  final bool isSaving;
  final AttendanceStatus attendanceStatus;
  final AttendanceSummaryEntity attendanceSummary;
  final List<AssignedJobEntity> assignedJobs;
  final String quickJobError;
  final String searchQuery;
  final String selectedFilter;
  final TechnicianJobEntity? selectedJob;

  const TechnicianState({
    this.selectedTab = 0,
    this.isLoading = false,
    this.isSaving = false,
    this.attendanceStatus = AttendanceStatus.notPunchedIn,
    required this.attendanceSummary,
    required this.assignedJobs,
    this.quickJobError = '',
    this.searchQuery = '',
    this.selectedFilter = 'All Status',
    this.selectedJob,
  });

  TechnicianState copyWith({
    int? selectedTab,
    bool? isLoading,
    bool? isSaving,
    AttendanceStatus? attendanceStatus,
    AttendanceSummaryEntity? attendanceSummary,
    List<AssignedJobEntity>? assignedJobs,
    String? quickJobError,
    String? searchQuery,
    String? selectedFilter,
    TechnicianJobEntity? selectedJob,
    bool clearSelectedJob = false,
  }) {
    return TechnicianState(
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      attendanceSummary: attendanceSummary ?? this.attendanceSummary,
      assignedJobs: assignedJobs ?? this.assignedJobs,
      quickJobError: quickJobError ?? this.quickJobError,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedJob: clearSelectedJob ? null : (selectedJob ?? this.selectedJob),
    );
  }

  String get currentDateTime =>
      DateFormat('EEEE, MMMM d, yyyy \'at\' hh:mm a').format(DateTime.now());
}

class TechnicianNotifier extends Notifier<TechnicianState> {
  final TechnicianProfileEntity profile = TechnicianProfileEntity.mock;

  final TechnicianStatsEntity productivity = const TechnicianStatsEntity(
    assignedJobs: 4,
    inProgress: 1,
    completedToday: 1,
    efficiency: 87,
    avgTimePerJob: '1.2 hrs',
    totalHoursWorked: '4h 35m',
  );

  final TextEditingController jobCardController = TextEditingController();
  final List<String> filterOptions = const [
    'All Status',
    'In Progress',
    'Completed',
    'Delayed',
    'Pending',
  ];

  final List<TechnicianJobEntity> _allJobs = [
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-0423',
      dateOfWork: '2026-04-23',
      startTime: '08:30',
      vehicleBrand: 'Toyota',
      vehicleModel: 'Camry',
      plateNumber: 'ABC-1234',
      status: TechJobStatus.inProgress,
      tasks: [
        WorkTaskEntity(
          id: 1,
          description: 'Engine oil change and filter replacement',
          status: TaskStatus.completed,
          startTime: '08:35',
        ),
        WorkTaskEntity(
          id: 2,
          description: 'Brake pad inspection and replacement',
          status: TaskStatus.inProgress,
          startTime: '09:15',
        ),
        WorkTaskEntity(id: 3, description: 'Tire rotation and alignment check'),
        WorkTaskEntity(
          id: 4,
          description: 'Battery voltage test and terminal cleaning',
        ),
      ],
    ),
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-0422',
      dateOfWork: '2026-04-22',
      startTime: '10:00',
      vehicleBrand: 'Honda',
      vehicleModel: 'Accord',
      plateNumber: 'XYZ-5678',
      status: TechJobStatus.completed,
      tasks: [
        WorkTaskEntity(
          id: 1,
          description: 'Full service inspection',
          status: TaskStatus.completed,
          startTime: '10:05',
          endTime: '11:30',
        ),
        WorkTaskEntity(
          id: 2,
          description: 'Air filter replacement',
          status: TaskStatus.completed,
          startTime: '11:35',
          endTime: '12:00',
        ),
        WorkTaskEntity(
          id: 3,
          description: 'Coolant top-up and pressure test',
          status: TaskStatus.completed,
          startTime: '12:05',
          endTime: '12:45',
        ),
      ],
    ),
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-0421',
      dateOfWork: '2026-04-21',
      startTime: '14:30',
      vehicleBrand: 'Ford',
      vehicleModel: 'F-150',
      plateNumber: 'DEF-9012',
      status: TechJobStatus.delayed,
      tasks: [
        WorkTaskEntity(
          id: 1,
          description: 'Transmission fluid change',
          status: TaskStatus.inProgress,
          startTime: '14:35',
        ),
        WorkTaskEntity(id: 2, description: 'Differential oil replacement'),
      ],
    ),
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-0420',
      dateOfWork: '2026-04-20',
      startTime: '09:00',
      vehicleBrand: 'Chevrolet',
      vehicleModel: 'Silverado',
      plateNumber: 'GHI-3456',
      status: TechJobStatus.pending,
      tasks: [
        WorkTaskEntity(id: 1, description: 'Spark plug replacement'),
        WorkTaskEntity(id: 2, description: 'Throttle body cleaning'),
        WorkTaskEntity(id: 3, description: 'PCV valve inspection'),
      ],
    ),
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-0419',
      dateOfWork: '2026-04-19',
      startTime: '11:30',
      vehicleBrand: 'BMW',
      vehicleModel: '328i',
      plateNumber: 'JKL-7890',
      status: TechJobStatus.inProgress,
      tasks: [
        WorkTaskEntity(
          id: 1,
          description: 'DSC sensor calibration',
          status: TaskStatus.completed,
          startTime: '11:35',
          endTime: '12:10',
        ),
        WorkTaskEntity(
          id: 2,
          description: 'Brake fluid flush',
          status: TaskStatus.inProgress,
          startTime: '12:15',
        ),
        WorkTaskEntity(id: 3, description: 'Wheel bearing inspection'),
      ],
    ),
    TechnicianJobEntity(
      jobCardNo: 'JC-2026-0418',
      dateOfWork: '2026-04-18',
      startTime: '15:00',
      vehicleBrand: 'Mercedes',
      vehicleModel: 'C-Class',
      plateNumber: 'MNO-2468',
      status: TechJobStatus.pending,
      tasks: [
        WorkTaskEntity(id: 1, description: 'AC compressor check'),
        WorkTaskEntity(id: 2, description: 'Cabin air filter replacement'),
      ],
    ),
  ];

  List<TechnicianJobEntity> get allJobs => _allJobs;

  List<TechnicianJobEntity> get filteredJobs => _allJobs.where((j) {
    final q = state.searchQuery;
    final matchSearch =
        q.isEmpty ||
        j.jobCardNo.toLowerCase().contains(q) ||
        j.vehicleBrand.toLowerCase().contains(q) ||
        j.vehicleModel.toLowerCase().contains(q) ||
        j.plateNumber.toLowerCase().contains(q);
    final matchFilter =
        state.selectedFilter == 'All Status' ||
        j.status.label == state.selectedFilter;
    return matchSearch && matchFilter;
  }).toList();

  int get totalJobs => _allJobs.length;
  int get inProgressJobs =>
      _allJobs.where((j) => j.status == TechJobStatus.inProgress).length;
  int get completedJobs =>
      _allJobs.where((j) => j.status == TechJobStatus.completed).length;
  int get delayedJobs =>
      _allJobs.where((j) => j.status == TechJobStatus.delayed).length;

  @override
  TechnicianState build() {
    ref.onDispose(jobCardController.dispose);
    refresh();
    return TechnicianState(
      attendanceSummary: const AttendanceSummaryEntity(
        punchIn: '08:15 AM',
        punchOut: '--:--',
        breakTime: '25 min',
        workHours: '4h 35m',
      ),
      assignedJobs: List.from(AssignedJobEntity.mockData),
    );
  }

  void selectTab(int i) {
    if (state.selectedTab == i) return;
    state = state.copyWith(selectedTab: i);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false);
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> punchIn() async {
    if (state.attendanceStatus != AttendanceStatus.notPunchedIn) return;
    final now = TimeOfDay.now();
    state = state.copyWith(
      attendanceStatus: AttendanceStatus.working,
      attendanceSummary: AttendanceSummaryEntity(
        punchIn: _fmt(now),
        punchOut: '--:--',
        breakTime: '0 min',
        workHours: '0h 0m',
      ),
    );
  }

  Future<void> punchOut() async {
    if (state.attendanceStatus == AttendanceStatus.notPunchedIn ||
        state.attendanceStatus == AttendanceStatus.punchedOut) {
      return;
    }
    final now = TimeOfDay.now();
    state = state.copyWith(
      attendanceStatus: AttendanceStatus.punchedOut,
      attendanceSummary: AttendanceSummaryEntity(
        punchIn: state.attendanceSummary.punchIn,
        punchOut: _fmt(now),
        breakTime: state.attendanceSummary.breakTime,
        workHours: state.attendanceSummary.workHours,
      ),
    );
  }

  Future<void> startBreak() async {
    if (state.attendanceStatus != AttendanceStatus.working) return;
    state = state.copyWith(attendanceStatus: AttendanceStatus.onBreak);
  }

  Future<void> endBreak() async {
    if (state.attendanceStatus != AttendanceStatus.onBreak) return;
    state = state.copyWith(attendanceStatus: AttendanceStatus.working);
  }

  void updateAssignedJobStatus(String id, AssignedJobStatus status) {
    final jobs = List<AssignedJobEntity>.from(state.assignedJobs);
    final idx = jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    jobs[idx].status = status;
    state = state.copyWith(assignedJobs: jobs);
  }

  void searchJobCard() {
    final val = jobCardController.text.trim();
    if (val.isEmpty) {
      state = state.copyWith(quickJobError: 'Please enter a job card number.');
      return;
    }
    final match = _allJobs
        .where((j) => j.jobCardNo.toLowerCase() == val.toLowerCase())
        .toList();
    if (match.isEmpty) {
      state = state.copyWith(quickJobError: 'Job card "$val" not found.');
    } else {
      state = state.copyWith(quickJobError: '', selectedJob: match.first);
    }
  }

  void clearQuickJobError() {
    if (state.quickJobError.isEmpty) return;
    state = state.copyWith(quickJobError: '');
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
  }

  void updateFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void openJob(TechnicianJobEntity job) {
    state = state.copyWith(selectedJob: job);
  }

  void closeJob() {
    state = state.copyWith(clearSelectedJob: true);
  }

  void startTask(TechnicianJobEntity job, WorkTaskEntity task) {
    final now = DateFormat('HH:mm').format(DateTime.now());
    final idx = job.tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;
    job.tasks[idx] = task.copyWith(
      status: TaskStatus.inProgress,
      startTime: now,
    );
    _syncJobStatus(job);
    state = state.copyWith();
  }

  void completeTask(TechnicianJobEntity job, WorkTaskEntity task) {
    final now = DateFormat('HH:mm').format(DateTime.now());
    final idx = job.tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;
    job.tasks[idx] = task.copyWith(status: TaskStatus.completed, endTime: now);
    _syncJobStatus(job);
    state = state.copyWith();
  }

  void updateTaskStatus(
    TechnicianJobEntity job,
    WorkTaskEntity task,
    TaskStatus newStatus,
  ) {
    final now = DateFormat('HH:mm').format(DateTime.now());
    final idx = job.tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;
    job.tasks[idx] = task.copyWith(
      status: newStatus,
      startTime: newStatus == TaskStatus.inProgress ? now : task.startTime,
      endTime: newStatus == TaskStatus.completed ? now : task.endTime,
    );
    _syncJobStatus(job);
    state = state.copyWith();
  }

  void _syncJobStatus(TechnicianJobEntity job) {
    final allDone = job.tasks.every((t) => t.status == TaskStatus.completed);
    final anyProgress = job.tasks.any((t) => t.status == TaskStatus.inProgress);
    if (allDone) {
      job.status = TechJobStatus.completed;
    } else if (anyProgress) {
      job.status = TechJobStatus.inProgress;
    }
  }

  void updateNotes(TechnicianJobEntity job, String notes) {
    job.notes = notes;
    state = state.copyWith();
  }

  Future<void> saveChanges(TechnicianJobEntity job) async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 900));
    state = state.copyWith(isSaving: false);
  }

  Future<void> completeJob(TechnicianJobEntity job) async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateFormat('HH:mm').format(DateTime.now());
    for (var i = 0; i < job.tasks.length; i++) {
      if (job.tasks[i].status != TaskStatus.completed) {
        job.tasks[i] = job.tasks[i].copyWith(
          status: TaskStatus.completed,
          endTime: now,
        );
      }
    }
    job.status = TechJobStatus.completed;
    state = state.copyWith(isSaving: false);
  }
}

final technicianDashboardProvider =
    NotifierProvider<TechnicianNotifier, TechnicianState>(
      TechnicianNotifier.new,
    );
