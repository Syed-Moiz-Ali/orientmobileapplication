import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_journey.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_skeleton.dart';

void main() {
  setUpAll(_loadFonts);

  group('CustomerServiceStatusTab â€” active workshop job', () {
    testWidgets('leads with what is happening to the vehicle', (tester) async {
      await _pumpStatus(tester, state: _state(activeService: _liveService));

      expect(find.text('Service status'), findsOneWidget);
      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(find.text('Full Service'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser \u00b7 A 12345'), findsOneWidget);
      // Current stage stays human readable even when the backend sends a code.
      expect(find.text('Current stage'), findsOneWidget);
      expect(find.text('Quality Check'), findsWidgets);
      expect(find.text('quality_check'), findsNothing);
      // No fabricated "live telemetry" theatre.
      expect(find.textContaining('LIVE'), findsNothing);
      expect(find.textContaining('Live'), findsNothing);
    });

    testWidgets('shows real progress with accessible semantics', (
      tester,
    ) async {
      await _pumpStatus(tester, state: _state(activeService: _liveService));

      expect(find.text('45%'), findsOneWidget);
      expect(
        find.text('Estimated completion \u00b7 2026-09-16 17:00'),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Service progress, 45 percent',
        ),
        findsOneWidget,
      );
    });

    testWidgets('never invents progress when the backend has none', (
      tester,
    ) async {
      await _pumpStatus(tester, state: _state(activeService: _quietService));

      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('Estimated completion'), findsNothing);
      expect(find.byType(CustomerServiceJourney), findsNothing);
    });

    testWidgets('renders only the real backend stage list as a journey', (
      tester,
    ) async {
      await _pumpStatus(tester, state: _state(activeService: _liveService));

      expect(find.byType(CustomerServiceJourney), findsOneWidget);
      expect(find.text('Service journey'), findsOneWidget);
      expect(find.text('Check-In'), findsOneWidget);
      expect(find.text('Inspection'), findsOneWidget);
      expect(find.text('Repair'), findsOneWidget);
      // Completed stages carry a real timestamp, not a fabricated one.
      expect(find.text('09:10'), findsOneWidget);
      expect(find.text('Done'), findsNWidgets(2));
      expect(find.text('Current'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Check-In, Done, 09:10',
        ),
        findsOneWidget,
      );
    });

    testWidgets('groups real job details without badge noise', (tester) async {
      await _pumpStatus(tester, state: _state(activeService: _liveService));

      expect(find.text('Service details'), findsOneWidget);
      expect(find.text('Job reference'), findsOneWidget);
      expect(find.text('JC-2026-1042'), findsOneWidget);
      expect(find.text('Started'), findsOneWidget);
      expect(find.text('Technician'), findsOneWidget);
      expect(find.text('Ravi'), findsOneWidget);
    });

    testWidgets('treats an unidentified active-job payload as idle', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(
          activeService: _malformedService,
          vehicles: const [_vehicle],
        ),
      );

      expect(find.text('IN SERVICE'), findsNothing);
      expect(find.text('Nothing to track right now'), findsOneWidget);
    });
  });

  group('CustomerServiceStatusTab â€” upcoming booking', () {
    testWidgets('makes clear the service is booked, not in progress', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_booking],
      );

      expect(find.text('Your appointment is booked.'), findsOneWidget);
      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Brake Inspection'), findsOneWidget);
      expect(find.text('2026-09-18 \u00b7 09:00'), findsOneWidget);
      expect(find.text('View booking'), findsOneWidget);
      // No workshop job, so no progress and no stage journey.
      expect(find.textContaining('%'), findsNothing);
      expect(find.byType(CustomerServiceJourney), findsNothing);
      expect(find.text('Booking reference'), findsOneWidget);
    });

    testWidgets('lists further live bookings instead of hiding them', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_booking, _secondBooking],
      );

      expect(find.text('1 more upcoming booking'), findsOneWidget);
    });
  });

  group('CustomerServiceStatusTab â€” action required', () {
    testWidgets('surfaces a pending estimate and routes into it', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(activeService: _liveService),
        approvals: const [_approval],
      );

      expect(find.text('Action required'), findsOneWidget);
      expect(
        find.text('Estimate AED 1,250 awaiting your approval'),
        findsOneWidget,
      );

      await tester.tap(find.text('Estimate AED 1,250 awaiting your approval'));
      await tester.pumpAndSettle();

      expect(find.text('APPROVALS estimateId=EST-9001'), findsOneWidget);
    });

    testWidgets('sends multiple estimates to the approvals overview', (
      tester,
    ) async {
      final notifier = await _pumpStatus(
        tester,
        state: _state(activeService: _liveService),
        approvals: const [_approval, _secondApproval],
      );

      expect(find.text('2 estimates awaiting your approval'), findsOneWidget);
      await tester.tap(find.text('2 estimates awaiting your approval'));
      await tester.pumpAndSettle();
      expect(
        notifier.selectedTabs,
        isEmpty,
        reason: 'approvals is contextual — it is not a workspace destination',
      );
      expect(find.text('APPROVALS estimateId=none'), findsOneWidget);
    });

    testWidgets('shows payment pending without inventing a payment flow', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(activeService: _liveService),
        invoices: const [_unpaidInvoice],
      );

      expect(find.text('1 unpaid invoice'), findsOneWidget);
      expect(find.textContaining('Pay now'), findsNothing);
    });
  });

  group('CustomerServiceStatusTab â€” no tracking', () {
    testWidgets('offers booking and history when nothing is scheduled', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_completed],
      );

      expect(find.text('Nothing to track right now'), findsOneWidget);
      expect(find.text('Book service'), findsOneWidget);
      expect(find.text('View bookings'), findsOneWidget);
      expect(find.text('Needs your attention'), findsNothing);
    });

    testWidgets('prioritises adding a vehicle when the garage is empty', (
      tester,
    ) async {
      await _pumpStatus(tester, state: _state(profile: _profile));

      expect(find.text('Add your vehicle'), findsOneWidget);
      expect(find.text('Book service'), findsNothing);
    });
  });

  group('CustomerServiceStatusTab â€” loading, error and refresh', () {
    testWidgets('shows a status-shaped skeleton on first load', (tester) async {
      await _pumpStatus(tester, state: _state(isLoading: true), settle: false);
      await tester.pump();

      expect(find.byType(CustomerStatusSkeleton), findsOneWidget);
    });

    testWidgets('offers a retry when nothing could ever load', (tester) async {
      final notifier = await _pumpStatus(
        tester,
        state: _state(loadError: 'unavailable'),
      );

      expect(find.text("We couldn't load your service status"), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(notifier.refreshCount, 1);
    });

    testWidgets('keeps usable tracking data when a refresh fails', (
      tester,
    ) async {
      final notifier = await _pumpStatus(
        tester,
        state: _state(activeService: _liveService, loadError: 'unavailable'),
      );

      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(
        find.text("We couldn't refresh your information."),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(notifier.refreshCount, 1);
    });

    testWidgets('pull to refresh requests updated tracking state', (
      tester,
    ) async {
      final notifier = await _pumpStatus(
        tester,
        state: _state(activeService: _liveService),
      );

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 320),
        1200,
      );
      await tester.pumpAndSettle();

      expect(notifier.refreshCount, greaterThan(0));
    });
  });

  group('CustomerServiceStatusTab â€” navigation and layout', () {
    testWidgets('opens the real booking behind the live job card', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        state: _state(activeService: _liveService),
        bookings: const [_linkedBooking],
      );

      await tester.tap(find.text('View booking'));
      await tester.pumpAndSettle();
      expect(find.text('BOOKING_DETAIL'), findsOneWidget);
    });

    testWidgets('opens booking service from the idle state', (tester) async {
      await _pumpStatus(tester, state: _state(vehicles: const [_vehicle]));

      await tester.tap(find.text('Book service'));
      await tester.pumpAndSettle();
      expect(find.text('BOOK_SERVICE'), findsOneWidget);
    });

    testWidgets('stays overflow-free on the smallest supported phone', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        size: const Size(320, 640),
        state: _state(activeService: _liveService, unpaidInvoices: 1),
        approvals: const [_approval],
        invoices: const [_unpaidInvoice],
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('handles long service names and references without overflow', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        size: const Size(320, 640),
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_verboseBooking],
      );

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Comprehensive'), findsWidgets);
    });

    testWidgets('survives an increased text scale', (tester) async {
      await _pumpStatus(
        tester,
        textScaler: const TextScaler.linear(1.6),
        state: _state(activeService: _liveService),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a two-column composition on wide layouts', (
      tester,
    ) async {
      await _pumpStatus(
        tester,
        size: const Size(1440, 900),
        state: _state(activeService: _liveService),
      );

      final panel = tester.getTopLeft(find.text('IN SERVICE'));
      final journey = tester.getTopLeft(find.text('Service journey'));
      expect(journey.dx, greaterThan(panel.dx));
    });

    testWidgets('renders in dark theme without exceptions', (tester) async {
      await _pumpStatus(
        tester,
        theme: AppTheme.dark(BrandConfig.orient),
        state: _state(activeService: _liveService),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('IN SERVICE'), findsOneWidget);
    });
  });

  group('CustomerServiceStatusTab â€” visual references', () {
    testWidgets('active service mobile', (tester) async {
      await _expectStatusGolden(
        tester,
        fileName: 'goldens/customer_status_active_mobile.png',
        state: _state(activeService: _liveService),
        approvals: const [_approval],
        invoices: const [_unpaidInvoice],
      );
    });

    testWidgets('upcoming booking mobile', (tester) async {
      await _expectStatusGolden(
        tester,
        fileName: 'goldens/customer_status_upcoming_mobile.png',
        state: _state(vehicles: const [_vehicle]),
        bookings: const [_booking],
      );
    });

    testWidgets('idle mobile', (tester) async {
      await _expectStatusGolden(
        tester,
        fileName: 'goldens/customer_status_idle_mobile.png',
        state: _state(vehicles: const [_vehicle]),
      );
    });

    testWidgets('active service tablet', (tester) async {
      await _expectStatusGolden(
        tester,
        size: const Size(1024, 900),
        fileName: 'goldens/customer_status_tablet.png',
        state: _state(activeService: _liveService),
      );
    });

    testWidgets('active service dark mobile', (tester) async {
      await _expectStatusGolden(
        tester,
        theme: AppTheme.dark(BrandConfig.orient),
        fileName: 'goldens/customer_status_dark_mobile.png',
        state: _state(activeService: _liveService),
      );
    });
  });
}

