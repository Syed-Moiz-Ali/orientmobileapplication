import 'package:shared_core/shared_core.dart';

class SupervisorRemoteDataSource {
  final ApiClient _client;
  SupervisorRemoteDataSource(this._client);

  Future<List<T>> _getObjects<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final result = await _client.get<List<dynamic>>(
      path,
      fromJson: (data) => data as List<dynamic>,
    );
    return result
        .unwrapOrThrow()
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<String>> _getStrings(String path) async {
    final result = await _client.get<List<dynamic>>(
      path,
      fromJson: (data) => data as List<dynamic>,
    );
    return result.unwrapOrThrow().map((value) => value.toString()).toList();
  }

  Future<List<KpiResponse>> getKpis() =>
      _getObjects(ApiEndpoints.supervisorKpis, KpiResponse.fromJson);

  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() => _getObjects(
    ApiEndpoints.supervisorAdvisorJobs,
    AdvisorJobCountResponse.fromJson,
  );

  Future<List<JobTypeResponse>> getJobTypes() =>
      _getObjects(ApiEndpoints.supervisorJobTypes, JobTypeResponse.fromJson);

  Future<List<RevenueMetricResponse>> getRevenueMetrics() => _getObjects(
    ApiEndpoints.supervisorRevenueMetrics,
    RevenueMetricResponse.fromJson,
  );

  Future<List<PendingStatusResponse>> getPendingStatuses() => _getObjects(
    ApiEndpoints.supervisorPendingStatuses,
    PendingStatusResponse.fromJson,
  );

  Future<List<String>> getDepartments() =>
      _getStrings(ApiEndpoints.departments);

  Future<List<String>> getTechnicians() =>
      _getStrings(ApiEndpoints.technicians);

  Future<List<SupervisorAssignedJob>> getAssignedJobs() => _getObjects(
    ApiEndpoints.supervisorAssignedJobs,
    SupervisorAssignedJob.fromJson,
  );

  // ---------- Seamless flows: booking / breakdown routing ----------

  Future<List<BookingQueueResponse>> getBookingQueue() => _getObjects(
    ApiEndpoints.supervisorBookings,
    BookingQueueResponse.fromJson,
  );

  Future<List<BreakdownQueueResponse>> getBreakdownQueue() => _getObjects(
    ApiEndpoints.supervisorBreakdowns,
    BreakdownQueueResponse.fromJson,
  );

  Future<List<AssignableStaffResponse>> getAssignableAdvisors() => _getObjects(
    ApiEndpoints.supervisorAssignableAdvisors,
    AssignableStaffResponse.fromJson,
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

  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() =>
      _getObjects(
        ApiEndpoints.supervisorAwaiting,
        AwaitingCompletionResponse.fromJson,
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
  Future<bool> qcReview(
    String jobCardRef,
    String action, {
    bool checklistPassed = true,
    String notes = '',
    String rejectReason = '',
  }) async {
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

  Future<List<StaffNotificationResponse>> getStaffNotifications() =>
      _getObjects(
        ApiEndpoints.staffNotifications,
        StaffNotificationResponse.fromJson,
      );

  Future<bool> markStaffNotificationRead(String id) async {
    final r = await _client.put(ApiEndpoints.staffNotificationRead(id));
    return r is Success;
  }
}
