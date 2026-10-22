// Characterization baseline for the supervisor Review list tab (GROUP-C list-ops).
//
// Behavior pins against the CURRENT Review UI. These tests assert behavior
// only (header copy, progress math, row copy, checklist-sheet entry, provider
// quirk, empty/error/loading affordances) — never legacy widget types — so
// they stay green across the App* recomposition and become the migration
// baseline. Do NOT modify these tests after the recomposition (see
// docs/ui-redesign/evaluation/supervisor-review-list-test-migration.md).

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
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_review_tab.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ---------------------------------------------------------------- fixtures

const _qcOne = AwaitingCompletionResponse(
  jobCardId: 7,
  jobCardRef: 'JC-207',
  customerName: 'Layla',
  vehicleInfo: 'Yaris XYZ 5678',
  technician: 'Omar Haddad',
  done: 4,
  total: 4,
  updatedAt: '2026-10-20 14:00',
  items: [WorkItemDetail(id: 1, description: 'Change engine oil')],
);

const _qcTwo = AwaitingCompletionResponse(
  jobCardId: 8,
  jobCardRef: 'JC-208',
  customerName: 'Ahmed',
  vehicleInfo: 'Camry ABC 1234',
  technician: 'Sara Ali',
  done: 3,
  total: 5,
  updatedAt: '2026-10-20 15:00',
  items: [WorkItemDetail(id: 2, description: 'Replace brake pads')],
);

class _ReviewData {
  const _ReviewData({
    this.awaiting = const [_qcOne, _qcTwo],
    this.fail = false,
    this.hang = false,
  });

  final List<AwaitingCompletionResponse> awaiting;
  final bool fail;
  final bool hang;
}

class _FakeSupervisorRemote implements SupervisorRemoteDataSource {
  _FakeSupervisorRemote(this.data);

  final _ReviewData data;

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
      _maybeHang(const <SupervisorAssignedJob>[]);
  @override
  Future<List<BookingQueueResponse>> getBookingQueue() =>
      _maybeHang(const []);
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
      // Growable copy: production parses growable lists; const lists would
      // throw on any notifier-side removeWhere where production never does.
      _maybeHang(List.of(data.awaiting));
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

Future<void> _pumpReview(
  WidgetTester tester, {
  _ReviewData data = const _ReviewData(),
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
        home: const Scaffold(body: SupervisorReviewTab()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  testWidgets('header shows title, subtitle and refresh', (tester) async {
    await _pumpReview(tester);

    expect(find.text('Quality control'), findsOneWidget);
    expect(
      find.text('Verify completed repairs before delivery'),
      findsOneWidget,
    );
    expect(find.byTooltip('Retry'), findsOneWidget);
  });

  testWidgets('rows render ref, identity, progress and start action', (
    tester,
  ) async {
    await _pumpReview(tester);

    expect(find.text('JC-207'), findsOneWidget);
    expect(find.text('JC-208'), findsOneWidget);
    // Identity line is customer + vehicle verbatim.
    expect(find.textContaining('Layla'), findsOneWidget);
    expect(find.textContaining('Yaris XYZ 5678'), findsOneWidget);
    // Progress math is done/total verbatim.
    expect(find.text('4/4 done'), findsOneWidget);
    expect(find.text('3/5 done'), findsOneWidget);
    // Every awaiting row carries its own Start QC (frequent action on card).
    expect(find.text('Start QC'), findsWidgets);
  });

  testWidgets('start opens the qc checklist sheet for the job', (tester) async {
    await _pumpReview(tester);

    await tester.tap(find.text('Start QC').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Quality control review'), findsOneWidget);
    expect(find.text('JC-207'), findsWidgets);
  });

  testWidgets('empty review shows the clear state with no action', (
    tester,
  ) async {
    await _pumpReview(tester, data: const _ReviewData(awaiting: []));

    // State copy is matched by containment: the recomposed atoms bidi-isolate
    // title + message (invisible), green on the current UI and the new atoms.
    expect(find.textContaining('Nothing awaiting sign-off'), findsOneWidget);
    expect(
      find.textContaining('Completed repairs appear here'),
      findsOneWidget,
    );
    // Honest empty: nothing to create here, so no Start QC anywhere.
    expect(find.text('Start QC'), findsNothing);
  });

  testWidgets('review refresh failure shows the error with retry', (
    tester,
  ) async {
    // First load surfaces the empty state (provider-owned: only refreshReview
    // writes reviewError/isReviewLoading — untouched); the error path below
    // is the refresh-driven one the tab actually owns.
    await _pumpReview(tester, data: const _ReviewData(fail: true));
    expect(find.textContaining('Nothing awaiting sign-off'), findsOneWidget);

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Could not load QC work.'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('JC-207'), findsNothing);
  });

  testWidgets('review refresh loading shows no rows and no error', (
    tester,
  ) async {
    await _pumpReview(tester, data: const _ReviewData(hang: true));

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('JC-207'), findsNothing);
    expect(find.textContaining('Could not load QC work.'), findsNothing);
    expect(find.textContaining('Nothing awaiting sign-off'), findsNothing);
  });
}
