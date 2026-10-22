// Structural tests for the recomposed customer bookings list.
//
// Presentation-tree assertions only: header/find-aids threshold, per-card
// Review/Track reachability (tap budgets AFTER ≤ BEFORE), honest status pills,
// search/filter sheets, failed-row inline Retry + remove bottom sheet,
// loading/empty/error states, pull-to-refresh. Behavior (providers,
// navigation targets, booking logic) is asserted nowhere.
import 'dart:async';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_item.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

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

const _inService = CustomerBookingEntity(
  id: 'b2',
  service: 'Brake pads',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '10 Jun 2026',
  time: '09:00',
  status: BookingStatus.inProgress,
  jobCardId: 'JC-7',
  bookingRef: 'BK-1002',
);

const _history = CustomerBookingEntity(
  id: 'b3',
  service: 'Wheel alignment',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  date: '02 May 2026',
  time: '09:00',
  status: BookingStatus.completed,
  bookingRef: 'BK-0987',
);

const _approval = CustomerBookingEntity(
  id: 'b4',
  service: 'Engine overhaul',
  vehicleName: 'Honda Civic',
  plateNumber: 'XYZ 5678',
  date: '15 Jun 2026',
  time: '11:00',
  status: BookingStatus.approvalRequired,
  estimateId: 'EST-1',
  estimateAmount: 1200,
  bookingRef: 'BK-1009',
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-7',
  plateNumber: 'XYZ 5678',
  vehicleName: 'Honda Civic',
  service: 'Brake pads',
  started: '',
  estCompletion: '',
  progressPercent: 40,
  // Test-data only: differs from the booking status so pill + stage prove
  // both signals independently (F3). Production predicate unchanged.
  currentStage: 'Quality check',
  technicianName: '',
  stages: [],
);

const _failed = FailedBooking(
  operationId: 'op-1',
  vehicleName: 'Toyota Camry',
  plateNumber: 'ABC 1234',
  service: 'Oil change',
  date: '12 Jun 2026',
  time: '10:00',
  notes: '',
);

class _FixedDashNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedDashNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

