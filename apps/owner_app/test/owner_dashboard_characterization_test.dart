// Characterization baseline for the owner home / executive cockpit (phase 7).
//
// Pins CURRENT-UI behavior against the present OwnerDashboardPage: the top-3
// frequent tasks with their before-tap counts (glance 0 taps, drill to
// job-cards 1 tap, triage approvals 1 tap + scroll / 2 taps via the existing
// command palette), the twelve quick-action destinations, and display
// invariants (verbatim figures, zero as 0, read-only approvals — never
// Approve/Reject buttons). Behavior only, never widget types, so these stay
// green across the App* recomposition and become the migration baseline.
// Do NOT modify these tests after the recomposition.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart' hide AsyncData;
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_adapters.dart';
import 'package:owner_app/features/dashboard/data/datasources/owner_remote_datasource.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/dashboard_body.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

// ---------------------------------------------------------------- fixtures

const _kpis = <KpiCardResponse>[
  KpiCardResponse(label: 'Revenue', value: 'AED 84K', sub: '+2.1% Ahead'),
  KpiCardResponse(label: 'Margin', value: '18.4%', sub: '+1.2% vs last week'),
  KpiCardResponse(label: 'Bay occupancy', value: '12/16', sub: '4 bays free'),
  KpiCardResponse(
    label: 'Pending approvals',
    value: '3',
    sub: '2 need decisions',
  ),
  KpiCardResponse(label: 'Open jobs', value: '12', sub: '12 active'),
  KpiCardResponse(label: 'New today', value: '5', sub: '5 booked'),
];

const _sales = <TrendPointResponse>[
  TrendPointResponse(month: 'Jan', value: 10),
  TrendPointResponse(month: 'Feb', value: 20),
  TrendPointResponse(month: 'Mar', value: 30),
];

const _profit = <TrendPointResponse>[
  TrendPointResponse(month: 'Jan', value: 5),
  TrendPointResponse(month: 'Feb', value: 8),
  TrendPointResponse(month: 'Mar', value: 12),
];

const _expenses = <TrendPointResponse>[
  TrendPointResponse(month: 'Jan', value: 3),
  TrendPointResponse(month: 'Feb', value: 4),
  TrendPointResponse(month: 'Mar', value: 6),
];

const _register = <JobCardRegisterResponse>[
  JobCardRegisterResponse(
    label: 'Engine repair',
    open: 3,
    completed: 5,
    total: 8,
  ),
  JobCardRegisterResponse(label: 'AC service', open: 0, completed: 4, total: 4),
];

class _HomeData {
  const _HomeData({this.fail = false, this.hang = false, this.empty = false});

  final bool fail;
  final bool hang;
  final bool empty;
}

class _FakeOwnerRemote implements OwnerRemoteDataSource {
  _FakeOwnerRemote(this.data);

  _HomeData data;

  Future<T> _gate<T>(T value) async {
    if (data.fail) throw Exception('offline');
    if (data.hang) await Completer<void>().future;
    return value;
  }

  @override
  Future<List<KpiCardResponse>> getKpis() =>
      _gate(data.empty ? const <KpiCardResponse>[] : _kpis);

  @override
  Future<List<TrendPointResponse>> getSalesTrend() =>
      _gate(data.empty ? const <TrendPointResponse>[] : _sales);

  @override
  Future<List<TrendPointResponse>> getProfitTrend() =>
      _gate(data.empty ? const <TrendPointResponse>[] : _profit);

  @override
  Future<List<TrendPointResponse>> getExpensesTrend() =>
      _gate(data.empty ? const <TrendPointResponse>[] : _expenses);

  @override
  Future<List<JobCardRegisterResponse>> getJobCardRegister() =>
      _gate(data.empty ? const <JobCardRegisterResponse>[] : _register);

  @override
  Future<List<TopSalesCategoryResponse>> getTopSales() =>
      _gate(const <TopSalesCategoryResponse>[]);

  @override
  Future<List<DocumentExpiryResponse>> getDocumentExpiry() =>
      _gate(const <DocumentExpiryResponse>[]);

  @override
  Future<List<JobStatusResponse>> getJobsByStatus(String stage) =>
      _gate(const <JobStatusResponse>[]);

