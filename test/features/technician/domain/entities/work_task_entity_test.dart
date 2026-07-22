import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/features/technician/domain/entities/work_task_entity.dart';

void main() {
  group('TaskStatus enum', () {
    test('has 3 values', () {
      expect(TaskStatus.values.length, 3);
    });

    test('includes pending', () {
      expect(TaskStatus.values, contains(TaskStatus.pending));
    });

    test('includes inProgress', () {
      expect(TaskStatus.values, contains(TaskStatus.inProgress));
    });

    test('includes completed', () {
      expect(TaskStatus.values, contains(TaskStatus.completed));
    });

    test('label returns correct string', () {
      expect(TaskStatus.pending.label, 'Pending');
      expect(TaskStatus.inProgress.label, 'In Progress');
      expect(TaskStatus.completed.label, 'Completed');
    });
  });

  group('WorkTaskEntity (freezed)', () {
    const testTask = WorkTaskEntity(
      id: 1,
      description: 'Oil Change',
      status: TaskStatus.inProgress,
      startTime: '09:00',
      endTime: '10:30',
    );

    test('constructor sets fields', () {
      expect(testTask.id, 1);
      expect(testTask.description, 'Oil Change');
      expect(testTask.status, TaskStatus.inProgress);
      expect(testTask.startTime, '09:00');
      expect(testTask.endTime, '10:30');
    });

    test('default status is pending', () {
      const task = WorkTaskEntity(id: 2, description: 'Test');
      expect(task.status, TaskStatus.pending);
    });

    test('default startTime and endTime are null', () {
      const task = WorkTaskEntity(id: 3, description: 'Test');
      expect(task.startTime, isNull);
      expect(task.endTime, isNull);
    });

    group('equality', () {
      test('equal entities are equal', () {
        const a = WorkTaskEntity(id: 1, description: 'Task');
        const b = WorkTaskEntity(id: 1, description: 'Task');
        expect(a, equals(b));
      });

      test('different id makes them unequal', () {
        const a = WorkTaskEntity(id: 1, description: 'Task');
        const b = WorkTaskEntity(id: 2, description: 'Task');
        expect(a, isNot(equals(b)));
      });

      test('different description makes them unequal', () {
        const a = WorkTaskEntity(id: 1, description: 'Task A');
        const b = WorkTaskEntity(id: 1, description: 'Task B');
        expect(a, isNot(equals(b)));
      });
    });

    group('hashCode', () {
      test('equal entities have same hashCode', () {
        const a = WorkTaskEntity(id: 1, description: 'Task');
        const b = WorkTaskEntity(id: 1, description: 'Task');
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('copyWith', () {
      test('returns same instance with no args', () {
        final copy = testTask.copyWith();
        expect(copy, equals(testTask));
      });

      test('updates status', () {
        final copy = testTask.copyWith(status: TaskStatus.completed);
        expect(copy.status, TaskStatus.completed);
        expect(copy.id, testTask.id);
        expect(copy.description, testTask.description);
      });

      test('updates startTime', () {
        final copy = testTask.copyWith(startTime: '11:00');
        expect(copy.startTime, '11:00');
      });

      test('updates endTime', () {
        final copy = testTask.copyWith(endTime: '12:00');
        expect(copy.endTime, '12:00');
      });
    });

    group('toJson / fromJson', () {
      test('toJson returns correct map', () {
        final json = testTask.toJson();
        expect(json['id'], 1);
        expect(json['description'], 'Oil Change');
        expect(json['status'], 'inProgress');
        expect(json['startTime'], '09:00');
        expect(json['endTime'], '10:30');
      });

      test('fromJson reconstructs entity', () {
        final json = testTask.toJson();
        final reconstructed = WorkTaskEntity.fromJson(json);
        expect(reconstructed, equals(testTask));
      });

      test('round-trip preserves all fields', () {
        final json = testTask.toJson();
        final reconstructed = WorkTaskEntity.fromJson(json);
        final reJson = reconstructed.toJson();
        expect(reJson, json);
      });

      test('fromJson handles missing optional fields', () {
        final json = <String, dynamic>{
          'id': 5,
          'description': 'Brake Check',
        };
        final task = WorkTaskEntity.fromJson(json);
        expect(task.id, 5);
        expect(task.description, 'Brake Check');
        expect(task.status, TaskStatus.pending);
        expect(task.startTime, isNull);
        expect(task.endTime, isNull);
      });
    });
  });
}
