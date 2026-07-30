import 'package:shared_core/shared_core.dart';

class TechnicianRemoteDataSource {
  final ApiClient _client;
  TechnicianRemoteDataSource(this._client);

  Future<TechnicianProfileResponse> getProfile(String empId) async => (await _client.get<TechnicianProfileResponse>(
    ApiEndpoints.technicianProfile,queryParams: {'empId': empId},fromJson: (d) => TechnicianProfileResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const TechnicianProfileResponse());

  Future<AttendanceResponse> punchIn(Map<String, dynamic> data) async => (await _client.post<AttendanceResponse>(
    ApiEndpoints.attendancePunchIn,data: data,fromJson: (d) => AttendanceResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const AttendanceResponse());

  Future<void> punchOut(Map<String, dynamic> data) async { await _client.post(ApiEndpoints.attendancePunchOut, data: data); }

  Future<void> breakStart(Map<String, dynamic> data) async { await _client.post(ApiEndpoints.attendanceBreakStart, data: data); }

  Future<void> breakEnd(Map<String, dynamic> data) async { await _client.post(ApiEndpoints.attendanceBreakEnd, data: data); }

  Future<AttendanceResponse> getAttendance(String empId, {String? date}) async => (await _client.get<AttendanceResponse>(
    ApiEndpoints.technicianAttendance,queryParams: {'empId': empId, if(date!=null)'date':date},
    fromJson: (d) => AttendanceResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const AttendanceResponse());

  Future<List<AssignedJobResponse>> getAssignedJobs(String empId) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.technicianAssignedJobs,queryParams: {'empId': empId},fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => AssignedJobResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<void> updateAssignedJobStatus(String id, String empId, String status) async {
    await _client.put(ApiEndpoints.technicianAssignedJobStatus(id), data: {'empId': empId, 'status': status});
  }

  Future<List<TechnicianJobResponse>> getJobs(String empId, {String? status}) async => (await _client.get<List<dynamic>>(
    ApiEndpoints.technicianJobs,queryParams: {'empId': empId, if(status!=null)'status':status},
    fromJson: (d) => d as List<dynamic>)).when(
    success: (l) => l.map((e) => TechnicianJobResponse.fromJson(e)).toList(), failure: (_) => []);

  Future<TechnicianJobResponse> searchJob(String q) async => (await _client.get<TechnicianJobResponse>(
    ApiEndpoints.technicianJobsSearch,queryParams: {'q': q},fromJson: (d) => TechnicianJobResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const TechnicianJobResponse());

  Future<TaskActionResponse> startTask(String jobCardNo, String taskId, String startTime) async => (await _client.put<TaskActionResponse>(
    ApiEndpoints.technicianTask(jobCardNo, taskId, 'start'),data: {'startTime': startTime},
    fromJson: (d) => TaskActionResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const TaskActionResponse());

  Future<void> completeTask(String jobCardNo, String taskId, String endTime) async {
    await _client.put(ApiEndpoints.technicianTask(jobCardNo, taskId, 'complete'), data: {'endTime': endTime});
  }

  Future<void> updateTaskStatus(String jobCardNo, String taskId, String status) async {
    await _client.put(ApiEndpoints.technicianTask(jobCardNo, taskId, 'status'), data: {'status': status});
  }

  Future<void> completeJob(Map<String, dynamic> data) async { await _client.post(ApiEndpoints.jobComplete, data: data); }

  Future<void> updateNotes(String jobCardNo, String notes) async {
    await _client.put(ApiEndpoints.technicianJobNotes(jobCardNo), data: {'notes': notes});
  }

  Future<ProductivityResponse> getProductivity(String empId) async => (await _client.get<ProductivityResponse>(
    ApiEndpoints.technicianProductivity,queryParams: {'empId': empId},fromJson: (d) => ProductivityResponse.fromJson(d))).when(success: (v) => v, failure: (_) => const ProductivityResponse());
}
