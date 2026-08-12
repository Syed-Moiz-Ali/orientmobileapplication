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
    queueBox = await Hive.openBox<SyncOperation>(
      'sync_queue_${DateTime.now().microsecondsSinceEpoch}',
    );
    failedBox = await Hive.openBox(
      'sync_failed_${DateTime.now().microsecondsSinceEpoch}',
    );
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

    final engine = SyncEngine(
      queue: SyncQueue(queueBox),
      failedBox: failedBox,
    );

    await engine.syncAll();

    expect(engine.status, SyncStatus.failure);
    expect(queueBox.get(op.id)?.retryCount, 1);
    expect(failedBox.isEmpty, isTrue);

    engine.dispose();
  });
}
