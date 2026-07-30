import 'package:shared_core/src/constants/api_constants.dart';
import 'package:shared_core/src/models/sync_models.dart';
import 'package:shared_core/src/network/api_client.dart';

class SyncClient {
  final ApiClient _client;
  SyncClient(this._client);

  Future<SyncResponse> syncInspection(String id, Map<String, dynamic> data) async {
    final r = await _client.post<SyncResponse>(
      ApiEndpoints.syncInspection(id), data: data,
      fromJson: (d) => SyncResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const SyncResponse());
  }

  Future<SyncResponse> syncJobComplete(String id, Map<String, dynamic> data) async {
    final r = await _client.post<SyncResponse>(
      ApiEndpoints.syncJobCompleteById(id), data: data,
      fromJson: (d) => SyncResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const SyncResponse());
  }

  Future<SyncResponse> syncRepairOrder(String id, Map<String, dynamic> data) async {
    final r = await _client.post<SyncResponse>(
      ApiEndpoints.syncRepairOrder(id), data: data,
      fromJson: (d) => SyncResponse.fromJson(d as Map<String, dynamic>));
    return r.when(success: (v) => v, failure: (_) => const SyncResponse());
  }
}
