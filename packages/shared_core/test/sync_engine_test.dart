import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late Box<SyncOperation> queueBox;
  late Box failedBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('sync_engine_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChangeTypeAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    queueBox = await Hive.openBox<SyncOperation>('sync_queue_${DateTime.now().microsecondsSinceEpoch}');
    failedBox = await Hive.openBox('sync_failed_${DateTime.now().microsecondsSinceEpoch}');
  });

  tearDown(() async {
    await queueBox.close();
    await failedBox.close();
  });

  test('missing handler is treated as a retryable sync failure', () async {
    final op = SyncOperation(
      id: 'op-1',
      entityType: 'unsupported',
      entityId: 'entity-1',
      changeType: ChangeType.create,
      payload: const {'value': 'x'},
      timestamp: 1,
    );
    await queueBox.put(op.id, op);

    final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);

    await engine.syncAll();

    expect(engine.status, SyncStatus.failure);
    expect(queueBox.get(op.id)?.retryCount, 1);
    expect(failedBox.isEmpty, isTrue);

    engine.dispose();
  });

  test('a later operation runs its rewritten payload, not the stale one', () async {
    // The offline scenario: a vehicle created with a temporary local id, and a
    // booking queued against that temporary id.
    await queueBox.put(
      '1-vehicle',
      SyncOperation(
        id: '1-vehicle',
        entityType: 'vehicle',
        entityId: '172345',
        changeType: ChangeType.create,
        payload: const {'brand': 'Toyota'},
        timestamp: 1,
      ),
    );
    await queueBox.put(
      '2-booking',
      SyncOperation(
        id: '2-booking',
        entityType: 'booking',
        entityId: '2-booking',
        changeType: ChangeType.create,
        payload: const {'vehicleId': '172345'},
        timestamp: 2,
      ),
    );

    final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);
    final sentVehicleIds = <String>[];

    // Registering the vehicle rewrites the queued booking to the real id, which
    // is what identity reconciliation does mid-pass.
    engine.registerHandler(
      _VehicleHandler(() async {
        final current = queueBox.get('2-booking')!;
        await queueBox.put(
          '2-booking',
          SyncOperation(
            id: current.id,
            entityType: current.entityType,
            entityId: current.entityId,
            changeType: current.changeType,
            payload: {...current.payload, 'vehicleId': '8472'},
            timestamp: current.timestamp,
            retryCount: current.retryCount,
          ),
        );
      }),
    );
    engine.registerHandler(_RecordingHandler('booking', sentVehicleIds));

    await engine.syncAll();

    expect(sentVehicleIds, ['8472'], reason: 'the booking must never be sent with the temporary vehicle id');
    engine.dispose();
  });

  test('an operation removed mid-pass is skipped, not executed', () async {
    await queueBox.put(
      'first',
      SyncOperation(
        id: 'first',
        entityType: 'first',
        entityId: 'first',
        changeType: ChangeType.create,
        payload: const {},
        timestamp: 1,
      ),
    );
    await queueBox.put(
      'second',
      SyncOperation(
        id: 'second',
        entityType: 'second',
        entityId: 'second',
        changeType: ChangeType.create,
        payload: const {},
        timestamp: 2,
      ),
    );

    final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);
    final executed = <String>[];
    engine.registerHandler(_RemovingHandler('first', queueBox));
    engine.registerHandler(_RecordingEntityHandler('second', executed));

    await engine.syncAll();

    expect(executed, isEmpty, reason: 'an operation deleted during the pass must not be resurrected');
    engine.dispose();
  });

  test('re-reading keeps the queue order and retry count', () async {
    for (final id in const ['a', 'b', 'c']) {
      await queueBox.put(
        id,
        SyncOperation(
          id: id,
          entityType: 'ordered',
          entityId: id,
          changeType: ChangeType.create,
          payload: const {},
          timestamp: 1,
        ),
      );
    }

    final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);
    final order = <String>[];
    engine.registerHandler(_RecordingEntityHandler('ordered', order));

    await engine.syncAll();

    expect(order, ['a', 'b', 'c'], reason: 'the initial scan still sets order');
    engine.dispose();
  });

  group('retryFailedOperation', () {
    SyncOperation failedOp(String id, String entity) => SyncOperation(
      id: id,
      entityType: entity,
      entityId: id,
      changeType: ChangeType.create,
      payload: {'stable': id},
      timestamp: 1,
      retryCount: 3,
    );

    test('retries only the selected operation and keeps its identity', () async {
      await failedBox.put('b1', failedOp('b1', 'booking'));
      await failedBox.put('v1', failedOp('v1', 'vehicle'));

      final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);
      final executed = <String>[];
      engine.registerHandler(_IdentityHandler('booking', executed, succeed: true));

      final ok = await engine.retryFailedOperation('b1');

      expect(ok, isTrue);
      expect(executed, ['b1']);
      expect(failedBox.containsKey('b1'), isFalse);
      expect(failedBox.containsKey('v1'), isTrue, reason: 'an unrelated failed operation is never attempted');
      expect(queueBox.isEmpty, isTrue, reason: 'no duplicate queue row');
      engine.dispose();
    });

    test('a failed retry keeps the same failed operation', () async {
      final original = failedOp('b2', 'booking');
      await failedBox.put('b2', original);

      final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);
      engine.registerHandler(_IdentityHandler('booking', [], succeed: false));

      final ok = await engine.retryFailedOperation('b2');

      expect(ok, isFalse);
      final kept = failedBox.get('b2');
      expect(kept.id, original.id);
      expect(kept.entityId, original.entityId);
      expect(kept.payload, original.payload, reason: 'payload is preserved');
      expect(kept.retryCount, 4);
      engine.dispose();
    });

    test('an unknown operation id is a safe no-op', () async {
      final engine = SyncEngine(queue: SyncQueue(queueBox), failedBox: failedBox);
      expect(await engine.retryFailedOperation('missing'), isFalse);
      engine.dispose();
    });
  });
}

class _VehicleHandler extends SyncHandler {
  _VehicleHandler(this.onSuccess);

  final Future<void> Function() onSuccess;

  @override
  String get entityType => 'vehicle';

  @override
  Future<bool> execute(SyncOperation operation) async {
    await onSuccess();
    return true;
  }
}

class _RecordingHandler extends SyncHandler {
  _RecordingHandler(this.entityType, this.vehicleIds);

  @override
  final String entityType;
  final List<String> vehicleIds;

  @override
  Future<bool> execute(SyncOperation operation) async {
    vehicleIds.add((operation.payload['vehicleId'] ?? '').toString());
    return true;
  }
}

class _RecordingEntityHandler extends SyncHandler {
  _RecordingEntityHandler(this.entityType, this.entityIds);

  @override
  final String entityType;
  final List<String> entityIds;

  @override
  Future<bool> execute(SyncOperation operation) async {
    entityIds.add(operation.entityId);
    return true;
  }
}

class _RemovingHandler extends SyncHandler {
  _RemovingHandler(this.entityType, this.box);

  @override
  final String entityType;
  final Box<SyncOperation> box;

  @override
  Future<bool> execute(SyncOperation operation) async {
    await box.delete('second');
    return true;
  }
}

class _IdentityHandler extends SyncHandler {
  _IdentityHandler(this.entityType, this.seen, {required this.succeed});

  @override
  final String entityType;
  final List<String> seen;
  final bool succeed;

  @override
  Future<bool> execute(SyncOperation operation) async {
    seen.add(operation.id);
    return succeed;
  }
}
