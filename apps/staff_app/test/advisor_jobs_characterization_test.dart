// Characterization baseline for the advisor jobs register (GROUP-B screen 1).
//
// Behavior pins against the CURRENT AdvisorJobsListView UI. These tests assert
// behavior only (rendered copy, filtering/sorting, navigation targets, sheet
// contracts, error/empty/loading affordances) — never legacy widget types — so
// they stay green across the App* recomposition and become the migration
// baseline. Do NOT modify these tests after the recomposition (see
// docs/ui-redesign/evaluation/advisor-jobs-test-migration.md).
//
// This register is the single unified surface for the advisor home Assigned
// list and for inspection / repair-order work (GROUP-B screen 2 collapses here:
// no separate inspection or repair-order list exists).

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_jobs_view.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_job_card_row.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ---------------------------------------------------------------- fixtures

const _intake = JobCardEntity(
  id: 'JC-2001',
  customerName: 'Zara',
  vehicleInfo: 'Corolla · DXB 111',
  time: 'Pending sync',
  status: JobCardStatus.pending,
);

const _inspection = JobCardEntity(
  id: 'JC-2002',
  customerName: 'Ahmed',
  vehicleInfo: 'Camry · ABC 1234',
  time: '10:30 AM',
  status: JobCardStatus.inspected,
);

const _approved = JobCardEntity(
  id: 'JC-2003',
  customerName: 'Layla',
  vehicleInfo: 'Yaris · XYZ 5678',
  time: '09:15 AM',
  status: JobCardStatus.approved,
);

const _wip = JobCardEntity(
  id: 'JC-2004',
  customerName: 'Omar',
  vehicleInfo: 'Hilux · DEF 9012',
  time: 'Yesterday',
  status: JobCardStatus.inProgress,
);

const _ready = JobCardEntity(
  id: 'JC-2005',
  customerName: 'Sara',
  vehicleInfo: 'Civic · GHI 3456',
  time: 'Yesterday',
  status: JobCardStatus.completed,
);

// Sixth card: pushes the register past the > 5 search-icon threshold.
const _extra = JobCardEntity(
  id: 'JC-2006',
  customerName: 'Rania',
  vehicleInfo: 'Patrol · JKL 789',
  time: 'Today',
  status: JobCardStatus.vehicleReceived,
);

const _allJobs = [_intake, _inspection, _approved, _wip, _ready];

const _booking = AdvisorBookingResponse(
  id: 7,
  customerName: 'Nadia',
  vehicleName: 'Patrol',
  serviceType: 'Oil change',
  bookingDate: '2026-10-21',
);

// ---------------------------------------------------------------- harness

class _JobsPump {
  _JobsPump({required this.router, required this.opened});

  final GoRouter router;
  final List<JobCardEntity> opened;
}

