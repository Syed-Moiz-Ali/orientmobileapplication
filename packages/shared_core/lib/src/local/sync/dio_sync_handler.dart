import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_core/src/constants/api_constants.dart' show ApiEndpoints;
import 'package:shared_core/src/local/helpers/environment_config.dart';
import 'package:shared_core/src/local/sync/sync_handler.dart';
import 'package:shared_core/src/local/sync/sync_operation.dart';
import 'package:shared_core/src/local/exceptions/sync_exceptions.dart';

class DioSyncHandler extends SyncHandler {
  @override
  final String entityType;
  final Dio _dio;

  DioSyncHandler(this.entityType, this._dio);

  @override
  Future<bool> execute(SyncOperation operation) async {
    if (operation.entityType == 'attachment') {
      return _executeAttachment(operation);
    }
    // FIX (audit P0): deletes were POSTed to the create endpoint — an offline
    // vehicle delete would re-CREATE the vehicle. Route deletes to DELETE.
    if (operation.changeType == ChangeType.delete) {
      return _executeDelete(operation);
    }
    final endpoint = _getEndpoint(operation);
    if (endpoint == null) {
      return false;
    }
    final url = '${EnvironmentConfig.baseUrl}$endpoint';
    final method = _methodFor(operation.entityType);

    try {
      final response = await _dio.request(
        url,
        data: _payloadFor(operation),
        options: Options(
          method: method,
          headers: {'Idempotency-Key': operation.id},
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      }

      if (response.statusCode == 409) {
        throw ConflictException('Conflict on ${operation.entityType} ${operation.entityId}');
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException('Conflict on ${operation.entityType} ${operation.entityId}');
      }
      rethrow;
    }
  }

  /// Deletes are routed to the entity's DELETE endpoint (only 'vehicle' is
  /// delete-capable today — add mappings here as deletes become supported).
  Future<bool> _executeDelete(SyncOperation operation) async {
    final String? endpoint = switch (operation.entityType) {
      'vehicle' => ApiEndpoints.customerVehicle(operation.entityId),
      _ => null,
    };
    if (endpoint == null) return false;
    final url = '${EnvironmentConfig.baseUrl}$endpoint';
    try {
      final response = await _dio.request(
        url,
        options: Options(
          method: 'DELETE',
          headers: {'Idempotency-Key': operation.id},
        ),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return true; // already gone
      rethrow;
    }
  }

  /// Attachments are uploaded as multipart files to the media endpoint.
  Future<bool> _executeAttachment(SyncOperation operation) async {
    final filePath = operation.payload['filePath'] as String?;
    if (filePath == null || filePath.isEmpty) {
      return false;
    }
    final endpoint = ApiEndpoints.mediaUploadFor(operation.entityId);
    final url = '${EnvironmentConfig.baseUrl}$endpoint';
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        ),
        'itemId': operation.payload['itemId'] ?? '',
        'type': operation.payload['type'] ?? 'photo',
      });
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: {'Idempotency-Key': operation.id}),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException('Conflict on ${operation.entityType} ${operation.entityId}');
      }
      rethrow;
    } on UnsupportedError {
      return false;
    }
  }

  String _methodFor(String entityType) {
    if (entityType == 'technician_job' ||
        entityType == 'work_item' ||
        entityType == 'assigned_job' ||
        entityType == 'job_card' ||
        entityType == 'job_card_technician') {
      return 'PUT';
    }
    return 'POST';
  }

  /// Maps the raw queued payload onto the backend DTO shapes so the server
  /// receives the same fields as its request bodies.
  Map<String, dynamic>? _payloadFor(SyncOperation op) {
    final payload = op.payload;
    switch (op.entityType) {
      case 'job_complete':
        // CompleteJobRequest: jobCardNo, empId, status, tasks[{id,status,startTime,endTime}], notes
        final tasks = (payload['tasks'] as List<dynamic>?)
            ?.map((t) {
              if (t is! Map) return <String, dynamic>{};
              final m = Map<String, dynamic>.from(t);
              return <String, dynamic>{
                if (m['id'] != null) 'id': m['id'].toString(),
                if (m['status'] != null) 'status': m['status'],
                if (m['startTime'] != null) 'startTime': m['startTime'],
                if (m['endTime'] != null) 'endTime': m['endTime'],
              };
            })
            .toList();
        return <String, dynamic>{
          'jobCardNo': payload['jobCardNo'] ?? op.entityId,
          if (payload['empId'] != null) 'empId': payload['empId'],
          if (payload['status'] != null) 'status': payload['status'],
          if (tasks != null) 'tasks': tasks,
          if (payload['notes'] != null) 'notes': payload['notes'],
        };
      case 'approval':
        // ApprovalActionRequest: action (required), customerName, amount
        return <String, dynamic>{
          'action': payload['action'] ?? 'approve',
          if (payload['reason'] != null) 'reason': payload['reason'],
          if (payload['customerName'] != null)
            'customerName': payload['customerName'],
          if (payload['amount'] != null) 'amount': payload['amount'],
        };
      case 'reminder':
        // CreateReminderRequest: customerName, vehicleId, task, dueDate, priority
        return <String, dynamic>{
          if (payload['customerName'] != null)
            'customerName': payload['customerName'],
          if (payload['vehicleId'] != null) 'vehicleId': payload['vehicleId'],
          'task': payload['task'] ?? 'Follow-up',
          if (payload['dueDate'] != null) 'dueDate': payload['dueDate'],
          if (payload['priority'] != null) 'priority': payload['priority'],
        };
      case 'attendance':
        // FIX (audit P0): forward EVERY field and route to the correct
        // endpoint per action — previously all 4 actions POSTed to punch-in
        // and punchOut/breakTime/workHours were dropped, corrupting hours.
        return <String, dynamic>{
          if (payload['empId'] != null) 'empId': payload['empId'],
          if (payload['status'] != null) 'status': payload['status'],
          if (payload['punchIn'] != null) 'punchIn': payload['punchIn'],
          if (payload['punchOut'] != null) 'punchOut': payload['punchOut'],
          if (payload['breakTime'] != null) 'breakTime': payload['breakTime'],
          if (payload['workHours'] != null) 'workHours': payload['workHours'],
          if (payload['date'] != null) 'date': payload['date'],
        };
      case 'assigned_job':
        // FIX (audit P0): entity type was unregistered — offline job status
        // updates failed into sync_failed forever.
        return <String, dynamic>{
          if (payload['empId'] != null) 'empId': payload['empId'],
          'status': payload['status'] ?? 'inProgress',
        };
      case 'job_card':
        return <String, dynamic>{
          'status': payload['status'] ?? 'inProgress',
        };
      case 'job_card_technician':
        return <String, dynamic>{
          if (payload['technician'] != null) 'technician': payload['technician'],
        };
      case 'vehicle':
        // Customer app vehicle payload already matches AddVehicleRequest
        // (brand/model/plateNumber/vin/color/year/mileage/lastService/nextDue).
        return payload;
      case 'technician_job':
        // UpdateAssignedJobStatusRequest: empId, status
        return <String, dynamic>{
          if (payload['empId'] != null) 'empId': payload['empId'],
          'status': payload['status'] ?? 'inProgress',
        };
      case 'vehicle_customer':
        // Flat intake form -> InspectionRequest shape:
        // { type, status, bookingId, customer{...}, vehicle{...}, additional{...} }
        return <String, dynamic>{
          'type': 'vehicle_customer',
          if (payload['status'] != null) 'status': payload['status'],
          if (payload['bookingId'] != null) 'bookingId': payload['bookingId'],
          'customer': <String, dynamic>{
            if (payload['customerName'] != null) 'customerName': payload['customerName'],
            if (payload['phoneNumber'] != null) 'phoneNumber': payload['phoneNumber'],
            if (payload['email'] != null) 'email': payload['email'],
          },
          'vehicle': <String, dynamic>{
            if (payload['registrationNumber'] != null)
              'registrationNumber': payload['registrationNumber'],
            if (payload['vin'] != null) 'vin': payload['vin'],
            if (payload['make'] != null) 'make': payload['make'],
            if (payload['model'] != null) 'model': payload['model'],
            if (payload['modelYear'] != null) 'modelYear': payload['modelYear'],
          },
          'additional': <String, dynamic>{
            if (payload['odometerReading'] != null)
              'odometerReading': payload['odometerReading'],
            if (payload['fuelLevel'] != null) 'fuelLevel': payload['fuelLevel'],
            if (payload['customerConsent'] != null)
              'customerConsent': payload['customerConsent'],
          },
        };
      case 'work_item':
        // WorkItemActionRequest replay: { status | startTime | endTime }
        final action = payload['action'] ?? 'status';
        return <String, dynamic>{
          if (action == 'start' || action == 'status')
            if (payload['startTime'] != null) 'startTime': payload['startTime'],
          if (action == 'complete' || action == 'status')
            if (payload['endTime'] != null) 'endTime': payload['endTime'],
          if (action == 'status')
            if (payload['status'] != null) 'status': payload['status'],
        };
      default:
        return payload;
    }
  }

  String? _getEndpoint(SyncOperation op) {
    switch (op.entityType) {
      case 'inspection':
        return ApiEndpoints.syncInspection(op.entityId);
      case 'repair_order':
        return ApiEndpoints.syncRepairOrder(op.entityId);
      case 'job_complete':
        return ApiEndpoints.jobComplete;
      case 'work_assignment':
        return ApiEndpoints.workAssignments;
      case 'booking':
        return ApiEndpoints.createBooking;
      case 'breakdown':
        return ApiEndpoints.customerBreakdowns;
      case 'vehicle_customer':
        // Advisor intake: creates a real job card server-side (customer,
        // vehicle, inspection tasks + booking link all happen in one call).
        return ApiEndpoints.inspections;
      case 'approval':
        return ApiEndpoints.approvalAction(op.entityId);
      case 'reminder':
        return ApiEndpoints.reminderCreate;
      case 'attendance':
        // FIX (audit P0): route by action — punch-in/out and break start/end
        // have distinct endpoints that were never used by the handler.
        final action = op.payload['action'] ?? 'punchIn';
        return switch (action) {
          'punchOut' => ApiEndpoints.attendancePunchOut,
          'breakStart' => ApiEndpoints.attendanceBreakStart,
          'breakEnd' => ApiEndpoints.attendanceBreakEnd,
          _ => ApiEndpoints.attendancePunchIn,
        };
      case 'technician_job':
        return ApiEndpoints.technicianAssignedJobStatus(op.entityId);
      case 'assigned_job':
        return ApiEndpoints.technicianAssignedJobStatus(op.entityId);
      case 'job_card':
        return ApiEndpoints.advisorJobCardStatus(op.entityId);
      case 'job_card_technician':
        return ApiEndpoints.advisorJobCardTechnician(op.entityId);
      case 'vehicle':
        return ApiEndpoints.customerVehicles;
      case 'work_item':
        // Offline replay of a per-item action on the legacy task endpoint,
        // which the backend routes through the same completion gate.
        final parts = op.entityId.split('|');
        if (parts.length < 3) return null;
        return ApiEndpoints.technicianTask(parts[0], parts[1], parts[2]);
      case 'attachment':
        // Attachments are uploaded through the multipart media endpoint when a
        // local file is available; otherwise they are left in the failed box.
        return ApiEndpoints.mediaUploadFor(op.entityId);
      default:
        return null;
    }
  }
}
