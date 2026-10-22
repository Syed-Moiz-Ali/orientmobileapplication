// Characterization baseline for the supervisor Queue list tab (GROUP-C list-ops).
//
// Behavior pins against the CURRENT Queue UI. These tests assert behavior
// only (header copy, priority sort, filter predicate, section counts, assign
// sheet + toast contracts, empty/no-match/error/loading affordances) — never
// legacy widget types — so they stay green across the App* recomposition and
// become the migration baseline. Do NOT modify these tests after the
// recomposition (see
// docs/ui-redesign/evaluation/supervisor-queue-list-test-migration.md).

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/data/datasources/supervisor_remote_datasource.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_queue_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ---------------------------------------------------------------- fixtures

const _vipBooking = BookingQueueResponse(
  id: 11,
  bookingRef: 'BK-301',
  customerName: 'Sara',
  vehicleName: 'Camry',
  plateNumber: 'ABC 1234',
  serviceType: 'VIP detailing',
  bookingDate: '2020-01-01 10:00',
);

const _normalBooking = BookingQueueResponse(
  id: 12,
  bookingRef: 'BK-302',
  customerName: 'Ahmed',
  vehicleName: 'Civic',
  plateNumber: 'DEF 9012',
  serviceType: 'Oil change',
  bookingDate: '2020-01-02 10:00',
);

const _insuranceBooking = BookingQueueResponse(
  id: 13,
  bookingRef: 'BK-303',
  customerName: 'Khalid',
  vehicleName: 'Hilux',
  plateNumber: 'XYZ 1111',
  serviceType: 'Insurance claim',
  bookingDate: '2020-01-03 10:00',
);

const _breakdown = BreakdownQueueResponse(
  id: 21,
  customerName: 'Nasser',
  issue: 'Engine overheating',
  vehicleName: 'Patrol',
  vehiclePlate: 'GHI 3456',
  location: 'Highway 40 km 12',
);

const _advisors = [
  AssignableStaffResponse(id: 31, name: 'Omar Haddad', role: 'Advisor'),
  AssignableStaffResponse(id: 32, name: 'Sara Ali', role: 'Advisor'),
];

class _QueueData {
  const _QueueData({
    this.bookings = const [_vipBooking, _normalBooking],
    this.breakdowns = const [_breakdown],
    this.advisors = _advisors,
    this.fail = false,
    this.hang = false,
  });

  final List<BookingQueueResponse> bookings;
  final List<BreakdownQueueResponse> breakdowns;
  final List<AssignableStaffResponse> advisors;
  final bool fail;
  final bool hang;
}

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  _FakeSupervisorRemote(this.data);

  final _QueueData data;

  Future<T> _maybeHang<T>(T value) async {
    if (data.fail) throw Exception('offline');
    if (data.hang) await Completer<void>().future;
    return value;
  }

  @override
  Future<List<KpiResponse>> getKpis() => _maybeHang(const []);
  @override
  Future<List<AdvisorJobCountResponse>> getAdvisorJobs() =>
      _maybeHang(const []);
  @override
  Future<List<JobTypeResponse>> getJobTypes() => _maybeHang(const []);
  @override
  Future<List<RevenueMetricResponse>> getRevenueMetrics() =>
      _maybeHang(const []);
  @override
  Future<List<PendingStatusResponse>> getPendingStatuses() =>
      _maybeHang(const []);
  @override
  Future<List<String>> getDepartments() => _maybeHang(const []);
  @override
  Future<List<String>> getTechnicians() => _maybeHang(const []);
  @override
  Future<List<SupervisorAssignedJob>> getAssignedJobs() =>
      // Growable copies: production parses growable lists and the notifier
      // mutates them in place (removeWhere on assign); const lists would throw
      // where production never does.
      _maybeHang(const <SupervisorAssignedJob>[]);
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() =>
      _maybeHang(List.of(data.bookings));
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() =>
      _maybeHang(List.of(data.breakdowns));
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() =>
      _maybeHang(List.of(data.advisors));
  @override
  Future<bool> assignBooking(int id, int advisorId) async => true;
  @override
  Future<bool> assignBreakdown(int id, int advisorId) async => true;
  @override
  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() =>
      _maybeHang(const []);
  @override
  Future<bool> approveCompletion(int jobCardId) async => true;
  @override
  Future<bool> rejectCompletion(int jobCardId, String reason) async => true;
  @override
  Future<bool> qcReview(
    String jobCardRef,
    String action, {
    bool checklistPassed = true,
    String notes = '',
    String rejectReason = '',
  }) async => true;
  @override
  Future<List<StaffNotificationResponse>> getStaffNotifications() =>
      _maybeHang(const []);
  @override
  Future<bool> markStaffNotificationRead(String id) async => true;
}

