// Characterization baseline for the supervisor Jobs list tab (GROUP-C list-ops).
//
// Behavior pins against the CURRENT Jobs tab UI. These tests assert behavior
// only (header copy + count, search predicate, status-bucket filter, progress
// math, empty/no-match/error/loading affordances, assign callbacks) — never
// legacy widget types — so they stay green across the App* recomposition and
// become the migration baseline. Do NOT modify these tests after the
// recomposition (see docs/ui-redesign/evaluation/supervisor-jobs-list-test-migration.md).

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
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ---------------------------------------------------------------- fixtures

const _runningJob = SupervisorAssignedJob(
  jobCard: 'JC-101',
  customer: 'Ahmed',
  vehicle: 'Camry ABC 1234',
  dateAssigned: '2026-10-20',
  done: 2,
  total: 5,
  status: 'In Progress',
);

const _doneJob = SupervisorAssignedJob(
  jobCard: 'JC-102',
  customer: 'Sara',
  vehicle: 'Civic DEF 9012',
  dateAssigned: '2026-10-19',
  done: 4,
  total: 4,
  status: 'Completed',
);

const _partsJob = SupervisorAssignedJob(
  jobCard: 'JC-900',
  customer: 'Khalid',
  vehicle: 'Hilux XYZ 1111',
  dateAssigned: '2026-10-18',
  done: 1,
  total: 4,
  status: 'Waiting for Parts',
);

class _JobsData {
  const _JobsData({
    this.jobs = const [_runningJob, _doneJob, _partsJob],
    this.fail = false,
    this.hang = false,
  });

  final List<SupervisorAssignedJob> jobs;
  final bool fail;
  final bool hang;
}

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  _FakeSupervisorRemote(this.data);

  final _JobsData data;

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
      // Growable copy: production parses growable lists; const lists would
      // throw on any notifier-side removeWhere where production never does.
      _maybeHang(List.of(data.jobs));
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() => _maybeHang(const []);
  @override
  Future<List<BreakdownQueueResponse>> getBreakdownQueue() =>
      _maybeHang(const []);
  @override
  Future<List<AssignableStaffResponse>> getAssignableAdvisors() =>
      _maybeHang(const []);
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

Future<void> _pumpJobs(
  WidgetTester tester, {
  _JobsData data = const _JobsData(),
  void Function()? onOpenAssign,
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
          body: SupervisorJobsTab(onOpenAssign: onOpenAssign ?? () {}),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

Finder _searchBox() => find.descendant(
  of: find.byType(AppSearchField),
  matching: find.byType(TextField),
);

/// Taps a status chip inside the shared filter bar (the summary strip repeats
/// the same labels, so the bar scope keeps the finder unambiguous).
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
        .setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async => null,
        );
  });

  testWidgets('header shows title, live count and the assign action', (
    tester,
  ) async {
    var assigns = 0;
    await _pumpJobs(tester, onOpenAssign: () => assigns++);

    expect(find.text('Active jobs'), findsOneWidget);
    expect(find.text('3 on the floor'), findsOneWidget);
    expect(find.text('Assign work'), findsOneWidget);

    await tester.tap(find.text('Assign work'));
    await tester.pump();
    expect(assigns, 1);
  });

  testWidgets('rows render identity, progress math and status copy', (
    tester,
  ) async {
    await _pumpJobs(tester);

    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-900'), findsOneWidget);
    // Progress math is done/total verbatim.
    expect(find.text('2/5 tasks'), findsOneWidget);
    expect(find.text('4/4 tasks'), findsOneWidget);
    expect(find.text('1/4 tasks'), findsOneWidget);
  });

  testWidgets('inline search narrows by job card, customer, vehicle, status', (
    tester,
  ) async {
    await _pumpJobs(tester);

    await tester.enterText(_searchBox(), 'sara');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-101'), findsNothing);
    expect(find.text('JC-900'), findsNothing);

    await tester.enterText(_searchBox(), 'JC-900');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The query itself stays in the field, so the ref reads twice.
    expect(find.text('JC-900'), findsWidgets);
    expect(find.text('JC-101'), findsNothing);
  });

  testWidgets('status rail filters by bucket and re-tap clears', (
    tester,
  ) async {
    await _pumpJobs(tester);

    await _tapFilter(tester, 'Completed');
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-101'), findsNothing);
    expect(find.text('JC-900'), findsNothing);

    await _tapFilter(tester, 'Completed');
    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-900'), findsOneWidget);

    await _tapFilter(tester, 'Parts delay');
    expect(find.text('JC-900'), findsOneWidget);
    expect(find.text('JC-101'), findsNothing);
  });

  testWidgets('no match offers a clear action that resets the list', (
    tester,
  ) async {
    await _pumpJobs(tester);

    await tester.enterText(_searchBox(), 'zzz-no-such-job');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // AppEmptyState/AppErrorState/AppBanner bidi-isolate title + message
    // (U+2066..U+2069), so state copy is matched by containment: green on the
    // current EmptyState/AppInfoPanel UI and on the recomposed atoms.
    expect(find.textContaining('No matching jobs'), findsOneWidget);

    // The no-match panel's clear restores all three rows.
    final clears = find.textContaining('Clear');
    expect(clears, findsWidgets);
    await tester.tap(clears.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JC-101'), findsOneWidget);
    expect(find.text('JC-102'), findsOneWidget);
    expect(find.text('JC-900'), findsOneWidget);
  });

  testWidgets('empty register shows the empty state with assign', (
    tester,
  ) async {
    var assigns = 0;
    await _pumpJobs(
      tester,
      data: const _JobsData(jobs: []),
      onOpenAssign: () => assigns++,
    );

    expect(find.textContaining('No active jobs'), findsOneWidget);
    expect(find.textContaining('Assign work to see jobs'), findsOneWidget);
    // U6/C16 one-primary-CTA ("never both at once" per the brief): the header
    // Assign is suppressed on the confirmed-empty register, so the
    // empty-state action is the single Assign on screen (same sheet).
    expect(find.text('Assign work'), findsOneWidget);

    await tester.tap(find.text('Assign work'));
    await tester.pump();
    expect(assigns, 1);
  });

  testWidgets('first-load failure shows the error with retry', (tester) async {
    await _pumpJobs(tester, data: const _JobsData(fail: true));

    expect(find.textContaining('Could not load active jobs.'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('JC-101'), findsNothing);
  });

  testWidgets('loading shows no rows and no error', (tester) async {
    await _pumpJobs(tester, data: const _JobsData(hang: true));

    expect(find.text('JC-101'), findsNothing);
    expect(find.textContaining('Could not load active jobs.'), findsNothing);
    expect(find.textContaining('No active jobs'), findsNothing);
  });
}
