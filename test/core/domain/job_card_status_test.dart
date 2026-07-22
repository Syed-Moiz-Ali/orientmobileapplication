import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/core/domain/job_card_status.dart';

void main() {
  group('JobCardStatus enum', () {
    test('has 6 values', () {
      expect(JobCardStatus.values.length, 6);
    });

    test('includes inProgress', () {
      expect(JobCardStatus.values, contains(JobCardStatus.inProgress));
    });

    test('includes waitingParts', () {
      expect(JobCardStatus.values, contains(JobCardStatus.waitingParts));
    });

    test('includes qualityCheck', () {
      expect(JobCardStatus.values, contains(JobCardStatus.qualityCheck));
    });

    test('includes completed', () {
      expect(JobCardStatus.values, contains(JobCardStatus.completed));
    });

    test('includes cancelled', () {
      expect(JobCardStatus.values, contains(JobCardStatus.cancelled));
    });

    test('includes pendingApproval', () {
      expect(JobCardStatus.values, contains(JobCardStatus.pendingApproval));
    });

    test('name returns correct string for inProgress', () {
      expect(JobCardStatus.inProgress.name, 'inProgress');
    });

    test('name returns correct string for pendingApproval', () {
      expect(JobCardStatus.pendingApproval.name, 'pendingApproval');
    });
  });
}