Future<_JobsPump> _pumpJobs(
  WidgetTester tester, {
  List<JobCardEntity> jobs = _allJobs,
  List<AdvisorBookingResponse> bookings = const [],
  bool failJobs = false,
  bool hangJobs = false,
  Size viewport = const Size(360, 800),
}) async {
  tester.view.physicalSize = Size(viewport.width * 3, viewport.height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final opened = <JobCardEntity>[];
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: AdvisorJobsListView(onJobCard: opened.add),
        ),
      ),
      GoRoute(
        path: AppRoutes.advisorCheckIn,
        builder: (context, state) =>
            const Scaffold(body: Text('checkin-stub')),
      ),
      GoRoute(
        path: AppRoutes.vehicleCustomer,
        builder: (context, state) =>
            const Scaffold(body: Text('newjob-stub')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        advisorRecentJobCardsProvider.overrideWith((ref) async {
          if (failJobs) throw Exception('offline');
          if (hangJobs) await Completer<void>().future;
          return jobs;
        }),
        advisorAssignedBookingsProvider.overrideWith((ref) async => bookings),
        // Harness: the search sheet also reads the approvals feed.
        advisorPendingApprovalsProvider.overrideWith((ref) async => const []),
        advisorPendingSyncCountProvider.overrideWith(
          (ref) => Stream<int>.value(0),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
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
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
  return _JobsPump(router: router, opened: opened);
}

void main() {
  // Harness: the search sheet reads the Hive customer box — in production
  // the box is always open; open an empty one here.
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('advisor_jobs_char');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('inspections');
  });

  /// Scroll-aware card pin: cards are ~200px tall, so later rows are not
  /// built until scrolled into view. Brings each card in, then pins its
  /// title + id + status label while visible.
  Future<void> expectCards(
    WidgetTester tester,
    Map<String, List<String>> titlesToLabels,
  ) async {
    final list = find.byType(ListView).first;
    for (final entry in titlesToLabels.entries) {
      await tester.dragUntilVisible(
        find.text(entry.key),
        list,
        const Offset(0, -300),
      );
      expect(find.text(entry.key), findsWidgets);
      for (final label in entry.value) {
        expect(find.text(label), findsWidgets);
      }
    }
  }

  testWidgets('register shows every card with identity and status', (
    tester,
  ) async {
    await _pumpJobs(tester);

    expect(find.text('Workshop Job Cards'), findsOneWidget);
    // Card hierarchy: customer + vehicle title, then chip, then meta + id;
    // status vocabulary visible (labels, not color alone).
    await expectCards(tester, {
      'Zara · Corolla': ['JC-2001', 'Pending'],
      'Ahmed · Camry': ['JC-2002', 'Inspected'],
      'Layla · Yaris': ['JC-2003', 'Approved'],
      'Omar · Hilux': ['JC-2004', 'In progress'],
      'Sara · Civic': ['JC-2005', 'Completed'],
    });
  });

  testWidgets('row tap opens the job workspace', (tester) async {
    final pump = await _pumpJobs(tester);

    // Tapping the card title hits the card InkWell.
    await tester.tap(find.text('Ahmed · Camry'));
    await tester.pump();

    expect(pump.opened, hasLength(1));
    expect(pump.opened.single.id, 'JC-2002');
    expect(tester.takeException(), isNull);
  });

  testWidgets('search icon hidden when the register is small', (
    tester,
  ) async {
    // Structural (brief-mandated header): ≤ 5 cards render no search icon —
    // the list is fully scannable as-is (the ONE sanctioned U1 exception).
    // Harness: one pump per test — a second pumpWidget does not refresh
    // Riverpod overrides, so each side of the rule gets its own test.
    await _pumpJobs(tester);
    expect(find.byTooltip('Search'), findsNothing);
  });

  testWidgets('search icon opens sheet search over the register', (
    tester,
  ) async {
    // With 6 cards the header icon opens the full-screen search sheet over
    // the loaded register (same predicate as the old inline field).
    final pump = await _pumpJobs(tester, jobs: [..._allJobs, _extra]);
    expect(find.byTooltip('Search'), findsOneWidget);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ahmed');
    await tester.pump();

    // Sheet result row only (register cards carry combined titles, so the
    // exact name matches the sheet row alone).
    expect(find.text('Ahmed'), findsOneWidget);
    expect(find.text('Zara'), findsNothing);
    expect(pump.opened, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status filter chip narrows, All restores', (tester) async {
    await _pumpJobs(tester);

    await tester.tap(find.text('Inspection'));
    await tester.pump();

    expect(find.textContaining('Ahmed'), findsWidgets);
    expect(find.textContaining('Zara'), findsNothing);
    expect(find.textContaining('Sara'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pump();

    await expectCards(tester, {
      'Zara · Corolla': ['JC-2001'],
      'Ahmed · Camry': ['JC-2002'],
      'Layla · Yaris': ['JC-2003'],
      'Omar · Hilux': ['JC-2004'],
      'Sara · Civic': ['JC-2005'],
    });
  });

  testWidgets('sort by customer orders A-Z', (tester) async {
    // Harness: two cards fit the viewport together, so both stay built for
    // the geometry assertion (tall cards scroll lazily with five).
    await _pumpJobs(tester, jobs: const [_intake, _inspection]);

    await tester.tap(find.text('Newest first').first);
    await tester.pumpAndSettle();
    // NOTE: the label carries a U+2013 en dash (ARB byte-identical).
    await tester.tap(find.text('Customer A–Z'));
    await tester.pump();

    final ahmedTop = tester.getTopLeft(find.text('Ahmed · Camry')).dy;
    final zaraTop = tester.getTopLeft(find.text('Zara · Corolla')).dy;
    expect(ahmedTop, lessThan(zaraTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty register offers the new-job action', (tester) async {
    final pump = await _pumpJobs(tester, jobs: const []);

    // Harness: AppEmptyState bidi-isolates copy (invisible isolates), so
    // pins use textContaining — same strings, rendering-identical.
    expect(find.textContaining('No job cards yet'), findsOneWidget);
    expect(
      find.textContaining(
        'New job cards will appear here as they are created.',
      ),
      findsOneWidget,
    );
    expect(find.text('New job card'), findsOneWidget);

    await tester.tap(find.text('New job card'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('newjob-stub'), findsOneWidget);
    expect(pump.opened, isEmpty);
  });

  testWidgets('no-match offers Clear which restores the list', (tester) async {
    // Structural: text search moved to the sheet, so no-match is driven
    // through the status filter on a sparse register (query clause is
    // preserved in code; the filter path is the reachable one).
    await _pumpJobs(tester, jobs: const [_intake, _inspection]);

    await tester.ensureVisible(find.text('Ready'));
    await tester.pump();
    await tester.tap(find.text('Ready'));
    await tester.pump();

    expect(find.text('No matching job cards'), findsOneWidget);
    // Two Clear controls (rail + no-match state); both reset the filter.
    expect(find.text('Clear'), findsWidgets);

    await tester.tap(find.text('Clear').first);
    await tester.pump();

    expect(find.textContaining('Zara'), findsWidgets);
    expect(find.textContaining('Ahmed'), findsWidgets);
    expect(find.text('No matching job cards'), findsNothing);
  });

  testWidgets('first-load failure shows retry and stays recoverable', (
    tester,
  ) async {
    await _pumpJobs(tester, failJobs: true);

    expect(find.text('Refresh Job Card'), findsWidgets);

    await tester.tap(find.text('Refresh Job Card').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Still failing (fake still throws) but the affordance persists and the
    // retry path does not crash.
    expect(find.text('Refresh Job Card'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('intake queue shows Check In, hidden while filtering', (
    tester,
  ) async {
    final pump = await _pumpJobs(tester, bookings: const [_booking]);

    expect(find.text('Assigned intake queue'), findsOneWidget);
    expect(find.text('Check In'), findsOneWidget);

    await tester.tap(find.text('Check In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('checkin-stub'), findsOneWidget);

    // Back to the register: filtering hides the intake section.
    pump.router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Structural: text search moved to the sheet; the filter rail drives
    // the hide-intake contract now.
    await tester.tap(find.text('Inspection'));
    await tester.pump();
    expect(find.text('Assigned intake queue'), findsNothing);
  });

  testWidgets('overflow opens the quick preview with an Open action', (
    tester,
  ) async {
    final pump = await _pumpJobs(tester);

    // Harness: target Ahmed's own row overflow (fixture order puts Zara first).
    final ahmedRow = find.ancestor(
      of: find.text('Ahmed · Camry'),
      matching: find.byType(AdvisorJobCardRow),
    );
    final ahmedMore = find.descendant(
      of: ahmedRow,
      matching: find.byTooltip('More actions'),
    );
    await tester.ensureVisible(ahmedMore);
    await tester.pump();
    await tester.tap(ahmedMore);
    // Harness: settle the sheet entrance animation so the action is
    // hit-testable (production motion unchanged).
    await tester.pumpAndSettle();

    expect(find.text('Open job card'), findsOneWidget);

    await tester.tap(find.text('Open job card'));
    await tester.pumpAndSettle();

    expect(pump.opened, hasLength(1));
    expect(pump.opened.single.id, 'JC-2002');
    expect(find.text('Open job card'), findsNothing);
  });

  testWidgets('loading shows a layout-mirroring skeleton', (tester) async {
    await _pumpJobs(tester, hangJobs: true);

    // Structural: the thin progress bar is gone (no permanent chrome);
    // loading owns skeleton cards mirroring the register layout.
    expect(find.byType(AppShimmerSkeleton), findsWidgets);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('wide layout keeps the sortable work matrix', (tester) async {
    final pump = await _pumpJobs(
      tester,
      viewport: const Size(1280, 800),
    );

    // Master-detail matrix: column headers plus every row.
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Job Card'), findsOneWidget);
    for (final jc in _allJobs) {
      expect(find.text(jc.customerName), findsWidgets);
    }
    // Wide matrix rows keep exact customer names (table cells unchanged).

    await tester.tap(find.text('Ahmed').first);
    await tester.pump();
    expect(find.text('Open job card'), findsOneWidget);

    await tester.tap(find.text('Open job card'));
    await tester.pump();
    expect(pump.opened, hasLength(1));
    expect(pump.opened.single.id, 'JC-2002');
  });
}
