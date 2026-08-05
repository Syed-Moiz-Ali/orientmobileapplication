import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';

void main() {
  group('CustomerBookingEntity', () {
    test('round-trips through JSON', () {
      const booking = CustomerBookingEntity(
        service: 'Oil Change & Filter',
        vehicleName: 'BMW 3 Series',
        plateNumber: 'AB19 XYZ',
        date: '5 Apr 2026',
        time: '10:00 AM',
        status: BookingStatus.confirmed,
      );
      final restored = CustomerBookingEntity.fromJson(booking.toJson());
      expect(restored.service, booking.service);
      expect(restored.status, BookingStatus.confirmed);
      expect(restored.statusLabel, 'Confirmed');
    });

    test('unknown status falls back to pending', () {
      final booking = CustomerBookingEntity.fromJson({
        'service': 'S',
        'vehicleName': 'V',
        'plateNumber': 'P',
        'date': 'd',
        'time': 't',
        'status': 'weird',
      });
      expect(booking.status, BookingStatus.pending);
      expect(booking.statusLabel, 'Pending');
    });
  });

  group('CustomerVehicleEntity', () {
    test('displayName combines brand and model', () {
      const vehicle = CustomerVehicleEntity(
        id: 'V1',
        brand: 'Toyota',
        model: 'Camry',
        plateNumber: 'ABC-123',
        vin: 'VIN123',
        color: 'White',
        year: 2022,
        mileage: '12000 km',
        lastService: 'Jun 2026',
        nextDue: 'Sep 2026',
        healthScore: 92,
      );
      expect(vehicle.displayName, 'Toyota Camry');
      expect(vehicle.shortLabel, 'Toyota Camry · ABC-123');
    });
  });

  group('ServiceStageEntity', () {
    test('parses statuses', () {
      final stage = ServiceStageEntity.fromJson({
        'name': 'In Workshop',
        'status': 'inProgress',
      });
      expect(stage.name, 'In Workshop');
      expect(stage.status, StageStatus.inProgress);
    });
  });
}
