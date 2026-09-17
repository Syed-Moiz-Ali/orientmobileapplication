import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/notifications/customer_push_scope.dart';
import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/data/datasources/customer_remote_datasource.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/domain/repositories/customer_repository.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_push_routing.dart';

/// A push may only ever do two things: converge canonical notification state,
/// or open the one destination its category genuinely leads to. These tests pin
/// both, without Firebase.
void main() {
  setUpAll(_loadFonts);

  // ── Pure routing ───────────────────────────────────────────────────────────

  group('Push routing', () {
    test('booking categories open the bookings destination', () {
      for (final type in const [
        'bookingReceived',
        'bookingAssigned',
        'completionApproved',
      ]) {
        final route = resolveCustomerPushRoute(type);

        expect(route.location, AppRoutes.bookingsLocation, reason: type);
        expect(route.isFallback, isFalse, reason: type);
      }
    });

    test('estimate and billing categories open approvals & billing', () {
      for (final type in const [
        'approvalNeeded',
        'invoiceReady',
        'paymentReceived',
      ]) {
        final route = resolveCustomerPushRoute(type);

        expect(route.location, AppRoutes.approvalsLocation(), reason: type);
        expect(route.isFallback, isFalse, reason: type);
      }
    });

    test('categories with no destination fall back to the inbox', () {
      for (final type in const [
        'estimateApproved',
        'estimateRejected',
        'breakdownAssigned',
        'general',
        'somethingTheBackendAddedLater',
        '',
      ]) {
        final route = resolveCustomerPushRoute(type);

        expect(route.location, AppRoutes.customerNotifications, reason: type);
        expect(route.isFallback, isTrue, reason: type);
      }
    });

    test(
      'a missing payload degrades to the neutral category and the inbox',
      () {
        final route = resolveCustomerPushRoute(null);

        expect(route.type, NotifType.general);
        expect(route.location, AppRoutes.customerNotifications);
        expect(route.isFallback, isTrue);
      },
    );

    test('never resolves to an exact-record route', () {
      for (final type in const [
        ...['bookingReceived', 'bookingAssigned', 'completionApproved'],
        'approvalNeeded',
        'invoiceReady',
        'paymentReceived',
        'estimateApproved',
        'breakdownAssigned',
        'general',
      ]) {
        final location = resolveCustomerPushRoute(type).location;

        expect(location, isNot(AppRoutes.customerBookingDetail));
        expect(location, isNot(AppRoutes.customerInvoiceDetail));
        expect(location, isNot(AppRoutes.customerBreakdownResult));
        expect(location.contains('estimateId'), isFalse);
      }
    });

    test('reuses the canonical category parser for every known type', () {
      for (final type in NotifType.values) {
        expect(resolveCustomerPushRoute(type.name).type, type);
      }
    });
  });

  // ── Foreground ─────────────────────────────────────────────────────────────

  group('Foreground push', () {
    testWidgets('refreshes canonical state without navigating', (tester) async {
      final harness = await _pumpPushApp(tester);

      harness.source.emitForeground('bookingReceived');
      await tester.pumpAndSettle();

      expect(harness.notifier.refreshCount, greaterThanOrEqualTo(1));
      expect(find.text('HOME'), findsOneWidget);
      expect(find.textContaining('BOOKINGS_DESTINATION'), findsNothing);
      expect(find.text('INBOX_DESTINATION'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a burst does not become a request storm', (tester) async {
      final repository = _FakeRepository(notifications: const [_unreadPush]);
      final harness = await _pumpPushApp(tester, repository: repository);
      final before = repository.getNotificationsCalls;

      // Hold the first load open so the whole burst really overlaps it, which
      // is what a real network round trip does.
      repository.gateGet = Completer<void>();
      for (var index = 0; index < 6; index++) {
        harness.source.emitForeground('completionApproved');
      }
      await tester.pump();
      expect(
        repository.getNotificationsCalls - before,
        1,
        reason: 'one fetch is in flight for the whole burst',
      );

      repository.gateGet!.complete();
      await tester.pumpAndSettle();

      expect(
        repository.getNotificationsCalls - before,
        2,
        reason: 'one shared fetch plus exactly one trailing rerun, not six',
      );
    });

    test('concurrent loads coalesce into one fetch plus one rerun', () async {
      final repository = _FakeRepository(notifications: const [_unreadPush]);
      repository.gateGet = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          customerRepositoryProvider.overrideWithValue(repository),
          customerRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
          authNotifierProvider.overrideWith(_FakeAuth.new),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(customerDashboardProvider.notifier);
      final first = notifier.refresh();
      final second = notifier.refresh();
      final third = notifier.refresh();

      expect(
        repository.getNotificationsCalls,
        1,
        reason: 'the first load is still in flight',
      );

      repository.gateGet!.complete();
      await Future.wait([first, second, third]);

      expect(
        repository.getNotificationsCalls,
        2,
        reason: 'one shared fetch plus exactly one trailing rerun',
      );
    });
  });

  // ── Opened push ────────────────────────────────────────────────────────────

  group('Opened push', () {
    testWidgets('a booking tap opens bookings', (tester) async {
      final harness = await _pumpPushApp(tester);

      harness.source.emitOpened('bookingReceived');
      await tester.pumpAndSettle();

      expect(find.text('BOOKINGS_DESTINATION tab=bookings'), findsOneWidget);
      expect(harness.navigations(), harness.baseline + 1);
    });

    testWidgets('an approval tap opens approvals & billing', (tester) async {
      final harness = await _pumpPushApp(tester);

      harness.source.emitOpened('approvalNeeded');
      await tester.pumpAndSettle();

      expect(find.text('APPROVALS_DESTINATION'), findsOneWidget);
      expect(harness.navigations(), harness.baseline + 1);
    });

    testWidgets('a non-routable tap opens the inbox', (tester) async {
      final harness = await _pumpPushApp(tester);

      harness.source.emitOpened('breakdownAssigned');
      await tester.pumpAndSettle();

      expect(find.text('INBOX_DESTINATION'), findsOneWidget);
      expect(find.textContaining('BOOKINGS_DESTINATION'), findsNothing);
      expect(find.text('APPROVALS_DESTINATION'), findsNothing);
    });

    testWidgets('an unknown category opens the inbox and never crashes', (
      tester,
    ) async {
      final harness = await _pumpPushApp(tester);

      harness.source.emitOpened('carReady');
      await tester.pumpAndSettle();

      expect(find.text('INBOX_DESTINATION'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the launch message is handled exactly once', (tester) async {
      final harness = await _pumpPushApp(
        tester,
        initialMessage: const PushMessage(
          messageId: 'm1',
          type: 'bookingReceived',
        ),
      );

      // The same message is delivered again on the opened-app stream, which is
      // what a launched-by-push app can observe.
      harness.source.emitOpened('bookingReceived', messageId: 'm1');
      await tester.pumpAndSettle();

      expect(find.text('BOOKINGS_DESTINATION tab=bookings'), findsOneWidget);
      expect(
        harness.navigations(),
        harness.baseline,
        reason: 'the launch intent navigated once and the duplicate added none',
      );
    });

    testWidgets('never marks anything read, because a push has no id', (
      tester,
    ) async {
      final repository = _FakeRepository(notifications: const [_unreadPush]);
      final harness = await _pumpPushApp(tester, repository: repository);

      harness.source.emitOpened('completionApproved');
      await tester.pumpAndSettle();

      expect(repository.markReadCalls, 0);
      expect(repository.readIds, isEmpty);
    });
  });

  // ── Auth gate ──────────────────────────────────────────────────────────────

  group('Auth gate', () {
    testWidgets('a push waits for the session instead of bypassing it', (
      tester,
    ) async {
      final harness = await _pumpPushApp(tester, authenticated: false);

      harness.source.emitOpened('bookingReceived');
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(find.textContaining('BOOKINGS_DESTINATION'), findsNothing);
      expect(harness.navigations(), harness.baseline);

      harness.auth.makeAuthenticated();
      await tester.pumpAndSettle();

      expect(find.text('BOOKINGS_DESTINATION tab=bookings'), findsOneWidget);
      expect(harness.navigations(), harness.baseline + 1);
    });

    testWidgets('a signed-out session never receives a customer route', (
      tester,
    ) async {
      final harness = await _pumpPushApp(
        tester,
        authenticated: false,
        initialMessage: const PushMessage(type: 'approvalNeeded'),
      );

      await tester.pumpAndSettle();

      expect(find.text('APPROVALS_DESTINATION'), findsNothing);
      expect(find.text('INBOX_DESTINATION'), findsNothing);
      expect(harness.navigations(), harness.baseline);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Guards ─────────────────────────────────────────────────────────────────

  group('Push implementation guards', () {
    test(
      'the routing helper is pure: no Firebase, no identifiers, no delays',
      () {
        const path =
            'lib/features/customer/presentation/support/customer_push_routing.dart';
        final source = File(path).readAsStringSync();

        for (final banned in const [
          'firebase',
          'FirebaseMessaging',
          'RemoteMessage',
          'Future.delayed',
          'Thread.sleep',
          'RegExp',
          'substring',
        ]) {
          expect(source.contains(banned), isFalse, reason: banned);
        }
        // It must reach destinations only through the app's route helpers.
        expect(source.contains('AppRoutes.'), isTrue);
      },
    );

    test('the push scope never marks notifications read', () {
      const path = 'lib/core/notifications/customer_push_scope.dart';
      final source = File(path).readAsStringSync();

      expect(source.contains('markRead'), isFalse);
      expect(source.contains('markNotificationRead'), isFalse);
      expect(source.contains('Future.delayed'), isFalse);
      expect(source.contains('CustomerBookingEntity'), isFalse);
      expect(source.contains('InvoiceResponse'), isFalse);
    });

    test('the app listens for push opens and launch messages', () {
      const path = 'lib/main.dart';
      final source = File(path).readAsStringSync();

      expect(source.contains('CustomerPushScope'), isTrue);
    });
  });
}

// ─── Harness ─────────────────────────────────────────────────────────────────

class _FakePushSource implements PushNotificationSource {
  final StreamController<PushMessage> _foreground =
      StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> _opened =
      StreamController<PushMessage>.broadcast();

  PushMessage? initial;

  @override
  Stream<PushMessage> get foregroundMessages => _foreground.stream;

  @override
  Stream<PushMessage> get openedMessages => _opened.stream;

  @override
  Future<PushMessage?> takeInitialMessage() async => initial;

  /// Synchronous on purpose: a `testWidgets` body runs under fake time, so an
  /// awaited delay here would deadlock instead of delivering the event.
  void emitForeground(String type) => _foreground.add(PushMessage(type: type));

  void emitOpened(String type, {String messageId = ''}) =>
      _opened.add(PushMessage(messageId: messageId, type: type));

  Future<void> close() async {
    await _foreground.close();
    await _opened.close();
  }
}

class _FakeAuth extends AuthNotifier {
  _FakeAuth({this.authenticated = false});

  final bool authenticated;

  @override
  AuthState build() => authenticated
      ? const AuthAuthenticated(role: UserRole.customer, token: 't')
      : const AuthUnauthenticated();

  /// Only valid once the notifier has been built.
  void makeAuthenticated() =>
      state = const AuthAuthenticated(role: UserRole.customer, token: 't');
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  int refreshCount = 0;

  @override
  CustomerDashboardState build() => const CustomerDashboardState(
    selectedIndex: 0,
    isLoading: false,
    selectedVehicle: '',
    selectedServiceType: '',
    bookingNotes: '',
    vehicles: [],
    notifications: [],
  );

  @override
  Future<void> refresh() async => refreshCount++;
}

class _FakeRepository implements CustomerRepository {
  _FakeRepository({List<CustomerNotificationEntity> notifications = const []})
    : _notifications = List.of(notifications);

  List<CustomerNotificationEntity> _notifications;
  int getNotificationsCalls = 0;
  int markReadCalls = 0;
  final List<String> readIds = [];
  Completer<void>? gateGet;
  Completer<bool>? gateRead;

  @override
  Future<List<CustomerNotificationEntity>> getNotifications() async {
    getNotificationsCalls++;
    if (gateGet != null) await gateGet!.future;
    return List.of(_notifications);
  }

  @override
  Future<bool> markNotificationRead(String id) async {
    markReadCalls++;
    readIds.add(id);
    if (gateRead != null) await gateRead!.future;
    _notifications = [
      for (final n in _notifications) n.id == id ? n.copyWith(isRead: true) : n,
    ];
    return true;
  }

  @override
  Future<bool> markAllNotificationsRead() async {
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
  @override
  Future<List<InvoiceResponse>> getInvoices() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _PushHarness {
  final _FakePushSource source;
  final _FakeAuth auth;
  final _FakeDashboardNotifier notifier;
  final int Function() navigations;

  /// Navigations already counted when the app finished mounting, so a test can
  /// assert what the push itself added.
  final int baseline;

  const _PushHarness({
    required this.source,
    required this.auth,
    required this.notifier,
    required this.navigations,
    required this.baseline,
  });
}

Future<_PushHarness> _pumpPushApp(
  WidgetTester tester, {
  bool authenticated = true,
  PushMessage? initialMessage,
  _FakeRepository? repository,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);

  final source = _FakePushSource()..initial = initialMessage;
  addTearDown(source.close);

  final auth = _FakeAuth(authenticated: authenticated);

  final notifier = _FakeDashboardNotifier();
  var navigations = 0;

  final router = GoRouter(
    initialLocation: '/',
    observers: [_CountingObserver(() => navigations++)],
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: Text('HOME')),
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
      GoRoute(
        path: AppRoutes.customerNotifications,
        builder: (_, __) => const Scaffold(body: Text('INBOX_DESTINATION')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // The real repository only matters to the tests that assert what the
        // push path does or does not call; the rest use the counting notifier.
        if (repository != null)
          customerRepositoryProvider.overrideWithValue(repository),
        if (repository != null)
          customerRemoteDataSourceProvider.overrideWithValue(_FakeRemote()),
        if (repository == null)
          customerDashboardProvider.overrideWith(() => notifier),
        pushNotificationSourceProvider.overrideWithValue(source),
        authNotifierProvider.overrideWith(() => auth),
        appRouterProvider.overrideWithValue(router),
      ],
      child: CustomerPushScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _PushHarness(
    source: source,
    auth: auth,
    notifier: notifier,
    navigations: () => navigations,
    baseline: navigations,
  );
}

class _CountingObserver extends NavigatorObserver {
  _CountingObserver(this._onPush);

  final void Function() _onPush;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _onPush();
    super.didPush(route, previousRoute);
  }
}

const _unreadPush = CustomerNotificationEntity(
  id: 'n1',
  title: 'Your vehicle is ready',
  body: 'Job card JC-2026-0042 has been checked and approved.',
  time: '12 Sep · 14:30',
  type: NotifType.completionApproved,
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
