import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/add_vehicle_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

/// Registering and updating a vehicle: only the make and plate are required,
/// optional data stays optional, and nothing is invented — no current-year
/// default, no `0 km`, no fabricated assessment, and no wiping what the
/// workshop recorded.
void main() {
  setUpAll(_loadFonts);

  group('Add vehicle form', () {
    testWidgets('requires only the make and the plate', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, remote: remote);

      expect(find.text('Add vehicle'), findsWidgets);
      expect(find.text('VEHICLE'), findsOneWidget);
      expect(find.text('REGISTRATION'), findsOneWidget);
      expect(find.text('DETAILS'), findsOneWidget);

      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();

      expect(find.text('Enter the make of your vehicle'), findsOneWidget);
      expect(find.text('Enter the registration plate'), findsOneWidget);
      expect(remote.created, isEmpty);

      await tester.enterText(find.byType(TextField).at(0), 'Toyota');
      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();
      expect(find.text('Enter the registration plate'), findsOneWidget);
      expect(remote.created, isEmpty);
    });

    testWidgets('sends exactly the documented contract', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, remote: remote);

      await _fill(tester, {
        0: 'toyota',
        1: 'camry',
        2: 'a 12345',
        3: 'jt2bf22k1w0123456',
        4: '2021',
        5: 'white',
        6: '48,200',
      });
      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();

      expect(remote.created, hasLength(1));
      final payload = remote.created.single;
      expect(payload.keys.toSet(), {
        'brand',
        'model',
        'plateNumber',
        'vin',
        'color',
        'year',
        'mileage',
        'lastService',
        'nextDue',
        'healthScore',
      });
      expect(payload['brand'], 'toyota');
      expect(
        payload['plateNumber'],
        'A 12345',
        reason: 'plates are normalised',
      );
      expect(payload['vin'], 'JT2BF22K1W0123456');
      expect(payload['color'], 'white');
      expect(payload['year'], 2021);
      expect(payload['mileage'], '48,200 km', reason: 'one km, never doubled');
      // Nothing is claimed on the customer's behalf.
      expect(payload['healthScore'], 0);
      expect(payload['lastService'], '');
      expect(payload['nextDue'], '');
    });

    testWidgets('never fabricates a year or a mileage', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, remote: remote);

      await _fill(tester, {0: 'Toyota', 2: 'A 12345'});
      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();

      final payload = remote.created.single;
      expect(payload['year'], 0, reason: 'an unknown year stays unknown');
      expect(payload['mileage'], '', reason: 'unknown mileage stays unknown');

      // An impossible year is rejected rather than saved.
      await _pumpForm(tester, remote: remote);
      await _fill(tester, {0: 'Toyota', 2: 'A 12345', 4: '1899'});
      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Enter a year between'), findsOneWidget);
      expect(remote.created, hasLength(1));
    });

    testWidgets('accepts a vehicle without optional details', (tester) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, remote: remote);

      await _fill(tester, {0: 'Nissan', 2: 'B 54321'});
      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();

      final payload = remote.created.single;
      expect(payload['model'], '');
      expect(payload['vin'], '');
      expect(payload['color'], '');
    });

    testWidgets('prevents a double submission and keeps values on failure', (
      tester,
    ) async {
      final remote = _FakeRemote(pending: true);
      await _pumpForm(tester, remote: remote);

      await _fill(tester, {0: 'Toyota', 2: 'A 12345'});
      await tester.tap(find.text('Add vehicle').last);
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      await tester.tap(find.text('Saving…'), warnIfMissed: false);
      await tester.pump();
      expect(remote.created, hasLength(1));

      remote.completeCreate(fails: true);
      await tester.pumpAndSettle();

      // The API's own reason is shown; nothing is swallowed.
      expect(find.text('The workshop rejected this vehicle.'), findsOneWidget);
      // Every value the customer typed is still there.
      expect(find.text('Toyota'), findsWidgets);
      expect(find.text('A 12345'), findsWidgets);
    });

    testWidgets('reports a queued save when the device is offline', (
      tester,
    ) async {
      final remote = _FakeRemote(offline: true);
      await _pumpForm(tester, remote: remote);

      await _fill(tester, {0: 'Toyota', 2: 'A 12345'});
      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();

      // The form closes with the vehicle it saved, even offline.
      expect(find.text('POPPED'), findsOneWidget);
    });
  });

  group('Edit vehicle form', () {
    testWidgets('prepopulates only genuine stored values', (tester) async {
      await _pumpForm(tester, editing: _camry);

      expect(find.text('Edit vehicle'), findsWidgets);
      expect(find.text('Toyota'), findsWidgets);
      expect(find.text('Camry'), findsWidgets);
      expect(find.text('A 12345'), findsWidgets);
      expect(find.text('2021'), findsWidgets);
      expect(find.text('White'), findsWidgets);
      expect(find.text('48,200'), findsWidgets);
    });

    testWidgets('represents unknown values honestly', (tester) async {
      await _pumpForm(tester, editing: _unknownValues);

      // No fabricated current year and no 0 km appear in the form.
      final year = tester.widget<TextField>(find.byType(TextField).at(4));
      final mileage = tester.widget<TextField>(find.byType(TextField).at(6));
      expect(year.controller?.text ?? '', '');
      expect(mileage.controller?.text ?? '', '');
    });

    testWidgets('preserves workshop data and saves through the API', (
      tester,
    ) async {
      final remote = _FakeRemote();
      await _pumpForm(tester, editing: _camry, remote: remote);

      await tester.enterText(find.byType(TextField).at(5), 'Silver');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(remote.updatedIds, ['v1']);
      final payload = remote.updated.single;
      expect(payload['color'], 'Silver');
      // The workshop's own assessment and dates are never overwritten.
      expect(payload['healthScore'], _camry.healthScore);
      expect(payload['lastService'], _camry.lastService);
      expect(payload['nextDue'], _camry.nextDue);
    });
  });

  group('Vehicle form layout', () {
    testWidgets('stays usable on a narrow phone and at large text', (
      tester,
    ) async {
      await _pumpForm(tester, size: const Size(320, 640));
      expect(tester.takeException(), isNull);

      await _pumpForm(
        tester,
        textScaler: const TextScaler.linear(1.6),
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpForm(tester, theme: AppTheme.dark(BrandConfig.orient));
      expect(tester.takeException(), isNull);
      expect(find.text('Add vehicle'), findsWidgets);
    });
  });

  group('Vehicle form visual references', () {
    testWidgets('add mobile', (tester) async {
      await _pumpForm(tester);
      await expectLater(
        find.byType(AddVehicleView),
        matchesGoldenFile('goldens/customer_add_vehicle_mobile.png'),
      );
    });

    testWidgets('add tablet', (tester) async {
      await _pumpForm(tester, size: const Size(1024, 900));
      await expectLater(
        find.byType(AddVehicleView),
        matchesGoldenFile('goldens/customer_add_vehicle_tablet.png'),
      );
    });

    testWidgets('add dark', (tester) async {
      await _pumpForm(tester, theme: AppTheme.dark(BrandConfig.orient));
      await expectLater(
        find.byType(AddVehicleView),
        matchesGoldenFile('goldens/customer_add_vehicle_dark.png'),
      );
    });

    testWidgets('edit mobile', (tester) async {
      await _pumpForm(tester, editing: _camry);
      await expectLater(
        find.byType(AddVehicleView),
        matchesGoldenFile('goldens/customer_edit_vehicle_mobile.png'),
      );
    });
  });
}

