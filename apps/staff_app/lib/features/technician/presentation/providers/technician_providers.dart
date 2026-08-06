import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/features/technician/data/datasources/technician_providers.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

final technicianRefreshProvider = StateProvider<int>((ref) => 0);

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
  static const String _defaultEmpId = 'EMP-001';

  TechnicianProfileEntity profile = const TechnicianProfileEntity(
    name: '',
    empId: _defaultEmpId,
    role: 'Technician',
    branch: '',
    shift: '',
    avatarInitials: 'T',
  );

  TechnicianStatsEntity productivity = const TechnicianStatsEntity(
    assignedJobs: 0,
    inProgress: 0,
    completedToday: 0,
    efficiency: 0,
    avgTimePerJob: '',
    totalHoursWorked: '',
  );

  final TextEditingController jobCardController = TextEditingController();
  final List<String> filterOptions = const [
    'All Status',
    'In Progress',
    'Completed',
    'Delayed',
    'Pending',
  ];

  final List<TechnicianJobEntity> _allJobs = [];

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
    _loadFromHive();
    _loadFromRemote();
    return TechnicianState(
      attendanceSummary: const AttendanceSummaryEntity(),
      assignedJobs: const [],
    );
  }

  Future<void> _loadFromRemote() async {
    final remote = ref.read(technicianRemoteDataSourceProvider);
    final logger = ref.read(loggerProvider);

    try {
      // FIX (audit P0): identity comes from the authenticated session.
      // The backend /technicians/profile endpoint now resolves the staff
      // record from the JWT principal — empId is never a query parameter.
      final profileResponse = await remote.getProfile('');
      profile = TechnicianProfileEntity(
        name: profileResponse.name,
        empId: profileResponse.empId.isEmpty
            ? profile.empId
            : profileResponse.empId,
        role: profileResponse.role.isEmpty
            ? 'Technician'
            : profileResponse.role,
        branch: profileResponse.branch,
        shift: profileResponse.shift,
        avatarInitials: profileResponse.avatarInitials.isEmpty
            ? _initials(profileResponse.name)
            : profileResponse.avatarInitials,
      );
      // Persist the resolved identity so offline Hive keys are user-correct.
      try {
        Hive.box<dynamic>('technician_jobs')
            .put('technician_profile', profile.toJson());
      } catch (_) {}

      final empId = profile.empId;

      final jobs = await remote.getJobs(empId);
      if (jobs.isNotEmpty) {
        _allJobs.clear();
        _allJobs.addAll(jobs.map(_jobFromResponse));
      }

      final assigned = await remote.getAssignedJobs(empId);
      if (assigned.isNotEmpty) {
        state = state.copyWith(
          assignedJobs: assigned.map(_assignedFromResponse).toList(),
        );
      }

      final att = await remote.getAttendance(empId);
      if (att.status.isNotEmpty && att.status != 'notPunchedIn') {
        state = state.copyWith(
          attendanceStatus: AttendanceStatus.values.firstWhere(
            (e) => e.name == att.status,
            orElse: () => AttendanceStatus.notPunchedIn,
          ),
          attendanceSummary: AttendanceSummaryEntity(
            punchIn: att.punchIn.isEmpty ? '--:--' : att.punchIn,
            punchOut: att.punchOut.isEmpty ? '--:--' : att.punchOut,
            breakTime: att.breakTime.isEmpty ? '0 min' : att.breakTime,
            workHours: att.workHours.isEmpty ? '0h 0m' : att.workHours,
          ),
        );
      }

      final prod = await remote.getProductivity(empId);
      if (prod.assignedJobs > 0 || prod.totalHoursWorked.isNotEmpty) {
        productivity = TechnicianStatsEntity(
          assignedJobs: prod.assignedJobs,
          inProgress: prod.inProgress,
          completedToday: prod.completedToday,
          efficiency: prod.efficiency.toDouble(),
          avgTimePerJob: prod.avgTimePerJob,
          totalHoursWorked: prod.totalHoursWorked,
        );
      }

      ref.read(technicianRefreshProvider.notifier).state++;
    } catch (e, st) {
      logger.e(
        'Failed to load technician data from remote',
        error: e,
        stackTrace: st,
      );
    }
  }

  TechnicianJobEntity _jobFromResponse(TechnicianJobResponse j) {
    final tasks = <WorkTaskEntity>[];
    for (var i = 0; i < j.tasks.length; i++) {
      final t = j.tasks[i];
      tasks.add(
        WorkTaskEntity(
          id: int.tryParse(t.id) ?? i + 1,
          ref: t.id,
          description: t.description,
          status: TaskStatus.values.firstWhere(
            (e) => e.name == t.status,
            orElse: () => TaskStatus.pending,
          ),
          startTime: t.startTime.isEmpty ? null : t.startTime,
          endTime: t.endTime.isEmpty ? null : t.endTime,
        ),
      );
    }
    return TechnicianJobEntity(
      jobCardNo: j.jobCardNo,
      dateOfWork: j.dateOfWork,
      startTime: j.startTime,
      vehicleBrand: j.vehicleBrand,
      vehicleModel: j.vehicleModel,
      plateNumber: j.plateNumber,
      status: TechJobStatus.values.firstWhere(
        (e) => e.name == j.status,
        orElse: () => TechJobStatus.pending,
      ),
      tasks: tasks,
      notes: j.notes,
    );
  }

  AssignedJobEntity _assignedFromResponse(AssignedJobResponse j) {
    return AssignedJobEntity(
      id: j.id,
      customerName: j.customerName,
      vehicle: j.vehicle,
      service: j.service,
      amount: double.tryParse(j.amount) ?? 0,
      status: AssignedJobStatus.values.firstWhere(
        (e) => e.name == j.status,
        orElse: () => AssignedJobStatus.pending,
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'T';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  void _loadFromHive() {
    try {
      final box = Hive.box<dynamic>('technician_jobs');
      // FIX (audit P0): restore the previously resolved identity so offline
      // Hive keys and displays are user-correct on shared tablets.
      final savedProfile = box.get('technician_profile');
      if (savedProfile != null) {
        try {
          profile = TechnicianProfileEntity.fromJson(
            Map<String, dynamic>.from(savedProfile),
          );
        } catch (_) {}
      }
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final att = box.get('attendance_${profile.empId}_$today');
      if (att != null) {
        state = state.copyWith(
          attendanceStatus: AttendanceStatus.values.firstWhere(
            (e) => e.name == att['status'],
            orElse: () => AttendanceStatus.notPunchedIn,
          ),
          attendanceSummary: AttendanceSummaryEntity.fromJson(att),
        );
      }
      final savedJobs = box.values
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .where((v) => v['jobCardNo'] != null)
          .map((v) => TechnicianJobEntity.fromJson(v))
          .toList();
      if (savedJobs.isNotEmpty) {
        _allJobs.clear();
        _allJobs.addAll(savedJobs);
      }
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e(
            'Failed to load technician jobs from Hive',
            error: e,
            stackTrace: st,
          );
    }
  }

  void selectTab(int i) {
    if (state.selectedTab == i) return;
    state = state.copyWith(selectedTab: i);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    _loadFromHive();
    await _loadFromRemote();
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
      attendanceSummary: AttendanceSummaryEntity(punchIn: _fmt(now)),
    );
    await _persistAttendance(action: 'punchIn');
    await ref.read(syncEngineProvider).syncAll();
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
    await _persistAttendance(action: 'punchOut');
    await ref.read(syncEngineProvider).syncAll();
  }

  Future<void> startBreak() async {
    if (state.attendanceStatus != AttendanceStatus.working) return;
    state = state.copyWith(attendanceStatus: AttendanceStatus.onBreak);
    await _persistAttendance(action: 'breakStart');
    await ref.read(syncEngineProvider).syncAll();
  }

  Future<void> endBreak() async {
    if (state.attendanceStatus != AttendanceStatus.onBreak) return;
    state = state.copyWith(attendanceStatus: AttendanceStatus.working);
    await _persistAttendance(action: 'breakEnd');
    await ref.read(syncEngineProvider).syncAll();
  }

  Future<void> _enqueueSync(
    String entityId,
    Map<String, dynamic> payload, {
    String entityType = 'attendance',
    ChangeType changeType = ChangeType.update,
  }) async {
    try {
      final queue = ref.read(syncQueueProvider);
      final id = await _generateId(entityType);
      await queue.enqueue(
        SyncOperation(
          id: id,
          entityType: entityType,
          entityId: entityId,
          changeType: changeType,
          payload: payload,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e('Failed to enqueue $entityType sync op', error: e, stackTrace: st);
    }
  }

  static Future<String> _generateId(String entityType) {
    final prefix =
        {
          'attendance': 'ATT',
          'assigned_job': 'AJOB',
          'technician_job': 'TJOB',
          'job_complete': 'JCMP',
        }[entityType] ??
        'SYNC';
    return IdGenerator.nextId(prefix);
  }

  Future<void> _persistAttendance({String action = 'punchIn'}) async {
    final payload = {
      'action': action,
      'empId': profile.empId,
      'status': state.attendanceStatus.name,
      'punchIn': state.attendanceSummary.punchIn,
      'punchOut': state.attendanceSummary.punchOut,
      'breakTime': state.attendanceSummary.breakTime,
      'workHours': state.attendanceSummary.workHours,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };
    // FIX (audit P0): attendance was persisted under a single global key —
    // on shared tablets the next user saw (and overwrote) the previous user's
    // punch state. Key by empId + date.
    final box = Hive.box<dynamic>('technician_jobs');
    box.put('attendance_${profile.empId}_${payload['date']}', payload);
    await _enqueueSync('attendance_${profile.empId}_${payload['date']}', payload);
  }

  Future<void> updateAssignedJobStatus(
    String id,
    AssignedJobStatus status,
  ) async {
    final jobs = List<AssignedJobEntity>.from(state.assignedJobs);
    final idx = jobs.indexWhere((j) => j.id == id);
    if (idx == -1) return;
    jobs[idx] = jobs[idx].copyWith(status: status);
    state = state.copyWith(assignedJobs: jobs);
    final payload = {'empId': profile.empId, 'status': status.name};
    Hive.box<dynamic>('technician_jobs').put('assigned_$id', payload);
    await _enqueueSync(id, payload, entityType: 'assigned_job');
    await ref.read(syncEngineProvider).syncAll();
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
    final updatedTasks = List<WorkTaskEntity>.from(job.tasks);
    updatedTasks[idx] = task.copyWith(
      status: TaskStatus.inProgress,
      startTime: now,
    );
    final updatedJob = _syncJobStatus(job.copyWith(tasks: updatedTasks));
    _persistJob(updatedJob);
    state = state.copyWith(selectedJob: updatedJob);
    _pushTaskAction(job.jobCardNo, task.ref, 'start', {'startTime': now});
  }

  void completeTask(TechnicianJobEntity job, WorkTaskEntity task) {
    final now = DateFormat('HH:mm').format(DateTime.now());
    final idx = job.tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;
    final updatedTasks = List<WorkTaskEntity>.from(job.tasks);
    updatedTasks[idx] = task.copyWith(
      status: TaskStatus.completed,
      endTime: now,
    );
    final updatedJob = _syncJobStatus(job.copyWith(tasks: updatedTasks));
    _persistJob(updatedJob);
    state = state.copyWith(selectedJob: updatedJob);
    _pushTaskAction(job.jobCardNo, task.ref, 'complete', {'endTime': now});
  }

  void updateTaskStatus(
    TechnicianJobEntity job,
    WorkTaskEntity task,
    TaskStatus newStatus,
  ) {
    final now = DateFormat('HH:mm').format(DateTime.now());
    final idx = job.tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;
    final updatedTasks = List<WorkTaskEntity>.from(job.tasks);
    updatedTasks[idx] = task.copyWith(
      status: newStatus,
      startTime: newStatus == TaskStatus.inProgress ? now : task.startTime,
      endTime: newStatus == TaskStatus.completed ? now : task.endTime,
    );
    final updatedJob = _syncJobStatus(job.copyWith(tasks: updatedTasks));
    _persistJob(updatedJob);
    state = state.copyWith(selectedJob: updatedJob);
    _pushTaskAction(job.jobCardNo, task.ref, 'status', {
      'status': newStatus.name,
    });
  }

  /// Pushes a per-task action to the backend (which advances the item and
  /// triggers the supervisor review gate when ALL items are done). Falls back
  /// to the offline sync queue when the request fails.
  Future<void> _pushTaskAction(
    String jobCardNo,
    String taskId,
    String action,
    Map<String, dynamic> payload,
  ) async {
    if (taskId.isEmpty) return;
    final remote = ref.read(technicianRemoteDataSourceProvider);
    try {
      switch (action) {
        case 'start':
          await remote.startTask(
            jobCardNo,
            taskId,
            payload['startTime'] as String? ?? '',
          );
          break;
        case 'complete':
          await remote.completeTask(
            jobCardNo,
            taskId,
            payload['endTime'] as String? ?? '',
          );
          break;
        default:
          await remote.updateTaskStatus(
            jobCardNo,
            taskId,
            payload['status'] as String? ?? 'inProgress',
          );
      }
    } catch (e, st) {
      ref
          .read(loggerProvider)
          .e(
            'Failed to push task action $action for $taskId',
            error: e,
            stackTrace: st,
          );
      final queue = ref.read(syncQueueProvider);
      final id = await IdGenerator.nextId('WT');
      await queue.enqueue(
        SyncOperation(
          id: id,
          entityType: 'work_item',
          entityId: '$jobCardNo|$taskId|$action',
          changeType: ChangeType.update,
          payload: {
            'jobCardNo': jobCardNo,
            'taskId': taskId,
            'action': action,
            ...payload,
          },
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  TechnicianJobEntity _syncJobStatus(TechnicianJobEntity job) {
    final allDone = job.tasks.every((t) => t.status == TaskStatus.completed);
    final anyProgress = job.tasks.any((t) => t.status == TaskStatus.inProgress);
    if (allDone) return job.copyWith(status: TechJobStatus.completed);
    if (anyProgress) return job.copyWith(status: TechJobStatus.inProgress);
    return job;
  }

  void updateNotes(TechnicianJobEntity job, String notes) {
    final updatedJob = job.copyWith(notes: notes);
    _persistJob(updatedJob);
    state = state.copyWith(selectedJob: updatedJob);
  }

  void _persistJob(TechnicianJobEntity job) {
    final payload = {
      'jobCardNo': job.jobCardNo,
      'dateOfWork': job.dateOfWork,
      'startTime': job.startTime,
      'vehicleBrand': job.vehicleBrand,
      'vehicleModel': job.vehicleModel,
      'plateNumber': job.plateNumber,
      'status': job.status.name,
      'notes': job.notes,
      'tasks': job.tasks
          .map(
            (t) => {
              'id': t.id,
              // FIX (audit P0): persist task `ref` so offline actions survive
              // a restart (previously dropped on reload).
              'ref': t.ref,
              'description': t.description,
              'status': t.status.name,
              'startTime': t.startTime,
              'endTime': t.endTime,
            },
          )
          .toList(),
    };
    final local = GenericLocalDataSource(Hive.box<dynamic>('technician_jobs'));
    local.save(job.jobCardNo, payload);
    _enqueueSync(job.jobCardNo, payload, entityType: 'technician_job');
    ref.read(technicianRefreshProvider.notifier).state++;
  }

  Future<void> saveChanges(TechnicianJobEntity job) async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true);
    _persistJob(job);
    await ref.read(syncEngineProvider).syncAll();
    state = state.copyWith(isSaving: false);
  }

  Future<void> completeJob(TechnicianJobEntity job) async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true);
    final now = DateFormat('HH:mm').format(DateTime.now());
    final updatedTasks = List<WorkTaskEntity>.from(job.tasks);
    for (var i = 0; i < updatedTasks.length; i++) {
      if (updatedTasks[i].status != TaskStatus.completed) {
        updatedTasks[i] = updatedTasks[i].copyWith(
          status: TaskStatus.completed,
          endTime: now,
        );
      }
    }
    final updatedJob = job.copyWith(
      tasks: updatedTasks,
      status: TechJobStatus.completed,
    );

    final local = GenericLocalDataSource(Hive.box<dynamic>('technician_jobs'));
    final payload = {
      'jobCardNo': updatedJob.jobCardNo,
      'empId': profile.empId,
      'dateOfWork': updatedJob.dateOfWork,
      'startTime': updatedJob.startTime,
      'vehicleBrand': updatedJob.vehicleBrand,
      'vehicleModel': updatedJob.vehicleModel,
      'plateNumber': updatedJob.plateNumber,
      'status': updatedJob.status.name,
      'notes': updatedJob.notes,
      'tasks': updatedJob.tasks
          .map(
            (t) => {
              'id': t.id,
              'description': t.description,
              'status': t.status.name,
              'startTime': t.startTime,
              'endTime': t.endTime,
            },
          )
          .toList(),
    };
    await local.save(updatedJob.jobCardNo, payload);

    final queue = ref.read(syncQueueProvider);
    final opId = await IdGenerator.nextId('JCMP');
    final op = SyncOperation(
      id: opId,
      entityType: 'job_complete',
      entityId: updatedJob.jobCardNo,
      changeType: ChangeType.update,
      payload: payload,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await queue.enqueue(op);
    await ref.read(syncEngineProvider).syncAll();

    state = state.copyWith(selectedJob: updatedJob, isSaving: false);
  }
}

final technicianDashboardProvider =
    NotifierProvider<TechnicianNotifier, TechnicianState>(
      TechnicianNotifier.new,
    );
