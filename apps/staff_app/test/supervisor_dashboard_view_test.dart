// Characterization baseline for the supervisor floor board (phase 5).
//
// Behavior pins against the CURRENT floor UI. These tests assert behavior
// only (bay codes/counts, copy, filter predicate, error/empty affordances,
// selection -> assign callbacks) — never legacy widget types — so they stay
// green across the App* recomposition and become the migration baseline.
// Do NOT modify these tests after the recomposition (see
// docs/ui-redesign/evaluation/supervisor-home-test-migration.md).

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
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ---------------------------------------------------------------- fixtures

const _occupiedJob = SupervisorAssignedJob(
  jobCard: 'JC-101',
  customer: 'Ahmed',
  vehicle: 'Camry ABC 1234',
  dateAssigned: '2026-10-20',
  done: 2,
  total: 5,
  status: 'In Progress',
);

const _partsJob = SupervisorAssignedJob(
  jobCard: 'JC-900',
  customer: 'Khalid',
  vehicle: 'Hilux XYZ 1111',
  dateAssigned: '2026-10-19',
  done: 1,
  total: 4,
  status: 'Waiting for Parts',
);

const _qcAwaiting = AwaitingCompletionResponse(
  jobCardId: 7,
  jobCardRef: 'JC-207',
  customerName: 'Layla',
  vehicleInfo: 'Yaris XYZ 5678',
  technician: 'Omar Haddad',
  done: 4,
  total: 4,
  updatedAt: '2026-10-20 14:00',
);

const _booking = BookingQueueResponse(
  id: 3,
  bookingRef: 'BK-301',
  customerName: 'Sara',
  vehicleName: 'Civic',
  plateNumber: 'DEF 9012',
  serviceType: 'Oil change',
  bookingDate: '2026-10-21 10:00',
);

const _breakdown = BreakdownQueueResponse(
  id: 5,
  customerName: 'Nasser',
  issue: 'Engine overheating',
  vehicleName: 'Patrol',
  vehiclePlate: 'GHI 3456',
  location: 'Highway 40 km 12',
);

/// Deterministic floor: 1 QC + 1 occupied job + 1 parts job + 1 booking =
/// 4 active bays, 12 idle bays, 1 breakdown in the rail.
class _FloorData {
  const _FloorData({
    this.jobs = const [_occupiedJob, _partsJob],
    this.awaiting = const [_qcAwaiting],
    this.bookings = const [_booking],
    this.breakdowns = const [_breakdown],
    this.fail = false,
    this.hang = false,
  });

  final List<SupervisorAssignedJob> jobs;
  final List<AwaitingCompletionResponse> awaiting;
  final List<BookingQueueResponse> bookings;
  final List<BreakdownQueueResponse> breakdowns;
  final bool fail;
  final bool hang;
}

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  _FakeSupervisorRemote(this.data);

  final _FloorData data;

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
      _maybeHang(data.jobs);
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() =>
      _maybeHang(data.bookings);
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() =>
      _maybeHang(data.breakdowns);
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() =>
      _maybeHang(const []);
  @override
  Future<bool> assignBooking(int id, int advisorId) async => true;
  @override
  Future<bool> assignBreakdown(int id, int advisorId) async => true;
  @override
  Future<List<AwaitingCompletionResponse>> getAwaitingCompletions() =>
      _maybeHang(data.awaiting);
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

