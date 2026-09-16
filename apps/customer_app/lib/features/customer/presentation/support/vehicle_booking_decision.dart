import 'package:customer_app/core/local/vehicle_identity_store.dart';

/// What the customer is allowed to do with the vehicle they selected.
///
/// This is the whole decision, expressed as data so it can be unit-tested
/// without Hive, connectivity or any plugin channel. The plugin-backed state is
/// read through [VehicleIdentityReader]; the side effect (submit or queue) lives
/// in the booking path.
enum VehicleBookingOutcome {
  /// A vehicle the workshop knows: book it with [VehicleBookingResolution.serverId].
  persisted,

  /// Created offline and still on its way: only a queued booking is honest.
  pendingOffline,

  /// Created offline while the device is online: the booking API must not be
  /// called until the vehicle is registered.
  pendingOnline,

  /// The workshop never accepted it: the customer needs an explicit retry.
  failedSync,

  /// No usable vehicle was selected.
  missing,
}

class VehicleBookingResolution {
  final VehicleBookingOutcome outcome;

  /// The id that may be sent to the booking API, when there is one.
  final String? serverId;

  const VehicleBookingResolution(this.outcome, [this.serverId]);

  bool get canSubmitOnline => outcome == VehicleBookingOutcome.persisted;
  bool get needsVehicleRetry => outcome == VehicleBookingOutcome.failedSync;
}

/// The identity facts the decision needs, read from local state.
abstract interface class VehicleIdentityReader {
  /// The server id a temporary local id has been reconciled to, if any.
  String? serverIdFor(String localId);

  /// True while the workshop has not accepted this vehicle.
  bool isPending(String localId);

  /// True when the vehicle's registration has exhausted its retries.
  bool hasFailedCreate(String localId);
}

/// Reads the durable local identity state (Hive + the sync engine's failed
/// queue). This is the only plugin/storage-aware part.
class StoreVehicleIdentityReader implements VehicleIdentityReader {
  const StoreVehicleIdentityReader();

  @override
  String? serverIdFor(String localId) =>
      VehicleIdentityStore.serverIdFor(localId);

  @override
  bool isPending(String localId) => VehicleIdentityStore.isPending(localId);

  @override
  bool hasFailedCreate(String localId) =>
      VehicleIdentityStore.hasFailedCreate(localId);
}

/// The single decision: may this vehicle be booked, and with which id?
///
/// Pure — no storage, no plugins — so the online-submit guarantee is directly
/// verifiable.
VehicleBookingResolution decideVehicleBooking({
  required String selectedVehicleId,
  required bool isOnline,
  required VehicleIdentityReader identity,
}) {
  final id = selectedVehicleId.trim();
  if (id.isEmpty) {
    return const VehicleBookingResolution(VehicleBookingOutcome.missing);
  }

  final mapped = identity.serverIdFor(id);
  if (mapped != null && mapped.isNotEmpty) {
    return VehicleBookingResolution(VehicleBookingOutcome.persisted, mapped);
  }
  if (!identity.isPending(id)) {
    return VehicleBookingResolution(VehicleBookingOutcome.persisted, id);
  }
  // Not registered yet: the failure state is terminal and needs an explicit
  // retry; otherwise only a queued (offline) booking is honest.
  if (identity.hasFailedCreate(id)) {
    return const VehicleBookingResolution(VehicleBookingOutcome.failedSync);
  }
  return VehicleBookingResolution(
    isOnline
        ? VehicleBookingOutcome.pendingOnline
        : VehicleBookingOutcome.pendingOffline,
    isOnline ? null : id,
  );
}
