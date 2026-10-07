import 'package:customer_app/core/local/sync_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

/// A booking the customer saved on this device whose replay to the workshop has
/// terminally failed: the device still holds it, but the workshop never
/// received it. Recovery state, not history.
class FailedBooking {
  /// The stable identity of the failed create — the same id the customer's
  /// device stored the booking under.
  final String operationId;
  final String vehicleName;
  final String plateNumber;
  final String service;
  final String date;
  final String time;
  final String notes;

  const FailedBooking({
    required this.operationId,
    required this.vehicleName,
    required this.plateNumber,
    required this.service,
    required this.date,
    required this.time,
    required this.notes,
  });

  /// Reads only fields genuinely present in the queued booking payload.
  factory FailedBooking.fromOperation(SyncOperation operation) {
    String read(String key) => (operation.payload[key] ?? '').toString().trim();
    return FailedBooking(
      operationId: operation.id,
      vehicleName: read('vehicleName'),
      plateNumber: read('plateNumber'),
      service: read('serviceType'),
      date: read('bookingDate'),
      time: read('bookingTime'),
      notes: read('notes'),
    );
  }

  /// The identity the bookings feed uses to reconcile the device cache with the
  /// workshop feed, so a failed booking maps back to its cached record.
  String get identityKey => CustomerBookingsPresentation.bookingKey(
    vehicleName: vehicleName,
    plateNumber: plateNumber,
    service: service,
    date: date,
    time: time,
  );
}

/// Failed booking creates, read from the sync engine's own failed store.
abstract interface class FailedBookingSync {
  /// The failed booking creates, oldest first. Empty when there is nothing to
  /// recover.
  List<FailedBooking> failedBookings();

  /// Replays exactly one failed booking create through the precise retry API.
  /// Returns true when the workshop accepted it.
  Future<bool> retry(String operationId);

  /// Discards one failed booking that cannot be delivered: its failed
  /// operation, any queue copy, and its provisional device record.
  Future<void> remove(String operationId);
}

class StoreFailedBookingSync implements FailedBookingSync {
  StoreFailedBookingSync(this._ref);

  final Ref _ref;

  static const _failedBoxName = 'sync_failed';
  static const _queueBoxName = 'sync_queue';

  @override
  List<FailedBooking> failedBookings() {
    try {
      final operations = Hive.box<SyncOperation>(
        _failedBoxName,
      ).values.where(_isFailedBookingCreate).toList();
      operations.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return operations.map(FailedBooking.fromOperation).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> retry(String operationId) async {
    // Only ever replay an operation this seam classifies as a failed booking
    // create, so an unrelated id can never be sent.
    final known = failedBookings().any(
      (booking) => booking.operationId == operationId,
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

  @override
  Future<void> remove(String operationId) async {
    final matches = failedBookings()
        .where((booking) => booking.operationId == operationId)
        .toList();
    if (matches.isEmpty) return;
    final identityKey = matches.first.identityKey;

    await _deleteOperation(_failedBoxName, operationId);
    // A copy can still be waiting in the send queue; removing the failed booking
    // must not leave a copy behind that would arrive later.
    await _deleteOperation(_queueBoxName, operationId);
    await _deleteProvisionalRecord(operationId);
    await _deleteCachedBooking(identityKey);
  }

  Future<void> _deleteOperation(String boxName, String id) async {
    try {
      final box = Hive.box<SyncOperation>(boxName);
      if (box.containsKey(id)) await box.delete(id);
    } catch (_) {}
  }

  Future<void> _deleteProvisionalRecord(String operationId) async {
    try {
      final box = Hive.box<dynamic>('customer_cache');
      if (box.containsKey('booking_$operationId')) {
        await box.delete('booking_$operationId');
      }
    } catch (_) {}
  }

  Future<void> _deleteCachedBooking(String identityKey) async {
    try {
      final box = Hive.box<dynamic>('customer_cache');
      final cached = box.get('cached_bookings');
      if (cached is! List) return;
      final kept = cached.where((entry) {
        if (entry is! Map) return true;
        return _cachedIdentityKey(entry) != identityKey;
      }).toList();
      await box.put('cached_bookings', kept);
    } catch (_) {}
  }

  static String _cachedIdentityKey(
    Map entry,
  ) => CustomerBookingsPresentation.bookingKey(
    vehicleName: (entry['vehicleName'] ?? entry['vehicle'] ?? '').toString(),
    plateNumber: (entry['plateNumber'] ?? entry['vehiclePlate'] ?? '')
        .toString(),
    service: (entry['serviceType'] ?? entry['serviceName'] ?? '').toString(),
    date: (entry['bookingDate'] ?? entry['date'] ?? '').toString(),
    time: (entry['time'] ?? '').toString(),
  );

  static bool _isFailedBookingCreate(SyncOperation operation) =>
      operation.entityType == 'booking' &&
      operation.changeType == ChangeType.create;
}

/// The recovery seam. A test replaces this with a fake so no Hive box is needed.
final failedBookingSyncProvider = Provider<FailedBookingSync>(
  (ref) => StoreFailedBookingSync(ref),
);

/// The failed booking creates currently needing customer recovery.
final customerFailedBookingsProvider = Provider<List<FailedBooking>>(
  (ref) => ref.watch(failedBookingSyncProvider).failedBookings(),
);
