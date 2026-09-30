import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';

void main() {
  group('PendingApprovalEntity', () {
    test('labels each approval type for the advisor UI', () {
      const estimate = PendingApprovalEntity(
        estimateId: 'EST-1',
        customerName: 'Ali',
        vehicleId: 'VEH-1',
        amount: 500,
      );
      const jobCard = PendingApprovalEntity(
        estimateId: 'JC-1',
        approvalType: 'job_card',
        customerName: 'Ali',
        vehicleId: 'VEH-1',
        amount: 0,
      );
      const inspection = PendingApprovalEntity(
        estimateId: 'INS-1',
        approvalType: 'inspection',
        customerName: 'Ali',
        vehicleId: 'VEH-1',
        amount: 0,
      );

      expect(estimate.typeLabel, 'Estimate');
      expect(estimate.isEstimate, isTrue);
      expect(jobCard.typeLabel, 'Job card');
      expect(jobCard.isEstimate, isFalse);
      expect(inspection.typeLabel, 'Inspection');
      expect(inspection.isEstimate, isFalse);
    });
  });
}
