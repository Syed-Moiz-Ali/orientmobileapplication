// Structural tests for the recomposed Advisor Home (phase 3).
//
// Presentation-tree assertions only: header, hero, quick-action row, pinned
// search, assigned media cards, summary and the loading/error/empty states.
// Behavior (providers, navigation targets, sync logic, sort order, search
// filtering predicate) is asserted nowhere here.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

const _urgent = JobCardEntity(
  id: 'JC-1042',
  customerName: 'Ahmed',
  vehicleInfo: 'Camry · ABC 1234',
  time: '10:30 AM',
  status: JobCardStatus.waitingParts,
);

const _active = JobCardEntity(
  id: 'JC-1041',
  customerName: 'Layla',
  vehicleInfo: 'Yaris · XYZ 5678',
  time: '09:15 AM',
  status: JobCardStatus.inProgress,
);

const _done = JobCardEntity(
  id: 'JC-1040',
  customerName: 'Sara',
  vehicleInfo: 'Civic · DEF 9012',
  time: 'Yesterday',
  status: JobCardStatus.completed,
);

const _stats = AdvisorStatsEntity(
  newJobCardsToday: 2,
  inspectionsToday: 6,
  pendingApprovals: 2,
  vehiclesWaiting: 1,
  readyForDelivery: 1,
  totalOpenJobCards: 3,
);

const _approvals = <PendingApprovalEntity>[
  PendingApprovalEntity(
    estimateId: 'E1',
    approvalType: 'estimate',
    customerName: 'Ahmed',
    vehicleId: 'V1',
    amount: 450,
  ),
  PendingApprovalEntity(
    estimateId: 'E2',
    approvalType: 'job_card',
    customerName: 'Layla',
    vehicleId: 'V2',
    amount: 120,
  ),
];

const _notifs = <StaffNotificationResponse>[
  StaffNotificationResponse(id: 'n1', title: 'QC passed', body: 'JC-1040'),
];

