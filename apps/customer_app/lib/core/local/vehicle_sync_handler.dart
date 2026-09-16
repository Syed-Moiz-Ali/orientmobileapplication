import 'package:dio/dio.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/local/vehicle_identity_store.dart';

/// Vehicle sync with identity reconciliation.
///
/// The shared handler discards every mutation response, so a vehicle created
/// offline kept its temporary local id forever — and that id could later be
/// submitted to the booking API. This handler only takes over vehicle CREATE:
/// it posts the same documented payload, reads the authoritative server id
/// from the response, and reconciles local identity through
/// [reconcileVehicleIdentity]. Updates and deletes keep the shared behaviour
/// exactly.
class VehicleSyncHandler implements SyncHandler {
  VehicleSyncHandler(this._dio, this._queue);

  final Dio _dio;
  final SyncQueue _queue;
  late final DioSyncHandler _delegate = DioSyncHandler(entityType, _dio);

  @override
  String get entityType => 'vehicle';

  @override
  Future<bool> execute(SyncOperation operation) async {
    if (operation.changeType != ChangeType.create) {
      return _delegate.execute(operation);
    }

    final response = await _dio.post<dynamic>(
      ApiEndpoints.customerVehicles,
      data: operation.payload,
      // Same idempotency protection the shared handler applies, so a replayed
      // create returns the original response instead of a duplicate vehicle.
      options: Options(headers: {'Idempotency-Key': operation.id}),
    );
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return false;
    }

    final serverId = _serverIdFrom(response.data);
    if (serverId.isNotEmpty) {
      await reconcileVehicleIdentity(
        tempId: operation.entityId,
        serverId: serverId,
        queue: _queue,
      );
    }
    return true;
  }

  /// The authoritative id from the API envelope (`data.id`).
  static String _serverIdFrom(dynamic body) {
    var payload = body;
    if (payload is Map && payload.containsKey('data')) {
      payload = payload['data'];
    }
    if (payload is Map) return (payload['id'] ?? '').toString().trim();
    return '';
  }
}
