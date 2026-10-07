import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_vehicle_delete.dart';
import 'package:customer_app/features/customer/presentation/support/vehicle_booking_decision.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  group('FailedVehicleDeleteSync seam (authoritative sync_failed)', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('failed_delete_test');
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
      await Hive.openBox<SyncOperation>('sync_failed');
    });

    tearDown(() async {
      await Hive.box<SyncOperation>('sync_failed').clear();
    });

    StoreFailedVehicleDeleteSync seam() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container.read(failedVehicleDeleteSyncProvider)
          as StoreFailedVehicleDeleteSync;
    }

    SyncOperation op(
      String id, {
      required String entityType,
      required ChangeType changeType,
      String entityId = '',
      int timestamp = 1,
    }) => SyncOperation(
      id: id,
      entityType: entityType,
      entityId: entityId.isEmpty ? id : entityId,
      changeType: changeType,
      payload: const {},
      timestamp: timestamp,
    );

    test('reads only failed vehicle deletes', () async {
      final failed = Hive.box<SyncOperation>('sync_failed');
      await failed.put(
        'vehicle-delete-veh-1',
        op(
          'vehicle-delete-veh-1',
          entityType: 'vehicle',
          changeType: ChangeType.delete,
          entityId: 'veh-1',
        ),
      );
      // A failed vehicle CREATE is a different state and must not appear here.
      await failed.put(
        'veh-2',
        op('veh-2', entityType: 'vehicle', changeType: ChangeType.create),
      );
      // A failed booking, and a vehicle UPDATE, are unrelated.
      await failed.put(
        'bk-1',
        op('bk-1', entityType: 'booking', changeType: ChangeType.delete),
      );
      await failed.put(
        'veh-3',
        op('veh-3', entityType: 'vehicle', changeType: ChangeType.update),
      );

      final recovered = seam().failedDeletes();

      expect(recovered.map((d) => d.operationId).toList(), [
        'vehicle-delete-veh-1',
      ]);
      expect(recovered.single.vehicleId, 'veh-1');
    });

    test('supports multiple failed deletes, oldest first', () async {
      final failed = Hive.box<SyncOperation>('sync_failed');
      await failed.put(
        'vehicle-delete-later',
        op(
          'vehicle-delete-later',
          entityType: 'vehicle',
          changeType: ChangeType.delete,
          entityId: 'veh-later',
          timestamp: 20,
        ),
      );
      await failed.put(
        'vehicle-delete-earlier',
        op(
          'vehicle-delete-earlier',
          entityType: 'vehicle',
          changeType: ChangeType.delete,
          entityId: 'veh-earlier',
          timestamp: 10,
        ),
      );

      expect(seam().failedDeletes().map((d) => d.vehicleId).toList(), [
        'veh-earlier',
        'veh-later',
      ]);
    });

    test('recovered state is durable across a fresh read', () async {
      await Hive.box<SyncOperation>('sync_failed').put(
        'vehicle-delete-veh-1',
        op(
          'vehicle-delete-veh-1',
          entityType: 'vehicle',
          changeType: ChangeType.delete,
          entityId: 'veh-1',
        ),
      );
      expect(seam().failedDeletes().single.vehicleId, 'veh-1');
    });
  });

  group('Vehicles failed-delete recovery', () {
    testWidgets('a queued delete is not a terminal failure', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const []),
      );

      expect(find.text("We couldn't remove this vehicle."), findsNothing);
      expect(find.text('Retry removal'), findsNothing);
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsOneWidget);
    });

    testWidgets('a terminal failure restores server truth from the reload', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
        onRefresh: (self) => self.setVehicles(const [_camry]),
      );

      // The optimistically hidden vehicle is back from the canonical feed.
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text("We couldn't remove this vehicle."), findsOneWidget);
      expect(
        find.text('The vehicle is still in your workshop account.'),
        findsOneWidget,
      );
      expect(find.text('Retry removal'), findsOneWidget);
      expect(find.text('1 registered vehicle'), findsOneWidget);
    });

    testWidgets('the failed state withdraws the normal Remove action', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
      );

      expect(find.text('Retry removal'), findsOneWidget);
      expect(
        find.text('Remove'),
        findsNothing,
        reason: 'a second delete must never be offered',
      );
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Book service'), findsOneWidget);
    });

    testWidgets('failed create uses its own treatment, not delete recovery', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const []),
        identity: _FakeIdentityReader(failedCreate: const {'veh-1'}),
      );

      expect(find.text("Vehicle couldn't finish saving."), findsOneWidget);
      expect(find.text("We couldn't remove this vehicle."), findsNothing);
    });

    testWidgets('Retry removal targets the correct operation', (tester) async {
      final failed = _FakeFailedDeleteSync(const [_failedDelete]);
      await _pumpTab(tester, vehicles: const [_camry], failed: failed);

      await tester.tap(find.text('Retry removal'));
      await tester.pumpAndSettle();

      expect(failed.retriedIds, [_failedDelete.operationId]);
    });

    testWidgets('Retry removal never calls the delete API directly', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
        remote: remote,
      );

      await tester.tap(find.text('Retry removal'));
      await tester.pumpAndSettle();

      expect(
        remote.deletedIds,
        isEmpty,
        reason: 'the failed operation is replayed, never a new delete',
      );
    });

    testWidgets('a second Retry tap cannot replay the same operation twice', (
      tester,
    ) async {
      final failed = _FakeFailedDeleteSync(const [
        _failedDelete,
      ], retryCompleter: Completer<bool>());
      await _pumpTab(tester, vehicles: const [_camry], failed: failed);

      await tester.tap(find.text('Retry removal'));
      await tester.pump();
      expect(find.text('Retrying\u2026'), findsOneWidget);
      await tester.tap(find.text('Retrying\u2026'), warnIfMissed: false);
      await tester.pump();

      expect(failed.retriedIds.length, 1);
      failed.retryCompleter!.complete(false);
      await tester.pumpAndSettle();
    });

    testWidgets('successful retry clears the recovery and refreshes vehicles', (
      tester,
    ) async {
      final failed = _FakeFailedDeleteSync(const [_failedDelete]);
      var refreshCount = 0;
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: failed,
        onRefresh: (self) {
          refreshCount++;
          self.setVehicles(const []);
        },
      );

      await tester.tap(find.text('Retry removal'));
      await tester.pumpAndSettle();

      expect(find.text("We couldn't remove this vehicle."), findsNothing);
      expect(find.text('Toyota Camry'), findsNothing);
      expect(refreshCount, greaterThan(0));
    });

    testWidgets(
      'a failed refresh after a successful retry does not restore the failure',
      (tester) async {
        final failed = _FakeFailedDeleteSync(const [_failedDelete]);
        var failRefresh = false;
        await _pumpTab(
          tester,
          vehicles: const [_camry],
          failed: failed,
          onRefresh: (self) {
            if (failRefresh) {
              self.setLoadError('Could not load your data.');
            }
          },
        );

        failRefresh = true;
        await tester.tap(find.text('Retry removal'));
        await tester.pumpAndSettle();

        // The workshop accepted the removal: the failure never returns.
        expect(find.text("We couldn't remove this vehicle."), findsNothing);
      },
    );

    testWidgets('a failed retry keeps the vehicle visible with recovery', (
      tester,
    ) async {
      final failed = _FakeFailedDeleteSync(const [
        _failedDelete,
      ], retryResult: false);
      await _pumpTab(tester, vehicles: const [_camry], failed: failed);

      await tester.tap(find.text('Retry removal'));
      await tester.pumpAndSettle();

      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text("We couldn't remove this vehicle."), findsOneWidget);
      expect(find.text('Retry removal'), findsOneWidget);
      expect(
        find.text("We couldn't remove this vehicle. Please try again."),
        findsOneWidget,
      );
    });

    testWidgets('retrying one failure leaves an unrelated failure untouched', (
      tester,
    ) async {
      final failed = _FakeFailedDeleteSync(const [
        _failedDelete,
        _secondFailed,
      ]);
      await _pumpTab(tester, vehicles: const [_camry, _patrol], failed: failed);

      expect(find.text("We couldn't remove this vehicle."), findsNWidgets(2));

      await tester.tap(find.text('Retry removal').first);
      await tester.pumpAndSettle();

      expect(failed.retriedIds, [_failedDelete.operationId]);
      expect(failed.failedDeletes().map((d) => d.vehicleId).toList(), [
        _secondFailed.vehicleId,
      ]);
      expect(find.text("We couldn't remove this vehicle."), findsOneWidget);
      expect(find.text('Nissan Patrol'), findsOneWidget);
    });

    testWidgets('Book service still works from a restored vehicle', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
      );

      await tester.tap(find.text('Book service'));
      await tester.pumpAndSettle();

      expect(find.text('BOOK_SERVICE vehicle=veh-1'), findsOneWidget);
    });

    testWidgets('never exposes technical sync terminology', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final forbidden in const [
        'sync',
        'queue',
        'operation',
        'hive',
        'http',
        'retry count',
      ]) {
        expect(
          texts.contains(forbidden),
          isFalse,
          reason: 'must not show "$forbidden"',
        );
      }
    });

    testWidgets('stays overflow-free on the smallest phone', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
        size: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Retry removal'), findsOneWidget);
    });

    testWidgets('survives an increased text scale', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_verboseVehicle],
        failed: _FakeFailedDeleteSync(const [_verboseFailedDelete]),
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.text("We couldn't remove this vehicle."), findsOneWidget);
      expect(find.text('Retry removal'), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Retry removal'), findsOneWidget);
    });

    testWidgets('failed-delete mobile golden', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_failed_delete_mobile.png'),
      );
    });

    testWidgets('failed-delete dark golden', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol],
        failed: _FakeFailedDeleteSync(const [_failedDelete]),
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_failed_delete_dark.png'),
      );
    });
  });
}