const _camry = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: 'JT2BF22K1W0123456',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '2 Jun 2026',
  nextDue: '2 Dec 2026',
  healthScore: 82,
);

const _unknownValues = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Nissan',
  model: '',
  plateNumber: 'C 11111',
  vin: '',
  color: '',
  year: 0,
  mileage: '',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

class _FakeRemote implements CustomerRemoteDataSource {
  _FakeRemote({this.pending = false, this.offline = false});

  final bool pending;
  final bool offline;
  final List<Map<String, dynamic>> created = [];
  final List<Map<String, dynamic>> updated = [];
  final List<String> updatedIds = [];
  Completer<VehicleResponse>? _completer;

  @override
  Future<VehicleResponse> addVehicle(Map<String, dynamic> data) {
    created.add(data);
    if (pending) {
      _completer ??= Completer<VehicleResponse>();
      return _completer!.future;
    }
    if (offline) throw const NetworkException('no connection');
    return Future.value(_responseFor(data));
  }

  @override
  Future<VehicleResponse> updateVehicle(String id, Map<String, dynamic> data) {
    updatedIds.add(id);
    updated.add(data);
    return Future.value(_responseFor(data, id: id));
  }

  void completeCreate({required bool fails}) => fails
      ? _completer!.completeError(
          const ValidationException('The workshop rejected this vehicle.'),
        )
      : _completer!.complete(_responseFor(created.single));

  VehicleResponse _responseFor(Map<String, dynamic> data, {String id = 'v9'}) =>
      VehicleResponse(
        id: id,
        brand: (data['brand'] ?? '') as String,
        model: (data['model'] ?? '') as String,
        plateNumber: (data['plateNumber'] ?? '') as String,
        vin: (data['vin'] ?? '') as String,
        color: (data['color'] ?? '') as String,
        year: (data['year'] as num?)?.toInt() ?? 0,
        mileage: (data['mileage'] ?? '') as String,
        lastService: (data['lastService'] ?? '') as String,
        nextDue: (data['nextDue'] ?? '') as String,
        healthScore: (data['healthScore'] as num?)?.toInt() ?? 0,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
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

Future<void> _fill(WidgetTester tester, Map<int, String> values) async {
  for (final entry in values.entries) {
    await tester.enterText(find.byType(TextField).at(entry.key), entry.value);
  }
  await tester.pumpAndSettle();
}

Future<void> _pumpForm(
  WidgetTester tester, {
  CustomerVehicleEntity? editing,
  _FakeRemote? remote,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final dataSource = remote ?? _FakeRemote();

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, __) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                final saved = await context.push<CustomerVehicleEntity>(
                  editing == null
                      ? AppRoutes.customerAddVehicle
                      : AppRoutes.customerEditVehicle(editing.id),
                );
                if (saved != null && context.mounted) {
                  context.go('/popped');
                }
              },
              child: const Text('OPEN_FORM'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/popped',
        builder: (_, __) => const Scaffold(body: Text('POPPED')),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) => const AddVehicleView(),
      ),
      GoRoute(
        path: '/edit-vehicle/:id',
        builder: (context, state) =>
            AddVehicleView(vehicleId: state.pathParameters['id'] ?? ''),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerRemoteDataSourceProvider.overrideWithValue(dataSource),
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier([if (editing != null) editing]),
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
  await tester.tap(find.text('OPEN_FORM'));
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
