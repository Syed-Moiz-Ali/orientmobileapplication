import 'package:shared_core/shared_core.dart';

class SupervisorRemoteDataSource {
  final ApiClient _client;
  SupervisorRemoteDataSource(this._client);

  Future<List<KpiResponse>> getKpis() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorKpis,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => KpiResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorAdvisorJobs,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => AdvisorJobCountResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<JobTypeResponse>> getJobTypes() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorJobTypes,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => JobTypeResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<RevenueMetricResponse>> getRevenueMetrics() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorRevenueMetrics,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => RevenueMetricResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<PendingStatusResponse>> getPendingStatuses() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorPendingStatuses,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => PendingStatusResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<String>> getDepartments() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.departments,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => e.toString()).toList(),
        failure: (_) => [],
      );

  Future<List<String>> getTechnicians() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.technicians,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => e.toString()).toList(),
        failure: (_) => [],
      );

  Future<List<SupervisorAssignedJob>> getAssignedJobs() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorAssignedJobs,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => SupervisorAssignedJob.fromJson(e)).toList(),
        failure: (_) => [],
      );

  // ---------- Seamless flows: booking / breakdown routing ----------

  Future<List<BookingQueueResponse>> getBookingQueue() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorBookings,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) => l.map((e) => BookingQueueResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<BreakdownQueueResponse>> getBreakdownQueue() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorBreakdowns,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => BreakdownQueueResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<List<AssignableStaffResponse>> getAssignableAdvisors() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorAssignableAdvisors,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => AssignableStaffResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<bool> assignBooking(int id, int advisorId) async {
    final r = await _client.put(
      ApiEndpoints.supervisorBookingAssign(id),
      data: {'advisorId': advisorId},
    );
    return r is Success;
  }

  Future<bool> assignBreakdown(int id, int advisorId) async {
    final r = await _client.put(
      ApiEndpoints.supervisorBreakdownAssign(id),
      data: {'advisorId': advisorId},
    );
    return r is Success;
  }

  // ---------- Seamless flows: completion review ----------

  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.supervisorAwaiting,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => AwaitingCompletionResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<bool> approveCompletion(int jobCardId) async {
    final r = await _client.put(
      ApiEndpoints.supervisorApproveCompletion(jobCardId),
    );
    return r is Success;
  }

  Future<bool> rejectCompletion(int jobCardId, String reason) async {
    final r = await _client.put(
      ApiEndpoints.supervisorRejectCompletion(jobCardId),
      data: {'reason': reason},
    );
    return r is Success;
  }

  // FE-FLOW (seamless-flow integration): the QC review gate — previously the
  // frontend had NO call to this endpoint (it was "entirely UI-less").
  Future<bool> qcReview(String jobCardRef, String action,
      {bool checklistPassed = true, String notes = '', String rejectReason = ''}) async {
    final r = await _client.post(
      ApiEndpoints.supervisorQcReview(jobCardRef),
      data: {
        'action': action,
        'checklistPassed': checklistPassed,
        'notes': notes,
        if (rejectReason.isNotEmpty) 'rejectReason': rejectReason,
      },
    );
    return r is Success;
  }

  // ---------- Seamless flows: staff notifications ----------

  Future<List<StaffNotificationResponse>> getStaffNotifications() async =>
      (await _client.get<List<dynamic>>(
        ApiEndpoints.staffNotifications,
        fromJson: (d) => d as List<dynamic>,
      )).when(
        success: (l) =>
            l.map((e) => StaffNotificationResponse.fromJson(e)).toList(),
        failure: (_) => [],
      );

  Future<bool> markStaffNotificationRead(String id) async {
    final r = await _client.put(ApiEndpoints.staffNotificationRead(id));
    return r is Success;
  }
}