// â”€â”€â”€ Fixtures (real entity shapes only) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const _profile = CustomerEntity(
  name: 'Ahmed Al Mansoori',
  firstName: 'Ahmed',
  avatarInitials: 'AM',
  memberId: 'CUS-1042',
);

const _vehicle = CustomerVehicleEntity(
  id: 'v1',
  brand: 'Toyota',
  model: 'Land Cruiser',
  plateNumber: 'A 12345',
  vin: '',
  color: 'White',
  year: 2021,
  mileage: '48,200 km',
  lastService: '2026-01-12',
  nextDue: '2026-07-12',
  healthScore: 82,
);

const _liveService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Land Cruiser',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  // A raw backend code so the screen must humanise it.
  currentStage: 'quality_check',
  technicianName: 'Ravi',
  stages: [
    ServiceStageEntity(
      name: 'Check-In',
      time: '09:10',
      status: StageStatus.done,
    ),
    ServiceStageEntity(
      name: 'Inspection',
      time: '09:40',
      status: StageStatus.done,
    ),
    ServiceStageEntity(name: 'Repair', status: StageStatus.inProgress),
    ServiceStageEntity(name: 'Quality Check', status: StageStatus.pending),
  ],
);

const _quietService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1055',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Land Cruiser',
  service: 'Brake Inspection',
  started: '',
  estCompletion: '',
  progressPercent: 0,
  currentStage: '',
  technicianName: '',
  stages: [],
);

