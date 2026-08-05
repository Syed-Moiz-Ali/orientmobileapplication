import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';

void main() {
  group('JobCard', () {
    test('copyWith updates status only', () {
      const jc = JobCard(
        id: 'JC-1',
        customerName: 'Ali',
        vehicle: 'Toyota Camry',
        plateNumber: 'ABC-123',
        services: ['Oil Change'],
        technician: 'Ravi',
        estCompletion: '2026-08-01',
        amount: 450,
        status: JobCardStatus.inProgress,
      );
      final updated = jc.copyWith(status: JobCardStatus.completed);
      expect(updated.status, JobCardStatus.completed);
      expect(updated.id, 'JC-1');
      expect(updated.amount, 450);
      expect(updated.services, ['Oil Change']);
    });

    test('vehicleDisplay combines vehicle and plate', () {
      const jc = JobCard(
        id: 'JC-1',
        customerName: 'Ali',
        vehicle: 'Honda Accord',
        plateNumber: 'XYZ-99',
        services: [],
        technician: '',
        estCompletion: '',
        amount: 0,
        status: JobCardStatus.pendingApproval,
      );
      expect(jc.vehicleDisplay, 'Honda Accord - XYZ-99');
    });
  });

  group('Message', () {
    test('holds recipient and body', () {
      const msg = Message(
        id: '1',
        recipient: 'Branch Manager',
        message: 'Please review',
        time: '10:00 AM',
      );
      expect(msg.recipient, 'Branch Manager');
      expect(msg.message, 'Please review');
    });
  });

  group('DashboardUiState', () {
    test('copyWith resets message text', () {
      const state = DashboardUiState();
      final typed = state.copyWith(messageText: 'hello');
      expect(typed.messageText, 'hello');
      final cleared = typed.copyWith(messageText: '');
      expect(cleared.messageText, '');
      expect(cleared.selectedIndex, 0);
    });
  });

  group('ActivityResponse parsing', () {
    test('parses backend activity payload', () {
      final activity = ActivityResponse.fromJson({
        'id': 'a1',
        'type': 'job_card',
        'title': 'New job card',
        'description': 'Ali · Toyota',
        'timestamp': '2026-07-31T08:00:00',
      });
      expect(activity.id, 'a1');
      expect(activity.type, 'job_card');
      expect(activity.title, 'New job card');
      expect(activity.timestamp, '2026-07-31T08:00:00');
    });
  });
}
