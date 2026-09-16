import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/support/customer_notification_presentation.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';

/// The inbox is truthful only if three things hold: read state really reaches
/// the workshop, the badge and the list read from one canonical count, and a
/// row only opens a destination its own category genuinely leads to.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'customer_notifications_test',
    );
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  // ── Read state ─────────────────────────────────────────────────────────────

  group('Notification read state', () {
    test('loads unread state from the backend', () async {
      final harness = await _start(
        notifications: const [_unread, _unreadTwo, _read],
      );

      expect(harness.notifier.state.notifications, hasLength(3));
      expect(harness.notifier.state.unreadCount, 2);
    });

    test(
      'marks one read through the backend and decrements the count',
      () async {
        final harness = await _start(
          notifications: const [_unread, _unreadTwo],
        );

        await harness.notifier.markRead('n1');

        expect(harness.repository.readIds, ['n1']);
        expect(harness.notifier.state.unreadCount, 1);
        expect(harness.notifier.state.notifications.first.isRead, isTrue);
      },
    );

    test('never marks an already-read notification twice', () async {
      final harness = await _start(notifications: const [_unread, _read]);

      await harness.notifier.markRead('n2');
      await harness.notifier.markRead('n2');
      await harness.notifier.markRead('n2');

      expect(harness.repository.readIds, isEmpty);
      expect(harness.repository.markReadCalls, 0);
    });

    test(
      'a refused marker keeps the tap and reconciles on the next load',
      () async {
        final harness = await _start(
          notifications: const [_unread],
          markReadResult: false,
        );

        await harness.notifier.markRead('n1');
        expect(
          harness.notifier.state.unreadCount,
          0,
          reason: 'the customer tapped it; the tap is respected',
        );

        await harness.notifier.refresh();
        expect(
          harness.notifier.state.unreadCount,
          1,
          reason:
              'the workshop still holds it unread, so the badge tells the truth',
        );
      },
    );

    test(
      'a refresh that races a tap cannot flash the row back to unread',
      () async {
        final harness = await _start(notifications: const [_unread]);
        harness.repository.gateRead = Completer<bool>();

        final pending = harness.notifier.markRead('n1');
        await harness.notifier.refresh();

        expect(
          harness.notifier.state.unreadCount,
          0,
          reason: 'the in-flight marker wins over the stale server list',
        );

        harness.repository.gateRead!.complete(true);
        await pending;
        expect(harness.notifier.state.unreadCount, 0);
      },
    );

    test('mark all uses the bulk endpoint and zeroes the count', () async {
      final harness = await _start(
        notifications: const [_unread, _unreadTwo, _read],
      );

      final saved = await harness.notifier.markAllRead();

      expect(saved, isTrue);
      expect(harness.repository.markAllCalls, 1);
      expect(
        harness.repository.readIds,
        isEmpty,
        reason: 'one bulk call, not a loop',
      );
      expect(harness.notifier.state.unreadCount, 0);
    });

    test('mark all is ignored while one is already in flight', () async {
      final harness = await _start(notifications: const [_unread, _unreadTwo]);
      harness.repository.gateAll = Completer<bool>();

      final first = harness.notifier.markAllRead();
      final second = await harness.notifier.markAllRead();
      harness.repository.gateAll!.complete(true);
      await first;

      expect(second, isFalse);
      expect(harness.repository.markAllCalls, 1);
    });

    test('a refused mark-all rolls back so the badge stays truthful', () async {
      final harness = await _start(
        notifications: const [_unread, _unreadTwo],
        markAllResult: false,
      );

      final saved = await harness.notifier.markAllRead();

      expect(saved, isFalse);
      expect(
        harness.notifier.state.unreadCount,
        2,
        reason: 'the workshop never stored it, so nothing is claimed',
      );
    });

    test('a restart reloads read state from the backend', () async {
      final repository = _FakeRepository(
        notifications: const [_unread, _unreadTwo],
      );
      final first = await _start(repository: repository);
      await first.notifier.markRead('n1');
      first.container.dispose();

      final second = await _start(repository: repository);

      expect(
        second.notifier.state.unreadCount,
        1,
        reason: 'the marker was persisted, not kept in memory',
      );
    });

    test('refresh keeps the read state the backend holds', () async {
      final harness = await _start(notifications: const [_unread, _unreadTwo]);
      await harness.notifier.markRead('n1');

      await harness.notifier.refresh();

      expect(harness.notifier.state.unreadCount, 1);
      expect(harness.notifier.state.notifications.first.isRead, isTrue);
    });
  });

  // ── Read-state cache (offline truth) ───────────────────────────────────────

  group('Notification cache', () {
    setUp(() async {
      await Hive.openBox<dynamic>('customer_cache').then((box) => box.clear());
    });

    test('a persisted marker is written to the offline cache', () async {
      final repository = CustomerRepositoryImpl(_FakeRemote());
      await repository.getNotifications();

      expect(await repository.markNotificationRead('n1'), isTrue);

      final cached =
          Hive.box<dynamic>('customer_cache').get('cached_notifications')
              as List;
      expect(cached, hasLength(1));
      expect(
        (cached.single as Map)['isRead'],
        isTrue,
        reason: 'an offline restart must not show it unread again',
      );
    });

    test(
      'a refused marker never writes a state the server does not hold',
      () async {
        final repository = CustomerRepositoryImpl(
          _FakeRemote(markReadResult: false),
        );
        await repository.getNotifications();

        expect(await repository.markNotificationRead('n1'), isFalse);

        final cached =
            Hive.box<dynamic>('customer_cache').get('cached_notifications')
                as List;
        expect((cached.single as Map)['isRead'], isFalse);
      },
    );
  });

  // ── Routing ────────────────────────────────────────────────────────────────

  group('Notification destinations', () {
    test('every category leads only where it genuinely can', () {
      expect(
        CustomerNotificationPresentation.destination(NotifType.bookingReceived),
        AppRoutes.bookingsLocation,
      );
      expect(
        CustomerNotificationPresentation.destination(NotifType.bookingAssigned),
        AppRoutes.bookingsLocation,
      );
      expect(
        CustomerNotificationPresentation.destination(
          NotifType.completionApproved,
        ),
        AppRoutes.bookingsLocation,
      );
      expect(
        CustomerNotificationPresentation.destination(NotifType.approvalNeeded),
        AppRoutes.approvalsLocation(),
      );
      expect(
        CustomerNotificationPresentation.destination(NotifType.invoiceReady),
        AppRoutes.approvalsLocation(),
      );
      expect(
        CustomerNotificationPresentation.destination(NotifType.paymentReceived),
        AppRoutes.approvalsLocation(),
      );
    });

    test('categories with nothing safe to open stay non-navigational', () {
      for (final type in const [
        NotifType.estimateApproved,
        NotifType.estimateRejected,
        NotifType.breakdownAssigned,
        NotifType.general,
      ]) {
        expect(
          CustomerNotificationPresentation.destination(type),
          isNull,
          reason: '$type carries no identifier to open anything with',
        );
        expect(CustomerNotificationPresentation.isActionable(type), isFalse);
      }
    });

    test('an unknown backend type degrades to a neutral category', () {
      expect(NotifType.fromWire('bookingReceived'), NotifType.bookingReceived);
      expect(NotifType.fromWire('paymentReceived'), NotifType.paymentReceived);
      expect(NotifType.fromWire('carReady'), NotifType.general);
      expect(NotifType.fromWire('somethingNew'), NotifType.general);
      expect(NotifType.fromWire(null), NotifType.general);
      expect(NotifType.fromWire(''), NotifType.general);
    });

    test('every category has an icon, a label and a theme-aware tone', () {
      for (final scheme in const [ColorScheme.light(), ColorScheme.dark()]) {
        for (final type in NotifType.values) {
          final expected = switch (CustomerNotificationPresentation.tone(
            type,
          )) {
            NotificationTone.attention => scheme.primary,
            NotificationTone.positive => scheme.tertiary,
            NotificationTone.neutral => scheme.onSurfaceVariant,
          };

          expect(
            CustomerNotificationPresentation.toneColor(scheme, type),
            expected,
            reason: '$type must take its colour from the active theme',
          );
          expect(CustomerNotificationPresentation.label(type), isNotEmpty);
          expect(CustomerNotificationPresentation.icon(type), isNotNull);
        }
      }
    });

    testWidgets('a booking notification opens the bookings destination', (
      tester,
    ) async {
      final notifier = await _pumpInbox(
        tester,
        notifications: const [_bookingUnread],
      );

      await tester.tap(find.text('Booking received'));
      await tester.pumpAndSettle();

      expect(notifier.markedIds, ['n7']);
      expect(find.text('BOOKINGS_DESTINATION tab=bookings'), findsOneWidget);
    });

    testWidgets('an estimate notification opens approvals & billing', (
      tester,
    ) async {
      await _pumpInbox(tester, notifications: const [_approvalUnread]);

      await tester.tap(find.text('Approve your estimate'));
      await tester.pumpAndSettle();

      expect(find.text('APPROVALS_DESTINATION'), findsOneWidget);
    });

    testWidgets('a category with no destination does not navigate', (
      tester,
    ) async {
      await _pumpInbox(
        tester,
        notifications: const [_breakdownUnread, _generalUnread],
      );

      await tester.tap(find.text('Breakdown assistance on the way'));
      await tester.pumpAndSettle();

      expect(find.textContaining('BOOKINGS_DESTINATION'), findsNothing);
      expect(find.text('APPROVALS_DESTINATION'), findsNothing);
      expect(find.byType(CustomerNotificationsView), findsOneWidget);
      expect(
        find.byIcon(Icons.chevron_right_rounded),
        findsNothing,
        reason: 'a row that opens nothing must not offer a chevron',
      );
    });
  });

  // ── Home badge ─────────────────────────────────────────────────────────────

  group('Home badge consistency', () {
    testWidgets('reading one notification updates the Home badge', (
      tester,
    ) async {
      final notifier = _FakeDashboardNotifier(
        _state(
          notifications: const [_unread, _unreadTwo, _unreadThree, _unreadFour],
        ),
      );
      await _pumpHomeAndInbox(tester, notifier);

      expect(_badge('Notifications, 4 unread'), findsOneWidget);

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      // A row with no destination: reading it must not leave this screen.
      await tester.tap(find.text('Breakdown assistance on the way'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(_badge('Notifications, 3 unread'), findsOneWidget);
      expect(notifier.markedIds, ['n4']);
    });

    testWidgets('mark all read clears the Home badge', (tester) async {
      final notifier = _FakeDashboardNotifier(
        _state(notifications: const [_unread, _unreadTwo]),
      );
      await _pumpHomeAndInbox(tester, notifier);

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(_badge('Notifications, 2 unread'), findsNothing);
      expect(_badge('Notifications, 0 unread'), findsNothing);
      expect(notifier.markAllCalls, 1);
    });
  });

  // ── Inbox states ───────────────────────────────────────────────────────────

  group('Inbox states', () {
    testWidgets('empty says so truthfully', (tester) async {
      await _pumpInbox(tester, notifications: const []);

      expect(find.text("You're all caught up"), findsOneWidget);
      expect(
        find.textContaining('bookings, estimates and service progress'),
        findsOneWidget,
      );
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('one unread still reads as a complete inbox', (tester) async {
      await _pumpInbox(tester, notifications: const [_unread]);

      expect(find.text('1 unread'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
      expect(find.text('Your vehicle is ready'), findsOneWidget);
    });

    testWidgets('one read offers no bulk action', (tester) async {
      await _pumpInbox(tester, notifications: const [_read]);

      expect(find.text('All read'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('a mixed list shows unread counts and both row states', (
      tester,
    ) async {
      await _pumpInbox(
        tester,
        notifications: const [_unread, _read, _bookingUnread],
      );

      expect(find.text('2 unread'), findsOneWidget);
      expect(find.text('Your vehicle is ready'), findsOneWidget);
      expect(find.text('Booking received'), findsOneWidget);
      expect(find.text('Invoice ready'), findsOneWidget);
    });

    testWidgets('twenty notifications render and scroll', (tester) async {
      await _pumpInbox(tester, notifications: _many(20));

      expect(find.text('20 unread'), findsOneWidget);
      expect(find.text('Notification 1'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Notification 20'), 300);
      expect(find.text('Notification 20'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a list-shaped skeleton while loading', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [],
        loading: true,
        settle: false,
      );
      await tester.pump();

      expect(find.byType(CustomerSkeleton), findsOneWidget);
      expect(find.text("You're all caught up"), findsNothing);
    });

    testWidgets('a failed first load is honest and recoverable', (
      tester,
    ) async {
      final notifier = await _pumpInbox(
        tester,
        notifications: const [],
        loadError: 'boom',
      );

      expect(find.text("We couldn't load your notifications."), findsOneWidget);
      expect(find.textContaining('network'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(notifier.refreshCount, 1);
    });

    testWidgets('a failed refresh keeps the notifications on screen', (
      tester,
    ) async {
      await _pumpInbox(
        tester,
        notifications: const [_unread, _read],
        loadError: 'boom',
      );

      expect(find.text('Your vehicle is ready'), findsOneWidget);
      expect(
        find.text("We couldn't refresh your information."),
        findsOneWidget,
      );
    });

    testWidgets('a refused bulk action is reported and can be retried', (
      tester,
    ) async {
      final notifier = await _pumpInbox(
        tester,
        notifications: const [_unread, _unreadTwo],
      );
      notifier.markAllResult = false;

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't mark your notifications as read."),
        findsOneWidget,
      );
      expect(find.text('2 unread'), findsOneWidget);
    });
  });

  // ── Layout and guards ──────────────────────────────────────────────────────

  group('Inbox layout and guards', () {
    testWidgets('stays overflow-free on every supported width', (tester) async {
      for (final width in const [320.0, 360.0, 390.0, 412.0, 430.0]) {
        await _pumpInbox(
          tester,
          notifications: const [_longTitle, _longBody],
          size: Size(width, 844),
        );

        expect(
          tester.takeException(),
          isNull,
          reason: 'notifications must not overflow at ${width}px',
        );
      }
    });

    testWidgets('survives 1.6x text with long content', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [_longTitle, _longBody],
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Vehicle inspection complete'),
        findsOneWidget,
      );
    });

    testWidgets('keeps the list a readable column on desktop', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [_unread, _read],
        size: const Size(1440, 900),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byType(CustomerNotificationsView)).width,
        1440,
      );
      // The grouped surface is a deliberate, bounded column, not edge to edge.
      final surface = tester.getRect(find.text('Mark all read'));
      expect(surface.left, greaterThan(1440 * 0.15));
    });

    testWidgets('renders on tablet and in dark mode', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [_unread, _read],
        size: const Size(1024, 900),
      );
      expect(tester.takeException(), isNull);

      await _pumpInbox(
        tester,
        notifications: const [_unread, _read],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Your vehicle is ready'), findsOneWidget);
    });

    testWidgets('announces unread state and the reading order', (tester) async {
      await _pumpInbox(tester, notifications: const [_unread, _read]);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label ?? '').startsWith('Unread. Service.'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label ?? '').startsWith('Read. Invoice.'),
        ),
        findsOneWidget,
      );
    });

    test('never reintroduces fake or inert notification content', () {
      final source = const [
        'lib/features/customer/presentation/customer_notifications_view.dart',
        'lib/features/customer/presentation/support/customer_notification_presentation.dart',
      ].map((path) => File(path).readAsStringSync()).join().toLowerCase();

      for (final banned in const [
        'offers',
        'promotion',
        'flash sale',
        'vip',
        'rewards',
        'recommended services',
        'deals',
      ]) {
        expect(
          source.contains(banned),
          isFalse,
          reason: '"$banned" must not ship',
        );
      }

      for (final path in const [
        'lib/features/customer/presentation/customer_notifications_view.dart',
      ]) {
        final file = File(path).readAsStringSync();
        expect(file.contains('onTap: () {}'), isFalse);
        expect(file.contains('onPressed: () {}'), isFalse);
        expect(file.contains('onChanged: (_) {}'), isFalse);
      }
    });
  });

  // ── Goldens ────────────────────────────────────────────────────────────────

  group('Notification visual references', () {
    testWidgets('mixed mobile', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [
          _bookingUnread,
          _approvalUnread,
          _read,
          _invoiceRead,
        ],
      );
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/customer_notifications_mixed_mobile.png'),
      );
    });

    testWidgets('one mobile', (tester) async {
      await _pumpInbox(tester, notifications: const [_approvalUnread]);
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/customer_notifications_one_mobile.png'),
      );
    });

    testWidgets('empty mobile', (tester) async {
      await _pumpInbox(tester, notifications: const []);
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/customer_notifications_empty_mobile.png'),
      );
    });

    testWidgets('tablet', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [
          _bookingUnread,
          _approvalUnread,
          _read,
          _invoiceRead,
        ],
        size: const Size(1024, 900),
      );
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/customer_notifications_tablet.png'),
      );
    });

    testWidgets('desktop', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [
          _bookingUnread,
          _approvalUnread,
          _read,
          _invoiceRead,
        ],
        size: const Size(1440, 900),
      );
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/customer_notifications_desktop.png'),
      );
    });

    testWidgets('dark mobile', (tester) async {
      await _pumpInbox(
        tester,
        notifications: const [
          _bookingUnread,
          _approvalUnread,
          _read,
          _invoiceRead,
        ],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(CustomerNotificationsView),
        matchesGoldenFile('goldens/customer_notifications_dark_mobile.png'),
      );
    });
  });
}

