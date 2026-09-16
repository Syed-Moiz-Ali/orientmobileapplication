import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/local/vehicle_identity_store.dart';

/// A vehicle created offline has no id the workshop knows. These regressions
/// pin the rules that keep such an id out of the API and make the vehicle
/// usable once its registration completes.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tempId = '1740000000000';
  const serverId = '42';
  late Directory tempDir;
  late Box<SyncOperation> queueBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('vehicle_identity_test');
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
    await Hive.openBox<dynamic>('customer_cache').then((box) => box.clear());
  });

  tearDown(() async {
    await queueBox.close();
  });

  test('an offline vehicle is pending until its create completes', () async {
    await VehicleIdentityStore.markPending(tempId);

    expect(VehicleIdentityStore.isPending(tempId), isTrue);
    expect(VehicleIdentityStore.serverIdFor(tempId), isNull);
    expect(
      VehicleIdentityStore.resolve(tempId),
      tempId,
      reason: 'an unresolved id is never rewritten',
    );
  });

  test('a reconciled vehicle resolves to the server id', () async {
    await VehicleIdentityStore.markPending(tempId);
    await reconcileVehicleIdentity(
      tempId: tempId,
      serverId: serverId,
      queue: SyncQueue(queueBox),
    );

    expect(VehicleIdentityStore.serverIdFor(tempId), serverId);
    expect(VehicleIdentityStore.resolve(tempId), serverId);
    expect(
      VehicleIdentityStore.isPending(tempId),
      isFalse,
      reason: 'the workshop accepted it, so it is no longer pending',
    );
  });

  test('reconciliation rewrites the cached vehicle and its bookings', () async {
    final cache = await Hive.openBox<dynamic>('customer_cache');
    await cache.put('cached_vehicles', [
      {'id': tempId, 'brand': 'Toyota', 'plateNumber': 'A 12345'},
    ]);
    await cache.put('cached_bookings', [
      {'id': 'b1', 'vehicleId': tempId, 'serviceType': 'Full Service'},
      {'id': 'b2', 'vehicleId': '7', 'serviceType': 'Oil Change'},
    ]);

    await reconcileVehicleIdentity(
      tempId: tempId,
      serverId: serverId,
      queue: SyncQueue(queueBox),
    );

    final vehicles = cache.get('cached_vehicles') as List;
    expect(vehicles, hasLength(1));
    expect((vehicles.single as Map)['id'], serverId);
    final bookings = cache.get('cached_bookings') as List;
    expect((bookings[0] as Map)['vehicleId'], serverId);
    expect(
      (bookings[1] as Map)['vehicleId'],
      '7',
      reason: 'other vehicles are untouched',
    );
  });

  test('reconciliation rewrites a booking queued for that vehicle', () async {
    await queueBox.put(
      'booking-local',
      SyncOperation(
        id: 'booking-local',
        entityType: 'booking',
        entityId: 'booking-local',
        changeType: ChangeType.create,
        payload: const {
          'vehicleId': tempId,
          'vehicleName': 'Toyota',
          'serviceType': 'Full Service',
        },
        timestamp: 1,
      ),
    );

    await reconcileVehicleIdentity(
      tempId: tempId,
      serverId: serverId,
      queue: SyncQueue(queueBox),
    );

    final queued = queueBox.get('booking-local')!;
    expect(
      queued.payload['vehicleId'],
      serverId,
      reason: 'the queued booking must replay against the persisted vehicle',
    );
    expect(queued.payload['serviceType'], 'Full Service');
  });

  test('a registration that exhausted its retries is detectable', () async {
    final failed = await Hive.openBox<SyncOperation>('sync_failed');
    await failed.put(
      '1740000000000-create',
      SyncOperation(
        id: '1740000000000-create',
        entityType: 'vehicle',
        entityId: tempId,
        changeType: ChangeType.create,
        payload: const {'brand': 'Toyota'},
        timestamp: 1,
      ),
    );

    expect(VehicleIdentityStore.hasFailedCreate(tempId), isTrue);
    expect(VehicleIdentityStore.hasFailedCreate('other'), isFalse);
  });

  test('forgetting a vehicle clears every local trace', () async {
    await VehicleIdentityStore.markPending(tempId);
    await VehicleIdentityStore.record(tempId, '8472');
    final failed = await Hive.openBox<SyncOperation>('sync_failed');
    await failed.put(
      '1740000000000-create',
      SyncOperation(
        id: '1740000000000-create',
        entityType: 'vehicle',
        entityId: tempId,
        changeType: ChangeType.create,
        payload: const {},
        timestamp: 1,
      ),
    );
    final cache = await Hive.openBox<dynamic>('customer_cache');
    await cache.put('cached_vehicles', [
      {'id': tempId, 'brand': 'Toyota'},
    ]);

    await VehicleIdentityStore.forget(tempId);

    expect(VehicleIdentityStore.isPending(tempId), isFalse);
    expect(VehicleIdentityStore.hasFailedCreate(tempId), isFalse);
    expect(VehicleIdentityStore.serverIdFor(tempId), isNull);
    expect(failed.containsKey('1740000000000-create'), isFalse);
    expect(
      VehicleIdentityStore.isPending(tempId),
      isFalse,
      reason: 'a removed vehicle can never resurrect on a later sync',
    );
  });

  test('the identity map survives an app restart', () async {
    await VehicleIdentityStore.record(tempId, serverId);

    // A restart reads the same local storage.
    await Hive.close();
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>('customer_cache');
    queueBox = await Hive.openBox<SyncOperation>(
      'sync_queue_${DateTime.now().microsecondsSinceEpoch}',
    );

    expect(VehicleIdentityStore.serverIdFor(tempId), serverId);
  });
}
