import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:orientmobileapplication/core/local/sync/sync_operation.dart';
import 'package:orientmobileapplication/core/local/sync/sync_queue.dart';

void main() {
  late Box<SyncOperation> box;
  late SyncQueue queue;

  setUpAll(() {
    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(ChangeTypeAdapter());
  });

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(dir.path);
    box = await Hive.openBox<SyncOperation>('test_sync_queue');
    queue = SyncQueue(box);
  });

  tearDown(() async {
    await box.clear();
    await box.close();
  });

  SyncOperation op({required String id, int retryCount = 0}) => SyncOperation(
    id: id,
    entityType: 'test',
    entityId: 'ID-$id',
    changeType: ChangeType.create,
    payload: {},
    timestamp: 1000,
    retryCount: retryCount,
  );

  group('SyncQueue', () {
    test('enqueue adds operation', () async {
      await queue.enqueue(op(id: '1'));
      expect(queue.length, 1);
    });

    test('peekAll returns all operations', () async {
      await queue.enqueue(op(id: '1'));
      await queue.enqueue(op(id: '2'));
      final all = queue.peekAll();
      expect(all.length, 2);
    });

    test('remove deletes operation by id', () async {
      await queue.enqueue(op(id: '1'));
      await queue.enqueue(op(id: '2'));
      await queue.remove('1');
      expect(queue.length, 1);
      expect(queue.peekAll().first.id, '2');
    });

    test('clear removes all operations', () async {
      await queue.enqueue(op(id: '1'));
      await queue.enqueue(op(id: '2'));
      await queue.clear();
      expect(queue.length, 0);
    });

    test('updateRetry persists changes', () async {
      await queue.enqueue(op(id: '1'));
      final updated = op(id: '1', retryCount: 3);
      await queue.updateRetry(updated);
      final all = queue.peekAll();
      expect(all.first.retryCount, 3);
    });

    test('length returns 0 for empty queue', () {
      expect(queue.length, 0);
    });

    test('enqueue multiple preserves order', () async {
      await queue.enqueue(op(id: '1'));
      await queue.enqueue(op(id: '2'));
      await queue.enqueue(op(id: '3'));
      final all = queue.peekAll();
      expect(all.map((o) => o.id).toList(), ['1', '2', '3']);
    });
  });
}
