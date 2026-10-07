import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_failed_booking_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  group('FailedBookingSync seam (authoritative sync_failed)', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = Directory.systemTemp.createTempSync('failed_booking_test');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SyncOperationAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ChangeTypeAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
      tempDir.deleteSync(recursive: true);
    });

    setUp(() async {
      await Hive.openBox<SyncOperation>('sync_failed');
      await Hive.openBox<SyncOperation>('sync_queue');
      await Hive.openBox<dynamic>('customer_cache');
    });

    tearDown(() async {
      await Hive.box<SyncOperation>('sync_failed').clear();
      await Hive.box<SyncOperation>('sync_queue').clear();
      await Hive.box<dynamic>('customer_cache').clear();
    });

    StoreFailedBookingSync seam() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      return container.read(failedBookingSyncProvider)
          as StoreFailedBookingSync;
    }

    SyncOperation bookingCreate(
      String id, {
      int timestamp = 1,
      String service = 'Brake Inspection',
    }) => SyncOperation(
      id: id,
      entityType: 'booking',
      entityId: id,
      changeType: ChangeType.create,
      payload: {
        'vehicleId': 'v1',
        'vehicleName': 'Toyota Land Cruiser',
        'plateNumber': 'A 12345',
        'serviceType': service,
        'bookingDate': '22 Sep 2026',
        'bookingTime': '09:00 AM',
        'notes': 'Front pads',
      },
      timestamp: timestamp,
    );

    test('reads failed booking creates and ignores other operations', () async {
      final failed = Hive.box<SyncOperation>('sync_failed');
      await failed.put('bk1', bookingCreate('bk1'));
      await failed.put(
        'vk1',
        SyncOperation(
          id: 'vk1',
          entityType: 'vehicle',
          entityId: 'vk1',
          changeType: ChangeType.delete,
          payload: const {},
          timestamp: 2,
        ),
      );
      await failed.put(
        'bk2',
        SyncOperation(
          id: 'bk2',
          entityType: 'booking',
          entityId: 'bk2',
          changeType: ChangeType.delete,
          payload: const {},
          timestamp: 3,
        ),
      );

      final recovered = seam().failedBookings();

      expect(recovered.map((b) => b.operationId).toList(), ['bk1']);
      expect(recovered.single.vehicleName, 'Toyota Land Cruiser');
      expect(recovered.single.plateNumber, 'A 12345');
      expect(recovered.single.service, 'Brake Inspection');
      expect(recovered.single.date, '22 Sep 2026');
      expect(recovered.single.time, '09:00 AM');
    });

    test('supports multiple failed bookings, oldest first', () async {
      final failed = Hive.box<SyncOperation>('sync_failed');
      await failed.put('later', bookingCreate('later', timestamp: 20));
      await failed.put('earlier', bookingCreate('earlier', timestamp: 10));

      expect(seam().failedBookings().map((b) => b.operationId).toList(), [
        'earlier',
        'later',
      ]);
    });

    test('maps a failed operation to the cache identity of its booking', () {
      final booking = FailedBooking.fromOperation(bookingCreate('bk1'));
      expect(
        booking.identityKey,
        CustomerBookingsPresentation.bookingKey(
          vehicleName: 'Toyota Land Cruiser',
          plateNumber: 'A 12345',
          service: 'Brake Inspection',
          date: '22 Sep 2026',
          time: '09:00 AM',
        ),
      );
    });

    test(
      'remove clears only the targeted booking and never a server record',
      () async {
        final failed = Hive.box<SyncOperation>('sync_failed');
        final queue = Hive.box<SyncOperation>('sync_queue');
        final cache = Hive.box<dynamic>('customer_cache');
        await failed.put('bk1', bookingCreate('bk1'));
        await failed.put(
          'bk2',
          bookingCreate('bk2', timestamp: 5, service: 'Tyre Rotation'),
        );
        await queue.put('bk1', bookingCreate('bk1'));
        await cache.put('booking_bk1', {'status': 'pending'});
        await cache.put('cached_bookings', [
          {
            'serviceType': 'Brake Inspection',
            'vehicleName': 'Toyota Land Cruiser',
            'plateNumber': 'A 12345',
            'bookingDate': '22 Sep 2026',
            'time': '09:00 AM',
            'status': 'pending',
          },
          {
            'serviceType': 'Oil Change',
            'vehicleName': 'Honda Civic',
            'plateNumber': 'B 99999',
            'bookingDate': '1 Jan 2026',
            'time': '10:00 AM',
            'bookingRef': 'BK-2026-0001',
          },
        ]);

        await seam().remove('bk1');

        expect(failed.containsKey('bk1'), isFalse);
        expect(
          failed.containsKey('bk2'),
          isTrue,
          reason: 'the other failure is untouched',
        );
        expect(queue.containsKey('bk1'), isFalse);
        expect(cache.containsKey('booking_bk1'), isFalse);
        final cached = (cache.get('cached_bookings') as List).cast<Map>();
        expect(cached.length, 1);
        expect(cached.single['bookingRef'], 'BK-2026-0001');
      },
    );

    test('recovered state is durable across a fresh read', () async {
      await Hive.box<SyncOperation>(
        'sync_failed',
      ).put('bk1', bookingCreate('bk1'));
      // A new reader over the same persistent box sees the same recovery state.
      expect(seam().failedBookings().single.operationId, 'bk1');
    });
  });

  group('Bookings failed-local recovery', () {
    testWidgets('a queued local booking is not a terminal failure', (
      tester,
    ) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const []),
        bookings: const [_localPending],
      );

      expect(find.text('NOT SENT'), findsNothing);
      expect(find.text('Needs attention'), findsNothing);
      expect(find.text('Brake Inspection'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets(
      'a terminal failure shows Not sent and the workshop non-receipt',
      (tester) async {
        await _pump(
          tester,
          failed: _FakeFailedBookingSync(const [_failedSync]),
          bookings: const [_localPending],
        );

        expect(find.text('NOT SENT'), findsOneWidget);
        expect(find.text('Needs attention'), findsOneWidget);
        expect(
          find.text("We couldn't send this booking to the workshop."),
          findsOneWidget,
        );
        expect(find.text("The workshop hasn't received it."), findsOneWidget);
        expect(find.text('Toyota Land Cruiser'), findsOneWidget);
        expect(find.text('A 12345'), findsOneWidget);
      },
    );

    testWidgets('the failed booking is excluded from workshop lifecycle counts', (
      tester,
    ) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending, _confirmed],
      );

      // Only the real server booking is counted; the failed one is not requested.
      expect(find.textContaining('1 upcoming'), findsOneWidget);
      expect(find.text('NOT SENT'), findsOneWidget);
    });

    testWidgets('marks the failure as a live region for assistive tech', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending],
      );

      final node = tester.getSemantics(find.byType(CustomerFailedBookingItem));
      expect(node.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets(
      'Retry targets the correct operation and never re-creates a booking',
      (tester) async {
        final fake = _FakeFailedBookingSync(const [_failedSync]);
        await _pump(tester, failed: fake, bookings: const [_localPending]);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(fake.retriedIds, [_failedSync.operationId]);
        expect(find.text('NOT SENT'), findsNothing);
      },
    );

    testWidgets('Retry refreshes canonical bookings into the workshop feed', (
      tester,
    ) async {
      final fake = _FakeFailedBookingSync(const [_failedSync]);
      var remote = <CustomerBookingEntity>[_localPending];
      await _pump(
        tester,
        failed: fake,
        bookingsLoader: () async => List.of(remote),
      );

      // The workshop now returns the booking it accepted.
      remote = const [_serverAccepted];
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('NOT SENT'), findsNothing);
      expect(find.text('CONFIRMED'), findsOneWidget);
    });

    testWidgets(
      'a failed refresh after a successful replay never restores Not sent',
      (tester) async {
        final fake = _FakeFailedBookingSync(const [_failedSync]);
        var failRefresh = false;
        await _pump(
          tester,
          failed: fake,
          bookingsLoader: () async {
            if (failRefresh) throw Exception('offline');
            return const [_localPending];
          },
        );

        failRefresh = true;
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // The operation reached the workshop: the terminal state is gone and never
        // comes back even though the follow-up refresh failed.
        expect(find.text('NOT SENT'), findsNothing);
      },
    );

    testWidgets('a failed Retry keeps the recovery state and its actions', (
      tester,
    ) async {
      final fake = _FakeFailedBookingSync(const [
        _failedSync,
      ], retryResult: false);
      await _pump(tester, failed: fake, bookings: const [_localPending]);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('NOT SENT'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
      expect(
        find.text("We couldn't send this booking. Please try again."),
        findsOneWidget,
      );
    });

    testWidgets('duplicate Retry taps cannot replay the same operation twice', (
      tester,
    ) async {
      final fake = _FakeFailedBookingSync(const [
        _failedSync,
      ], retryCompleter: Completer<bool>());
      await _pump(tester, failed: fake, bookings: const [_localPending]);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text('Retrying\u2026'), findsOneWidget);
      await tester.tap(find.text('Retrying\u2026'), warnIfMissed: false);
      await tester.pump();

      expect(fake.retriedIds.length, 1);
      fake.retryCompleter!.complete(false);
      await tester.pumpAndSettle();
    });

    testWidgets(
      'removing a failed booking asks for confirmation and can be cancelled',
      (tester) async {
        final fake = _FakeFailedBookingSync(const [_failedSync]);
        await _pump(tester, failed: fake, bookings: const [_localPending]);

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        expect(find.text('Remove saved booking?'), findsOneWidget);
        expect(
          find.text(
            'This removes the booking stored on this device. The workshop has '
            'not received it.',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Keep booking'));
        await tester.pumpAndSettle();

        expect(fake.removedIds, isEmpty);
        expect(find.text('NOT SENT'), findsOneWidget);
      },
    );

    testWidgets('confirming Remove clears only that failed booking', (
      tester,
    ) async {
      final fake = _FakeFailedBookingSync(const [_failedSync, _secondFailed]);
      await _pump(
        tester,
        failed: fake,
        bookings: const [_localPending, _secondLocalPending],
      );

      // Both failures are recoverable on their own.
      expect(find.text('NOT SENT'), findsNWidgets(2));

      await tester.tap(find.text('Remove').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove booking'));
      await tester.pumpAndSettle();

      expect(fake.removedIds, [_failedSync.operationId]);
      expect(find.text('Tyre Rotation'), findsOneWidget);
      expect(find.text('NOT SENT'), findsOneWidget);
    });

    testWidgets('never exposes technical sync terminology', (tester) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending],
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final forbidden in const [
        'sync',
        'queue',
        'operation',
        'hive',
        'http',
        'offline engine',
        'retry count',
      ]) {
        expect(
          texts.contains(forbidden),
          isFalse,
          reason: 'must not show "$forbidden"',
        );
      }
    });

    testWidgets('the failed state stays overflow-free on the smallest phone', (
      tester,
    ) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending],
        size: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('NOT SENT'), findsOneWidget);
    });

    testWidgets('the failed state survives an increased text scale', (
      tester,
    ) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_verboseFailed]),
        bookings: const [_verboseLocalPending],
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('NOT SENT'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('the failed state renders in dark theme', (tester) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending],
        theme: AppTheme.dark(BrandConfig.orient),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('NOT SENT'), findsOneWidget);
    });

    testWidgets('failed-sync mobile golden', (tester) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending, _confirmed],
      );
      await expectLater(
        find.byType(CustomerBookingsTab),
        matchesGoldenFile('goldens/customer_bookings_failed_sync_mobile.png'),
      );
    });

    testWidgets('failed-sync dark golden', (tester) async {
      await _pump(
        tester,
        failed: _FakeFailedBookingSync(const [_failedSync]),
        bookings: const [_localPending, _confirmed],
        theme: AppTheme.dark(BrandConfig.orient),
      );
      await expectLater(
        find.byType(CustomerBookingsTab),
        matchesGoldenFile('goldens/customer_bookings_failed_sync_dark.png'),
      );
    });
  });
}

