import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/local/vehicle_identity_store.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_help_view.dart';
import 'package:customer_app/features/customer/presentation/customer_breakdown_result_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_breakdown_sync.dart';

/// Roadside assistance is a request, not a dispatch: these tests pin the exact
/// contract payload, the honest offline/success distinction, and the absence of
/// the claims the backend cannot keep.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('customer_breakdown_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChangeTypeAdapter());
    }
  });

  tearDownAll(() async {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Request contract', () {
    testWidgets('sends exactly the fields the workshop accepts', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Dead battery');
      await tester.enterText(_location, 'Level B2, Marina Mall');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(remote.payloads, hasLength(1));
      final payload = remote.payloads.single;
      expect(payload['issue'], 'Dead battery');
      expect(payload['vehicleId'], 'v1');
      expect(payload['vehicleName'], 'Toyota Camry');
      expect(payload['vehiclePlate'], 'A 12345');
      expect(payload['location'], 'Level B2, Marina Mall');
      expect(
        payload.keys,
        isNot(contains('notes')),
        reason: 'the backend rejects unknown keys',
      );
    });

    testWidgets('merges the optional detail into the single issue field', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Flat tyre');
      await tester.enterText(find.byType(TextField).last, 'front left wheel');
      await tester.enterText(_location, 'Airport Road');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(remote.payloads.single['issue'], 'Flat tyre — front left wheel');
    });

    testWidgets('never sends a temporary vehicle id', (tester) async {
      // The real app marks an offline-created vehicle as pending, which is what
      // tells the request path its id is not usable at the workshop yet. Hive
      // work runs outside fake time, so it cannot deadlock the test.
      await tester.runAsync(() async {
        await Hive.openBox<dynamic>(
          'customer_cache',
        ).then((box) => box.clear());
        await VehicleIdentityStore.markPending(_offlineVehicle.id);
      });
      addTearDown(() => VehicleIdentityStore.clearPending(_offlineVehicle.id));

      final remote = _FakeRemote();
      await _pumpForm(
        tester,
        // A vehicle the workshop has not accepted yet.
        vehicles: [_offlineVehicle],
        remote: remote,
      );

      await _choose(tester, 'Overheating');
      await tester.enterText(_location, 'Sheikh Zayed Road');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      final payload = remote.payloads.single;
      expect(payload.containsKey('vehicleId'), isFalse);
      expect(
        payload['vehiclePlate'],
        'A 99999',
        reason: 'the real details still reach the workshop',
      );
    });

    testWidgets('a request without a vehicle is still accepted', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, vehicles: const [], remote: remote);

      expect(find.text('No vehicles registered yet'), findsOneWidget);
      await _choose(tester, 'Something else');
      await tester.enterText(_location, 'Jumeirah Beach Road');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      final payload = remote.payloads.single;
      expect(payload.containsKey('vehicleId'), isFalse);
      expect(payload['vehicleName'], '');
      expect(remote.payloads, hasLength(1));
    });

    testWidgets('preselects the only vehicle but never guesses between two', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpForm(
        tester,
        vehicles: const [_camry, _patrol],
        remote: remote,
      );

      await _choose(tester, "Won't start");
      await tester.enterText(_location, 'Al Wasl Road');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(
        remote.payloads.single.containsKey('vehicleId'),
        isFalse,
        reason: 'two cars means the customer must say which one',
      );
    });

    testWidgets('a selected vehicle is used', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(
        tester,
        vehicles: const [_camry, _patrol],
        remote: remote,
      );

      await tester.tap(find.text('Nissan Patrol'));
      await tester.pumpAndSettle();
      await _choose(tester, 'Brake problem');
      await tester.enterText(_location, 'Deira');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      final payload = remote.payloads.single;
      expect(payload['vehicleId'], 'v2');
      expect(payload['vehicleName'], 'Nissan Patrol');
      expect(payload['vehiclePlate'], 'A 99999');
    });
  });

  group('Validation', () {
    testWidgets('requires a description of what happened', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await tester.enterText(_location, 'Level B2');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(
        find.text("Tell us what's wrong so the workshop can help."),
        findsOneWidget,
      );
      expect(remote.payloads, isEmpty);
    });

    testWidgets('requires a location the workshop can find', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Flat tyre');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add where the vehicle is so the workshop can find you.'),
        findsOneWidget,
      );
      expect(remote.payloads, isEmpty);
    });
  });

  group('Submission', () {
    testWidgets('shows a sending state and never submits twice', (
      tester,
    ) async {
      final remote = _FakeRemote()..gate = Completer<void>();
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Flat tyre');
      await tester.enterText(_location, 'Level B2');

      await tester.tap(find.text('Request assistance'));
      await tester.pump();
      expect(find.text('Sending request…'), findsOneWidget);

      // A second tap while the first is still in flight must be ignored.
      await tester.tap(find.text('Sending request…'));
      await tester.pump();
      expect(remote.payloads, hasLength(1));

      remote.gate!.complete();
      await tester.pumpAndSettle();
      expect(remote.payloads, hasLength(1));
    });

    testWidgets('a server failure keeps every input and says so', (
      tester,
    ) async {
      final remote = _FakeRemote()..failure = const ValidationException('no');
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Overheating');
      await tester.enterText(_location, 'Airport Road');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBreakdownHelpView), findsOneWidget);
      expect(find.text('no'), findsOneWidget);
      expect(find.text('Overheating'), findsOneWidget);
      expect(find.text('Airport Road'), findsOneWidget);
      expect(find.text('Request assistance'), findsOneWidget);
    });
  });

  group('Offline', () {
    testWidgets('queues the request and says it has not been sent', (
      tester,
    ) async {
      final remote = _FakeRemote()
        ..failure = const NetworkException('Connection failed');
      final queue = _RecordingQueue();
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        remote: remote,
        queue: queue,
      );

      await _choose(tester, 'Dead battery');
      await tester.enterText(_location, 'Level B2, Marina Mall');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      final queued = queue.enqueued.single;
      expect(queued.entityType, 'breakdown');
      expect(queued.changeType, ChangeType.create);
      expect(queued.payload['issue'], 'Dead battery');

      expect(find.text('Request saved'), findsOneWidget);
      expect(
        find.textContaining("hasn't been sent yet"),
        findsOneWidget,
        reason: 'a queued request must never claim the workshop received it',
      );
      expect(find.textContaining('cannot see this request'), findsOneWidget);
    });

    testWidgets('a response timeout is not queued as a second request', (
      tester,
    ) async {
      final remote = _FakeRemote()
        ..failure = const NetworkException(
          'We did not receive data from the server',
        );
      final queue = _RecordingQueue();
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        remote: remote,
        queue: queue,
      );

      await _choose(tester, 'Flat tyre');
      await tester.enterText(_location, 'Level B2');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(queue.enqueued, isEmpty);
      expect(
        find.textContaining("couldn't confirm whether the workshop received"),
        findsOneWidget,
      );
      expect(find.byType(CustomerBreakdownHelpView), findsOneWidget);
    });
  });

  group('Failed request recovery', () {
    testWidgets('a queued request is never presented as a failure', (
      tester,
    ) async {
      final remote = _FakeRemote()
        ..failure = const NetworkException('Connection failed');
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        remote: remote,
        queue: _RecordingQueue(),
      );

      await _choose(tester, 'Dead battery');
      await tester.enterText(_location, 'Level B2');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(find.text('Request saved'), findsOneWidget);
      expect(find.textContaining('workshop has not received'), findsNothing);
      expect(find.text('Retry sending'), findsNothing);
    });

    testWidgets('a failed request states the workshop has not received it', (
      tester,
    ) async {
      final failed = _FakeFailedBreakdownSync(
        operations: [_failedBreakdownOperation()],
      );
      await _pumpForm(tester, vehicles: const [_camry], failedSync: failed);

      expect(
        find.text("We couldn't send your roadside request"),
        findsOneWidget,
      );
      expect(
        find.textContaining('the workshop has not received it'),
        findsOneWidget,
      );
      expect(find.text('Retry sending'), findsOneWidget);
      expect(find.text('Remove request'), findsOneWidget);
      expect(
        find.textContaining('Flat tyre'),
        findsWidgets,
        reason: 'the saved request shows what was actually asked for',
      );
    });

    testWidgets('retry replays the saved request, never a new submission', (
      tester,
    ) async {
      final failed = _FakeFailedBreakdownSync(
        operations: [_failedBreakdownOperation()],
      );
      final remote = _FakeRemote();
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        remote: remote,
        failedSync: failed,
      );

      await tester.tap(find.text('Retry sending'));
      await tester.pumpAndSettle();

      expect(failed.retryCalls, 1);
      expect(
        remote.payloads,
        isEmpty,
        reason: 'retry must reuse the stored request, not submit a new one',
      );
      expect(
        find.text('Your saved request was sent to the workshop.'),
        findsOneWidget,
      );
      expect(find.text('Retry sending'), findsNothing);
    });

    testWidgets('a second retry tap while one is running is ignored', (
      tester,
    ) async {
      final failed = _FakeFailedBreakdownSync(
        operations: [_failedBreakdownOperation()],
      )..gate = Completer<void>();
      await _pumpForm(tester, vehicles: const [_camry], failedSync: failed);

      await tester.tap(find.text('Retry sending'));
      await tester.pump();
      expect(find.text('Retrying…'), findsOneWidget);

      await tester.tap(find.text('Retrying…'));
      await tester.pump();
      expect(failed.retryCalls, 1);

      failed.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a retry that fails again keeps the recovery available', (
      tester,
    ) async {
      final failed = _FakeFailedBreakdownSync(
        operations: [_failedBreakdownOperation()],
        retryClears: false,
      );
      await _pumpForm(tester, vehicles: const [_camry], failedSync: failed);

      await tester.tap(find.text('Retry sending'));
      await tester.pumpAndSettle();

      expect(find.textContaining('workshop has not received it'), findsWidgets);
      expect(find.text('Retry sending'), findsOneWidget);
      expect(find.text('Remove request'), findsOneWidget);
      expect(
        find.textContaining("We still couldn't send your request"),
        findsOneWidget,
      );
    });

    testWidgets('removing asks first and only then discards it', (
      tester,
    ) async {
      final failed = _FakeFailedBreakdownSync(
        operations: [_failedBreakdownOperation()],
      );
      await _pumpForm(tester, vehicles: const [_camry], failedSync: failed);

      await tester.tap(find.text('Remove request'));
      await tester.pumpAndSettle();
      expect(find.text('Remove saved request?'), findsOneWidget);
      expect(
        find.textContaining('The workshop has not received it.'),
        findsOneWidget,
      );

      // Cancelling leaves the saved request exactly where it was.
      await tester.tap(find.text('Keep request'));
      await tester.pumpAndSettle();
      expect(failed.removeCalls, 0);
      expect(find.text('Retry sending'), findsOneWidget);

      await tester.tap(find.text('Remove request'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove request').last);
      await tester.pumpAndSettle();

      expect(failed.removeCalls, 1);
      expect(find.text('Retry sending'), findsNothing);
      expect(find.text('Saved request removed.'), findsOneWidget);
    });

    testWidgets('the recovery copy never exposes technical detail', (
      tester,
    ) async {
      final failed = _FakeFailedBreakdownSync(
        operations: [_failedBreakdownOperation()],
      );
      await _pumpForm(tester, vehicles: const [_camry], failedSync: failed);

      final rendered = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join(' ')
          .toLowerCase();

      for (final banned in const [
        'sync',
        'queue',
        'hive',
        'http',
        'operation',
        'retry count',
        'entityid',
        'failed box',
      ]) {
        expect(rendered.contains(banned), isFalse, reason: banned);
      }
    });
  });
  group('Result', () {
    testWidgets('a sent request shows its real reference and details', (
      tester,
    ) async {
      final remote = _FakeRemote()..reference = 'BD-2026-0007';
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Flat tyre');
      await tester.enterText(_location, 'Level B2, Marina Mall');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerBreakdownResultView), findsOneWidget);
      expect(find.text('BD-2026-0007'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('Level B2, Marina Mall'), findsOneWidget);
      expect(find.text('Flat tyre'), findsOneWidget);
      expect(
        find.text('The workshop has received your request.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('assigns an advisor'),
        findsOneWidget,
        reason: 'the only real next step is advisor assignment',
      );
    });

    testWidgets('never promises that help is already on the way', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, vehicles: const [_camry], remote: remote);

      await _choose(tester, 'Flat tyre');
      await tester.enterText(_location, 'Level B2');
      await tester.tap(find.text('Request assistance'));
      await tester.pumpAndSettle();

      for (final claim in const [
        'Help is on the way',
        'on the way',
        'en route',
        'dispatched',
        'ETA',
        'towing',
      ]) {
        expect(
          find.textContaining(claim),
          findsNothing,
          reason: '"$claim" is not backed by the request that was made',
        );
      }
    });
  });

  group('Layout and guards', () {
    testWidgets('stays overflow-free on every supported width', (tester) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpForm(
          tester,
          vehicles: const [_camry, _patrol],
          size: Size(width, 844),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'the request form must not overflow at ${width}px',
        );
      }
    });

    testWidgets('survives 1.6x text, tablet, desktop and dark mode', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        textScaler: const TextScaler.linear(1.6),
      );
      expect(tester.takeException(), isNull);

      await _pumpForm(
        tester,
        vehicles: const [_camry],
        size: const Size(1024, 900),
      );
      expect(tester.takeException(), isNull);

      await _pumpForm(
        tester,
        vehicles: const [_camry],
        size: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);

      await _pumpForm(
        tester,
        vehicles: const [_camry],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Roadside assistance'), findsOneWidget);
    });

    test('never claims capability the backend does not have', () {
      final source = const [
        'lib/features/customer/presentation/customer_breakdown_help_view.dart',
        'lib/features/customer/presentation/customer_breakdown_result_view.dart',
      ].map((path) => File(path).readAsStringSync().toLowerCase()).join();

      for (final banned in const [
        '24/7',
        '15-20',
        '15–20',
        '40km',
        'free towing',
        'auto-detected',
        'gps location',
        'dispatching unit',
        'emergency dispatch',
        'help is on the way',
        'unit en route',
        'technician en route',
        'tow truck',
        'sos',
        'priority flatbed',
        'fuel delivery',
        'lockout',
        'rescue',
      ]) {
        expect(
          source.contains(banned),
          isFalse,
          reason: '"$banned" must not ship',
        );
      }
    });

    test('the detail screen and its route are gone', () {
      expect(
        File(
          'lib/features/customer/presentation/customer_breakdown_detail_view.dart',
        ).existsSync(),
        isFalse,
      );
      final router = File('lib/core/router/app_router.dart').readAsStringSync();
      expect(router.contains('customerBreakdownDetail'), isFalse);
      expect(router.contains('CustomerBreakdownDetailView'), isFalse);
    });

    test('queued requests use the registered sync entity type', () {
      final source = File(
        'lib/features/customer/presentation/customer_breakdown_help_view.dart',
      ).readAsStringSync();
      expect(source.contains("entityType: 'breakdown'"), isTrue);

      final handlers = File(
        'lib/core/local/sync_providers.dart',
      ).readAsStringSync();
      expect(handlers.contains("'breakdown'"), isTrue);
    });
  });

  group('Failed request store', () {
    setUp(() async {
      await Hive.openBox<SyncOperation>(
        'sync_failed',
      ).then((box) => box.clear());
      await Hive.openBox<SyncOperation>(
        'sync_queue',
      ).then((box) => box.clear());
    });

    test('detects failed roadside creates and nothing else', () async {
      final failed = Hive.box<SyncOperation>('sync_failed');
      await failed.put('b1', _failedBreakdownOperation());
      await failed.put(
        'v1',
        SyncOperation(
          id: 'v1',
          entityType: 'vehicle',
          entityId: 'v1',
          changeType: ChangeType.create,
          payload: const {'brand': 'Toyota'},
          timestamp: 1,
          retryCount: 3,
        ),
      );
      // Still only queued, so it is not a failure yet.
      await Hive.box<SyncOperation>('sync_queue').put(
        'b2',
        SyncOperation(
          id: 'b2',
          entityType: 'breakdown',
          entityId: 'b2',
          changeType: ChangeType.create,
          payload: const {'issue': 'Flat tyre'},
          timestamp: 2,
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final detected = container
          .read(failedBreakdownSyncProvider)
          .failedBreakdowns()
          .map((operation) => operation.id)
          .toList();

      expect(detected, ['breakdown-1740000000000']);
    });

    test('removing deletes only the roadside request', () async {
      final failed = Hive.box<SyncOperation>('sync_failed');
      await failed.put('b1', _failedBreakdownOperation());
      await failed.put(
        'v1',
        SyncOperation(
          id: 'v1',
          entityType: 'vehicle',
          entityId: 'v1',
          changeType: ChangeType.create,
          payload: const {'brand': 'Toyota'},
          timestamp: 1,
          retryCount: 3,
        ),
      );
      // A copy still waiting to be sent must go with it.
      await Hive.box<SyncOperation>(
        'sync_queue',
      ).put('breakdown-1740000000000', _failedBreakdownOperation());

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(failedBreakdownSyncProvider).remove();

      expect(failed.containsKey('breakdown-1740000000000'), isFalse);
      expect(
        failed.containsKey('v1'),
        isTrue,
        reason: 'an unrelated failed vehicle request is untouched',
      );
      expect(Hive.box<SyncOperation>('sync_queue').isEmpty, isTrue);
    });

    test('the failed state survives reopening the store', () async {
      await Hive.box<SyncOperation>(
        'sync_failed',
      ).put('b1', _failedBreakdownOperation());

      await Hive.box<SyncOperation>('sync_failed').close();
      await Hive.openBox<SyncOperation>('sync_failed');

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(failedBreakdownSyncProvider).failedBreakdowns(),
        hasLength(1),
      );
    });
  });
  group('Visual references', () {
    testWidgets('form mobile', (tester) async {
      await _pumpForm(tester, vehicles: const [_camry, _patrol]);
      await _choose(tester, 'Flat tyre');
      await tester.enterText(_location, 'Level B2, Marina Mall');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CustomerBreakdownHelpView),
        matchesGoldenFile('goldens/customer_breakdown_form_mobile.png'),
      );
    });

    testWidgets('saved offline mobile', (tester) async {
      await _pumpFormThroughResult(tester, sent: false);
      await expectLater(
        find.byType(CustomerBreakdownResultView),
        matchesGoldenFile('goldens/customer_breakdown_offline_mobile.png'),
      );
    });

    testWidgets('sent mobile', (tester) async {
      await _pumpFormThroughResult(tester, sent: true);
      await expectLater(
        find.byType(CustomerBreakdownResultView),
        matchesGoldenFile('goldens/customer_breakdown_success_mobile.png'),
      );
    });

    testWidgets('form tablet', (tester) async {
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        size: const Size(1024, 900),
      );
      await _choose(tester, 'Dead battery');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CustomerBreakdownHelpView),
        matchesGoldenFile('goldens/customer_breakdown_tablet.png'),
      );
    });

    testWidgets('form desktop', (tester) async {
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        size: const Size(1440, 900),
      );
      await _choose(tester, 'Dead battery');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CustomerBreakdownHelpView),
        matchesGoldenFile('goldens/customer_breakdown_desktop.png'),
      );
    });

    testWidgets('failed sync mobile', (tester) async {
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        failedSync: _FakeFailedBreakdownSync(
          operations: [_failedBreakdownOperation()],
        ),
      );
      await expectLater(
        find.byType(CustomerBreakdownHelpView),
        matchesGoldenFile('goldens/customer_breakdown_failed_sync_mobile.png'),
      );
    });

    testWidgets('form dark mobile', (tester) async {
      await _pumpForm(
        tester,
        vehicles: const [_camry],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await _choose(tester, 'Overheating');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(CustomerBreakdownHelpView),
        matchesGoldenFile('goldens/customer_breakdown_dark_mobile.png'),
      );
    });
  });
}

