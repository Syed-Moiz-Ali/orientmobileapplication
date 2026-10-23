// Structural tests for the recomposed customer notifications list.
//
// Presentation-tree assertions only: app-bar title, summary row (count +
// Mark-all visibility predicate), group sections in stable order, actionable
// (chevron) vs read-only rows, unread/read treatment, empty / loading /
// error / stale states, pull-to-refresh. Behavior (providers, navigation
// targets, read-marker logic) is asserted nowhere. Navigation and network
// handlers are never tapped.
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

const _service = CustomerNotificationEntity(
  id: 'n1',
  title: 'Booking confirmed',
  body: 'Your Camry is booked for Saturday.',
  time: '2h ago',
  type: NotifType.bookingReceived,
);

const _approval = CustomerNotificationEntity(
  id: 'n2',
  title: 'Estimate needs approval',
  body: 'Review the brake estimate.',
  time: '3h ago',
  type: NotifType.approvalNeeded,
);

const _general = CustomerNotificationEntity(
  id: 'n3',
  title: 'Workshop update',
  body: 'Holiday hours next week.',
  time: '1d ago',
  type: NotifType.general,
  isRead: true,
);

// D3 fixtures (>5 rule): search-visible cases need a loaded inbox of 6 so the
// AppBar action appears; titles/bodies stay verbatim stored-field style.
const _service2 = CustomerNotificationEntity(
  id: 'n5',
  title: 'Technician assigned',
  body: 'Ali will handle your Camry service today.',
  time: '5h ago',
  type: NotifType.bookingAssigned,
  isRead: true,
);

const _approval2 = CustomerNotificationEntity(
  id: 'n6',
  title: 'Estimate approved',
  body: 'The brake estimate was approved. Work resumes today.',
  time: '8h ago',
  type: NotifType.estimateApproved,
  isRead: true,
);

const _invoice = CustomerNotificationEntity(
  id: 'n7',
  title: 'Invoice ready',
  body: 'Invoice INV-2041 is ready for payment.',
  time: '1d ago',
  type: NotifType.invoiceReady,
  isRead: true,
);

const _inbox6 = <CustomerNotificationEntity>[
  _service,
  _approval,
  _general,
  _service2,
  _approval2,
  _invoice,
];

class _FixedDashNotifier extends CustomerDashboardNotifier {
  final CustomerDashboardState fixed;
  _FixedDashNotifier(this.fixed);
  @override
  CustomerDashboardState build() => fixed;
}

CustomerDashboardState _state({
  bool isLoading = false,
  String loadError = '',
  List<CustomerNotificationEntity> notifications = const [],
}) => CustomerDashboardState(
  selectedIndex: 0,
  isLoading: isLoading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  vehicles: const [],
  notifications: notifications,
  profile: null,
  loadError: loadError,
);