Future<void> _pumpFloor(
  WidgetTester tester, {
  _FloorData data = const _FloorData(),
  void Function()? onOpenAssign,
  void Function()? onOpenQueue,
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
        home: Scaffold(
          body: SupervisorDashboardTab(
            onOpenAssign: onOpenAssign ?? () {},
            onOpenQueue: onOpenQueue ?? () {},
            onOpenReview: onOpenReview ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

/// Taps a filter chip inside the shared filter bar (the legend repeats the
/// same labels, so the bar scope keeps the finder unambiguous).
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

  testWidgets('board renders 16 bays with mixed states and occupancy', (
    tester,
  ) async {
    await _pumpFloor(tester);

    // All 16 spatial tiles mount, first and last bay codes bound the board.
    expect(find.text('B-01'), findsOneWidget);
    expect(find.text('B-16'), findsOneWidget);
    // Occupancy sentence: 2 jobs + 1 booking + 1 awaiting = 4 active.
    expect(find.textContaining('4 active'), findsOneWidget);
    expect(find.textContaining('16 bays'), findsOneWidget);
    // Every placed record is identifiable by its real ref.
    expect(find.text('JC-207'), findsOneWidget);
    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-900'), findsOneWidget);
    expect(find.text('BK-301'), findsOneWidget);
    // No error affordance on the happy path.
    expect(
      find.text('Could not load the floor. Pull to refresh.'),
      findsNothing,
    );
  });

  testWidgets('bay-state filter keeps the same predicate', (tester) async {
    await _pumpFloor(tester);

    await _tapFilter(tester, 'Parts delay');

    // Only the waiting-for-parts bay survives the filter.
    expect(find.text('JC-900'), findsOneWidget);
    expect(find.text('JC-101'), findsNothing);
    expect(find.text('JC-207'), findsNothing);

    await _tapFilter(tester, 'All');

    expect(find.text('JC-900'), findsOneWidget);
    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-207'), findsOneWidget);
  });

  testWidgets('filter with no matches offers a clear action', (tester) async {
    await _pumpFloor(
      tester,
      data: const _FloorData(awaiting: [], breakdowns: []),
    );

    await _tapFilter(tester, 'QC');

    // AppEmptyState wraps copy in invisible bidi isolates, so the
    // rendering-identical assertion matches by containment.
    expect(find.textContaining('No bays match this filter'), findsOneWidget);
    expect(find.text('Clear'), findsWidgets);

    // Either clear action resets the predicate; the filter bar's stays
    // on screen in both layouts, so it is the stable tap target.
    final clear = find.descendant(
      of: find.byType(AppFilterBar),
      matching: find.text('Clear'),
    );
    expect(clear, findsOneWidget);
    await tester.ensureVisible(clear);
    await tester.tap(clear);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('JC-101'), findsOneWidget);
  });

  testWidgets('bay tap opens the assign entry and selects the bay', (
    tester,
  ) async {
    var assignCalls = 0;
    await _pumpFloor(tester, onOpenAssign: () => assignCalls++);

    await tester.tap(find.text('JC-101'));
    await tester.pump();

    // One tap, assign sheet entry requested once.
    expect(assignCalls, 1);
    // Selection surfaces the dispatch action for the chosen bay.
    expect(find.text('Dispatch to technician'), findsWidgets);

    // The surfaced dispatch action reuses the same assign entry.
    await tester.tap(find.text('Dispatch to technician').first);
    await tester.pump();
    expect(assignCalls, 2);
  });

  testWidgets('rail actions reach queue and review destinations', (
    tester,
  ) async {
    var queueCalls = 0;
    var reviewCalls = 0;
    await _pumpFloor(
      tester,
      onOpenQueue: () => queueCalls++,
      onOpenReview: () => reviewCalls++,
    );

    // Rail rows forward to the queue destination.
    final row = find.text('Engine overheating');
    expect(row, findsOneWidget);
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pump();
    expect(queueCalls, 1);

    // Review CTA forwards to the review destination.
    final review = find.text('Review');
    expect(review, findsOneWidget);
    await tester.ensureVisible(review);
    await tester.tap(review);
    await tester.pump();
    expect(reviewCalls, 1);
  });

  testWidgets('loading shows no bays and no error', (tester) async {
    await _pumpFloor(tester, data: const _FloorData(hang: true));

    expect(find.text('B-01'), findsNothing);
    expect(
      find.text('Could not load the floor. Pull to refresh.'),
      findsNothing,
    );
  });

  testWidgets('load failure shows the error with a retry action', (
    tester,
  ) async {
    await _pumpFloor(tester, data: const _FloorData(fail: true));

    // AppErrorState wraps copy in invisible bidi isolates, so the
    // rendering-identical assertions match by containment.
    expect(
      find.textContaining('Could not load the floor. Pull to refresh.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    // Retry re-runs the load (still failing here) without crashing.
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('Could not load the floor. Pull to refresh.'),
      findsOneWidget,
    );
  });

  testWidgets('empty floor shows the clear queue and no error', (tester) async {
    await _pumpFloor(
      tester,
      data: const _FloorData(
        jobs: [],
        awaiting: [],
        bookings: [],
        breakdowns: [],
      ),
    );

    expect(find.text('The queue is clear'), findsOneWidget);
    expect(
      find.text('Could not load the floor. Pull to refresh.'),
      findsNothing,
    );
    // Nothing active on the occupancy sentence.
    expect(find.textContaining('0 active'), findsOneWidget);
  });
}