// ---------- Fixtures ----------

const _camry = CustomerVehicleEntity(
  id: 'veh-1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: 'JTNBE46K',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '2026-01-12',
  nextDue: '2026-07-12',
  healthScore: 82,
);

const _patrol = CustomerVehicleEntity(
  id: 'veh-2',
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'B 67890',
  vin: 'JN1TANT31U0',
  color: 'Black',
  year: 2022,
  mileage: '31,000 km',
  lastService: '2026-02-01',
  nextDue: '2026-08-01',
  healthScore: 90,
);

const _verboseVehicle = CustomerVehicleEntity(
  id: 'veh-3',
  brand: 'Mercedes-Benz',
  model: 'GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  vin: 'W1N1671591A',
  color: 'Obsidian Black',
  year: 2023,
  mileage: '12,400 km',
  lastService: '2026-03-01',
  nextDue: '2026-09-01',
  healthScore: 95,
);

const _failedDelete = FailedVehicleDelete(
  operationId: 'vehicle-delete-veh-1',
  vehicleId: 'veh-1',
);

const _secondFailed = FailedVehicleDelete(
  operationId: 'vehicle-delete-veh-2',
  vehicleId: 'veh-2',
);

const _verboseFailedDelete = FailedVehicleDelete(
  operationId: 'vehicle-delete-veh-3',
  vehicleId: 'veh-3',
);