Future<void> _pumpList(
  WidgetTester tester, {
  required CustomerDashboardState state,
  ThemeData? theme,
  double scale = 1.0,
}) async {
  // The inbox is sized for a phone viewport; pump at 360x800 (production
  // fold) so the harness does not invent overflows the production size
  // never has.
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(
          () => _FixedDashNotifier(state),
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
        home: const CustomerNotificationsView(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  group('notifications list (after)', () {
    testWidgets('title + summary count + Mark-all when unread', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(notifications: const [_service, _general]),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('1 unread'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
      // D3 (ui/fix-rulings): ONE rule (>5 loaded) everywhere — ≤5 shows NO
      // search icon (this 2-item inbox), same as vehicles/bookings family.
      // No filter by design.
      expect(find.byTooltip('Search notifications'), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsNothing);
      expect(find.byTooltip('Filter notifications'), findsNothing);
    });

    testWidgets('all read: muted line, no Mark-all', (tester) async {
      await _pumpList(
        tester,
        state: _state(notifications: const [_general]),
      );

      expect(find.text('All read'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('groups render in stable service-first order', (tester) async {
      await _pumpList(
        tester,
        state: _state(
          notifications: const [_general, _approval, _service],
        ),
      );

      expect(find.text('Service updates'), findsOneWidget);
      expect(find.text('Approvals'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Booking confirmed'), findsOneWidget);
      expect(find.text('Estimate needs approval'), findsOneWidget);
      expect(find.text('Workshop update'), findsOneWidget);
    });

    testWidgets('actionable rows carry chevron, read-only rows do not', (
      tester,
    ) async {
      await _pumpList(
        tester,
        state: _state(
          notifications: const [_service, _approval, _general],
        ),
      );

      // bookingReceived + approvalNeeded open destinations; general does not.
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
    });

    testWidgets('row shows category + time meta', (tester) async {
      await _pumpList(
        tester,
        state: _state(notifications: const [_service]),
      );

      expect(find.textContaining('Booking'), findsWidgets);
      expect(find.textContaining('2h ago'), findsOneWidget);
    });

    testWidgets('empty: one icon + one sentence, no action', (tester) async {
      await _pumpList(tester, state: _state());

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.textContaining("You're all caught up"), findsOneWidget);
      // Calm empty (U6): nothing exists to create, so no action button.
      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(AppPillButton), findsNothing);
      expect(find.byType(RefreshIndicator), findsNothing);
      // No data to find: single search path hidden when inbox empty.
      expect(find.byTooltip('Search notifications'), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    testWidgets('search visible only when loaded >5 + sheet filters', (
      tester,
    ) async {
      await _pumpList(tester, state: _state(notifications: _inbox6));

      // D3 ONE rule: 6 loaded → exactly 1 search icon, top-right.
      expect(find.byTooltip('Search notifications'), findsOneWidget);
      await tester.tap(find.byTooltip('Search notifications'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppSearchField), findsOneWidget);
      expect(find.text('Search by title or message'), findsOneWidget);
      // D4: result rows render whole — primary titles wrap ≤2 (no 1-line cut).
      final sheetTitles = tester.widgetList<Text>(
        find.text('Estimate needs approval'),
      );
      expect(sheetTitles, isNotEmpty);
      for (final w in sheetTitles) {
        expect(w.maxLines, 2);
      }
      await tester.enterText(find.byType(TextField), 'Booking confirmed');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // Sheet opens over the inbox ListView, so the background row stays in
      // the tree (plus the field value itself): the filtered sheet adds hits,
      // the unfiltered row stays at one (background only).
      expect(find.text('Booking confirmed'), findsWidgets);
      expect(find.text('Estimate needs approval'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'zzz-no-match');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('No notifications match your search.'),
        findsOneWidget,
      );
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('loading: mirroring skeleton, no rows', (tester) async {
      await _pumpList(tester, state: _state(isLoading: true));

      expect(find.byType(AppShimmerSkeleton), findsWidgets);
      expect(find.text('Booking confirmed'), findsNothing);
    });

    testWidgets('first-load error: title + retry', (tester) async {
      await _pumpList(tester, state: _state(loadError: 'No connection'));

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(
        find.textContaining("We couldn't load your notifications."),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('stale: data kept plus warning banner', (tester) async {
      await _pumpList(
        tester,
        state: _state(
          notifications: const [_service],
          loadError: 'No connection',
        ),
      );

      expect(find.text('Booking confirmed'), findsOneWidget);
      expect(find.byType(AppBanner), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('dark theme pumps clean with rows', (tester) async {
      await _pumpList(
        tester,
        state: _state(notifications: const [_service, _general]),
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Booking confirmed'), findsOneWidget);
    });

    testWidgets('1.3x text scale pumps clean', (tester) async {
      await _pumpList(
        tester,
        state: _state(notifications: const [_service, _general]),
        scale: 1.3,
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Booking confirmed'), findsOneWidget);
    });
  });
}
