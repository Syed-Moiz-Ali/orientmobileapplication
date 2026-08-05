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
    if (entityType == 'technician_job') return 'PUT';
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
        // PunchInRequest: empId, status, punchIn, date
        return <String, dynamic>{
          if (payload['empId'] != null) 'empId': payload['empId'],
          if (payload['status'] != null) 'status': payload['status'],
          if (payload['punchIn'] != null) 'punchIn': payload['punchIn'],
          if (payload['date'] != null) 'date': payload['date'],
        };
      case 'technician_job':
        // UpdateAssignedJobStatusRequest: empId, status
        return <String, dynamic>{
          if (payload['empId'] != null) 'empId': payload['empId'],
          'status': payload['status'] ?? 'inProgress',
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
      case 'vehicle_customer':
        return ApiEndpoints.customerVehicles;
      case 'approval':
        return ApiEndpoints.approvalAction(op.entityId);
      case 'reminder':
        return ApiEndpoints.reminderCreate;
      case 'attendance':
        return ApiEndpoints.attendancePunchIn;
      case 'technician_job':
        return ApiEndpoints.technicianAssignedJobStatus(op.entityId);
      case 'attachment':
        // Attachments are uploaded through the multipart media endpoint when a
        // local file is available; otherwise they are left in the failed box.
        return ApiEndpoints.mediaUploadFor(op.entityId);
      default:
        return null;
    }
  }
}