// ─── Harness ─────────────────────────────────────────────────────────────────

Finder get _location => find.byType(TextField).first;

Future<void> _choose(WidgetTester tester, String symptom) async {
  await tester.tap(find.text(symptom));
  await tester.pumpAndSettle();
}

/// A failed roadside request as the sync engine stores it, without a Hive box.
class _FakeFailedBreakdownSync implements FailedBreakdownSync {
  _FakeFailedBreakdownSync({
    List<SyncOperation>? operations,
    this.retryClears = true,
  }) : operations = List.of(operations ?? const []);

  List<SyncOperation> operations;
  final bool retryClears;
  int retryCalls = 0;
  int removeCalls = 0;
  Completer<void>? gate;

  @override
  List<SyncOperation> failedBreakdowns() => List.of(operations);

  @override
  Future<bool> retry() async {
    retryCalls++;
    if (gate != null) await gate!.future;
    if (retryClears) operations = [];
    return operations.isEmpty;
  }

  @override
  Future<void> remove() async {
    removeCalls++;
    operations = [];
  }
}

SyncOperation _failedBreakdownOperation() => SyncOperation(
  id: 'breakdown-1740000000000',
  entityType: 'breakdown',
  entityId: 'breakdown-1740000000000',
  changeType: ChangeType.create,
  payload: const {
    'issue': 'Flat tyre',
    'vehicleName': 'Toyota Camry',
    'vehiclePlate': 'A 12345',
    'location': 'Level B2, Marina Mall',
  },
  timestamp: 1,
  retryCount: 3,
);

