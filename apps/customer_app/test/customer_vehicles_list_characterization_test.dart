// Structural tests for the recomposed customer vehicles list (phase 6).
//
// Presentation-tree assertions only: header/find-aids threshold, per-card
// Book/menu reachability (tap budgets AFTER ≤ BEFORE), honest context pills,
// ValueKey('vehicle-<id>'), search/filter sheets, remove bottom sheet,
// loading/empty/error states, pull-to-refresh. Behavior (providers,
// navigation targets, booking logic) is asserted nowhere.
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_vehicle_delete.dart';
import 'package:customer_app/features/customer/presentation/support/vehicle_booking_decision.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicle_record.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _v1 = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'ABC 1234',
  vin: 'JT1ABC',
  color: 'White',
  year: 2021,
  mileage: '45000 km',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

const _v2 = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Honda',
  model: 'Civic',
  plateNumber: 'XYZ 5678',
  vin: '',
  color: 'Silver',
  year: 2019,
  mileage: '78200 km',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

const _upcoming = CustomerBookingEntity(
  id: 'b1',
  service: 'Oil change',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  date: '12 Jun 2026',
  time: '10:00',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-1001',
);

const _completed = CustomerBookingEntity(
  id: 'b2',
  service: 'Brake pads',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '02 May 2026',
  time: '09:00',
  status: BookingStatus.completed,
  bookingRef: 'BK-0987',
);

class _FixedDashNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedDashNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

class _NoFailedSync implements FailedVehicleDeleteSync {
  @override
  List<FailedVehicleDelete> failedDeletes() => const [];
  @override
  Future<bool> retry(String operationId) async => false;
}

class _NoIdentityReader implements VehicleIdentityReader {
  @override
  String? serverIdFor(String localId) => null;
  @override
  bool isPending(String localId) => false;
  @override
  bool hasFailedCreate(String localId) => false;
}

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerVehicleEntity> vehicles = const [],
  CustomerServiceEntity? activeService,
}) => CustomerDashboardState(
  selectedIndex: 2,
  isLoading: isLoading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  vehicles: vehicles,
  notifications: const [],
  activeService: activeService,
  profile: null,
  loadError: loadError,
);

