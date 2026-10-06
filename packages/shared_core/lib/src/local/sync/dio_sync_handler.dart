import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
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
    final method = _methodFor(operation);

    try {
      final response = await _dio.request(
        url,
        data: _payloadFor(operation),
        options: Options(
          method: method,
          headers: {'Idempotency-Key': operation.id},
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (operation.entityType == 'vehicle_customer') {
          await _cacheIntakeResponse(operation, response.data);
          await _uploadIntakeMedia(response.data, operation.payload);
        }
        return true;
      }

      if (response.statusCode == 409) {
        throw ConflictException(
          'Conflict on ${operation.entityType} ${operation.entityId}',
        );
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException(
          'Conflict on ${operation.entityType} ${operation.entityId}',
        );
      }
      rethrow;
    }
  }

  /// After the intake is accepted, store the server-assigned job card
  /// reference on the local intake record so the follow-up inspection can be
  /// linked to the exact job card the backend created.
  Future<void> _cacheIntakeResponse(
    SyncOperation operation,
    dynamic responseBody,
  ) async {
    dynamic body = responseBody;
    if (body is Map && body['data'] != null) body = body['data'];
    if (body is! Map) return;
    try {
      final box = Hive.box<dynamic>('inspections');
      final existing = box.get(operation.entityId);
      final record = existing is Map
          ? Map<String, dynamic>.from(existing)
          : <String, dynamic>{
              'id': operation.entityId,
              'type': 'vehicle_customer',
            };
      record['jobCardRef'] = body['jobCardRef']?.toString() ?? '';
      record['serverJobCardId'] = body['jobCardId']?.toString() ?? '';
      record['inspectionId'] = body['id']?.toString() ?? '';
      await box.put(operation.entityId, record);
    } catch (_) {
      // Local caching is best-effort; the server remains the source of truth.
    }
  }

  Future<void> _uploadIntakeMedia(
    dynamic responseBody,
    Map<String, dynamic> payload,
  ) async {
    dynamic body = responseBody;
    if (body is Map && body['data'] != null) body = body['data'];
    final recordId = body is Map ? body['id']?.toString() ?? '' : '';
    if (recordId.isEmpty) return;

    final uploads = <({String path, String itemId, String type})>[];
    for (final path in (payload['jobPhotoPaths'] as List? ?? const [])) {
      if (path.toString().isNotEmpty) {
        uploads.add((path: path.toString(), itemId: 'job-card', type: 'photo'));
      }
    }
    for (final path in (payload['jobVideoPaths'] as List? ?? const [])) {
      if (path.toString().isNotEmpty) {
        uploads.add((path: path.toString(), itemId: 'job-card', type: 'video'));
      }
    }
    for (final raw in (payload['jobDescriptionMedia'] as List? ?? const [])) {
      if (raw is! Map) continue;
      final path = raw['path']?.toString() ?? '';
      final itemId = raw['itemId']?.toString() ?? '';
      final type = raw['type']?.toString() ?? '';
      if (path.isNotEmpty && itemId.isNotEmpty && type.isNotEmpty) {
        uploads.add((path: path, itemId: itemId, type: type));
      }
    }
    final customerSignature =
        payload['customerSignaturePath']?.toString() ?? '';
    if (customerSignature.isNotEmpty) {
      uploads.add((
        path: customerSignature,
        itemId: 'customer-signature',
        type: 'signature',
      ));
    }
    final advisorSignature = payload['advisorSignaturePath']?.toString() ?? '';
    if (advisorSignature.isNotEmpty) {
      uploads.add((
        path: advisorSignature,
        itemId: 'advisor-signature',
        type: 'signature',
      ));
    }
    final registrationDocument =
        payload['registrationDocumentPath']?.toString() ?? '';
    if (registrationDocument.isNotEmpty) {
      uploads.add((
        path: registrationDocument,
        itemId: 'registration-certificate',
        type: 'document',
      ));
    }
    final insuranceDocument =
        payload['insuranceDocumentPath']?.toString() ?? '';
    if (insuranceDocument.isNotEmpty) {
      uploads.add((
        path: insuranceDocument,
        itemId: 'insurance-document',
        type: 'document',
      ));
    }

    final endpoint = _mediaEndpoint(recordId, 'inspections');
    final url = '${EnvironmentConfig.baseUrl}$endpoint';
    for (final upload in uploads) {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          upload.path,
          filename: upload.path.split(RegExp(r'[/\\]')).last,
        ),
        'itemId': upload.itemId,
        'type': upload.type,
      });
      await _dio.post(url, data: formData);
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
    final endpoint = _mediaEndpoint(
      operation.entityId,
      operation.payload['module']?.toString(),
    );
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
        throw ConflictException(
          'Conflict on ${operation.entityType} ${operation.entityId}',
        );
      }
      rethrow;
    } on UnsupportedError {
      return false;
    }
  }

  String _methodFor(SyncOperation operation) {
    final entityType = operation.entityType;
    if (entityType == 'vehicle' && operation.changeType == ChangeType.update) {
      return 'PUT';
    }
    if (entityType == 'technician_job' &&
        operation.payload['status'] == 'completed') {
      return 'POST';
    }
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
        final tasks = (payload['tasks'] as List<dynamic>?)?.map((t) {
          if (t is! Map) return <String, dynamic>{};
          final m = Map<String, dynamic>.from(t);
          return <String, dynamic>{
            if (m['id'] != null) 'id': m['id'].toString(),
            if (m['status'] != null) 'status': m['status'],
            if (m['startTime'] != null) 'startTime': m['startTime'],
            if (m['endTime'] != null) 'endTime': m['endTime'],
          };
        }).toList();
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
        return <String, dynamic>{'status': payload['status'] ?? 'inProgress'};
      case 'job_card_technician':
        return <String, dynamic>{
          if (payload['technician'] != null)
            'technician': payload['technician'],
        };
      case 'vehicle':
        // Customer app vehicle payload matches AddVehicleRequest.
        // Ensure healthScore is within [0, 100].
        final p = Map<String, dynamic>.from(payload);
        final rawHealth = p['healthScore'];
        if (rawHealth is int && (rawHealth < 0 || rawHealth > 100)) {
          p['healthScore'] = 100;
        }
        return p;
      case 'booking':
        // CreateBookingRequest: vehicleId, vehicleName, plateNumber,
        // serviceType, bookingDate, bookingTime, notes.
        return <String, dynamic>{
          if (payload['vehicleId'] != null)
            'vehicleId': payload['vehicleId'].toString(),
          if (payload['vehicleName'] != null)
            'vehicleName': payload['vehicleName'],
          if (payload['plateNumber'] != null)
            'plateNumber': payload['plateNumber'],
          'serviceType':
              payload['serviceType'] ?? payload['service'] ?? 'Service',
          if (payload['bookingDate'] != null)
            'bookingDate': payload['bookingDate'],
          if (payload['bookingTime'] != null)
            'bookingTime': payload['bookingTime'],
          if (payload['notes'] != null) 'notes': payload['notes'],
        };
      case 'technician_job':
        if (payload['status'] == 'completed') {
          final tasks = (payload['tasks'] as List<dynamic>?)?.map((t) {
            if (t is! Map) return <String, dynamic>{};
            final m = Map<String, dynamic>.from(t);
            return <String, dynamic>{
              if (m['id'] != null) 'id': m['id'].toString(),
              if (m['status'] != null) 'status': m['status'],
              if (m['startTime'] != null) 'startTime': m['startTime'],
              if (m['endTime'] != null) 'endTime': m['endTime'],
            };
          }).toList();
          return <String, dynamic>{
            'jobCardNo': op.entityId,
            if (payload['empId'] != null) 'empId': payload['empId'],
            'status': 'completed',
            if (tasks != null) 'tasks': tasks,
            if (payload['notes'] != null) 'notes': payload['notes'],
          };
        }
        // UpdateAssignedJobStatusRequest: empId, status
        return <String, dynamic>{
          if (payload['empId'] != null) 'empId': payload['empId'],
          'status': payload['status'] ?? 'inProgress',
        };
      case 'vehicle_customer':
        return buildVehicleCustomerIntakePayload(payload);
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
      case 'inspection':
        // Carry checkpoint notes alongside the sections so an offline
        // inspection also persists its notes when it eventually syncs.
        final notes = <Map<String, String>>[];
        final media = payload['media'];
        if (media is Map) {
          media.forEach((key, value) {
            if (value is Map) {
              final note = value['note']?.toString().trim() ?? '';
              if (note.isNotEmpty) {
                notes.add({'itemId': key.toString(), 'note': note});
              }
            }
          });
        }
        return <String, dynamic>{
          ...payload,
          if (notes.isNotEmpty) 'itemNotes': notes,
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
        if (op.payload['status'] == 'completed') {
          return ApiEndpoints.jobComplete;
        }
        return ApiEndpoints.technicianAssignedJobStatus(op.entityId);
      case 'assigned_job':
        return ApiEndpoints.technicianAssignedJobStatus(op.entityId);
      case 'job_card':
        return ApiEndpoints.advisorJobCardStatus(op.entityId);
      case 'job_card_technician':
        return ApiEndpoints.advisorJobCardTechnician(op.entityId);
      case 'vehicle':
        return op.changeType == ChangeType.update
            ? ApiEndpoints.customerVehicle(op.entityId)
            : ApiEndpoints.customerVehicles;
      case 'work_item':
        // Offline replay of a per-item action on the legacy task endpoint,
        // which the backend routes through the same completion gate.
        final parts = op.entityId.split('|');
        if (parts.length < 3) return null;
        return ApiEndpoints.technicianTask(parts[0], parts[1], parts[2]);
      case 'attachment':
        // Attachments are uploaded through the multipart media endpoint when a
        // local file is available; otherwise they are left in the failed box.
        return _mediaEndpoint(op.entityId, op.payload['module']?.toString());
      default:
        return null;
    }
  }

  String _mediaEndpoint(String recordId, String? module) {
    return switch (module) {
      'repair-orders' => ApiEndpoints.repairOrderMediaUpload(recordId),
      _ => ApiEndpoints.inspectionMediaUpload(recordId),
    };
  }
}

