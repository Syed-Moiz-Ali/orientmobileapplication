import 'package:flutter_test/flutter_test.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';

void main() {
  group('ChangeType enum', () {
    test('has 3 values', () {
      expect(ChangeType.values.length, 3);
    });

    test('includes create', () {
      expect(ChangeType.values, contains(ChangeType.create));
    });

    test('includes update', () {
      expect(ChangeType.values, contains(ChangeType.update));
    });

    test('includes delete', () {
      expect(ChangeType.values, contains(ChangeType.delete));
    });
  });

  group('SyncOperation', () {
    final testPayload = <String, dynamic>{
      'customerName': 'Test Customer',
      'vehicle': 'Toyota Camry',
    };

    final testOperation = SyncOperation(
      id: 'SYNC-001',
      entityType: 'customer_booking',
      entityId: 'BK-2026-0001',
      changeType: ChangeType.create,
      payload: testPayload,
      timestamp: 1000000,
    );

    group('toJson / fromJson', () {
      test('toJson returns correct map', () {
        final json = testOperation.toJson();
        expect(json['id'], 'SYNC-001');
        expect(json['entityType'], 'customer_booking');
        expect(json['entityId'], 'BK-2026-0001');
        expect(json['changeType'], 0);
        expect(json['payload'], testPayload);
        expect(json['timestamp'], 1000000);
        expect(json['retryCount'], 0);
      });

      test('fromJson reconstructs SyncOperation', () {
        final json = testOperation.toJson();
        final reconstructed = SyncOperation.fromJson(json);
        expect(reconstructed.id, testOperation.id);
        expect(reconstructed.entityType, testOperation.entityType);
        expect(reconstructed.entityId, testOperation.entityId);
        expect(reconstructed.changeType, testOperation.changeType);
        expect(reconstructed.payload, testOperation.payload);
        expect(reconstructed.timestamp, testOperation.timestamp);
        expect(reconstructed.retryCount, testOperation.retryCount);
      });

      test('round-trip preserves all fields', () {
        final json = testOperation.toJson();
        final reconstructed = SyncOperation.fromJson(json);
        final reJson = reconstructed.toJson();
        expect(reJson, json);
      });

      test('fromJson handles missing retryCount', () {
        final json = <String, dynamic>{
          'id': 'SYNC-002',
          'entityType': 'test',
          'entityId': 'ID-001',
          'changeType': 1,
          'payload': <String, dynamic>{},
          'timestamp': 2000000,
        };
        final op = SyncOperation.fromJson(json);
        expect(op.retryCount, 0);
      });

      test('fromJson reads retryCount when present', () {
        final json = <String, dynamic>{
          'id': 'SYNC-003',
          'entityType': 'test',
          'entityId': 'ID-001',
          'changeType': 2,
          'payload': <String, dynamic>{'key': 'value'},
          'timestamp': 3000000,
          'retryCount': 5,
        };
        final op = SyncOperation.fromJson(json);
        expect(op.retryCount, 5);
      });
    });

    group('copyWith', () {
      test('returns same instance when retryCount is null', () {
        final copy = testOperation.copyWith();
        expect(copy.id, testOperation.id);
        expect(copy.retryCount, testOperation.retryCount);
      });

      test('updates retryCount when provided', () {
        final copy = testOperation.copyWith(retryCount: 3);
        expect(copy.retryCount, 3);
        expect(copy.id, testOperation.id);
      });
    });

    group('fields', () {
      test('retryCount defaults to 0', () {
        expect(testOperation.retryCount, 0);
      });
    });
  });
}