Future<void> _pumpList(
  WidgetTester tester, {
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  ThemeData? theme,
  double scale = 1.0,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(
          () => _FixedDashNotifier(state),
        ),
        customerBookingsProvider.overrideWith((ref) async => bookings),
        failedVehicleDeleteSyncProvider.overrideWith((ref) => _NoFailedSync()),
        vehicleIdentityReaderProvider.overrideWith(
          (ref) => _NoIdentityReader(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: CustomerVehiclesTab()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

List<CustomerVehicleEntity> _six() => [
  for (var i = 0; i < 6; i++)
    CustomerVehicleEntity(
      id: 'v$i',
      brand: 'Toyota',
      model: 'Camry',
      plateNumber: 'ABC 100$i',
      vin: '',
      color: 'White',
      year: 2021,
      mileage: '45000 km',
      lastService: '',
      nextDue: '',
      healthScore: -1,
    ),
];

void main() {
  group('vehicles list (after)', () {
    testWidgets('<=5: header + count + Add, no find-aids, direct Book', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1, _v2]),
        bookings: const [_upcoming, _completed],
      );

      expect(find.text('My vehicles'), findsOneWidget);
      expect(find.text('2 registered vehicles'), findsOneWidget);
      // Add stays a header action when non-empty (1 tap from list).
      expect(find.text('Add vehicle'), findsOneWidget);
      // Progressive disclosure: no search/filter icons with ≤ 5 items.
      expect(find.byTooltip('Search vehicles'), findsNothing);
      expect(find.byTooltip('Filter vehicles'), findsNothing);
      // Records keyed by vehicle id.
      expect(find.byKey(const ValueKey('vehicle-v1')), findsOneWidget);
      expect(find.byKey(const ValueKey('vehicle-v2')), findsOneWidget);
      // Book service directly on each card (≤ 1 tap from the list).
      expect(find.text('Book service'), findsNWidgets(2));
      // Edit/Remove live in the card menu, not as direct buttons.
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Remove'), findsNothing);
      expect(find.byIcon(Icons.more_vert_rounded), findsNWidgets(2));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('card menu holds Edit + Remove (existing routes)', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1]),
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      // Removing opens the confirmation sheet instead of navigating.
      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Remove Toyota Camry?'), findsOneWidget);
      expect(find.text('Keep vehicle'), findsOneWidget);
      // Cancel keeps the car and closes both sheet and menu.
      await tester.tap(find.text('Keep vehicle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Edit'), findsNothing);
      expect(find.byKey(const ValueKey('vehicle-v1')), findsOneWidget);
    });

    testWidgets('context pill sentence-case from contextFor only', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1, _v2]),
        bookings: const [_upcoming, _completed],
      );
      expect(find.byType(AppStatusChip), findsNWidgets(2));
      // Sentence case via theme: no ALL-CAPS labels anywhere.
      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('Last service'), findsOneWidget);
      expect(find.text('BOOKED'), findsNothing);
      expect(find.text('LAST SERVICE'), findsNothing);
      expect(find.text('View'), findsNWidgets(2));
      expect(find.text('ABC 1234'), findsOneWidget);
      expect(find.text('Toyota Camry · 2021'), findsOneWidget);
    });

    testWidgets('no status pill when no context exists', (tester) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1]),
        bookings: const [],
      );
      expect(find.byType(AppStatusChip), findsNothing);
      expect(find.text('View'), findsNothing);
      expect(find.text('Track'), findsNothing);
      expect(find.text('Toyota Camry · 2021'), findsOneWidget);
    });

    testWidgets('>5: search + filter icons appear together', (tester) async {
      await _pumpList(tester, state: _state(vehicles: _six()));
      expect(find.text('6 registered vehicles'), findsOneWidget);
      expect(find.byTooltip('Search vehicles'), findsOneWidget);
      expect(find.byTooltip('Filter vehicles'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('vehicle-v$i')), findsOneWidget);
      }
      expect(find.text('Book service'), findsNWidgets(6));
    });

    testWidgets('search sheet filters loaded records, no-match + Clear', (
      tester,
    ) async {
      await _pumpList(tester, state: _state(vehicles: _six()));
      await tester.tap(find.byTooltip('Search vehicles'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(find.text('Search by name, plate, or colour'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'ABC 1001');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Sheet rows live in the sheet ListView; the background list keeps all
      // six cards behind the scrim.
      final sheetList = find.byType(ListView);
      expect(
        find.descendant(of: sheetList, matching: find.text('ABC 1001')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheetList, matching: find.text('ABC 1002')),
        findsNothing,
      );
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('No vehicles match your search.'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('filter applies + count updates + no-match + Clear', (
      tester,
    ) async {
      const upcoming0 = CustomerBookingEntity(
        id: 'b1',
        service: 'Oil change',
        vehicleName: 'Toyota Camry',
        plateNumber: 'ABC 1000',
        date: '12 Jun 2026',
        time: '10:00',
        status: BookingStatus.confirmed,
        bookingRef: 'BK-1001',
      );
      const completed1 = CustomerBookingEntity(
        id: 'b2',
        service: 'Brake pads',
        vehicleName: 'Toyota Camry',
        plateNumber: 'ABC 1001',
        date: '02 May 2026',
        time: '09:00',
        status: BookingStatus.completed,
        bookingRef: 'BK-0987',
      );
      await _pumpList(
        tester,
        state: _state(vehicles: _six()),
        bookings: const [upcoming0, completed1],
      );

      Future<void> applyFilter(String option) async {
        await tester.tap(find.byTooltip('Filter vehicles'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text(option));
        await tester.pump();
        await tester.tap(find.text('Show results'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Booked or requested: only the upcoming vehicle stays; the subtitle
      // updates with the filtered count (ICU plural: 1 → singular).
      await applyFilter('Booked or requested');
      expect(find.byKey(const ValueKey('vehicle-v0')), findsOneWidget);
      expect(find.byKey(const ValueKey('vehicle-v1')), findsNothing);
      expect(find.text('1 registered vehicle'), findsOneWidget);

      // Last service: only the completed vehicle stays.
      await applyFilter('Last service');
      expect(find.byKey(const ValueKey('vehicle-v1')), findsOneWidget);
      expect(find.byKey(const ValueKey('vehicle-v0')), findsNothing);

      // In the workshop now: nothing matches → no-match state + Clear.
      await applyFilter('In the workshop now');
      expect(find.text('No vehicles match this filter.'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.text('6 registered vehicles'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('vehicle-v$i')), findsOneWidget);
      }
    });

    testWidgets('plural count renders 0/1/6 with zero as 0 (U11)', (
      tester,
    ) async {
      // 6 → plural other.
      await _pumpList(tester, state: _state(vehicles: _six()));
      expect(find.text('6 registered vehicles'), findsOneWidget);
      // Filter to zero matches → header shows "0 ..." (zero as 0, not "-").
      await tester.tap(find.byTooltip('Filter vehicles'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('In the workshop now'));
      await tester.pump();
      await tester.tap(find.text('Show results'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('0 registered vehicles'), findsOneWidget);
      expect(find.text('No vehicles match this filter.'), findsOneWidget);
    });

    testWidgets('filter sheet on 6+ list filters + count + no-match', (
      tester,
    ) async {
      await _pumpList(tester, state: _state(vehicles: _six()));
      await tester.tap(find.byTooltip('Filter vehicles'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Filter vehicles'), findsWidgets);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('In the workshop now'), findsOneWidget);
      expect(find.text('Booked or requested'), findsOneWidget);
      expect(find.text('Last service'), findsOneWidget);
      expect(find.text('No active context'), findsOneWidget);
      expect(find.text('Show results'), findsOneWidget);
      // None of the six has bookings: "No active context" keeps all six.
      await tester.tap(find.text('No active context'));
      await tester.pump();
      await tester.tap(find.text('Show results'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('6 registered vehicles'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('vehicle-v$i')), findsOneWidget);
      }
    });

    testWidgets('remove opens a confirmation bottom sheet, cancel keeps car', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1]),
      );
      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Remove Toyota Camry?'), findsOneWidget);
      expect(find.text('Remove vehicle'), findsOneWidget);
      expect(find.text('Keep vehicle'), findsOneWidget);
      await tester.tap(find.text('Keep vehicle'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('vehicle-v1')), findsOneWidget);
    });

    testWidgets('empty: one icon + one sentence + one Add action', (
      tester,
    ) async {
      await _pumpList(tester, state: _state(vehicles: const []));
      expect(find.byType(AppEmptyState), findsOneWidget);
      // AppEmptyState bidi-isolates its copy; match the sentence inside.
      expect(find.textContaining('No vehicles added yet'), findsOneWidget);
      expect(find.text('Add vehicle'), findsOneWidget);
      expect(find.byKey(const ValueKey('vehicle-v1')), findsNothing);
      // Empty state owns the only Add entry point (header Add hidden).
      expect(find.text('Add vehicle'), findsOneWidget);
    });

    testWidgets('loading: mirroring skeleton, no records', (tester) async {
      await _pumpList(
        tester,
        state: _state(isLoading: true, vehicles: const []),
      );
      expect(find.byType(AppShimmerSkeleton), findsWidgets);
      expect(find.byKey(const ValueKey('vehicle-v1')), findsNothing);
    });

    testWidgets('load failure: title + retry', (tester) async {
      await _pumpList(
        tester,
        state: _state(loadError: 'No connection', vehicles: const []),
      );
      expect(find.byType(AppErrorState), findsOneWidget);
      // AppErrorState bidi-isolates its copy; match the title inside.
      expect(
        find.textContaining("We couldn't load your vehicles"),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('record unit: title/plate/specs/action row, no pill w/o ctx', (
      tester,
    ) async {      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: CustomerVehicleRecord(
              vehicle: _v1,
              onBookService: () {},
              onEdit: () {},
              onRemove: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Toyota Camry · 2021'), findsOneWidget);
      expect(find.text('ABC 1234'), findsOneWidget);
      // Year lives ONCE in the title; specs line is colour + mileage only.
      expect(find.text('White · 45000 km'), findsOneWidget);
      expect(find.text('2021 · White · 45000 km'), findsNothing);
      expect(find.textContaining('VIN'), findsOneWidget);
      expect(find.byType(AppStatusChip), findsNothing);
      expect(find.text('Book service'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });

    testWidgets('dark theme pumps clean with both records', (tester) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1, _v2]),
        bookings: const [_upcoming, _completed],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(find.text('My vehicles'), findsOneWidget);
      expect(find.text('Book service'), findsNWidgets(2));
      expect(find.byType(AppStatusChip), findsNWidgets(2));
    });

    testWidgets('1.3x text scale pumps clean with actions wrapping', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_v1, _v2]),
        bookings: const [_upcoming, _completed],
        scale: 1.3,
      );
      expect(find.text('My vehicles'), findsOneWidget);
      expect(find.text('Book service'), findsNWidgets(2));
      expect(find.byIcon(Icons.more_vert_rounded), findsNWidgets(2));
    });
  });
}