// ─── Harness ─────────────────────────────────────────────────────────────────

Finder _badge(String label) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == label,
);

class _InboxHarness {
  final ProviderContainer container;
  final _FakeRepository repository;
  final CustomerDashboardNotifier notifier;

  const _InboxHarness({
    required this.container,
    required this.repository,
    required this.notifier,
  });
}

Future<_InboxHarness> _start({
  List<CustomerNotificationEntity> notifications = const [],
  _FakeRepository? repository,
  bool markReadResult = true,
  bool markAllResult = true,
}) async {
  final repo =
      repository ??
      _FakeRepository(
        notifications: notifications,
        markReadResult: markReadResult,
        markAllResult: markAllResult,
      );
  final container = ProviderContainer(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repo),
      customerRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
      authNotifierProvider.overrideWith(_FakeAuth.new),
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(customerDashboardProvider.notifier);
  await notifier.refresh();

  return _InboxHarness(
    container: container,
    repository: repo,
    notifier: notifier,
  );
}

/// The dashboard notifier with local, observable marks — used by the widget
/// tests so the view's own wiring is what gets exercised. Persistence itself is
/// pinned by the notifier-level group above.
class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;
  int refreshCount = 0;
  int markAllCalls = 0;
  bool markAllResult = true;
  final List<String> markedIds = [];

  @override
  CustomerDashboardState build() => _initial;

  @override
  Future<void> refresh() async => refreshCount++;

  @override
  Future<void> markRead(String id) async {
    markedIds.add(id);
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications)
          n.id == id ? n.copyWith(isRead: true) : n,
      ],
    );
  }

  @override
  Future<bool> markAllRead() async {
    markAllCalls++;
    if (!markAllResult) return false;
    state = state.copyWith(
      notifications: [
        for (final n in state.notifications) n.copyWith(isRead: true),
      ],
    );
    return true;
  }

  @override
  void selectTab(int index) => state = state.copyWith(selectedIndex: index);

  @override
  void selectDestination(CustomerDestination destination) =>
      selectTab(destination.index);
}

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() =>
      const AuthAuthenticated(role: UserRole.customer, token: 'test-token');
}

