import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/customer/presentation/support/vehicle_booking_decision.dart';

/// The booking guard's decision, tested directly — no Hive, no connectivity, no
/// plugin channels. This is the guarantee that a temporary vehicle id can never
/// reach the online booking API.
class _FakeIdentity implements VehicleIdentityReader {
  _FakeIdentity({this.mapped, this.pending = false, this.failed = false});

  final String? mapped;
  final bool pending;
  final bool failed;

  @override
  String? serverIdFor(String localId) => mapped;

  @override
  bool isPending(String localId) => pending;

  @override
  bool hasFailedCreate(String localId) => failed;
}

void main() {
  group('vehicle booking decision', () {
    test('a workshop vehicle is booked with its own id', () {
      final resolution = decideVehicleBooking(
        selectedVehicleId: 'v1',
        isOnline: true,
        identity: _FakeIdentity(),
      );

      expect(resolution.outcome, VehicleBookingOutcome.persisted);
      expect(resolution.serverId, 'v1');
      expect(resolution.canSubmitOnline, isTrue);
    });

    test('a pending vehicle ONLINE may not be submitted at all', () {
      final resolution = decideVehicleBooking(
        selectedVehicleId: '1723456789',
        isOnline: true,
        identity: _FakeIdentity(pending: true),
      );

      expect(resolution.outcome, VehicleBookingOutcome.pendingOnline);
      expect(
        resolution.serverId,
        isNull,
        reason: 'nothing may be sent for an unregistered vehicle',
      );
      expect(resolution.canSubmitOnline, isFalse);
    });

    test('a pending vehicle OFFLINE keeps its id for a queued booking', () {
      final resolution = decideVehicleBooking(
        selectedVehicleId: '1723456789',
        isOnline: false,
        identity: _FakeIdentity(pending: true),
      );

      expect(resolution.outcome, VehicleBookingOutcome.pendingOffline);
      expect(
        resolution.serverId,
        '1723456789',
        reason: 'the queued payload is rewritten when the vehicle syncs',
      );
      expect(resolution.canSubmitOnline, isFalse);
    });

    test(
      'a reconciled vehicle books with the server id, never the temp id',
      () {
        final resolution = decideVehicleBooking(
          selectedVehicleId: '1723456789',
          isOnline: true,
          identity: _FakeIdentity(mapped: '8472'),
        );

        expect(resolution.outcome, VehicleBookingOutcome.persisted);
        expect(resolution.serverId, '8472');
        expect(resolution.serverId, isNot('1723456789'));
      },
    );

    test('a mapping wins even while the pending marker lingers', () {
      final resolution = decideVehicleBooking(
        selectedVehicleId: '1723456789',
        isOnline: true,
        identity: _FakeIdentity(mapped: '8472', pending: true),
      );

      expect(resolution.outcome, VehicleBookingOutcome.persisted);
      expect(resolution.serverId, '8472');
    });

    test('a registration that failed needs the customer to retry', () {
      final resolution = decideVehicleBooking(
        selectedVehicleId: '1723456789',
        isOnline: true,
        identity: _FakeIdentity(pending: true, failed: true),
      );

      expect(resolution.outcome, VehicleBookingOutcome.failedSync);
      expect(resolution.canSubmitOnline, isFalse);
      expect(resolution.needsVehicleRetry, isTrue);
      expect(resolution.serverId, isNull);
    });

    test('no selection means nothing to book', () {
      final resolution = decideVehicleBooking(
        selectedVehicleId: '  ',
        isOnline: true,
        identity: _FakeIdentity(),
      );

      expect(resolution.outcome, VehicleBookingOutcome.missing);
      expect(resolution.canSubmitOnline, isFalse);
    });
  });
}