class _NoFailedSync implements FailedBookingSync {
  @override
  List<FailedBooking> failedBookings() => const [];
  @override
  Future<bool> retry(String operationId) async => false;
  @override
  Future<void> remove(String operationId) async {}
}

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerVehicleEntity> vehicles = const [],
  CustomerServiceEntity? activeService,
}) => CustomerDashboardState(
  selectedIndex: 1,
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

const _vehicle = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Camry',
  plateNumber: 'ABC 1234',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '45000 km',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

List<CustomerBookingEntity> _six() => [
  for (var i = 0; i < 6; i++)
    CustomerBookingEntity(
      id: 'b$i',
      service: i == 0 ? 'Oil change' : 'Service $i',
      vehicleName: 'Toyota Camry',
      plateNumber: 'ABC 100$i',
      date: '12 Jun 2026',
      time: '10:00',
      status: BookingStatus.confirmed,
      bookingRef: 'BK-100$i',
    ),
];

Future<void> _pumpList(
  WidgetTester tester, {
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<FailedBooking> failed = const [],
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
        customerFailedBookingsProvider.overrideWith((ref) => failed),
        failedBookingSyncProvider.overrideWith((ref) => _NoFailedSync()),
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
        home: const Scaffold(body: CustomerBookingsTab()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  group('bookings list (after)', () {
    testWidgets('<=5: header + subtitle + Book, no find-aids', (tester) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_upcoming, _history],
      );

      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('1 upcoming · 1 past service'), findsOneWidget);
      // Book stays a header action when non-empty (1 tap from list).
      expect(find.text('Book service'), findsOneWidget);
      // Progressive disclosure: no search/filter icons with ≤ 5 items.
      expect(find.byTooltip('Search bookings'), findsNothing);
      expect(find.byTooltip('Filter bookings'), findsNothing);
      expect(find.byType(CustomerBookingItem), findsNWidgets(2));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('active + history sections split with counts', (tester) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [_upcoming, _inService, _history],
      );

      expect(find.text('Upcoming & in service'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.byType(CustomerBookingItem), findsNWidgets(3));
    });

    testWidgets('row: title + sentence-case pill + plate + reference', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [_upcoming],
      );

      expect(find.text('Oil change'), findsOneWidget);
      expect(find.byType(AppStatusChip), findsOneWidget);
      // Sentence case via theme: no ALL-CAPS labels anywhere.
      expect(find.text('CONFIRMED'), findsNothing);
      expect(find.text('Toyota Camry'), findsOneWidget);
      expect(find.text('BK-1001'), findsOneWidget);
    });

    testWidgets('approval row carries direct Review action', (tester) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [_approval],
      );

      expect(find.text('Review'), findsOneWidget);
      expect(find.textContaining('awaiting approval'), findsOneWidget);
    });

    testWidgets('trackable row carries direct Track service action', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(activeService: _liveService),
        bookings: const [_inService],
      );

      expect(find.text('Track service'), findsOneWidget);
      expect(find.textContaining('Current stage'), findsOneWidget);
    });

    testWidgets('failed rows: sentence-case pill + inline Retry/Remove', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [],
        failed: const [_failed],
      );

      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.byType(AppStatusChip), findsOneWidget);
      expect(find.text('Not sent'), findsOneWidget);
      expect(find.text('NOT SENT'), findsNothing);
      expect(
        find.text("We couldn't send this booking to the workshop."),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('remove opens a confirmation bottom sheet, cancel keeps row', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [],
        failed: const [_failed],
      );

      await tester.tap(find.text('Remove'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Remove saved booking?'), findsOneWidget);
      expect(find.text('Remove booking'), findsOneWidget);
      expect(find.text('Keep booking'), findsOneWidget);
      await tester.tap(find.text('Keep booking'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Remove saved booking?'), findsNothing);
      expect(find.text('Not sent'), findsOneWidget);
    });

    testWidgets('>5: search + filter icons appear together', (tester) async {
      await _pumpList(tester, state: _state(), bookings: _six());
      expect(find.byTooltip('Search bookings'), findsOneWidget);
      expect(find.byTooltip('Filter bookings'), findsOneWidget);
      expect(find.byType(CustomerBookingItem), findsNWidgets(6));
    });

    testWidgets('search sheet filters loaded records, no-match + Clear', (
      tester,
    ) async {
      await _pumpList(tester, state: _state(), bookings: _six());
      await tester.tap(find.byTooltip('Search bookings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(
        find.text('Search by service, vehicle, or plate'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'Oil change');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final sheetList = find.byType(ListView);
      expect(
        find.descendant(of: sheetList, matching: find.text('Oil change')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheetList, matching: find.text('Service 1')),
        findsNothing,
      );
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('No bookings match your search.'),
        findsOneWidget,
      );
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('<=5: no filter chrome (threshold contract)', (tester) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [_upcoming, _history],
      );

      // Only 2 bookings: no find-aids (≤ 5). Drive the filter through the
      // sheet state directly is impossible without the icon, so this asserts
      // the threshold contract instead: cards only, no filter chrome.
      expect(find.byTooltip('Filter bookings'), findsNothing);
      expect(find.byType(CustomerBookingItem), findsNWidgets(2));
    });

    testWidgets('filter on 6+ list filters + no-match + Clear', (
      tester,
    ) async {
      final mixed = [
        ..._six().sublist(0, 5),
        const CustomerBookingEntity(
          id: 'bh',
          service: 'Wheel alignment',
          vehicleName: 'Toyota Camry',
          plateNumber: 'ABC 1009',
          date: '02 May 2026',
          time: '09:00',
          status: BookingStatus.completed,
          bookingRef: 'BK-0987',
        ),
      ];
      await _pumpList(tester, state: _state(), bookings: mixed);

      Future<void> applyFilter(String option) async {
        await tester.tap(find.byTooltip('Filter bookings'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        // The sheet opens over the list, so option text (e.g. "History")
        // also matches the section header behind the scrim: tap the chip
        // that owns the label.
        final chip = find.widgetWithText(AppChip, option);
        await tester.tap(chip);
        await tester.pump();
        await tester.tap(find.text('Show results'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(find.text('Filter bookings'), findsNothing);
      // Sheet options present.
      await tester.tap(find.byTooltip('Filter bookings'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Upcoming'), findsWidgets);
      expect(find.text('In service'), findsOneWidget);
      expect(find.text('History'), findsWidgets);
      expect(find.text('Show results'), findsOneWidget);
      await tester.tap(find.text('Show results'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // History: only the completed booking stays.
      await applyFilter('History');
      expect(find.text('Wheel alignment'), findsOneWidget);
      expect(find.text('Oil change'), findsNothing);

      // In service: nothing matches → no-match state + Clear.
      await applyFilter('In service');
      expect(
        find.text('No bookings match this filter.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Clear'));
      await tester.pump();
      expect(find.byType(CustomerBookingItem), findsNWidgets(6));
    });

    testWidgets('empty with vehicles: one icon + one sentence + one Book', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(vehicles: const [_vehicle]),
      );

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.textContaining('No bookings yet'), findsOneWidget);
      expect(find.text('Book service'), findsOneWidget);
      expect(find.byType(CustomerBookingItem), findsNothing);
    });

    testWidgets('loading: mirroring skeleton, no rows', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerDashboardProvider.overrideWith(
              () => _FixedDashNotifier(_state(isLoading: true)),
            ),
            customerBookingsProvider.overrideWith(
              (ref) => Completer<List<CustomerBookingEntity>>().future,
            ),
            customerFailedBookingsProvider.overrideWith((ref) => const []),
            failedBookingSyncProvider.overrideWith((ref) => _NoFailedSync()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(BrandConfig.orient),
            home: const Scaffold(body: CustomerBookingsTab()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.byType(AppShimmerSkeleton), findsWidgets);
      expect(find.byType(CustomerBookingItem), findsNothing);
    });

    testWidgets('first-load error: title + retry', (tester) async {
      await _pumpList(
        tester,
        state: _state(loadError: 'No connection'),
      );

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(
        find.textContaining("We couldn't load your bookings"),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('dark theme pumps clean with rows', (tester) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [_upcoming, _history],
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(find.text('Bookings'), findsOneWidget);
      expect(find.byType(CustomerBookingItem), findsNWidgets(2));
      expect(find.byType(AppStatusChip), findsNWidgets(2));
    });

    testWidgets('1.3x text scale pumps clean', (tester) async {
      await _pumpList(
        tester,
        state: _state(),
        bookings: const [_upcoming, _history],
        scale: 1.3,
      );

      expect(find.text('Bookings'), findsOneWidget);
      expect(find.byType(CustomerBookingItem), findsNWidgets(2));
    });
  });
}
