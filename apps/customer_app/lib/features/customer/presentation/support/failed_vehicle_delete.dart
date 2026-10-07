import 'package:customer_app/core/local/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

/// A vehicle removal the customer asked for that the workshop never confirmed.
///
/// Unlike a failed vehicle create, this means the vehicle most likely still
/// exists at the workshop, so the app must converge back to that server truth
/// instead of continuing to hide it locally.
class FailedVehicleDelete {
  /// The stable identity of the failed delete.
  final String operationId;

  /// The authoritative server vehicle id the delete targets.
  final String vehicleId;

  const FailedVehicleDelete({
    required this.operationId,
    required this.vehicleId,
  });

  factory FailedVehicleDelete.fromOperation(SyncOperation operation) =>
      FailedVehicleDelete(
        operationId: operation.id,
        vehicleId: operation.entityId,
      );
}

/// Failed vehicle deletes, read from the sync engine's own failed store.
abstract interface class FailedVehicleDeleteSync {
  /// The failed vehicle deletes, oldest first. Empty when there is nothing to
  /// recover.
  List<FailedVehicleDelete> failedDeletes();

  /// Replays exactly one failed delete through the precise retry API. Returns
  /// true when the workshop confirmed the vehicle is gone.
  Future<bool> retry(String operationId);
}

class StoreFailedVehicleDeleteSync implements FailedVehicleDeleteSync {
  StoreFailedVehicleDeleteSync(this._ref);

  final Ref _ref;

  static const _failedBoxName = 'sync_failed';

  @override
  List<FailedVehicleDelete> failedDeletes() {
    try {
      final operations = Hive.box<SyncOperation>(
        _failedBoxName,
      ).values.where(_isFailedVehicleDelete).toList();
      operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return operations.map(FailedVehicleDelete.fromOperation).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> retry(String operationId) async {
    // Only ever replay an operation this seam classifies as a failed vehicle
    // delete, so an unrelated id can never be sent.
    final known = failedDeletes().any(
      (operation) => operation.operationId == operationId,
    );
    if (!known) return false;
    try {
      return await _ref
          .read(syncEngineProvider)
          .retryFailedOperation(operationId);
    } catch (_) {
      return false;
    }
  }

  /// Strictly a vehicle DELETE — a failed vehicle create is a different, already
  /// handled state and must never trigger delete recovery.
  static bool _isFailedVehicleDelete(SyncOperation operation) =>
      operation.entityType == 'vehicle' &&
      operation.changeType == ChangeType.delete;
}

/// The recovery seam. A test replaces this with a fake so no Hive box is needed.
final failedVehicleDeleteSyncProvider = Provider<FailedVehicleDeleteSync>(
  (ref) => StoreFailedVehicleDeleteSync(ref),
);

/// The failed vehicle deletes currently needing customer recovery.
final customerFailedVehicleDeletesProvider =
    Provider<List<FailedVehicleDelete>>(
      (ref) => ref.watch(failedVehicleDeleteSyncProvider).failedDeletes(),
    );