const _malformedService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: '',
  plateNumber: '',
  vehicleName: '',
  service: '',
  started: '',
  estCompletion: '',
  progressPercent: 0,
  currentStage: '',
  technicianName: '',
  stages: [],
);

const _booking = CustomerBookingEntity(
  id: 'b1',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2026-09-18',
  time: '09:00',
  status: BookingStatus.confirmed,
  jobCardRef: 'BK-2026-0188',
);

const _secondBooking = CustomerBookingEntity(
  id: 'b2',
  service: 'Tyre Rotation',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2026-10-02',
  time: '14:00',
  status: BookingStatus.pending,
);

const _linkedBooking = CustomerBookingEntity(
  id: 'b3',
  service: 'Full Service',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2026-09-14',
  time: '09:00',
  status: BookingStatus.inProgress,
  jobCardId: 'JC-2026-1042',
  jobCardRef: 'JC-2026-1042',
);

const _verboseBooking = CustomerBookingEntity(
  id: 'b5',
  service:
      'Comprehensive Annual Service, Wheel Alignment and Air Conditioning '
      'System Inspection',
  vehicleName: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  date: '2026-09-20',
  time: '09:00',
  status: BookingStatus.confirmed,
  jobCardRef: 'BOOKING-REFERENCE-2026-0000-LONG-IDENTIFIER-99441',
);

