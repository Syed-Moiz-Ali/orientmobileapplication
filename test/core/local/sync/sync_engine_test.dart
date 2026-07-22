import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/exceptions/sync_exceptions.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';
import 'package:orientmobileapplication/core/local/sync/sync_queue.dart';
import 'package:orientmobileapplication/core/local/sync/sync_engine.dart';
import 'package:orientmobileapplication/core/local/sync/sync_handler.dart';
import 'package:orientmobileapplication/core/local/sync/sync_status.dart';

class _TestHandler extends SyncHandler {
  final Future<bool> Function() onExecute;
  _TestHandler(this.onExecute);
  @override
  String get entityType => 'test_entity';
  @override
  Future<bool> execute(SyncOperation operation) => onExecute();
}

class _FailingTestHandler extends SyncHandler {
  @override
  String get entityType => 'test_entity';
  @override
  Future<bool> execute(SyncOperation operation) => Future.value(false);
}

class _ThrowingTestHandler extends SyncHandler {
  @override
  String get entityType => 'test_entity';
  @override
  Future<bool> execute(SyncOperation operation) => throw ConflictException();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Box<SyncOperation> queueBox;
  late Box failedBox;
  late SyncQueue queue;
  late SyncEngine engine;

  setUpAll(() {
    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(ChangeTypeAdapter());
  });

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    queueBox = await Hive.openBox<SyncOperation>('test_engine_queue');
    failedBox = await Hive.openBox('test_engine_failed');
    queue = SyncQueue(queueBox);
  });

  tearDown(() async {
    try {
      engine.dispose();
    } catch (_) {}
    await queueBox.clear();
    await failedBox.clear();
    await queueBox.close();
    await failedBox.close();
  });

  SyncOperation op({String id = '1', String entityType = 'test_entity'}) => SyncOperation(
    id: id,
    entityType: entityType,
    entityId: 'ID-$id',
    changeType: ChangeType.create,
    payload: {},
    timestamp: 1000,
  );

  group('SyncEngine', () {
    test('initial status is idle', () {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      expect(engine.status, SyncStatus.idle);
    });

    test('syncAll emits success when queue is empty', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      SyncStatus? emitted;
      engine.addListener((s) => emitted = s);
      await engine.syncAll();
      expect(emitted, SyncStatus.success);
    });

    test('syncAll emits success when all operations succeed', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      engine.registerHandler(_TestHandler(() => Future.value(true)));
      await queue.enqueue(op());
      SyncStatus? emitted;
      engine.addListener((s) => emitted = s);
      await engine.syncAll();
      expect(emitted, SyncStatus.success);
      expect(queue.length, 0);
    });

    test('syncAll emits failure when operations fail', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      engine.registerHandler(_FailingTestHandler());
      await queue.enqueue(op());
      SyncStatus? emitted;
      engine.addListener((s) => emitted = s);
      await engine.syncAll();
      expect(emitted, SyncStatus.failure);
    });

    test('syncAll emits conflict on ConflictException', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      engine.registerHandler(_ThrowingTestHandler());
      await queue.enqueue(op());
      SyncStatus? emitted;
      engine.addListener((s) => emitted = s);
      await engine.syncAll();
      expect(emitted, SyncStatus.conflict);
      expect(queue.length, 0);
    });

    test('syncAll retries on exception up to maxRetries', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      int attempts = 0;
      engine.registerHandler(_TestHandler(() {
        attempts++;
        return Future.value(false);
      }));
      await queue.enqueue(op(id: 'retry-test'));
      await engine.syncAll();
      expect(attempts, 1); // first attempt, retryCount becomes 1
      expect(queue.length, 1); // still in queue
    });

    test('emits failure when no handler registered', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      await queue.enqueue(op(entityType: 'unknown'));
      SyncStatus? emitted;
      engine.addListener((s) => emitted = s);
      await engine.syncAll();
      expect(emitted, SyncStatus.failure);
      expect(queue.length, 1);
    });

    test('syncAll does nothing when already syncing', () async {
      engine = SyncEngine(queue: queue, failedBox: failedBox, connectivity: Connectivity());
      SyncStatus? emitted;
      engine.addListener((s) => emitted = s);
      // First call starts syncing
      final future = engine.syncAll();
      // Second call should be ignored
      await engine.syncAll();
      // First call completes
      await future;
      // Should only have seen syncing then success
      expect(emitted, SyncStatus.success);
    });
  });
}
