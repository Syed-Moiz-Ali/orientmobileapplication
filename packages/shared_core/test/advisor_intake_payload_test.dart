import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('buildVehicleCustomerIntakePayload', () {
    test('maps the new client intake fields into the backend shape', () {
      final payload = buildVehicleCustomerIntakePayload({
        'customerName': 'Ali',
        'phoneNumber': '501234567',
        'emirate': 'Dubai',
        'plateCode': 'A',
        'plateNumber': '12345',
        'fuelType': 'Petrol',
        'vehicleColor': 'White',
        'jobCategory': 'Insurance',
        'markupType': '10%',
        'orderType': 'Retail',
        'jobDescription': 'Replace brake pads',
        'lpoNumber': 'LPO-1',
        'policyNumber': 'POL-2',
        'accidentNumber': 'ACC-9',
        'vehicleBodyCondition': {
          'mapId': 'advisor_car_top',
          'view': 'top',
          'parts': {
            'hood': {'condition': 'damaged'},
          },
        },
      });

      expect(payload['type'], 'vehicle_customer');

      final customer = payload['customer'] as Map;
      expect(customer['customerName'], 'Ali');
      expect(customer['phoneNumber'], '501234567');

      final vehicle = payload['vehicle'] as Map;
      expect(vehicle['emirate'], 'Dubai');
      expect(vehicle['plateCode'], 'A');
      expect(vehicle['plateNumber'], '12345');
      expect(vehicle['fuelType'], 'Petrol');
      expect(vehicle['vehicleColor'], 'White');
      expect(vehicle['lpoNumber'], 'LPO-1');
      expect(vehicle['policyNumber'], 'POL-2');
      expect(vehicle['accidentNumber'], 'ACC-9');

      final additional = payload['additional'] as Map;
      expect(additional['jobCategory'], 'Insurance');
      expect(additional['markupType'], '10%');
      expect(additional['orderType'], 'Retail');
      expect(additional['jobDescription'], 'Replace brake pads');
      expect(payload['customerRequests'], 'Replace brake pads');
      expect(
        (payload['vehicleBodyCondition'] as Map)['mapId'],
        'advisor_car_top',
      );
    });

    test('never forwards the obsolete client fields', () {
      final payload = buildVehicleCustomerIntakePayload({
        'customerName': 'Ali',
        'occupation': 'Engineer',
        'organisation': 'ACME',
        'groupTaxNumber': 'GT-1',
        'purchaseDate': '2020-01-01',
      });

      final customer = payload['customer'] as Map;
      expect(customer.containsKey('occupation'), isFalse);
      expect(customer.containsKey('organisation'), isFalse);
      expect(customer.containsKey('groupTaxNumber'), isFalse);

      final vehicle = payload['vehicle'] as Map;
      expect(vehicle.containsKey('purchaseDate'), isFalse);
    });
  });

  group('InspectionSummaryResponse', () {
    test('parses a job-card inspection summary', () {
      final summary = InspectionSummaryResponse.fromJson({
        'found': true,
        'inspectionRef': 'INS-1',
        'summary': 'Inspected 6 item(s).',
        'counts': {'good': 5, 'fair': 1, 'poor': 0, 'total': 6},
        'issues': ['Wiper Blade (fair)'],
      });

      expect(summary.found, isTrue);
      expect(summary.inspectionRef, 'INS-1');
      expect(summary.total, 6);
      expect(summary.fair, 1);
      expect(summary.issues.length, 1);
    });

    test('reports not found when a job card has no inspection', () {
      final summary = InspectionSummaryResponse.fromJson({'found': false});
      expect(summary.found, isFalse);
      expect(summary.total, 0);
    });
  });
}
