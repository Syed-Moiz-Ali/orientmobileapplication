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
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_vehicle_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicle_record.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

/// My vehicles: real identity, real specification, real service context from
/// the customer's own bookings — and no fabricated health, MOT or service-due
/// claims and no stock photography.
void main() {
  setUpAll(_loadFonts);

  group('Vehicles tab states', () {
    testWidgets('shows a vehicles-shaped skeleton while loading', (
      tester,
    ) async {
      await _pumpTab(tester, vehicles: const [], loading: true, settle: false);
      await tester.pump();

      expect(find.byType(CustomerSkeleton), findsOneWidget);
    });

    testWidgets('offers a recoverable state when nothing could load', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [],
        loadError: 'Could not load your data.',
      );

      expect(find.text("We couldn't load your vehicles"), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text("We couldn't load your vehicles"), findsOneWidget);
    });

    testWidgets('keeps a failed refresh from blanking the garage', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        loadError: 'Could not load your data.',
      );

      expect(find.text('Toyota Camry'), findsWidgets);
      expect(
        find.text("We couldn't refresh your information."),
        findsOneWidget,
      );
    });

    testWidgets('asks for a first vehicle when the garage is empty', (
      tester,
    ) async {
      await _pumpTab(tester, vehicles: const []);

      expect(find.text('My vehicles'), findsOneWidget);
      expect(find.text('No vehicles added yet'), findsOneWidget);
      expect(find.text('Add vehicle'), findsWidgets);

      await tester.tap(find.text('Add vehicle').last);
      await tester.pumpAndSettle();
      expect(find.text('ADD_VEHICLE'), findsOneWidget);
    });
  });

  group('Vehicles tab records', () {
    testWidgets('shows real identity, specification and count', (tester) async {
      await _pumpTab(tester, vehicles: const [_camry]);

      expect(find.text('1 registered vehicle'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('A 12345'), findsWidgets);
      expect(find.text('2021 \u00b7 White \u00b7 48,200 km'), findsOneWidget);
    });

    testWidgets('omits unknown metadata instead of inventing it', (
      tester,
    ) async {
      await _pumpTab(tester, vehicles: const [_sparse]);

      expect(find.text('Nissan'), findsWidgets);
      expect(find.textContaining('0 km'), findsNothing);
      expect(find.textContaining('\u00b7'), findsNothing);
    });

    testWidgets('lists several vehicles with their real count', (tester) async {
      await _pumpTab(tester, vehicles: const [_camry, _patrol]);

      expect(find.text('2 registered vehicles'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsWidgets);
      expect(find.text('Nissan Patrol'), findsWidgets);
    });

    testWidgets('handles a large garage without overflow', (tester) async {
      final many = [
        for (var index = 0; index < 12; index++)
          CustomerVehicleEntity(
            id: 'v$index',
            brand: 'Toyota',
            model: 'Model $index',
            plateNumber: 'A 1000$index',
            vin: '',
            color: 'White',
            year: 2020 + (index % 3),
            mileage: '${10 + index}0,000 km',
            lastService: '',
            nextDue: '',
            healthScore: 0,
          ),
      ];
      await _pumpTab(tester, vehicles: many);

      expect(find.text('12 registered vehicles'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomerVehicleRecord), findsWidgets);
    });

    testWidgets('never claims health, MOT or service-due from defaults', (
      tester,
    ) async {
      // The vehicle carries the client-written defaults the old flow produced.
      await _pumpTab(tester, vehicles: const [_legacyDefaults]);

      expect(find.textContaining('MOT'), findsNothing);
      expect(find.textContaining('Health'), findsNothing);
      expect(find.textContaining('100%'), findsNothing);
      expect(find.text('Last service'), findsNothing);
      expect(find.textContaining('Next due'), findsNothing);
    });

    testWidgets('renders no vehicle photography of any kind', (tester) async {
      await _pumpTab(tester, vehicles: const [_camry, _patrol]);

      expect(find.byType(Image), findsNothing);
    });
  });

  group('Vehicles tab real service context', () {
    testWidgets('shows the live workshop stage for the matching vehicle', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        activeService: _liveService,
      );

      expect(find.text('IN THE WORKSHOP NOW'), findsOneWidget);
      expect(find.textContaining('Quality Check'), findsOneWidget);

      await tester.tap(find.text('Track'));
      await tester.pumpAndSettle();
      expect(find.text('SERVICE_STATUS'), findsOneWidget);
    });

    testWidgets('never borrows another vehicle’s live job', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_patrol],
        activeService: _liveService, // belongs to the Camry's plate
      );

      expect(find.text('IN THE WORKSHOP NOW'), findsNothing);
    });

    testWidgets('shows the real upcoming appointment for the vehicle', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        bookings: const [_upcoming],
      );

      expect(find.text('BOOKED'), findsOneWidget);
      expect(find.textContaining('Brake Inspection'), findsWidgets);

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      expect(find.text('BOOKING_DETAIL'), findsOneWidget);
    });

    testWidgets('shows the real last completed service', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        bookings: const [_completed],
      );

      expect(find.text('LAST SERVICE'), findsOneWidget);
      expect(find.textContaining('Oil & Filter Change'), findsWidgets);
    });

    testWidgets('shows no context when nothing references the vehicle', (
      tester,
    ) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        bookings: const [_otherVehicleBooking],
      );

      expect(find.text('LAST SERVICE'), findsNothing);
      expect(find.text('BOOKED'), findsNothing);
      expect(find.text('IN THE WORKSHOP NOW'), findsNothing);
    });
  });

  group('Vehicles tab actions', () {
    testWidgets('opens Book service for that exact vehicle', (tester) async {
      await _pumpTab(tester, vehicles: const [_camry, _patrol]);

      await tester.tap(find.text('Book service').first);
      await tester.pumpAndSettle();

      // The vehicle travels with the request, so the customer does not choose
      // the same car twice.
      expect(find.text('BOOK_SERVICE vehicle=v1'), findsOneWidget);
    });

    testWidgets('opens Edit for that vehicle', (tester) async {
      await _pumpTab(tester, vehicles: const [_camry, _patrol]);

      await tester.tap(find.text('Edit').last);
      await tester.pumpAndSettle();

      expect(find.text('EDIT_VEHICLE v2'), findsOneWidget);
    });

    testWidgets('confirms before removing, naming the vehicle', (tester) async {
      final remote = _FakeRemote();
      await _pumpTab(tester, vehicles: const [_camry], remote: remote);

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Remove Toyota Camry?'), findsOneWidget);
      expect(
        find.text('A 12345 will be removed from your vehicles.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Keep vehicle'));
      await tester.pumpAndSettle();
      expect(remote.deletedIds, isEmpty);
      expect(find.text('Toyota Camry'), findsWidgets);
    });

    testWidgets('removes the vehicle and reports it', (tester) async {
      final remote = _FakeRemote();
      await _pumpTab(tester, vehicles: const [_camry], remote: remote);

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Remove vehicle'));
      await tester.pumpAndSettle();

      expect(remote.deletedIds, ['v1']);
      expect(find.text('Vehicle removed.'), findsOneWidget);
      expect(find.text('Toyota Camry'), findsNothing);
    });

    testWidgets('keeps the vehicle when removal fails', (tester) async {
      final remote = _FakeRemote(deleteFails: true);
      await _pumpTab(tester, vehicles: const [_camry], remote: remote);

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Remove vehicle'));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't remove this vehicle. Please try again."),
        findsOneWidget,
      );
      expect(find.text('Toyota Camry'), findsWidgets);
    });
  });

  group('Vehicles tab layout and imagery guards', () {
    testWidgets('stays overflow-free on every supported width', (tester) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpTab(
          tester,
          vehicles: const [_verbose, _camry, _patrol],
          size: Size(width, 844),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'vehicles must not overflow at ${width}px',
        );
      }
    });

    testWidgets('survives large text and long values', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_verbose],
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Mercedes-Benz'), findsWidgets);
    });

    testWidgets('uses two columns on a wide layout', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol, _verbose, _sparse],
        bookings: const [_upcoming, _completed],
        size: const Size(1440, 900),
      );

      final records = tester.widgetList<CustomerVehicleRecord>(
        find.byType(CustomerVehicleRecord),
      );
      expect(records.length, 4);
      final first = tester.getTopLeft(find.byType(CustomerVehicleRecord).first);
      final fourth = tester.getTopLeft(find.byType(CustomerVehicleRecord).last);
      expect(fourth.dx, greaterThan(first.dx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark theme', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol],
        bookings: const [_upcoming, _completed],
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('My vehicles'), findsOneWidget);
    });

    test('never reintroduces fake vehicle imagery or claims', () {
      for (final path in const [
        'lib/features/customer/presentation/widgets/customer_vehicles_tab.dart',
        'lib/features/customer/presentation/widgets/customer_vehicle_record.dart',
        'lib/features/customer/presentation/add_vehicle_view.dart',
        'lib/features/customer/presentation/support/customer_vehicle_presentation.dart',
      ]) {
        final source = File(path).readAsStringSync();
        expect(source.contains('unsplash'), isFalse, reason: path);
        expect(source.contains('Image.network'), isFalse, reason: path);
        expect(source.contains('MOT'), isFalse, reason: path);
        expect(source.contains('V5C'), isFalse, reason: path);
        expect(source.contains('Upload Vehicle Photo'), isFalse, reason: path);
      }
    });
  });

  group('Vehicle presentation', () {
    test('normalises the mileage without inventing or duplicating km', () {
      expect(CustomerVehiclePresentation.mileageLabel('48200'), '48200 km');
      expect(
        CustomerVehiclePresentation.mileageLabel('48,200 km'),
        '48,200 km',
      );
      expect(CustomerVehiclePresentation.mileageLabel('48200 KM'), '48200 km');
      expect(CustomerVehiclePresentation.mileageLabel(''), '');
      expect(CustomerVehiclePresentation.mileageLabel('  '), '');
      expect(CustomerVehiclePresentation.mileageInput('48,200 km'), '48,200');
      expect(CustomerVehiclePresentation.mileageInput(''), '');
    });

    test('normalises the plate', () {
      expect(CustomerVehiclePresentation.plateLabel(' a 12345 '), 'A 12345');
      expect(CustomerVehiclePresentation.plateLabel('a-12345'), 'A-12345');
    });

    test('states only real specifications', () {
      expect(CustomerVehiclePresentation.specs(_camry), [
        '2021',
        'White',
        '48,200 km',
      ]);
      expect(CustomerVehiclePresentation.specs(_sparse), isEmpty);
      expect(CustomerVehiclePresentation.hasSpecs(_sparse), isFalse);
    });

    test('sends only the documented API fields', () {
      final payload = CustomerVehiclePresentation.apiPayload(_camry);

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
      expect(payload.containsKey('id'), isFalse);
      expect(payload['plateNumber'], 'A 12345');
      expect(payload['mileage'], '48,200 km');
    });

    test('matches context by plate only', () {
      expect(
        CustomerVehiclePresentation.bookingsFor(_camry, const [_upcoming]),
        hasLength(1),
      );
      expect(
        CustomerVehiclePresentation.bookingsFor(_patrol, const [_upcoming]),
        isEmpty,
      );
      expect(
        CustomerVehiclePresentation.bookingsFor(_sparse, const [_upcoming]),
        isEmpty,
        reason: 'a vehicle without a plate cannot be matched',
      );
    });
  });

  group('Vehicles visual references', () {
    testWidgets('one vehicle mobile', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry],
        activeService: _liveService,
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_one_mobile.png'),
      );
    });

    testWidgets('multiple vehicles mobile', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol],
        bookings: const [_upcoming, _completed],
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_multiple_mobile.png'),
      );
    });

    testWidgets('empty mobile', (tester) async {
      await _pumpTab(tester, vehicles: const []);
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_empty_mobile.png'),
      );
    });

    testWidgets('tablet', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol, _verbose, _sparse],
        bookings: const [_upcoming, _completed],
        size: const Size(1024, 900),
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_tablet.png'),
      );
    });

    testWidgets('desktop', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol, _verbose, _sparse],
        bookings: const [_upcoming, _completed],
        size: const Size(1440, 900),
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_desktop.png'),
      );
    });

    testWidgets('dark mobile', (tester) async {
      await _pumpTab(
        tester,
        vehicles: const [_camry, _patrol],
        bookings: const [_upcoming, _completed],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(CustomerVehiclesTab),
        matchesGoldenFile('goldens/customer_vehicles_dark_mobile.png'),
      );
    });
  });
}

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _camry = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'A 12345',
  vin: 'JT2BF22K1W0123456',
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
  year: 2023,
  mileage: '12,000 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

