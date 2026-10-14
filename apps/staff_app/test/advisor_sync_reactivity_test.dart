import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';

/// Phase 06 — pending-sync reactivity for the shell's `OfflineStatusPill`.
///
/// Proves the queued count updates from the existing `sync_queue` Hive box
/// change stream (no polling, no second source of truth) and that the stream
/// tears down cleanly.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('advisor_sync_reactivity');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChangeTypeAdapter());
    }
    await Hive.openBox<SyncOperation>('sync_queue');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    await Hive.box<SyncOperation>('sync_queue').clear();
  });

  SyncOperation op(String id) => SyncOperation(
    id: id,
    entityType: 'approval',
    entityId: 'EST-1',
    changeType: ChangeType.update,
    payload: const {'action': 'approve'},
    timestamp: 1,
  );

  test('stream emits the initial count then tracks enqueue and remove', () async {
    final box = Hive.box<SyncOperation>('sync_queue');
    final values = <int>[];
    final sub = advisorPendingSyncCountStream(box).distinct().listen(
      values.add,
    );
    addTearDown(sub.cancel);

    await _waitUntil(() => values.isNotEmpty);
    expect(values.first, 0);

    await box.put(op('a').id, op('a'));
    await _waitUntil(() => values.contains(1));

    await box.put(op('b').id, op('b'));
    await _waitUntil(() => values.contains(2));

    await box.delete('a');
    await _waitUntil(() => values.last == 1);

    await box.clear();
    await _waitUntil(() => values.last == 0);

    expect(values.first, 0);
    expect(values.last, 0);
    expect(values, containsAllInOrder(<int>[0, 1, 2, 1, 0]));
  });

  test('provider reflects the queue and updates reactively', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(advisorPendingSyncCountProvider.future), 0);

    await Hive.box<SyncOperation>('sync_queue').put(op('x').id, op('x'));
    await _waitUntil(
      () => container.read(advisorPendingSyncCountProvider).value == 1,
    );
    expect(container.read(advisorPendingSyncCountProvider).value, 1);

    await Hive.box<SyncOperation>('sync_queue').delete('x');
    await _waitUntil(
      () => container.read(advisorPendingSyncCountProvider).value == 0,
    );
    expect(container.read(advisorPendingSyncCountProvider).value, 0);
  });

  test('subscription cleans up without errors', () async {
    final box = Hive.box<SyncOperation>('sync_queue');
    final sub = advisorPendingSyncCountStream(box).listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(sub.isPaused, isFalse);
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for stream condition');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
