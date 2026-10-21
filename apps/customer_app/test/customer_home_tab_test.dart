// Structural tests for the recomposed Customer Home (phase 6).
//
// Presentation-tree assertions only: hero priority, carousel, quick actions,
// recent-activity group and the loading/error/empty states. Behavior
// (providers, navigation targets, booking logic) is asserted nowhere here.

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

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

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-1',
  plateNumber: 'ABC 1234',
  vehicleName: 'Toyota Camry',
  service: 'Full service',
  started: '',
  estCompletion: 'Today, 5 PM',
  progressPercent: 60,
  currentStage: 'On the lift',
  technicianName: '',
  stages: [],
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

class _FixedHomeNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedHomeNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

const _vehicle2 = CustomerVehicleEntity(
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

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerVehicleEntity> vehicles = const [],
  CustomerServiceEntity? activeService,
  int unpaidInvoices = 0,
  bool withProfile = true,
}) => CustomerDashboardState(
  selectedIndex: 0,
  isLoading: isLoading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  vehicles: vehicles,
  notifications: const [],
  activeService: activeService,
  profile: withProfile
      ? const CustomerEntity(
          name: 'Ahmed Ali',
          firstName: 'Ahmed',
          avatarInitials: 'AA',
          memberId: 'M1',
        )
      : null,
  unpaidInvoices: unpaidInvoices,
  loadError: loadError,
);