/// Stands in for the workshop's own list: a successful marker is what makes the
/// next load read back as read.
class _FakeRepository implements CustomerRepository {
  _FakeRepository({
    List<CustomerNotificationEntity> notifications = const [],
    this.markReadResult = true,
    this.markAllResult = true,
  }) : _notifications = List.of(notifications);

  List<CustomerNotificationEntity> _notifications;
  bool markReadResult;
  bool markAllResult;
  int markReadCalls = 0;
  int markAllCalls = 0;
  final List<String> readIds = [];
  Completer<bool>? gateRead;
  Completer<bool>? gateAll;

  @override
  Future<List<CustomerNotificationEntity>> getNotifications() async =>
      List.of(_notifications);

  @override
  Future<bool> markNotificationRead(String id) async {
    markReadCalls++;
    readIds.add(id);
    if (gateRead != null) await gateRead!.future;
    if (!markReadResult) return false;
    _notifications = [
      for (final n in _notifications) n.id == id ? n.copyWith(isRead: true) : n,
    ];
    return true;
  }

  @override
  Future<bool> markAllNotificationsRead() async {
    markAllCalls++;
    if (gateAll != null) await gateAll!.future;
    if (!markAllResult) return false;
    _notifications = [for (final n in _notifications) n.copyWith(isRead: true)];
    return true;
  }

