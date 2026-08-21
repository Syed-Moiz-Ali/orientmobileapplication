import 'package:shared_core/shared_core.dart';

class TechnicianRemoteDataSource {
  final ApiClient _client;
  TechnicianRemoteDataSource(this._client);

  // FIX (audit P0): identity is resolved from the JWT principal server-side;
  // empId is no longer a query parameter (was an IDOR + default EMP-001 bug).
  Future<TechnicianProfileResponse> getProfile(String empId) async =>
      (await _client.get<TechnicianProfileResponse>(
        ApiEndpoints.technicianProfile,
        fromJson: (d) => TechnicianProfileResponse.fromJson(d),
      )).unwrapOrThrow();

  Future<AttendanceResponse> punchIn(Map<String, dynamic> data) async =>
      (await _client.post<AttendanceResponse>(
        ApiEndpoints.attendancePunchIn,
        data: data,
        fromJson: (d) => AttendanceResponse.fromJson(d),
      )).unwrapOrThrow();

  Future<void> punchOut(Map<String, dynamic> data) async {
    (await _client.post(
      ApiEndpoints.attendancePunchOut,
      data: data,
    )).unwrapOrThrow();
  }

  Future<void> breakStart(Map<String, dynamic> data) async {
    (await _client.post(
      ApiEndpoints.attendanceBreakStart,
      data: data,
    )).unwrapOrThrow();
  }

  Future<void> breakEnd(Map<String, dynamic> data) async {
    (await _client.post(
      ApiEndpoints.attendanceBreakEnd,
      data: data,
    )).unwrapOrThrow();
  }

  Future<AttendanceResponse> getAttendance(
    String empId, {
    String? date,
  }) async => (await _client.get<AttendanceResponse>(
    ApiEndpoints.technicianAttendance,
    queryParams: {'empId': empId, if (date != null) 'date': date},
    fromJson: (d) => AttendanceResponse.fromJson(d),
  )).unwrapOrThrow();

  Future<List<AssignedJobResponse>> getAssignedJobs(String empId) async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.technicianAssignedJobs,
        queryParams: {'empId': empId},
        fromJson: (d) => d as List<dynamic>,
      )).unwrapOrThrow().map((e) => AssignedJobResponse.fromJson(e)).toList();

  Future<void> updateAssignedJobStatus(
    String id,
    String empId,
    String status,
  ) async {
    (await _client.put(
      ApiEndpoints.technicianAssignedJobStatus(id),
      data: {'empId': empId, 'status': status},
    )).unwrapOrThrow();
  }

  Future<List<TechnicianJobResponse>> getJobs(
    String empId, {
    String? status,
  }) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.technicianJobs,
    queryParams: {'empId': empId, if (status != null) 'status': status},
    fromJson: (d) => d as List<dynamic>,
  )).unwrapOrThrow().map((e) => TechnicianJobResponse.fromJson(e)).toList();

  Future<TechnicianJobResponse> searchJob(String q) async =>
      (await _client.get<TechnicianJobResponse>(
        ApiEndpoints.technicianJobsSearch,
        queryParams: {'q': q},
        fromJson: (d) => TechnicianJobResponse.fromJson(d),
      )).unwrapOrThrow();

  Future<TaskActionResponse> startTask(
    String jobCardNo,
    String taskId,
    String startTime,
  ) async => (await _client.put<TaskActionResponse>(
    ApiEndpoints.technicianTask(jobCardNo, taskId, 'start'),
    data: {'startTime': startTime},
    fromJson: (d) => TaskActionResponse.fromJson(d),
  )).unwrapOrThrow();

  Future<void> completeTask(
    String jobCardNo,
    String taskId,
    String endTime,
  ) async {
    (await _client.put(
      ApiEndpoints.technicianTask(jobCardNo, taskId, 'complete'),
      data: {'endTime': endTime},
    )).unwrapOrThrow();
  }

  Future<void> updateTaskStatus(
    String jobCardNo,
    String taskId,
    String status,
  ) async {
    (await _client.put(
      ApiEndpoints.technicianTask(jobCardNo, taskId, 'status'),
      data: {'status': status},
    )).unwrapOrThrow();
  }

  Future<void> completeJob(Map<String, dynamic> data) async {
    (await _client.post(ApiEndpoints.jobComplete, data: data)).unwrapOrThrow();
  }

  Future<void> updateNotes(String jobCardNo, String notes) async {
    (await _client.put(
      ApiEndpoints.technicianJobNotes(jobCardNo),
      data: {'notes': notes},
    )).unwrapOrThrow();
  }

  Future<void> requestPart(Map<String, dynamic> data) async {
    (await _client.post(
      '/technician/parts-requests',
      data: data,
    )).unwrapOrThrow();
  }

  Future<void> escalateIssue(Map<String, dynamic> data) async {
    (await _client.post('/technician/escalations', data: data)).unwrapOrThrow();
  }

  Future<ProductivityResponse> getProductivity(String empId) async =>
      (await _client.get<ProductivityResponse>(
        ApiEndpoints.technicianProductivity,
        queryParams: {'empId': empId},
        fromJson: (d) => ProductivityResponse.fromJson(d),
      )).unwrapOrThrow();
}