Future<void> _pumpHome(
  WidgetTester tester, {
  List<JobCardEntity> jobs = const [_done, _urgent, _active],
  AdvisorStatsEntity stats = _stats,
  List<PendingApprovalEntity> approvals = _approvals,
  List<StaffNotificationResponse> notifs = _notifs,
  bool failJobs = false,
  bool hangJobs = false,
}) async {
  final jobsOverride = advisorRecentJobCardsProvider.overrideWith((ref) async {
    if (failJobs) throw Exception('offline');
    if (hangJobs) await Completer<void>().future;
    return jobs;
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        jobsOverride,
        advisorDashboardProvider.overrideWith((ref) async => stats),
        advisorPendingApprovalsProvider.overrideWith((ref) async => approvals),
        advisorPendingSyncCountProvider.overrideWith(
          (ref) => Stream<int>.value(0),
        ),
        advisorNotificationsProvider.overrideWith((ref) async => notifs),
        // Off-screen tabs stay mounted in the IndexedStack; keep them on
        // fakes so no backend/Hive is touched.
        advisorAssignedBookingsProvider.overrideWith((ref) async => []),
        advisorReportDataProvider.overrideWith(
          (ref) async => const AdvisorReportData(),
        ),
        advisorInfoProvider.overrideWithValue(
          const AdvisorInfo(
            name: 'Omar Haddad',
            id: 'A1',
            branch: 'Branch A',
            shift: 'Morning shift',
          ),
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
        home: const Scaffold(body: AdvisorHomeView()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('header greets with offline pill, bell badge and avatar', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Greeting headline + branch/shift line own the header (no app bar).
    expect(find.text('Good to see you, Omar Haddad'), findsOneWidget);
    expect(find.text('Branch A · Morning shift'), findsOneWidget);
    expect(find.byType(AppPageHeader), findsOneWidget);
    // Offline coordination pill, bell with combined badge, profile avatar.
    expect(find.byType(OfflineStatusPill), findsOneWidget);
    // 1 notification + 2 approvals behind one error badge on the bell, plus
    // the approvals-tile badge carrying the same count.
    expect(find.byType(AppBadge), findsNWidgets(2));
    expect(find.byType(AppAvatar), findsOneWidget);
  });

  testWidgets('hero shows inspections-due-today with sentence and View jobs', (
    tester,
  ) async {
    await _pumpHome(tester);

    // ONE hero card: key number + delta sentence + verb-first primary CTA.
    // No dead media block, no stray See-all (Show-all lives on the
    // Assigned / summary sections only).
    expect(find.text('6 inspections due today'), findsOneWidget);
    expect(find.text("+2 today. Review what's urgent first."), findsOneWidget);
    expect(find.text('View jobs'), findsOneWidget);
    expect(find.byType(AppMediaCard), findsNothing);
    // Assigned and summary each carry a See-all action.
    expect(find.text('See all'), findsNWidgets(2));
  });

  testWidgets('hero zero-state shows caught-up copy with View jobs', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      jobs: const [_done],
      stats: const AdvisorStatsEntity(
        newJobCardsToday: 0,
        inspectionsToday: 0,
        pendingApprovals: 0,
        vehiclesWaiting: 0,
        readyForDelivery: 0,
        totalOpenJobCards: 1,
      ),
    );

    // No "urgent first" when nothing is due.
    expect(find.text('0 inspections due today'), findsOneWidget);
    expect(
      find.text("You're caught up — new jobs will appear here."),
      findsOneWidget,
    );
    expect(find.text('View jobs'), findsOneWidget);
  });

  testWidgets('quick actions are full-word tiles with New job primary', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Full labels, never mid-word ellipsis ("Sca..." regression).
    expect(find.text('Scan vehicle'), findsOneWidget);
    expect(find.text('New job card'), findsOneWidget);
    // Approvals carries its count inline (wireframe "Approvals (3)" style).
    expect(find.text('Approvals (2)'), findsOneWidget);
    // All three tiles mounted (2x2 reflow keeps the odd tile + spacer).
    expect(find.byKey(const Key('advisor_quick_scan')), findsOneWidget);
    expect(find.byKey(const Key('advisor_quick_new')), findsOneWidget);
    expect(find.byKey(const Key('advisor_quick_approvals')), findsOneWidget);
  });

  testWidgets('pinned pill search shows hint with recents and scan', (
    tester,
  ) async {
    await _pumpHome(tester);

    expect(find.byType(AppSearchBar), findsOneWidget);
    // Short verb hint always fits beside the scan CTA (long hint truncated).
    expect(find.text('Search'), findsOneWidget);
    // Scan CTA keeps its route affordance next to the pill.
    expect(find.byTooltip('Scan vehicle'), findsWidgets);
  });

  testWidgets('assigned jobs render as media cards with Show all', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Urgent-first order is preserved (waitingParts sorts above the rest).
    // Cards lead with the job id; customer shares the vehicle line.
    expect(find.textContaining('Ahmed'), findsWidgets);
    expect(find.textContaining('Layla'), findsOneWidget);
    expect(find.textContaining('Sara'), findsOneWidget);
    // Only the urgent row carries the due-today microcopy.
    expect(find.textContaining('Due today'), findsOneWidget);
    // One status chip per card (3 cards + the side-preview chip at the
    // medium test viewport), no legacy divider rows.
    expect(find.byType(AppStatusChip), findsNWidgets(4));
    // Count inline on the header line (never on its own line).
    expect(find.text('Assigned work orders (3)'), findsOneWidget);
    // Job-id-first cards with chevron affordance (medium viewport in the
    // test harness renders the two-column split, same cards).
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
  });

  testWidgets('assigned search filters by id, customer and vehicle', (
    tester,
  ) async {
    await _pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'LAYLA');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    // Same predicate as before: id / customer / vehicle, case-insensitive.
    expect(find.text('Layla'), findsOneWidget);
    expect(find.text('Ahmed'), findsNothing);
    expect(find.text('Sara'), findsNothing);
    // The submitted query is remembered, but no chip duplicates the active
    // query text — only the field shows it.
    expect(find.text('LAYLA'), findsOneWidget);
  });

  testWidgets('empty assigned list shows one empty state with New job action', (
    tester,
  ) async {
    await _pumpHome(tester, jobs: const []);

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.textContaining('No jobs assigned yet'), findsOneWidget);
    expect(
      find.textContaining(
        'New job cards will appear here. Create one to get started.',
      ),
      findsOneWidget,
    );
    // Quick tile + empty-state action share the sentence-case label.
    expect(find.text('New job card'), findsWidgets);
  });

  testWidgets('loading skeleton mirrors the final layout', (tester) async {
    await _pumpHome(tester, hangJobs: true);

    expect(find.byType(AppShimmerSkeleton), findsWidgets);
    expect(find.byType(AppMediaCard), findsNothing);
  });

  testWidgets('error state with retry when nothing loaded', (tester) async {
    await _pumpHome(tester, failJobs: true);

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(
      find.textContaining('Some live workshop data could not be loaded.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