/// Converts the flat advisor intake form payload into the backend
/// `InspectionRequest` shape. Shared by the offline sync handler and the
/// online intake call so both reach the backend identically.
Map<String, dynamic> buildVehicleCustomerIntakePayload(
  Map<String, dynamic> payload,
) {
  return <String, dynamic>{
    'type': 'vehicle_customer',
    if (payload['status'] != null) 'status': payload['status'],
    if (payload['bookingId'] != null) 'bookingId': payload['bookingId'],
    'customer': <String, dynamic>{
      if (payload['isB2B'] != null) 'isB2B': payload['isB2B'],
      if (payload['customerName'] != null)
        'customerName': payload['customerName'],
      if (payload['phoneNumber'] != null) 'phoneNumber': payload['phoneNumber'],
      if (payload['email'] != null) 'email': payload['email'],
      if (payload['customerGroup'] != null)
        'customerGroup': payload['customerGroup'],
      if (payload['gender'] != null) 'gender': payload['gender'],
      if (payload['address'] != null) 'address': payload['address'],
      if (payload['taxNumber'] != null) 'taxNumber': payload['taxNumber'],
      if (payload['source'] != null) 'source': payload['source'],
    },
    'vehicle': <String, dynamic>{
      if (payload['emirate'] != null) 'emirate': payload['emirate'],
      if (payload['plateCode'] != null) 'plateCode': payload['plateCode'],
      if (payload['plateNumber'] != null) 'plateNumber': payload['plateNumber'],
      if (payload['registrationNumber'] != null)
        'registrationNumber': payload['registrationNumber'],
      if (payload['vin'] != null) 'vin': payload['vin'],
      if (payload['make'] != null) 'make': payload['make'],
      if (payload['model'] != null) 'model': payload['model'],
      if (payload['modelYear'] != null) 'modelYear': payload['modelYear'],
      if (payload['cylinders'] != null) 'cylinders': payload['cylinders'],
      if (payload['engineCapacity'] != null)
        'engineCapacity': payload['engineCapacity'],
      if (payload['vehicleColor'] != null)
        'vehicleColor': payload['vehicleColor'],
      if (payload['fuelType'] != null) 'fuelType': payload['fuelType'],
      if (payload['engineNumber'] != null)
        'engineNumber': payload['engineNumber'],
      if (payload['insuranceProvider'] != null)
        'insuranceProvider': payload['insuranceProvider'],
      if (payload['insuranceTaxNumber'] != null)
        'insuranceTaxNumber': payload['insuranceTaxNumber'],
      if (payload['insuranceAddress'] != null)
        'insuranceAddress': payload['insuranceAddress'],
      if (payload['policyNumber'] != null)
        'policyNumber': payload['policyNumber'],
      if (payload['lpoNumber'] != null) 'lpoNumber': payload['lpoNumber'],
      if (payload['accidentNumber'] != null)
        'accidentNumber': payload['accidentNumber'],
      if (payload['insuranceExpiryDate'] != null)
        'insuranceExpiryDate': payload['insuranceExpiryDate'],
    },
    'additional': <String, dynamic>{
      if (payload['odometerReading'] != null)
        'odometerReading': payload['odometerReading'],
      if (payload['fuelLevel'] != null) 'fuelLevel': payload['fuelLevel'],
      if (payload['customerConsent'] != null)
        'customerConsent': payload['customerConsent'],
      if (payload['jobCategory'] != null) 'jobCategory': payload['jobCategory'],
      if (payload['markupType'] != null) 'markupType': payload['markupType'],
      if (payload['orderType'] != null) 'orderType': payload['orderType'],
      if (payload['jobDescription'] != null)
        'jobDescription': payload['jobDescription'],
      if (payload['jobDescriptions'] != null)
        'jobDescriptions': payload['jobDescriptions'],
    },
    if (payload['jobDescription'] != null)
      'customerRequests': payload['jobDescription'],
  };
}