  @override
  Future<List<ApprovalCategoryResponse>> getApprovalCategories() =>
      _gate(const <ApprovalCategoryResponse>[]);

  @override
  Future<List<PendingJobResponse>> getPendingJobs() =>
      _gate(const <PendingJobResponse>[]);

  @override
  Future<List<OwnerJobCardResponse>> getActiveJobs() =>
      _gate(const <OwnerJobCardResponse>[]);

  @override
  Future<List<InvoiceResponse>> getInvoices(String? status) =>
      _gate(const <InvoiceResponse>[]);

  @override
  Future<ArSummaryResponse> getArSummary() => _gate(
    const ArSummaryResponse(
      totalOutstanding: 0,
      days0to30: 0,
      days31to60: 0,
      days61to90: 0,
      days90plus: 0,
    ),
  );

  @override
  Future<List<ArRecordResponse>> getArRecords() =>
      _gate(const <ArRecordResponse>[]);

  @override
  Future<List<MessageResponse>> getMessages() =>
      _gate(const <MessageResponse>[]);

  @override
  Future<MessageResponse> sendMessage(String recipient, String message) =>
      _gate(MessageResponse(recipient: recipient, message: message));

  @override
  Future<List<ActivityResponse>> getActivity(int page, int limit) =>
      _gate(const <ActivityResponse>[]);

  @override
  Future<List<OwnerJobCardResponse>> getOwnerJobCards() =>
      _gate(const <OwnerJobCardResponse>[]);

  @override
  Future<bool> updateJobCardStatus(String id, String status) => _gate(true);
}

// ---------------------------------------------------------------- harness

/// Team tab stays quiet under the shell pump: no network, no fetch.
class _CalmTeamNotifier extends TeamNotifier {
  @override
  TeamState build() => const TeamState(isLoading: false);
}

class _Marker extends StatelessWidget {
  final String location;

  const _Marker(this.location);

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('at:$location')));
}

GoRouter _router(Widget home) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => home),
    for (final r in <String>[
      AppRoutes.jobCards,
      AppRoutes.inventory,
      AppRoutes.accountsReceivable,
      AppRoutes.pendingApprovals,
      AppRoutes.jobStatus,
      AppRoutes.documentExpiry,
      AppRoutes.feedbackModeration,
      AppRoutes.attendance,
      AppRoutes.team,
      AppRoutes.subscription,
    ])
      GoRoute(path: r, builder: (_, s) => _Marker(s.matchedLocation)),
  ],
);

Widget _app(GoRouter router, {Locale locale = const Locale('en')}) =>
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        OwnerLocalizations.delegate,
        SharedCoreLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(BrandConfig.orient, locale: locale),
      routerConfig: router,
    );