// ---------- Fixtures (real entity shapes only) ----------

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

const _failedSync = FailedBooking(
  operationId: '1723456789000',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  service: 'Brake Inspection',
  date: '22 Sep 2026',
  time: '09:00 AM',
  notes: '',
);

const _secondFailed = FailedBooking(
  operationId: '1723456799000',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  service: 'Tyre Rotation',
  date: '2 Oct 2026',
  time: '02:00 PM',
  notes: '',
);

const _verboseFailed = FailedBooking(
  operationId: '1723456800000',
  vehicleName: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  service:
      'Comprehensive Annual Service, Wheel Alignment and Air Conditioning '
      'System Inspection',
  date: '20 Sep 2026',
  time: '09:00 AM',
  notes: '',
);

const _localPending = CustomerBookingEntity(
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.pending,
);

const _secondLocalPending = CustomerBookingEntity(
  service: 'Tyre Rotation',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '2 Oct 2026',
  time: '02:00 PM',
  status: BookingStatus.pending,
);

const _verboseLocalPending = CustomerBookingEntity(
  service:
      'Comprehensive Annual Service, Wheel Alignment and Air Conditioning '
      'System Inspection',
  vehicleName: 'Mercedes-Benz GLE 450 4MATIC AMG Line',
  plateNumber: 'DUBAI A 99441',
  date: '20 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.pending,
);

