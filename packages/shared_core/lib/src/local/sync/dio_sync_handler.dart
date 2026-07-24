import 'package:dio/dio.dart';
import 'package:shared_core/src/constants/api_constants.dart';
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
    final endpoint = _getEndpoint(operation);
    final url = '${EnvironmentConfig.baseUrl}$endpoint';

    try {
      final response = await _dio.post(
        url,
        data: operation.payload,
        options: Options(
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

  String _getEndpoint(SyncOperation op) {
    switch (op.entityType) {
      case 'inspection':
        return '${ApiConstants.inspections}/${op.entityId}';
      case 'job_complete':
        return '${ApiConstants.jobComplete}/${op.entityId}';
      case 'work_assignment':
        return ApiConstants.workAssignments;
      case 'booking':
        return ApiConstants.bookings;
      case 'repair_order':
        return '${ApiConstants.repairOrders}/${op.entityId}';
      default:
        throw ArgumentError('Unknown entity type: ${op.entityType}');
    }
  }
}
