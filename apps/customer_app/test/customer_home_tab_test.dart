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

    expect(find.text('2 unpaid invoices'), findsWidgets);
    expect(
      find.text('Review and settle your outstanding invoices.'),
      findsOneWidget,
    );
    expect(find.byType(AppMediaCard), findsOneWidget);
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

    // Garage keeps silhouette art + booking context behind "Show all".
    expect(find.text('Your vehicle'), findsOneWidget);
    expect(find.text('Show all'), findsOneWidget);
    expect(find.byType(VehicleSilhouetteArt), findsOneWidget);
    // One row of tiles with accessible labels; the idle hero carries its
    // own explicit CTA with the same verb-first copy (structural: 2 texts).
    expect(find.text('Book service'), findsNWidgets(2));
    expect(find.text('Breakdown help'), findsOneWidget);
    expect(find.text('Invoices'), findsWidgets);
    expect(find.text('History'), findsOneWidget);
    // Recent activity is an inset group, max three rows.
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.byType(AppListGroup), findsOneWidget);
  });

  testWidgets('new customer gets one empty state with one action', (
    tester,
  ) async {
    await _pumpHome(tester, state: _state(withProfile: false));

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.textContaining('Your garage is empty'), findsOneWidget);
    expect(find.text('Add your vehicle'), findsOneWidget);
    expect(find.byType(AppCarousel), findsNothing);
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