Future<void> _pumpHome(
  WidgetTester tester, {
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<CustomerApprovalSummaryResponse> approvals = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(
          () => _FixedHomeNotifier(state),
        ),
        customerBookingsProvider.overrideWith((ref) async => bookings),
        customerApprovalsProvider.overrideWith((ref) async => approvals),
      ],
      child: MaterialApp(
        theme: AppTheme.light(BrandConfig.orient),
        home: const Scaffold(body: CustomerHomeTab()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('approval hero wins over payment due, with +N more row', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle], unpaidInvoices: 1),
      bookings: const [_upcoming, _completed],
      approvals: const [
        CustomerApprovalSummaryResponse(estimateId: 'E1', amount: 450),
      ],
    );

    // Approval first (attention-panel order), one sentence, single CTA card.
    expect(find.textContaining('450'), findsWidgets);
    expect(find.text('Approval needed before work continues'), findsOneWidget);
    expect(find.byType(AppMediaCard), findsOneWidget);
    // Two attention items -> overflow row into the approvals screen.
    expect(find.text('1 more item needs review'), findsOneWidget);
    // Payment-due hero is suppressed while an approval waits.
    expect(find.text('1 unpaid invoice'), findsNothing);
  });

  testWidgets('payment-due hero when no approval waits', (tester) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle], unpaidInvoices: 2),
      bookings: const [_completed],
    );

    // Title keeps the count exactly once; the chip no longer echoes it.
    expect(find.text('2 unpaid invoices'), findsOneWidget);
    expect(find.text('Unpaid'), findsOneWidget);
    expect(
      find.text('Review and settle your outstanding invoices.'),
      findsOneWidget,
    );
    expect(find.byType(AppMediaCard), findsOneWidget);
    expect(find.text('Review invoices'), findsOneWidget);
  });

  testWidgets('payment hero suppresses the duplicate invoices tile', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle], unpaidInvoices: 2),
      bookings: const [_completed],
    );

    // U7: one path to invoices — the hero CTA owns it while showing.
    expect(find.text('Review invoices'), findsOneWidget);
    expect(find.text('Invoices'), findsNothing);
    expect(find.text('Book service'), findsOneWidget);
    expect(find.text('Breakdown help'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('service hero with tracking CTA when no attention', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      state: _state(
        vehicles: const [_vehicle],
        activeService: _liveService,
      ),
      bookings: const [_upcoming, _completed],
    );

    expect(find.text('Full service'), findsOneWidget);
    expect(find.byType(AppCarousel), findsOneWidget);
    // Explicit verb-first CTA under the hero card (card tap retained).
    expect(find.text('Track service'), findsOneWidget);
  });

  testWidgets('garage carousel, quick actions and recent activity', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle]),
      bookings: const [_completed],
    );

    // U6/U7: nothing is due, so the hero is a calm status row — no media
    // card, no duplicate Book-service CTA (the tile keeps the one path).
    expect(find.byType(AppMediaCard), findsNothing);
    expect(
      find.text('Your vehicle is not in the workshop right now.'),
      findsOneWidget,
    );
    expect(find.text('Book service'), findsOneWidget);
    // U7: one vehicle is fully shown — no "Show all".
    expect(find.text('Your vehicle'), findsOneWidget);
    expect(find.text('Show all'), findsNothing);
    expect(find.byType(VehicleSilhouetteArt), findsOneWidget);
    // Search icon sits top-right of the greeting header (U1/U9).
    expect(find.byTooltip('Search'), findsOneWidget);
    // One row of tiles with accessible labels.
    expect(find.text('Breakdown help'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    // Recent activity is an inset group, max three rows.
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.byType(AppListGroup), findsOneWidget);
  });

  testWidgets('two vehicles keep Show all and grouped mileage', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle, _vehicle2]),
      bookings: const [_completed],
    );

    expect(find.text('Your garage'), findsOneWidget);
    expect(find.text('Show all'), findsOneWidget);
    // C11: thousands grouping on the garage spec lines.
    expect(find.textContaining('45,000 km'), findsOneWidget);
    expect(find.textContaining('78,200 km'), findsOneWidget);
  });

  testWidgets('new customer gets a calm status row with a text action', (
    tester,
  ) async {
    await _pumpHome(tester, state: _state(withProfile: false));

    // U6: no full hero card for the new-customer state either — the compact
    // status row carries the full sentence (never cut mid-sentence) and
    // "Add your vehicle" stays a one-tap text action (booking needs one).
    expect(find.byType(AppEmptyState), findsNothing);
    expect(find.byType(AppMediaCard), findsNothing);
    expect(
      find.text(
        'Add your vehicle to book service, follow repair progress, and keep every update in one place.',
      ),
      findsOneWidget,
    );
    expect(find.text('Add your vehicle'), findsOneWidget);
    expect(find.byType(AppCarousel), findsNothing);
  });

  testWidgets('header search opens a sheet over existing data', (tester) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle, _vehicle2]),
      bookings: const [_completed],
    );

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    // Empty query: hint only — the app keeps no recents to show.
    expect(
      find.text('Search vehicles and bookings'),
      findsOneWidget,
    );
    expect(
      find.text('Type to search your vehicles and bookings.'),
      findsOneWidget,
    );

    // Filtering reads the lists the home already holds — no new logic.
    // (The home cards stay in the tree behind the sheet overlay.)
    await tester.enterText(find.byType(TextField), 'camry');
    await tester.pump();
    expect(find.text('Toyota Camry'), findsNWidgets(2));
    expect(find.text('Honda Civic'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz-no-match');
    await tester.pump();
    expect(
      find.text('No matches. Try a different search.'),
      findsOneWidget,
    );
  });

  testWidgets('loading skeleton mirrors the final layout', (tester) async {
    await _pumpHome(
      tester,
      state: _state(isLoading: true, withProfile: false),
    );

    expect(find.byType(AppShimmerSkeleton), findsWidgets);
    expect(find.byType(AppMediaCard), findsNothing);
  });

  testWidgets('error state with retry when nothing loaded', (tester) async {
    await _pumpHome(
      tester,
      state: _state(loadError: 'No connection', withProfile: false),
    );

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(
      find.textContaining("We couldn't load your information"),
      findsOneWidget,
    );
  });

  testWidgets('stale data keeps rendering under a warning banner', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      state: _state(vehicles: const [_vehicle], loadError: 'No connection'),
      bookings: const [_completed],
    );

    expect(find.byType(AppBanner), findsOneWidget);
    expect(find.text('Your vehicle'), findsOneWidget);
  });
}