const _confirmed = CustomerBookingEntity(
  id: 'b-confirmed',
  service: 'Oil & Filter Change',
  vehicleName: 'Honda Civic',
  plateNumber: 'B 99999',
  date: '1 Oct 2026',
  time: '10:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0001',
);

const _serverAccepted = CustomerBookingEntity(
  id: 'b-accepted',
  service: 'Brake Inspection',
  vehicleName: 'Toyota Land Cruiser',
  plateNumber: 'A 12345',
  date: '22 Sep 2026',
  time: '09:00 AM',
  status: BookingStatus.confirmed,
  bookingRef: 'BK-2026-0188',
);

// ---------- Harness ----------

class _FakeFailedBookingSync implements FailedBookingSync {
  _FakeFailedBookingSync(
    this._bookings, {
    this.retryResult = true,
    this.retryCompleter,
  });

  List<FailedBooking> _bookings;
  final bool retryResult;

  /// When set, a retry waits on this instead of completing immediately.
  final Completer<bool>? retryCompleter;

  final List<String> retriedIds = [];
  final List<String> removedIds = [];

  @override
  List<FailedBooking> failedBookings() => List.of(_bookings);

  @override
  Future<bool> retry(String operationId) async {
    retriedIds.add(operationId);
    final accepted = retryCompleter != null
        ? await retryCompleter!.future
        : retryResult;
    if (accepted) {
      _bookings = _bookings
          .where((booking) => booking.operationId != operationId)
          .toList();
    }
    return accepted;
  }