// ---------- Harness ----------

class _FakeRemote implements CustomerRemoteDataSource {
  final List<String> deletedIds = [];

  @override
  Future<void> deleteVehicle(String id) async => deletedIds.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeIdentityReader implements VehicleIdentityReader {
  _FakeIdentityReader({this.failedCreate = const {}});

  final Set<String> failedCreate;

  @override
  String? serverIdFor(String localId) => null;

  @override
  bool isPending(String localId) => false;

  @override
  bool hasFailedCreate(String localId) => failedCreate.contains(localId);
}

class _FakeFailedDeleteSync implements FailedVehicleDeleteSync {
  _FakeFailedDeleteSync(
    this._items, {
    this.retryResult = true,
    this.retryCompleter,
  });

  List<FailedVehicleDelete> _items;
  final bool retryResult;
  final Completer<bool>? retryCompleter;

  final List<String> retriedIds = [];

  @override
  List<FailedVehicleDelete> failedDeletes() => List.of(_items);

  @override
  Future<bool> retry(String operationId) async {
    retriedIds.add(operationId);
    final accepted = retryCompleter != null
        ? await retryCompleter!.future
        : retryResult;
    if (accepted) {
      _items = _items
          .where((operation) => operation.operationId != operationId)
          .toList();
    }
    return accepted;
  }
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial, this._onRefresh);

  final CustomerDashboardState _initial;
  final void Function(_FakeDashboardNotifier self) _onRefresh;

  int refreshCount = 0;

  @override
  CustomerDashboardState build() => _initial;

  @override
  Future<void> refresh() async {
    refreshCount++;
    _onRefresh(this);
  }

  void setVehicles(List<CustomerVehicleEntity> vehicles) =>
      state = state.copyWith(vehicles: vehicles);

  void setLoadError(String error) => state = state.copyWith(loadError: error);
}

Future<void> _pumpTab(
  WidgetTester tester, {
  required List<CustomerVehicleEntity> vehicles,
  required FailedVehicleDeleteSync failed,
  void Function(_FakeDashboardNotifier self)? onRefresh,
  String loadError = '',
  _FakeRemote? remote,
  VehicleIdentityReader? identity,
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
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: CustomerVehiclesTab()),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) => const Scaffold(body: Text('ADD_VEHICLE')),
      ),
      GoRoute(
        path: '/edit-vehicle/:id',
        builder: (context, state) =>
            Scaffold(body: Text('EDIT_VEHICLE ${state.pathParameters['id']}')),
      ),
      GoRoute(
        path: AppRoutes.customerBookService,
        builder: (context, state) => Scaffold(
          body: Text(
            'BOOK_SERVICE vehicle='
            '${state.uri.queryParameters['vehicleId'] ?? 'none'}',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerServiceStatus,
        builder: (_, __) => const Scaffold(body: Text('SERVICE_STATUS')),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        builder: (_, __) => const Scaffold(body: Text('BOOKING_DETAIL')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerRemoteDataSourceProvider.overrideWithValue(
          remote ?? _FakeRemote(),
        ),
        failedVehicleDeleteSyncProvider.overrideWithValue(failed),
        vehicleIdentityReaderProvider.overrideWithValue(
          identity ?? _FakeIdentityReader(),
        ),
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            CustomerDashboardState(
              selectedIndex: 0,
              isLoading: false,
              selectedVehicle: '',
              selectedServiceType: '',
              bookingNotes: '',
              loadError: loadError,
              vehicles: vehicles,
              notifications: const [],
            ),
            onRefresh ?? (_) {},
          ),
        ),
        customerBookingsProvider.overrideWith((ref) async => const []),
        customerApprovalsProvider.overrideWith((ref) async => const []),
        customerInvoicesProvider.overrideWith((ref) async => const []),
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
