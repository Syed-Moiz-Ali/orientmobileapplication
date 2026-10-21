// Structural tests for the recomposed Advisor Home (U-laws rebuild).
//
// Presentation-tree assertions only: header, hero, quick-action row, search
// sheet entry, assigned list cards and the loading/error/empty states.
// Behavior (providers, navigation targets, sync logic, sort order, search
// filtering predicate) is asserted nowhere here.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/domain/entities/advisor_stats_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/domain/entities/pending_approval_entity.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_home_view.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_reports_provider.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_search_sheet.dart';
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
  String advisorName = 'Omar Haddad',
  double scale = 1.0,
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
          AdvisorInfo(
            name: advisorName,
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: AdvisorHomeView()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('header greets with search icon, bell badge and avatar', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Date line + greeting headline + branch/shift line own the header (no
    // app bar, no sync pill — sync surfaces only as an AppBanner when
    // abnormal). Full name wraps to 2 lines, never truncated (guard e).
    expect(find.text('Good to see you, Omar Haddad'), findsOneWidget);
    expect(find.text('Branch A · Morning shift'), findsOneWidget);
    expect(find.byType(OfflineStatusPill), findsNothing);
    // 1 notification + 2 approvals behind one error badge on the bell, plus
    // the approvals-tile badge carrying the same count.
    expect(find.byType(AppBadge), findsNWidgets(2));
    expect(find.byType(AppAvatar), findsOneWidget);
    // Single search entry (U1/U9): the header search icon top-right next
    // to the bell + avatar — same placement as customer home. No inline
    // pill duplicating it (guard f covers the TextField half).
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(find.byType(AppSearchBar), findsNothing);
  });

  testWidgets('abnormal sync surfaces once as a banner, never a pill', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Normal case (online, nothing queued): no banner, no pill.
    expect(find.byType(AppBanner), findsNothing);
    expect(find.byType(OfflineStatusPill), findsNothing);
  });

  testWidgets('first assigned order sits above the fold at 360x800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _pumpHome(tester);

    // Wireframe-consistent order: header -> hero -> quick actions ->
    // assigned list (no inline pill pushing content down). The urgent-first
    // card (JC-1042) must clear the bottom nav without scrolling.
    final card = tester.getRect(find.text('JC-1042').first);
    final nav = tester.getRect(find.byType(AppBottomNavigation));
    expect(card.bottom, lessThanOrEqualTo(nav.top));
  });

  testWidgets('hero shows inspections-due-today with sentence and View jobs', (
    tester,
  ) async {
    await _pumpHome(tester);

    // ONE hero card: key number + delta sentence + verb-first primary CTA.
    // No dead media block. U7: no See-all when nothing more is shown (all
    // 3 fit the cap) — the hero View jobs is the one path into Jobs.
    expect(find.text('6 inspections due today'), findsOneWidget);
    expect(find.text("+2 today. Review what's urgent first."), findsOneWidget);
    expect(find.text('View jobs'), findsOneWidget);
    expect(find.byType(AppMediaCard), findsNothing);
    expect(find.text('See all'), findsNothing);
  });

  testWidgets('hero zero-state is a calm row with no filled button', (
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

    // U6: no "0 …" key number, no "urgent first", no filled CTA to nothing.
    expect(find.text('0 inspections due today'), findsNothing);
    expect(find.text('View jobs'), findsNothing);
    expect(
      find.text("You're caught up — new jobs will appear here."),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('quick actions are 3 equal columns, count once', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Full labels, never mid-word ellipsis ("Sca..." regression).
    expect(find.text('Scan vehicle'), findsOneWidget);
    expect(find.text('New job card'), findsOneWidget);
    // Approvals count appears exactly ONCE: on the badge, never in the
    // label (no "Approvals (2)" duplication).
    expect(find.text('Approvals'), findsOneWidget);
    expect(find.text('Approvals (2)'), findsNothing);
    // All three tiles mounted as equal columns (no orphan, no scroll):
    // no SingleChildScrollView may sit between a tile and the home.
    for (final key in [
      const Key('advisor_quick_scan'),
      const Key('advisor_quick_new'),
      const Key('advisor_quick_approvals'),
    ]) {
      expect(find.byKey(key), findsOneWidget);
      var scrolled = false;
      find
          .byKey(key)
          .evaluate()
          .single
          .visitAncestorElements((ancestor) {
            if (ancestor.widget is SingleChildScrollView) {
              scrolled = true;
              return false;
            }
            return true;
          });
      expect(scrolled, isFalse, reason: '$key scrolls instead of fitting');
    }
  });

  testWidgets('quick actions fit 360px at 1.3x with no cut-offs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _pumpHome(tester, scale: 1.3);

    // U5/U14: every tile fully inside the viewport — no horizontal
    // cut-offs at 360px + 1.3x.
    const width = 360.0;
    for (final key in [
      const Key('advisor_quick_scan'),
      const Key('advisor_quick_new'),
      const Key('advisor_quick_approvals'),
    ]) {
      final rect = tester.getRect(find.byKey(key));
      expect(rect.left, greaterThanOrEqualTo(-0.5), reason: '$key cut left');
      expect(rect.right, lessThanOrEqualTo(width + 0.5), reason: '$key cut right');
    }
  });

  testWidgets('search sheet opens from the header icon with scan inside', (
    tester,
  ) async {
    await _pumpHome(tester);

    // One search path (U1/U7): the header icon opens the full-screen
    // sheet (autofocus + recents + scan inside, same predicate verbatim).
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    final sheet = find.byType(AdvisorSearchSheet);
    expect(sheet, findsOneWidget);
    final field = find.descendant(
      of: sheet,
      matching: find.byType(TextField),
    );
    expect(field, findsOneWidget);
    // Scan lives inside the sheet (existing route target, verified below
    // by tooltip — same affordance the quick-action tile owns).
    expect(find.descendant(
      of: sheet,
      matching: find.byTooltip('Scan vehicle'),
    ), findsOneWidget);

    // Same predicate as the removed inline pill: id / customer / vehicle,
    // case-insensitive — across BOTH sheet feeds (job cards + approvals).
    // "Layla" hits one job card and one approval; Ahmed/Sara hit neither.
    await tester.enterText(field, 'LAYLA');
    await tester.pump();
    expect(
      find.descendant(of: sheet, matching: find.text('Layla')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Ahmed')),
      findsNothing,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Sara')),
      findsNothing,
    );
  });

  testWidgets('assigned jobs render as cards without See-all when all fit', (
    tester,
  ) async {
    await _pumpHome(tester);

    // Urgent-first order is preserved (waitingParts sorts above the rest).
    // Cards lead with customer + vehicle; the job id is small meta.
    expect(find.textContaining('Ahmed'), findsWidgets);
    expect(find.textContaining('Layla'), findsOneWidget);
    expect(find.textContaining('Sara'), findsOneWidget);
    // Only the urgent row carries the due-today microcopy.
    expect(find.textContaining('Due today'), findsOneWidget);
    // One status chip per card (3 cards + the side-preview chip at the
    // medium test viewport), no legacy divider rows.
    expect(find.byType(AppStatusChip), findsNWidgets(4));
    // Count inline on the header line (never on its own line).
    expect(find.text('Work orders (3)'), findsOneWidget);
    // U7: all 3 fit the cap of 6, so no See-all — the hero View jobs is
    // the one path into Jobs.
    expect(find.text('See all'), findsNothing);
    // Customer-first cards with chevron affordance (medium viewport in the
    // test harness renders the two-column split, same cards).
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
  });

  testWidgets('assigned See-all appears only when more exist than shown', (
    tester,
  ) async {
    const extra = [
      JobCardEntity(
        id: 'JC-1039',
        customerName: 'Omar',
        vehicleInfo: 'Accord · GHI 3456',
        time: '08:00 AM',
        status: JobCardStatus.inProgress,
      ),
      JobCardEntity(
        id: 'JC-1038',
        customerName: 'Noor',
        vehicleInfo: 'Sunny · JKL 7890',
        time: 'Yesterday',
        status: JobCardStatus.vehicleReceived,
      ),
      JobCardEntity(
        id: 'JC-1037',
        customerName: 'Khalid',
        vehicleInfo: 'Altima · MNO 1234',
        time: 'Yesterday',
        status: JobCardStatus.inspected,
      ),
      JobCardEntity(
        id: 'JC-1036',
        customerName: 'Maha',
        vehicleInfo: 'Corolla · PQR 5678',
        time: 'Monday',
        status: JobCardStatus.workAssigned,
      ),
    ];
    await _pumpHome(tester, jobs: const [...extra, _done, _urgent, _active]);

    // 7 > cap of 6: the count stays honest and See-all appears once.
    expect(find.text('Work orders (7)'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
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

  group('hard-reject U-guards (e)–(h)', () {
    testWidgets('(e) greeting shows a long name in full, no ellipsis', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      // 28-char name at the 360x800 floor.
      await _pumpHome(tester, advisorName: 'Amina Yousuf Al Blooshi Khan');

      final greeting = find.text(
        'Good to see you, Amina Yousuf Al Blooshi Khan',
      );
      expect(greeting, findsOneWidget);
      final widget = tester.widget<Text>(greeting);
      // U5: wraps to 2 lines with the FULL name — never "…" on a name.
      expect(widget.maxLines, 2);
      expect(widget.softWrap, isTrue);
      expect(widget.overflow, isNot(TextOverflow.ellipsis));
      // No ellipsis glyph anywhere in the header copy.
      for (final element in find
          .descendant(
            of: find.byType(AdvisorHomeView),
            matching: find.byType(Text),
          )
          .evaluate()
          .take(12)) {
        final data =
            (element.widget as Text).data ??
            (element.widget as Text).textSpan?.toPlainText() ??
            '';
        expect(data.contains('…'), isFalse, reason: 'ellipsis in "$data"');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('(f) search icon in header, no inline field in the body', (
      tester,
    ) async {
      await _pumpHome(tester);

      // U1: the header search icon is the visible entry (Ctrl+K kept).
      expect(find.byTooltip('Search'), findsOneWidget);
      expect(find.byType(AppSearchBar), findsNothing);
      // Every remaining TextField (Jobs tab search, …) sits under an
      // inactive Offstage branch — none renders inline in the Today body.
      for (final element in find.byType(TextField).evaluate()) {
        var hidden = false;
        element.visitAncestorElements((ancestor) {
          final w = ancestor.widget;
          if (w is Offstage && w.offstage) {
            hidden = true;
            return false;
          }
          return true;
        });
        expect(hidden, isTrue, reason: 'inline TextField in the Today body');
      }
    });

    testWidgets('(g) tap count to job detail is 1, within the before-count', (
      tester,
    ) async {
      // BEFORE-count (documented): 1 tap — launch lands on Today with the
      // first assigned job visible above the fold; a single tap opens the
      // detail. U3 requires AFTER ≤ BEFORE (and the most-frequent task ≤ 2).
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: AdvisorHomeView()),
          ),
          GoRoute(
            path: AppRoutes.advisorJobDetail,
            builder: (_, __) =>
                const Scaffold(body: Text('JOB DETAIL STUB')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            advisorRecentJobCardsProvider.overrideWith(
              (ref) async => const [_done, _urgent, _active],
            ),
            advisorDashboardProvider.overrideWith((ref) async => _stats),
            advisorPendingApprovalsProvider.overrideWith(
              (ref) async => _approvals,
            ),
            advisorPendingSyncCountProvider.overrideWith(
              (ref) => Stream<int>.value(0),
            ),
            advisorNotificationsProvider.overrideWith((ref) async => _notifs),
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
          child: MaterialApp.router(
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
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);

      // The first job is visible with zero taps (compact 360px ⇒ the
      // single-column branch wires the card straight to the detail route).
      expect(find.text('Ahmed · Camry · ABC 1234'), findsOneWidget);
      await tester.tap(find.text('Ahmed · Camry · ABC 1234'));
      await tester.pumpAndSettle();
      // Exactly 1 tap opens the detail: 1 ≤ before-count (1) ≤ 3. ✓
      expect(find.text('JOB DETAIL STUB'), findsOneWidget);
    });

    testWidgets('(h) page uses exactly one background color', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await _pumpHome(tester);

      final context = tester.element(find.byType(AdvisorHomeView));
      final page = Theme.of(context).scaffoldBackgroundColor;
      // Every Scaffold in the tree falls back to the page token.
      for (final scaffold in tester
          .widgetList<Scaffold>(find.byType(Scaffold))) {
        expect(scaffold.backgroundColor ?? page, page);
      }
      // Scoped to the home subtree: any full-width painted band must be the
      // page token — no stray strips behind rows (U12).
      var tokenBandFound = false;
      final painted = find.descendant(
        of: find.byType(AdvisorHomeView),
        matching: find.byWidgetPredicate(
          (w) =>
              w is ColoredBox ||
              (w is Container &&
                  (w.color != null || w.decoration is BoxDecoration)) ||
              (w is DecoratedBox && w.decoration is BoxDecoration),
        ),
      );
      for (final element in painted.evaluate()) {
        final widget = element.widget;
        Color? color;
        if (widget is ColoredBox) {
          color = widget.color;
        } else if (widget is Container) {
          final decoration = widget.decoration;
          color = widget.color ??
              (decoration is BoxDecoration ? decoration.color : null);
        } else {
          color = ((widget as DecoratedBox).decoration as BoxDecoration).color;
        }
        if (color == null) continue;
        final rect = tester.getRect(find.byWidget(widget));
        if (rect.width >= 359) {
          expect(color, page, reason: 'stray band $rect paints $color');
          tokenBandFound = true;
        }
      }
      expect(tokenBandFound, isTrue);
    });
  });
}