  @override
  Future<void> remove(String operationId) async {
    removedIds.add(operationId);
    _bookings = _bookings
        .where((booking) => booking.operationId != operationId)
        .toList();
  }
}

class _FakeDashboardNotifier extends CustomerDashboardNotifier {
  _FakeDashboardNotifier(this._initial);

  final CustomerDashboardState _initial;
  int refreshCount = 0;

  @override
  CustomerDashboardState build() => _initial;

  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

Future<_FakeDashboardNotifier> _pump(
  WidgetTester tester, {
  required FailedBookingSync failed,
  List<CustomerBookingEntity> bookings = const [],
  Future<List<CustomerBookingEntity>> Function()? bookingsLoader,
  Size size = const Size(390, 844),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final notifier = _FakeDashboardNotifier(
    const CustomerDashboardState(
      selectedIndex: 1,
      isLoading: false,
      selectedVehicle: '',
      selectedServiceType: '',
      bookingNotes: '',
      vehicles: [_vehicle],
      notifications: [],
      profile: CustomerEntity(
        name: 'Ahmed Al Mansoori',
        firstName: 'Ahmed',
        avatarInitials: 'AM',
        memberId: 'CUS-1042',
      ),
    ),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customerDashboardProvider.overrideWith(() => notifier),
        failedBookingSyncProvider.overrideWithValue(failed),
        customerBookingsProvider.overrideWith(
          (ref) async => bookingsLoader != null
              ? await bookingsLoader()
              : List.of(bookings),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme ?? AppTheme.light(BrandConfig.orient),
        home: Scaffold(body: CustomerBookingsTab()),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return notifier;
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