Future<({ProviderContainer container, GoRouter router})> _pump(
  WidgetTester tester,
  _FakeOwnerRemote fake,
  Widget home, {
  List<Override> extraOverrides = const [],
  // Compact phone still by default: the register renders its record-row
  // fallback (the 'Open: 0' metadata only exists there) and the actions
  // render as a single column, matching the 360x800 brief matrix.
  Size surface = const Size(390, 844),
}) async {
  tester.view.physicalSize = Size(surface.width * 3, surface.height * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [
      dashboardDataSourceProvider.overrideWithValue(
        DashboardUIRemoteAdapter(fake),
      ),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);
  final router = _router(home);
  // Real async for the backend beat: the notifier's microtask loadAll only
  // settles on real event-loop turns (technician capture harness pattern).
  await tester.runAsync(() async {
    await Hive.box<dynamic>('owner_messages').clear();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: _app(router)),
    );
    for (var i = 0; i < 40; i++) {
      if (!container.read(dashboardUiProvider).isLoading) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
  return (container: container, router: router);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(tester.takeException(), isNull);
}

void main() {
  setUp(() {
    final binding = TestDefaultBinaryMessengerBinding.instance;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    // No stored session: secure storage reads resolve to null.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall call) async => null,
    );
    // Connectivity: wifi on both the v6 (`checkConnectivity`) and legacy
    // (`check`) method names. The plugin casts the reply to List, so the
    // mock returns a list (baseline harness shape), never a bare String.
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall call) async {
        if (call.method == 'checkConnectivity' || call.method == 'check') {
          return <String>['wifi'];
        }
        return null;
      },
    );
    binding.defaultBinaryMessenger.setMockStreamHandler(
      const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
      MockStreamHandler.inline(
        onListen: (Object? args, MockStreamHandlerEventSink events) {},
      ),
    );
  });

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('owner_home_char');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('owner_messages');
  });

  testWidgets('glance shows revenue hero and pills with zero taps', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const Scaffold(body: OwnerDashboardPage()),
    );

    // BEFORE: hero + first pods above the fold at launch — no interaction.
    // SHELL FIX (C16 hard-reject): pod overlines render sentence case
    // (`Revenue`, `Margin`) — the shared AppKpiCard no longer uppercases.
    expect(find.text('Revenue'), findsWidgets);
    expect(find.text('AED 84K'), findsOneWidget);
    expect(find.text('+2.1% Ahead'), findsOneWidget);
    expect(find.text('Margin'), findsOneWidget);
    expect(find.text('Live operations'), findsOneWidget);
    // BEFORE-QUIRK (pinned, not fixed — logic untouchable): the header is a
    // `const _CockpitHeader()` reading KPIs via `ref.read`, so it freezes at
    // the first content build when the adapter lists are still empty. The
    // active/today pills never populate on fresh load even though the hero
    // and pods (non-const, same pass) render the same KPIs. The recomposition
    // rebuilds the header on shared atoms with the KPIs passed down, so only
    // the Live pill is pinned here to stay green across the migration.
  });

  testWidgets('register row drill opens job cards in one tap', (tester) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const Scaffold(body: OwnerDashboardPage()),
    );

    await tester.ensureVisible(find.text('Engine repair'));
    await tester.tap(find.text('Engine repair'));
    await _settle(tester);

    // BEFORE: register row tap -> context.push(AppRoutes.jobCards).
    expect(find.text('at:${AppRoutes.jobCards}'), findsOneWidget);
  });

  testWidgets('register view-all opens the same job-cards route', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const Scaffold(body: OwnerDashboardPage()),
    );

    // The section trailing stays a real TextButton (the quick-actions
    // show-all added by the recomposition is a list row, never a TextButton).
    await tester.ensureVisible(find.widgetWithText(TextButton, 'View all'));
    await tester.tap(find.widgetWithText(TextButton, 'View all'));
    await _settle(tester);

    expect(find.text('at:${AppRoutes.jobCards}'), findsOneWidget);
  });

  testWidgets('approvals tile triages in one tap plus scroll', (tester) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const Scaffold(body: OwnerDashboardPage()),
    );

    await tester.ensureVisible(find.text('Approvals'));
    await tester.tap(find.text('Approvals'));
    await _settle(tester);

    // BEFORE: tile -> context.push(AppRoutes.pendingApprovals).
    expect(find.text('at:${AppRoutes.pendingApprovals}'), findsOneWidget);
  });

  testWidgets('palette search path reaches approvals in two taps', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const DashboardBody(),
      surface: const Size(800, 600),
      extraOverrides: [
        teamProvider.overrideWith(_CalmTeamNotifier.new),
        ownerActivityFeedProvider.overrideWith(
          (ref) async => const <Map<String, dynamic>>[],
        ),
      ],
    );

    // Tap 1: shell AppBar search opens the existing command palette.
    // RULING (a) relocation (ui/fix-rulings): the shell AppBar owns the
    // single visible search path on the dashboard tab (top-right action
    // cluster); the home page header shows none — same palette, same
    // destination, same tap count (2 taps to the triage route).
    final headerSearch = find.descendant(
      of: find.byType(AppAppBar),
      matching: find.byIcon(Icons.search_rounded),
    );
    expect(headerSearch, findsOneWidget);
    await tester.tap(headerSearch);
    await _settle(tester);
    expect(find.text('Search destinations…'), findsWidgets);

    // Tap 2: the palette destination pushes the same triage route.
    final inDialog = find.descendant(
      of: find.byType(Dialog),
      matching: find.text('Approvals'),
    );
    expect(inDialog, findsOneWidget);
    await tester.tap(inDialog);
    await _settle(tester);

    expect(find.text('at:${AppRoutes.pendingApprovals}'), findsOneWidget);
  });

  testWidgets('all twelve quick-action destinations survive', (tester) async {
    final pumped = await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const Scaffold(body: OwnerDashboardPage()),
    );
    final container = pumped.container;
    final router = pumped.router;

    Future<void> tapPush(String label, String route) async {
      await tester.ensureVisible(find.text(label).first);
      await tester.tap(find.text(label).first);
      await _settle(tester);
      expect(
        find.text('at:$route'),
        findsOneWidget,
        reason: '$label must push $route',
      );
      router.pop();
      await _settle(tester);
    }

    // Every destination is a visible tile — nothing hides behind an
    // overflow/Show-all row, so each stays one tap away.
    await tapPush('Job cards', AppRoutes.jobCards);
    await tapPush('Inventory', AppRoutes.inventory);
    await tapPush('Receivables', AppRoutes.accountsReceivable);
    await tapPush('Approvals', AppRoutes.pendingApprovals);
    await tapPush('Job status', AppRoutes.jobStatus);
    await tapPush('Compliance', AppRoutes.documentExpiry);
    await tapPush('Reviews', AppRoutes.feedbackModeration);
    await tapPush('Attendance', AppRoutes.attendance);
    await tapPush('Team & roles', AppRoutes.team);
    await tapPush('Subscription', AppRoutes.subscription);

    // Tab destinations switch the shell tab instead of pushing.
    final tabs = <String, int>{'Top sales': 1, 'Messages': 2};
    for (final entry in tabs.entries) {
      await tester.ensureVisible(find.text(entry.key).first);
      await tester.tap(find.text(entry.key).first);
      await _settle(tester);
      expect(
        container.read(dashboardUiProvider).selectedIndex,
        entry.value,
        reason: '${entry.key} must select tab ${entry.value}',
      );
      container.read(dashboardUiProvider.notifier).selectTab(0);
      await _settle(tester);
    }
  });

  testWidgets('figures verbatim, zero as 0, no approve/reject buttons', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData()),
      const Scaffold(body: OwnerDashboardPage()),
    );

    // BEFORE: adapter figures render verbatim; missing families omitted.
    expect(find.text('AED 84K'), findsOneWidget);
    expect(find.text('+2.1% Ahead'), findsOneWidget);
    expect(find.text('12/16'), findsWidgets);
    // Zero renders as 0, never '-' or blank.
    expect(find.textContaining('Open: 0'), findsOneWidget);
    // STOP-grade: approvals stay a read-only triage — no decision buttons.
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('empty shows honest empty states, never zero-filled', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData(empty: true)),
      const Scaffold(body: OwnerDashboardPage()),
    );

    // FORWARD PIN: the recomposition renders these two through AppEmptyState
    // (bidi-isolated, invisible U+2066/2069), so the finders use
    // textContaining — identical pins, green on both UIs.
    expect(find.textContaining('No figures yet.'), findsOneWidget);
    expect(find.textContaining('No register rows.'), findsOneWidget);
    expect(find.text('No trend data yet.'), findsWidgets);
    expect(find.text('AED 84K'), findsNothing);
    expect(find.text('Margin'), findsNothing);
    expect(find.text('Live operations'), findsOneWidget);
  });

  testWidgets('first load failure shows the message with retry', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData(fail: true)),
      const Scaffold(body: OwnerDashboardPage()),
    );

    expect(
      find.textContaining('Dashboard data could not be loaded'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsWidgets);
  });

  testWidgets('loading shows no data and no error', (tester) async {
    await _pump(
      tester,
      _FakeOwnerRemote(const _HomeData(hang: true)),
      const Scaffold(body: OwnerDashboardPage()),
      // HARNESS: the legacy loading skeleton is taller than a phone still,
      // so this state pumps on a tall surface to avoid a test-only overflow.
      surface: const Size(420, 1600),
    );

    expect(find.text('AED 84K'), findsNothing);
    expect(find.text('Engine repair'), findsNothing);
    expect(find.textContaining('could not be loaded'), findsNothing);
  });
}
