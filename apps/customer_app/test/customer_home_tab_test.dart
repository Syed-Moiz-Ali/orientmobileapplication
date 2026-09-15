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
import 'package:customer_app/features/customer/presentation/widgets/customer_home_quick_actions.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_service_summary.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';

void main() {
  setUpAll(_loadFonts);

  group('CustomerHomeTab states', () {
    testWidgets('shows a composition-matched skeleton on first load', (
      tester,
    ) async {
      await _pumpHome(tester, state: _state(isLoading: true), settle: false);
      await tester.pump();

      expect(find.byType(CustomerHomeSkeleton), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('offers a retry when nothing could be loaded', (tester) async {
      final notifier = await _pumpHome(
        tester,
        state: _state(loadError: 'unavailable'),
      );

      expect(find.text("We couldn't load your information"), findsOneWidget);
      expect(find.textContaining('Check your connection'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(notifier.refreshCount, 1);
    });

    testWidgets('keeps the screen when a refresh fails after data loaded', (
      tester,
    ) async {
      final notifier = await _pumpHome(
        tester,
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser],
          loadError: 'unavailable',
        ),
      );

      expect(find.text('No active service'), findsOneWidget);
      expect(
        find.text("We couldn't refresh your information."),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(notifier.refreshCount, 1);
    });

    testWidgets('welcomes a new customer and prioritises adding a vehicle', (
      tester,
    ) async {
      await _pumpHome(tester, state: _state(profile: _profile));

      expect(find.text('Welcome to Orient'), findsOneWidget);
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Your garage is empty'), findsOneWidget);
      expect(find.text('Add your vehicle'), findsOneWidget);
      expect(find.text('Book service'), findsOneWidget);
      // No garage section and no duplicate garage shortcut yet.
      expect(find.text('Your vehicle'), findsNothing);
      expect(find.text('My vehicles'), findsNothing);
      expect(find.text('Recent activity'), findsNothing);
      expect(find.text('Needs your attention'), findsNothing);
    });

    testWidgets('leads with the live service tracker for an active job', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser],
          activeService: _activeService,
        ),
      );

      expect(find.text('IN SERVICE'), findsOneWidget);
      expect(find.text('Full Service'), findsOneWidget);
      expect(find.text('Toyota Land Cruiser \u00b7 A 12345'), findsOneWidget);
      expect(find.text('Current stage \u00b7 Quality Check'), findsOneWidget);
      expect(find.text('45%'), findsOneWidget);
      expect(
        find.text('Estimated completion \u00b7 2026-09-16 17:00'),
        findsOneWidget,
      );
      expect(find.text('Track service'), findsOneWidget);
      expect(find.text('No active service'), findsNothing);
    });

    testWidgets('shows a not-yet-started booking when no job card exists', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
        bookings: const [_activeBooking],
      );

      expect(find.text('CONFIRMED'), findsOneWidget);
      expect(find.text('Brake Inspection'), findsOneWidget);
      expect(find.text('BK-2026-0188'), findsOneWidget);
      expect(find.text('2026-09-18 \u00b7 09:00'), findsOneWidget);
      expect(find.text('View booking'), findsOneWidget);
    });

    testWidgets('shows a compact idle state when nothing is in service', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser, _patrol],
        ),
      );

      expect(find.text('No active service'), findsOneWidget);
      expect(
        find.text('Your vehicles are not in the workshop right now.'),
        findsOneWidget,
      );
      // Booking is offered exactly once, by the persistent action row.
      expect(find.text('Book a service'), findsNothing);
      expect(find.text('Book service'), findsOneWidget);
      expect(find.text('Needs your attention'), findsNothing);
    });
  });

  group('CustomerHomeTab real data', () {
    testWidgets('summarises garage data and skips unassessed health', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser, _patrol],
        ),
      );

      expect(find.text('Your garage'), findsOneWidget);
      expect(find.text('Nissan Patrol'), findsOneWidget);
      expect(find.text('2021 \u00b7 48,200 km \u00b7 White'), findsOneWidget);
      // Only the assessed vehicle carries a health pill.
      expect(find.text('Health 82%'), findsOneWidget);
      expect(find.textContaining('Health'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
    });

    testWidgets('surfaces approvals and unpaid invoices only when real', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser],
          unpaidInvoices: 2,
        ),
        approvals: const [_approval],
      );

      expect(find.text('Needs your attention'), findsOneWidget);
      expect(
        find.text('Estimate AED 1,250 awaiting your approval'),
        findsOneWidget,
      );
      expect(find.text('2 unpaid invoices'), findsOneWidget);
    });

    testWidgets('lists recent finished work without repeating the live job', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
        bookings: const [_activeBooking, _completedBooking],
      );

      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Oil & Filter Change'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      // The confirmed booking owns the summary panel, so it is not duplicated.
      expect(find.text('Brake Inspection'), findsOneWidget);
    });

    testWidgets('exposes unread notification state and opens the inbox', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(
          profile: _profile,
          notifications: const [_unreadNotification, _readNotification],
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Notifications, 1 unread',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
    });
  });

  group('CustomerHomeTab navigation', () {
    testWidgets('opens book service from the primary action', (tester) async {
      await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
      );

      await tester.tap(find.text('Book service'));
      await tester.pumpAndSettle();
      expect(find.text('BOOK_SERVICE'), findsOneWidget);
    });

    testWidgets('opens breakdown help from the quick actions', (tester) async {
      await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
      );

      await tester.tap(find.text('Breakdown help'));
      await tester.pumpAndSettle();
      expect(find.text('BREAKDOWN_HELP'), findsOneWidget);
    });

    testWidgets('routes garage management to the vehicles tab', (tester) async {
      final notifier = await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
      );

      await tester.tap(find.text('Manage'));
      await tester.pump();
      expect(notifier.selectedTabs, [4]);
    });

    testWidgets('opens the active booking detail from the summary', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
        bookings: const [_activeBooking],
      );

      await tester.tap(find.text('View booking'));
      await tester.pumpAndSettle();
      expect(find.text('BOOKING_DETAIL'), findsOneWidget);
    });

    testWidgets('routes approvals attention rows to the approvals tab', (
      tester,
    ) async {
      final notifier = await _pumpHome(
        tester,
        state: _state(profile: _profile, unpaidInvoices: 1),
      );

      await tester.tap(find.text('1 unpaid invoice'));
      await tester.pump();
      expect(notifier.selectedTabs, [3]);
    });
  });

  group('CustomerHomeTab layout', () {
    testWidgets('stays overflow-free on the smallest supported phone', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        size: const Size(320, 640),
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser, _patrol],
          unpaidInvoices: 1,
        ),
        approvals: const [_approval],
        bookings: const [_activeBooking, _completedBooking],
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives an increased text scale', (tester) async {
      await _pumpHome(
        tester,
        textScaler: const TextScaler.linear(1.6),
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser, _patrol],
          activeService: _activeService,
        ),
        bookings: const [_completedBooking],
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a structured two-column composition on wide layouts', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        size: const Size(1440, 900),
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
      );

      final summary = tester.getTopLeft(
        find.byType(CustomerHomeServiceSummary),
      );
      final actions = tester.getTopLeft(find.byType(CustomerHomeQuickActions));

      expect(actions.dx, greaterThan(summary.dx));
      expect((actions.dy - summary.dy).abs(), lessThan(1));
    });

    testWidgets('renders in dark theme without exceptions', (tester) async {
      await _pumpHome(
        tester,
        theme: AppTheme.dark(BrandConfig.orient),
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser],
          activeService: _activeService,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('IN SERVICE'), findsOneWidget);
    });

    testWidgets('pull to refresh triggers a real dashboard refresh', (
      tester,
    ) async {
      final notifier = await _pumpHome(
        tester,
        state: _state(profile: _profile, vehicles: const [_landCruiser]),
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

  group('CustomerHomeTab visual references', () {
    testWidgets('active service mobile', (tester) async {
      await _expectHomeGolden(
        tester,
        fileName: 'goldens/customer_home_active_mobile.png',
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser],
          activeService: _activeService,
          unpaidInvoices: 1,
        ),
        approvals: const [_approval],
      );
    });

    testWidgets('idle garage mobile', (tester) async {
      await _expectHomeGolden(
        tester,
        fileName: 'goldens/customer_home_idle_mobile.png',
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser, _patrol],
        ),
        bookings: const [_completedBooking],
      );
    });

    testWidgets('new customer mobile', (tester) async {
      await _expectHomeGolden(
        tester,
        fileName: 'goldens/customer_home_new_mobile.png',
        state: _state(profile: _profile),
      );
    });

    testWidgets('tablet composition', (tester) async {
      await _expectHomeGolden(
        tester,
        size: const Size(1024, 900),
        fileName: 'goldens/customer_home_tablet.png',
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser, _patrol],
          activeService: _activeService,
        ),
      );
    });

    testWidgets('dark mode mobile', (tester) async {
      await _expectHomeGolden(
        tester,
        theme: AppTheme.dark(BrandConfig.orient),
        fileName: 'goldens/customer_home_dark_mobile.png',
        state: _state(
          profile: _profile,
          vehicles: const [_landCruiser],
          activeService: _activeService,
        ),
      );
    });
  });
}

