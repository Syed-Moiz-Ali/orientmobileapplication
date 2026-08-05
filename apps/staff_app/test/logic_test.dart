import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';

void main() {
  group('TechnicianJobEntity', () {
    test('parses from persisted map', () {
      final job = TechnicianJobEntity.fromJson({
        'jobCardNo': 'JC-2026-0001',
        'dateOfWork': '2026-07-31',
        'startTime': '08:30',
        'vehicleBrand': 'Toyota',
        'vehicleModel': 'Camry',
        'plateNumber': 'ABC-123',
        'status': 'inProgress',
        'notes': 'check brakes',
        'tasks': [
          {
            'id': 1,
            'description': 'Oil change',
            'status': 'completed',
            'startTime': '08:35',
            'endTime': '09:00',
          },
          {'id': 2, 'description': 'Brake pads', 'status': 'pending'},
        ],
      });
      expect(job.jobCardNo, 'JC-2026-0001');
      expect(job.status, TechJobStatus.inProgress);
      expect(job.tasks.length, 2);
      expect(job.tasks.first.status, TaskStatus.completed);
      expect(job.notes, 'check brakes');
    });

    test('unknown status falls back to pending', () {
      final job = TechnicianJobEntity.fromJson({
        'jobCardNo': 'JC-1',
        'dateOfWork': '2026-07-31',
        'status': 'nonsense',
        'tasks': [],
      });
      expect(job.status, TechJobStatus.pending);
    });

    test('progressPercent reflects completed tasks', () {
      const job = TechnicianJobEntity(
        jobCardNo: 'JC-1',
        dateOfWork: '2026-07-31',
        startTime: '08:00',
        vehicleBrand: 'A',
        vehicleModel: 'B',
        plateNumber: 'P',
        tasks: [
          WorkTaskEntity(id: 1, description: 'x', status: TaskStatus.completed),
          WorkTaskEntity(id: 2, description: 'y', status: TaskStatus.completed),
          WorkTaskEntity(id: 3, description: 'z'),
        ],
      );
      expect(job.progressPercent, closeTo(2 / 3, 0.0001));
      expect(job.completedTasks, 2);
    });
  });

  group('Status labels', () {
    test('attendance labels map to friendly text', () {
      expect(AttendanceStatus.notPunchedIn.label, 'Not Punched In');
      expect(AttendanceStatus.working.label, 'Working');
      expect(AttendanceStatus.punchedOut.label, 'Punched Out');
    });

    test('assigned job status labels', () {
      expect(AssignedJobStatus.pending.label, 'Pending');
      expect(AssignedJobStatus.completed.actionLabel, 'Complete');
    });
  });

  group('JobCardEntity', () {
    test('copyWith keeps other fields', () {
      const jc = JobCardEntity(
        id: 'JC-1',
        customerName: 'Ali',
        vehicleInfo: 'Toyota',
        time: '10:00',
        status: JobCardStatus.inProgress,
      );
      final updated = jc.copyWith(status: JobCardStatus.completed);
      expect(updated.id, 'JC-1');
      expect(updated.customerName, 'Ali');
      expect(updated.status, JobCardStatus.completed);
    });
  });

  group('AdvisorInfo', () {
    test('initials derive from name', () {
      const info = AdvisorInfo(
        name: 'Ali Rahman',
        id: 'ADV-001',
        branch: 'Main Branch',
        shift: '',
      );
      expect(info.initials, 'AR');
    });

    test('single-word names produce single initial', () {
      const info = AdvisorInfo(
        name: 'Advisor',
        id: 'ADV-002',
        branch: 'Dubai',
        shift: '',
      );
      expect(info.initials, 'A');
    });
  });

  group('SyncOperation', () {
    test('round-trips through JSON', () {
      final op = SyncOperation(
        id: 'INS-1',
        entityType: 'inspection',
        entityId: 'INS-1',
        changeType: ChangeType.create,
        payload: {'statuses': {}},
        timestamp: 1234567890,
        retryCount: 2,
      );
      final restored = SyncOperation.fromJson(op.toJson());
      expect(restored.id, op.id);
      expect(restored.entityType, 'inspection');
      expect(restored.changeType, ChangeType.create);
      expect(restored.payload, {'statuses': {}});
      expect(restored.retryCount, 2);
    });
  });
}