const _completed = CustomerBookingEntity(
  id: 'b4',
  service: 'Oil & Filter Change',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2026-06-02',
  time: '11:00',
  status: BookingStatus.completed,
);

const _approval = CustomerApprovalSummaryResponse(
  estimateId: 'EST-9001',
  customerName: 'Ahmed Al Mansoori',
  amount: 1250,
  status: 'pending',
  createdAt: '2026-09-15',
);

const _secondApproval = CustomerApprovalSummaryResponse(
  estimateId: 'EST-9002',
  customerName: 'Ahmed Al Mansoori',
  amount: 400,
  status: 'pending',
  createdAt: '2026-09-15',
);

const _unpaidInvoice = InvoiceResponse(
  id: 'INV-7001',
  customerName: 'Ahmed Al Mansoori',
  date: '2026-09-10',
  amount: 480,
  taxAmount: 24,
  grandTotal: 504,
  status: 'unpaid',
);

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  CustomerEntity? profile,
  List<CustomerVehicleEntity> vehicles = const [],
  List<CustomerNotificationEntity> notifications = const [],
  CustomerServiceEntity? activeService,
  int unpaidInvoices = 0,
}) {
  return CustomerDashboardState(
    selectedIndex: 0,
    isLoading: isLoading,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    loadError: loadError,
    vehicles: vehicles,
    notifications: notifications,
    activeService: activeService,
    profile: profile,
    unpaidInvoices: unpaidInvoices,
  );
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;
  final List<int> selectedTabs = [];
  int refreshCount = 0;

  @override
  CustomerDashboardState build() => _initial;

  @override
  void selectTab(int index) {
    selectedTabs.add(index);
    state = state.copyWith(selectedIndex: index);
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

Future<_FakeDashboardNotifier> _pumpStatus(
  WidgetTester tester, {
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<CustomerApprovalSummaryResponse> approvals = const [],
  List<InvoiceResponse> invoices = const [],
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final notifier = _FakeDashboardNotifier(state);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: CustomerServiceStatusTab()),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (context, routeState) => Scaffold(
          body: Text(
            'DASHBOARD_${routeState.uri.queryParameters['tab']}'
            '_${routeState.uri.queryParameters['estimateId']}',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerApprovals,
        builder: (context, routeState) => Scaffold(
          body: Text(
            'APPROVALS estimateId='
            '${routeState.uri.queryParameters['estimateId'] ?? 'none'}',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerBookingDetail,
        builder: (_, __) => const Scaffold(body: Text('BOOKING_DETAIL')),
      ),
      GoRoute(
        path: AppRoutes.customerBookService,
        builder: (_, __) => const Scaffold(body: Text('BOOK_SERVICE')),
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
        customerDashboardProvider.overrideWith(() => notifier),
        customerBookingsProvider.overrideWith((ref) async => bookings),
        customerApprovalsProvider.overrideWith((ref) async => approvals),
        customerInvoicesProvider.overrideWith((ref) async => invoices),
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
  if (settle) {
    await tester.pumpAndSettle();
  }
  return notifier;
}

Future<void> _expectStatusGolden(
  WidgetTester tester, {
  required String fileName,
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<CustomerApprovalSummaryResponse> approvals = const [],
  List<InvoiceResponse> invoices = const [],
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  await _pumpStatus(
    tester,
    state: state,
    bookings: bookings,
    approvals: approvals,
    invoices: invoices,
    size: size,
    theme: theme,
  );
  await expectLater(
    find.byType(CustomerServiceStatusTab),
    matchesGoldenFile(fileName),
  );
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