class _FakeRemote implements CustomerRemoteDataSource {
  final List<Map<String, dynamic>> payloads = [];
  String reference = 'BD-TEST-0001';
  Object? failure;
  Completer<void>? gate;

  @override
  Future<IdResponse> createBreakdown(Map<String, dynamic> data) async {
    payloads.add(Map<String, dynamic>.from(data));
    if (gate != null) await gate!.future;
    final error = failure;
    if (error != null) throw error;
    return IdResponse(id: reference);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Records what the request path would have queued, with no Hive and no real
/// I/O, so the offline behaviour is deterministic inside a widget test.
class _RecordingQueue implements SyncQueue {
  final List<SyncOperation> enqueued = [];

  @override
  Future<void> enqueue(SyncOperation operation) async =>
      enqueued.add(operation);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('');
}

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 't');
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._vehicles);

  final List<CustomerVehicleEntity> _vehicles;

  @override
  CustomerDashboardState build() => CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: _vehicles,
    notifications: const [],
  );

  @override
  Future<void> refresh() async {}
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required List<CustomerVehicleEntity> vehicles,
  _FakeRemote? remote,
  _RecordingQueue? queue,
  _FakeFailedBreakdownSync? failedSync,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const CustomerBreakdownHelpView()),
      GoRoute(
        path: AppRoutes.customerBreakdownResult,
        builder: (_, state) => CustomerBreakdownResultView(
          result: (state.extra as Map<String, dynamic>?) ?? const {},
        ),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) => const Scaffold(body: Text('ADD_VEHICLE')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(vehicles),
        ),
        customerRemoteDataSourceProvider.overrideWithValue(
          remote ?? _FakeRemote(),
        ),
        authNotifierProvider.overrideWith(_FakeAuth.new),
        if (queue != null) syncQueueProvider.overrideWithValue(queue),
        failedBreakdownSyncProvider.overrideWithValue(
          failedSync ?? _FakeFailedBreakdownSync(),
        ),
        // The form pushes the result route through the app's router provider.
        appRouterProvider.overrideWith((ref) => router),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Renders the result page directly with the same data the form would send.