Future<void> _pumpQueue(
  WidgetTester tester, {
  _QueueData data = const _QueueData(),
  void Function()? onOpenReview,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supervisorRemoteDataSourceProvider.overrideWithValue(
          _FakeSupervisorRemote(data),
        ),
        connectivityStatusProvider.overrideWith(
          (ref) => Stream<ConnectivityResult>.value(ConnectivityResult.wifi),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          StaffLocalizations.delegate,
          SharedCoreLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(body: SupervisorQueueTab(onOpenReview: onOpenReview ?? () {})),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

/// Taps a priority chip inside the shared filter bar (the section labels
/// repeat count badges, so the bar scope keeps the finder unambiguous).
Future<void> _tapFilter(WidgetTester tester, String label) async {
  final chip = find.descendant(
    of: find.byType(AppFilterBar),
    matching: find.text(label),
  );
  expect(chip, findsOneWidget);
  await tester.tap(chip);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  testWidgets('header shows title, subtitle and refresh', (tester) async {
    await _pumpQueue(tester);

    expect(find.text('Incoming queue'), findsOneWidget);
    expect(
      find.text('Priority-sorted bookings and breakdowns'),
      findsOneWidget,
    );
    expect(find.byTooltip('Retry'), findsOneWidget);
  });

  testWidgets('sections render with counts, priority pills and vip-first order', (
    tester,
  ) async {
    await _pumpQueue(tester);

    expect(find.text('Breakdowns'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    // Priority pills come from real record text only (the VIP chip in the
    // filter rail is the second VIP on the tab).
    expect(find.text('VIP'), findsNWidgets(2));
    expect(find.text('Emergency'), findsOneWidget);
    // Every waiting row carries its own Assign (frequent action on the card).
    expect(find.text('Assign advisor'), findsWidgets);
    // VIP surfaces above normal (stable priority sort).
    final vipDy = tester.getCenter(find.text('Camry')).dy;
    final normalDy = tester.getCenter(find.text('Civic')).dy;
    expect(vipDy, lessThan(normalDy));
  });

  testWidgets('priority filter narrows bookings only, breakdowns stay', (
    tester,
  ) async {
    await _pumpQueue(tester);

    await _tapFilter(tester, 'VIP');

    expect(find.text('Camry'), findsOneWidget);
    expect(find.text('Civic'), findsNothing);
    // The filter never hides breakdowns.
    expect(find.text('Patrol'), findsOneWidget);

    await _tapFilter(tester, 'VIP');
    expect(find.text('Civic'), findsOneWidget);
  });

  testWidgets('insurance filter shows only insurance bookings', (
    tester,
  ) async {
    await _pumpQueue(
      tester,
      data: const _QueueData(
        bookings: [_vipBooking, _normalBooking, _insuranceBooking],
        breakdowns: [_breakdown],
      ),
    );

    await _tapFilter(tester, 'Insurance');

    expect(find.text('Hilux'), findsOneWidget);
    expect(find.text('Camry'), findsNothing);
    expect(find.text('Civic'), findsNothing);
    // The filter never hides breakdowns.
    expect(find.text('Patrol'), findsOneWidget);
  });

  testWidgets('assign with no advisors shows the guard toast, no sheet', (
    tester,
  ) async {
    await _pumpQueue(
      tester,
      data: const _QueueData(advisors: []),
    );

    await tester.tap(find.text('Assign advisor').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('No active advisors'), findsOneWidget);
    expect(find.text('Route to advisor'), findsNothing);
  });

  testWidgets('no match offers a clear action that resets the filter', (
    tester,
  ) async {
    await _pumpQueue(
      tester,
      data: const _QueueData(
        bookings: [_normalBooking],
        breakdowns: [],
      ),
    );

    await _tapFilter(tester, 'Insurance');

    // State copy is matched by containment: the recomposed atoms bidi-isolate
    // title + message (invisible), green on the current UI and the new atoms.
    expect(find.textContaining('No matching queue items'), findsOneWidget);

    final clears = find.textContaining('Clear');
    expect(clears, findsWidgets);
    await tester.tap(clears.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Civic'), findsOneWidget);
  });

  testWidgets('assign opens the advisor picker and confirms with a toast', (
    tester,
  ) async {
    await _pumpQueue(tester);

    // The breakdown row carries the first Assign on the tab.
    await tester.tap(find.text('Assign advisor').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Route to advisor'), findsOneWidget);
    expect(find.text('Omar Haddad'), findsOneWidget);

    // The sheet confirm is the later Assign in the tree (overlay on top).
    await tester.tap(find.text('Assign advisor').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Breakdown dispatched'), findsOneWidget);
  });

  testWidgets('empty queue shows the clear state with no action', (
    tester,
  ) async {
    await _pumpQueue(
      tester,
      data: const _QueueData(bookings: [], breakdowns: []),
    );

    expect(find.textContaining('The queue is clear'), findsOneWidget);
    expect(
      find.textContaining('No bookings or breakdowns waiting.'),
      findsOneWidget,
    );
    // Honest empty: nothing to create here, so no Assign anywhere.
    expect(find.text('Assign advisor'), findsNothing);
  });

  testWidgets('queue refresh failure shows the error with retry', (
    tester,
  ) async {
    // First load surfaces the empty state (provider-owned: only refreshQueue
    // writes queueError/isQueueLoading — untouched); the error path below is
    // the refresh-driven one the tab actually owns.
    await _pumpQueue(tester, data: const _QueueData(fail: true));
    expect(find.textContaining('The queue is clear'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.textContaining('Could not refresh the dispatch queue.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('Camry'), findsNothing);
  });

  testWidgets('queue refresh loading shows no rows and no error', (
    tester,
  ) async {
    await _pumpQueue(tester, data: const _QueueData(hang: true));

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Camry'), findsNothing);
    expect(
      find.textContaining('Could not refresh the dispatch queue.'),
      findsNothing,
    );
    expect(find.textContaining('The queue is clear'), findsNothing);
  });
}