// ─── Fixtures (real entity shapes, no fabricated business claims) ────────────

const _profile = CustomerEntity(
  name: 'Ahmed Al Mansoori',
  firstName: 'Ahmed',
  avatarInitials: 'AM',
  memberId: 'CUS-1042',
);

const _landCruiser = CustomerVehicleEntity(
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

const _patrol = CustomerVehicleEntity(
  id: 'v2',
  brand: 'Nissan',
  model: 'Patrol',
  plateNumber: 'B 98765',
  vin: '',
  color: '',
  year: 0,
  mileage: '',
  lastService: '',
  nextDue: '',
  healthScore: -1,
);

const _activeService = CustomerServiceEntity(
  hasActiveJob: true,
  jobCardId: 'JC-2026-1042',
  plateNumber: 'A 12345',
  vehicleName: 'Toyota Land Cruiser',
  service: 'Full Service',
  started: '2026-09-14',
  estCompletion: '2026-09-16 17:00',
  progressPercent: 45,
  currentStage: 'Quality Check',
  technicianName: 'Ravi',
  stages: [],
);

const _activeBooking = CustomerBookingEntity(
  id: 'b1',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2026-09-18',
  time: '09:00',
  status: BookingStatus.confirmed,
  jobCardRef: 'BK-2026-0188',
);

const _completedBooking = CustomerBookingEntity(
  id: 'b2',
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

const _unreadNotification = CustomerNotificationEntity(
  id: 'n1',
  title: 'Your vehicle is ready',
  body: 'Please collect your Land Cruiser from Bay 3.',
  time: '2h ago',
  type: NotifType.carReady,
);

const _readNotification = CustomerNotificationEntity(
  id: 'n2',
  title: 'Booking confirmed',
  body: 'Your brake inspection is confirmed.',
  time: 'Yesterday',
  type: NotifType.bookingConfirmed,
  isRead: true,
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

Future<_FakeDashboardNotifier> _pumpHome(
  WidgetTester tester, {
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<CustomerApprovalSummaryResponse> approvals = const [],
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
        builder: (_, __) => const Scaffold(body: CustomerHomeTab()),
      ),
      GoRoute(
        path: AppRoutes.customerBookService,
        builder: (_, __) => const Scaffold(body: Text('BOOK_SERVICE')),
      ),
      GoRoute(
        path: AppRoutes.customerBreakdownHelp,
        builder: (_, __) => const Scaffold(body: Text('BREAKDOWN_HELP')),
      ),
      GoRoute(
        path: AppRoutes.customerNotifications,
        builder: (_, __) => const Scaffold(body: Text('NOTIFICATIONS')),
      ),
      GoRoute(
        path: AppRoutes.customerAddVehicle,
        builder: (_, __) => const Scaffold(body: Text('ADD_VEHICLE')),
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
        customerDashboardProvider.overrideWith(() => notifier),
        customerBookingsProvider.overrideWith((ref) async => bookings),
        customerApprovalsProvider.overrideWith((ref) async => approvals),
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

Future<void> _expectHomeGolden(
  WidgetTester tester, {
  required String fileName,
  required CustomerDashboardState state,
  List<CustomerBookingEntity> bookings = const [],
  List<CustomerApprovalSummaryResponse> approvals = const [],
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  await _pumpHome(
    tester,
    state: state,
    bookings: bookings,
    approvals: approvals,
    size: size,
    theme: theme,
  );
  await expectLater(find.byType(CustomerHomeTab), matchesGoldenFile(fileName));
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