Future<void> _pumpFormThroughResult(
  WidgetTester tester, {
  required bool sent,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(BrandConfig.orient),
      home: CustomerBreakdownResultView(
        result: {
          'sent': sent,
          'reference': sent ? 'BD-2026-0007' : '',
          'vehicleName': 'Toyota Camry',
          'vehiclePlate': 'A 12345',
          'location': 'Level B2, Marina Mall',
          'issue': 'Flat tyre',
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _camry = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _patrol = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'A 99999',
  vin: '',
  color: 'Black',
  year: 2019,
  mileage: '92,000 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

/// An offline-created vehicle: its id is local until the workshop accepts it.
// ignore: prefer_const_constructors
final _offlineVehicle = CustomerVehicleEntity(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'A 99999',
  vin: '',
  color: 'Black',
  year: 2019,
  mileage: '92,000 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

Future<void> _loadFonts() async {
  final appFont = File(
    '..${Platform.pathSeparator}..${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}shared_core${Platform.pathSeparator}assets'
    '${Platform.pathSeparator}fonts${Platform.pathSeparator}plus_jakarta_sans'
    '${Platform.pathSeparator}PlusJakartaSans-Variable.ttf',
  );
  final appBytes = await appFont.readAsBytes();
  await (FontLoader(
    AppFontFamilies.app,
  )..addFont(Future.value(ByteData.sublistView(appBytes)))).load();

  final flutterBin = File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent;
  final materialFont = File(
    '${flutterBin.path}${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts'
    '${Platform.pathSeparator}materialicons-regular.otf',
  );
  final iconBytes = await materialFont.readAsBytes();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(iconBytes)))).load();
}