  @override
  Future<List<CustomerVehicleEntity>> getVehicles() async => const [];

  @override
  Future<CustomerEntity> getCustomerProfile() async => const CustomerEntity(
    name: 'Ahmed',
    firstName: 'Ahmed',
    avatarInitials: 'AM',
    memberId: '',
  );

  @override
  Future<List<CustomerBookingEntity>> getBookings() async => const [];

  @override
  Future<CustomerServiceEntity> getActiveService() async =>
      const CustomerServiceEntity(
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
}

class _FakeRemote implements CustomerRemoteDataSource {
  _FakeRemote({this.markReadResult = true});

  final bool markReadResult;
  int markReadCalls = 0;
  int markAllCalls = 0;
  final List<String> readIds = [];

  @override
  Future<List<NotificationResponse>> getNotifications() async => const [
    _response,
  ];

  @override
  Future<bool> markNotificationRead(String id) async {
    markReadCalls++;
    readIds.add(id);
    return markReadResult;
  }

  @override
  Future<bool> markAllNotificationsRead() async {
    markAllCalls++;
    return markReadResult;
  }

  @override
  Future<List<InvoiceResponse>> getInvoices() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

const _response = NotificationResponse(
  id: 'n1',
  title: 'Your vehicle is ready',
  body: 'Job card JC-2026-0042 has been checked and approved.',
  time: '12 Sep · 14:30',
  type: 'completionApproved',
);

Future<_FakeDashboardNotifier> _pumpInbox(
  WidgetTester tester, {
  required List<CustomerNotificationEntity> notifications,
  String loadError = '',
  bool loading = false,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
  bool settle = true,
}) async {
  final notifier = _FakeDashboardNotifier(
    _state(
      notifications: notifications,
      loadError: loadError,
      loading: loading,
    ),
  );
  await _pumpRouter(
    tester,
    notifier,
    size,
    textScaler,
    theme,
    settle,
    AppRoutes.customerNotifications,
  );
  return notifier;
}

/// Home and the inbox in one app, so the badge and the list provably read from
/// the same canonical state.
Future<void> _pumpHomeAndInbox(
  WidgetTester tester,
  _FakeDashboardNotifier notifier,
) async {
  await _pumpRouter(
    tester,
    notifier,
    const Size(390, 844),
    TextScaler.noScaling,
    null,
    true,
    '/',
  );
}

Future<void> _pumpRouter(
  WidgetTester tester,
  _FakeDashboardNotifier notifier,
  Size size,
  TextScaler textScaler,
  ThemeData? theme,
  bool settle,
  String initialLocation,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: CustomerHomeTab()),
      ),
      GoRoute(
        path: AppRoutes.customerNotifications,
        builder: (_, __) => const CustomerNotificationsView(),
      ),
      GoRoute(
        path: AppRoutes.customerDashboard,
        builder: (context, state) => Scaffold(
          body: Text(
            'BOOKINGS_DESTINATION '
            'tab=${state.uri.queryParameters['tab'] ?? 'none'}',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerApprovals,
        builder: (_, __) => const Scaffold(body: Text('APPROVALS_DESTINATION')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(() => notifier),
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
  if (settle) await tester.pumpAndSettle();
}

CustomerDashboardState _state({
  List<CustomerNotificationEntity> notifications = const [],
  String loadError = '',
  bool loading = false,
}) => CustomerDashboardState(
  selectedIndex: 0,
  isLoading: loading,
  selectedVehicle: '',
  selectedServiceType: '',
  bookingNotes: '',
  loadError: loadError,
  vehicles: const [],
  notifications: notifications,
);

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

List<CustomerNotificationEntity> _many(int count) => [
  for (var index = 1; index <= count; index++)
    CustomerNotificationEntity(
      id: 'n$index',
      title: 'Notification $index',
      body: 'Workshop update number $index.',
      time: '12 Sep · 10:0$index',
      type: NotifType.bookingReceived,
    ),
];

// ─── Fixtures ────────────────────────────────────────────────────────────────

const _unread = CustomerNotificationEntity(
  id: 'n1',
  title: 'Your vehicle is ready',
  body: 'Job card JC-2026-0042 has been checked and approved.',
  time: '12 Sep · 14:30',
  type: NotifType.completionApproved,
);

const _unreadTwo = CustomerNotificationEntity(
  id: 'n2',
  title: 'Payment received',
  body: 'Payment PAY-2026-0011 recorded for invoice INV-2026-0007.',
  time: '12 Sep · 12:05',
  type: NotifType.paymentReceived,
);

const _unreadThree = CustomerNotificationEntity(
  id: 'n3',
  title: 'Booking confirmed',
  body: 'Your booking BK-2026-0044 is confirmed with advisor Ravi.',
  time: '11 Sep · 09:15',
  type: NotifType.bookingAssigned,
);

const _unreadFour = CustomerNotificationEntity(
  id: 'n4',
  title: 'Breakdown assistance on the way',
  body: 'Advisor Ravi is handling your request BD-2026-0009.',
  time: '10 Sep · 18:40',
  type: NotifType.breakdownAssigned,
);

const _read = CustomerNotificationEntity(
  id: 'n5',
  title: 'Invoice ready',
  body: 'Invoice INV-2026-0007 is ready to view.',
  time: '9 Sep · 16:20',
  type: NotifType.invoiceReady,
  isRead: true,
);

const _invoiceRead = CustomerNotificationEntity(
  id: 'n6',
  title: 'Estimate approved',
  body: 'Estimate RO-2026-0031 — work will start shortly.',
  time: '8 Sep · 11:00',
  type: NotifType.estimateApproved,
  isRead: true,
);

const _bookingUnread = CustomerNotificationEntity(
  id: 'n7',
  title: 'Booking received',
  body: 'Your booking BK-2026-0051 for Full Service has been received.',
  time: '12 Sep · 15:10',
  type: NotifType.bookingReceived,
);

const _approvalUnread = CustomerNotificationEntity(
  id: 'n8',
  title: 'Approve your estimate',
  body: 'Estimate RO-2026-0044 · 1,250.00 · review the work and approve.',
  time: '12 Sep · 15:22',
  type: NotifType.approvalNeeded,
);

const _breakdownUnread = CustomerNotificationEntity(
  id: 'n9',
  title: 'Breakdown assistance on the way',
  body: 'Advisor Ravi is handling your request BD-2026-0011.',
  time: '12 Sep · 15:30',
  type: NotifType.breakdownAssigned,
);

const _generalUnread = CustomerNotificationEntity(
  id: 'n10',
  title: 'Workshop update',
  body: 'Your workshop posted an update.',
  time: '12 Sep · 15:40',
  type: NotifType.general,
);

const _longTitle = CustomerNotificationEntity(
  id: 'n11',
  title:
      'Vehicle inspection complete and ready for collection at the main '
      'workshop reception desk',
  body: 'Your Toyota Land Cruiser has passed its multi-point inspection.',
  time: '12 Sep · 14:30 · updated',
  type: NotifType.completionApproved,
);

const _longBody = CustomerNotificationEntity(
  id: 'n12',
  title: 'Estimate ready for review',
  body:
      'Your workshop sent an estimate covering the front brake pads, both '
      'front discs, a brake fluid flush and a full multi-point inspection. '
      'Review the itemised work before we start, and let us know if you would '
      'like anything removed from the quote.',
  time: '12 Sep · 14:31',
  type: NotifType.approvalNeeded,
);