/// Exactly what the old client wrote: a defaulted, never-assessed vehicle.
const _legacyDefaults = CustomerVehicleEntity(
  id: 'v3',
  brand: 'Honda',
  model: 'Civic',
  plateNumber: 'B 54321',
  vin: '',
  color: '',
  year: 2026,
  mileage: '0 km',
  lastService: 'N/A',
  nextDue: 'N/A',
  healthScore: 100,
);

const _sparse = CustomerVehicleEntity(
  id: 'v4',
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

const _verbose = CustomerVehicleEntity(
  id: 'v5',
  brand: 'Mercedes-Benz',
  model: 'GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  vin: '',
  color: 'Obsidian Black',
  year: 2022,
  mileage: '128,400 km',
  lastService: '',
  nextDue: '',
  healthScore: 0,
);

const _upcoming = CustomerBookingEntity(
  id: 'b1',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0042',
);

const _completed = CustomerBookingEntity(
  id: 'b2',
  service: 'Oil & Filter Change',
  vehicleName: 'Toyota Camry',
  plateNumber: 'A 12345',
  date: '2 Jun 2026',
  time: '11:00 AM',
  status: BookingStatus.completed,
  bookingRef: 'BK-2026-0011',
);

const _otherVehicleBooking = CustomerBookingEntity(
  id: 'b3',
  service: 'Tyre Rotation',
  vehicleName: 'Nissan Patrol',
  plateNumber: 'A 99999',
  date: '1 Aug 2026',
  time: '10:00 AM',
  status: BookingStatus.completed,
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Camry',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  currentStage: 'quality_check',
  technicianName: 'Ravi',
  stages: [],
);

class _FakeRemote implements CustomerRemoteDataSource {
  _FakeRemote({this.deleteFails = false});

  final bool deleteFails;
  final List<String> deletedIds = [];

  @override
  Future<void> deleteVehicle(String id) async {
    deletedIds.add(id);
    if (deleteFails) throw const ValidationException('not removable');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial, this._onRefresh);

  final CustomerDashboardState _initial;
  final void Function() _onRefresh;

  @override
  CustomerDashboardState build() => _initial;

  @override
  Future<void> refresh() async => _onRefresh();
}

Future<void> _pumpTab(
  WidgetTester tester, {
  required List<CustomerVehicleEntity> vehicles,
  List<CustomerBookingEntity> bookings = const [],
  CustomerServiceEntity? activeService,
  String loadError = '',
  bool loading = false,
  _FakeRemote? remote,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
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
        customerRemoteDataSourceProvider.overrideWithValue(dataSource),
        customerDashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            CustomerDashboardState(
              selectedIndex: 0,
              isLoading: loading,
              selectedVehicle: '',
              selectedServiceType: '',
              bookingNotes: '',
              loadError: loadError,
              vehicles: vehicles,
              notifications: const [],
              activeService: activeService,
            ),
            () {},
          ),
        ),
        customerBookingsProvider.overrideWith((ref) async => bookings),
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
  if (settle) await tester.pumpAndSettle();
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
