// Fixtures mirror `CustomerVehicleEntity`
// (apps/customer_app/.../customer/domain/entities/customer_entities.dart):
// brand, model, plateNumber, vin, color, year, mileage (+ owner fields from
// the intake/lead form patterns).
import 'fixture_types.dart';

class VehicleFormFixture {
  final String make;
  final String model;
  final String plate;
  final String vin;
  final int year;
  final String colour;
  final String mileage;
  final LocalizedText owner;
  final String phone;
  final LocalizedText notes;

  const VehicleFormFixture({
    required this.make,
    required this.model,
    required this.plate,
    required this.vin,
    required this.year,
    required this.colour,
    required this.mileage,
    required this.owner,
    required this.phone,
    required this.notes,
  });
}

/// Pre-filled example used by the "focused / invalid" review variants.
const VehicleFormFixture vehicleFormFixture = VehicleFormFixture(
  make: 'Toyota',
  model: 'Land Cruiser GXR',
  plate: 'A 12345',
  vin: 'JTMHV05J204123456',
  year: 2021,
  colour: 'Pearl White',
  mileage: '48,200',
  owner: LocalizedText('Ahmed Al Mansoori', 'أحمد المنصوري'),
  phone: '+971 50 123 4567',
  notes: LocalizedText(
    'Second key not available. Customer waits on site.',
    'المفتاح الاحتياطي غير متوفر. العميل ينتظر في الورشة.',
  ),
);
