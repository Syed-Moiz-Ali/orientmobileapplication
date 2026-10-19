import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/messages_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_activity_feed_tab.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/top_sales_page.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

const _delegates = <LocalizationsDelegate<dynamic>>[
  OwnerLocalizations.delegate,
  SharedCoreLocalizations.delegate,
  SharedAuthLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _kpis = [
  OwnerKpi(
    label: 'Active jobs',
    value: '24',
    icon: Icons.build_circle_outlined,
    state: KpiSemanticState.info,
    sub: '6 due today',
  ),
  OwnerKpi(
    label: 'Revenue',
    value: 'AED 84K',
    icon: Icons.payments_outlined,
    state: KpiSemanticState.success,
    sub: '+18.4% vs target',
  ),
  OwnerKpi(
    label: 'Gross margin',
    value: '44.2%',
    icon: Icons.trending_up_rounded,
    state: KpiSemanticState.success,
    sub: '+2.1% ahead',
  ),
  OwnerKpi(
    label: 'Approvals',
    value: '7',
    icon: Icons.fact_check_outlined,
    state: KpiSemanticState.warning,
    sub: 'Needs attention',
  ),
];

const _register = [
  JobCardRegisterItem(label: 'In progress', open: 12, completed: 4, total: 28),
  JobCardRegisterItem(label: 'Awaiting approval', open: 7, completed: 0, total: 9),
];

const _sales = [
  SalesTrendPoint('Jan', 42),
  SalesTrendPoint('Feb', 56),
  SalesTrendPoint('Mar', 61),
];

const _profit = [
  SalesTrendPoint('Jan', 18),
  SalesTrendPoint('Feb', 24),
  SalesTrendPoint('Mar', 27),
];

const _expenses = [
  SalesTrendPoint('Jan', 22),
  SalesTrendPoint('Feb', 26),
  SalesTrendPoint('Mar', 30),
];

const _categories = [
  TopSalesCategory(
    title: 'Brake services',
    items: [
      TopSalesItem(sno: 1, description: 'Brake pad replacement', value: 'AED 12K'),
      TopSalesItem(sno: 2, description: 'Disc resurfacing', value: 'AED 4K'),
    ],
  ),
];

class _FakeUi extends DashboardUiNotifier {
  final DashboardUiState seed;
  _FakeUi([this.seed = const DashboardUiState()]);

  @override
  DashboardUiState build() => seed;

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => _kpis;

  @override
  List<JobCardRegisterItem> get registerItems => _register;

  @override
  List<SalesTrendPoint> get salesTrend => _sales;

  @override
  List<SalesTrendPoint> get profitTrend => _profit;

  @override
  List<SalesTrendPoint> get expensesTrend => _expenses;

  @override
  List<TopSalesCategory> get topSalesCategories => _categories;
}

class _EmptyUi extends DashboardUiNotifier {
  @override
  DashboardUiState build() => const DashboardUiState();

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => const [];

  @override
  List<JobCardRegisterItem> get registerItems => const [];

  @override
  List<SalesTrendPoint> get salesTrend => const [];

  @override
  List<SalesTrendPoint> get profitTrend => const [];

  @override
  List<SalesTrendPoint> get expensesTrend => const [];

  @override
  List<TopSalesCategory> get topSalesCategories => const [];
}

class _ErrorUi extends DashboardUiNotifier {
  @override
  DashboardUiState build() =>
      const DashboardUiState(errorMessage: 'Refresh failed.');

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => const [];

  @override
  List<JobCardRegisterItem> get registerItems => const [];

  @override
  List<SalesTrendPoint> get salesTrend => const [];

  @override
  List<SalesTrendPoint> get profitTrend => const [];

  @override
  List<SalesTrendPoint> get expensesTrend => const [];

  @override
  List<TopSalesCategory> get topSalesCategories => const [];
}

class _FakeTeam extends TeamNotifier {
  @override
  TeamState build() => const TeamState(
        isLoading: false,
        staff: [
          StaffMember(
            id: '1',
            empId: 'EMP-1',
            name: 'Sara Iqbal',
            role: 'Advisor',
            branch: 'Al Quoz',
            phone: '+971501234567',
            isActive: true,
          ),
        ],
      );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  DashboardUiNotifier Function()? ui,
  Size size = const Size(390, 844),
  Locale locale = const Locale('en'),
  List<Override> extra = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardUiProvider.overrideWith(ui ?? _FakeUi.new),
        teamProvider.overrideWith(_FakeTeam.new),
        ...extra,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: _delegates,
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Cockpit hero and pods (frozen figures, verbatim)', () {
    testWidgets('revenue KPI fronts the hero with its delta', (tester) async {
      await _pump(tester, const OwnerDashboardPage());
      expect(find.text('AED 84K'), findsOneWidget);
      expect(find.text('+18.4% vs target'), findsOneWidget);
      // No fabricated advisor leaderboard on the cockpit.
      expect(find.textContaining('Top advisor'), findsNothing);
    });

    testWidgets('margin and approvals KPIs surface as pods', (tester) async {
      await _pump(tester, const OwnerDashboardPage());
      expect(find.text('44.2%'), findsOneWidget);
      expect(find.text('7'), findsWidgets);
    });

    testWidgets('empty figures render explicit empty states', (tester) async {
      await _pump(tester, const OwnerDashboardPage(), ui: _EmptyUi.new);
      expect(find.text('No figures yet.'), findsOneWidget);
      expect(find.text('No register rows.'), findsOneWidget);
      expect(find.text('No trend data yet.'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('error renders with retry', (tester) async {
      await _pump(tester, const OwnerDashboardPage(), ui: _ErrorUi.new);
      expect(find.text('Refresh failed.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('register rows and quick actions render', (tester) async {
      await _pump(tester, const OwnerDashboardPage());
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Job register'), findsOneWidget);
      expect(find.text('Job cards'), findsOneWidget);
      expect(find.text('Receivables'), findsOneWidget);
      expect(find.text('Team & roles'), findsOneWidget);
    });

    testWidgets('cockpit survives 1.3x without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardUiProvider.overrideWith(_FakeUi.new),
            teamProvider.overrideWith(_FakeTeam.new),
          ],
          child: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.3),
            ),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              supportedLocales: AppLocales.supported,
              localizationsDelegates: _delegates,
              theme: AppTheme.light(BrandConfig.orient),
              home: const Scaffold(body: OwnerDashboardPage()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Leaderboard (categories, never invented advisors)', () {
    testWidgets('expands a category to its ranked lines', (tester) async {
      await _pump(tester, const TopSalesPage());
      expect(find.text('Brake pad replacement'), findsNothing);
      await tester.tap(find.text('Brake services'));
      await tester.pumpAndSettle();
      expect(find.text('Brake pad replacement'), findsOneWidget);
      expect(find.text('AED 12K'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('empty categories render the empty state', (tester) async {
      await _pump(tester, const TopSalesPage(), ui: _EmptyUi.new);
      expect(find.text('No sales data.'), findsOneWidget);
    });
  });

  group('Comms (frozen send path)', () {
    testWidgets('composer validates before sending', (tester) async {
      await _pump(tester, const MessagesPage());
      expect(find.text('Broadcast message to team'), findsOneWidget);
      await tester.tap(find.text('Send message'));
      await tester.pumpAndSettle();
      // No recipient selected: the frozen notifier returns false.
      expect(find.text('Message failed. Check recipient selection.'),
          findsOneWidget);
    });
  });

  group('Activity (grouped, relative time, real routes)', () {
    testWidgets('empty feed renders the empty state', (tester) async {
      await _pump(
        tester,
        const OwnerActivityFeedTab(),
        extra: [
          ownerActivityFeedProvider.overrideWith((ref) async => []),
        ],
      );
      expect(find.text('No activity yet'), findsOneWidget);
    });

    testWidgets('approval event taps through to approvals', (tester) async {
      final router = GoRouter(
        initialLocation: '/feed',
        routes: [
          GoRoute(
            path: '/feed',
            builder: (_, __) =>
                const Scaffold(body: OwnerActivityFeedTab()),
          ),
          GoRoute(
            path: '/pending-approvals',
            builder: (_, __) =>
                const Scaffold(body: Text('APPROVALS-DEST')),
          ),
        ],
      );
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardUiProvider.overrideWith(_FakeUi.new),
            teamProvider.overrideWith(_FakeTeam.new),
            ownerActivityFeedProvider.overrideWith((ref) async => [
                  {
                    'id': 'a1',
                    'type': 'approval',
                    'icon': 'fact_check',
                    'color': '#D97706',
                    'title': 'Job #9281 approved by customer',
                    'description': 'Estimate LPO-1042',
                    'timestamp': DateTime.now()
                        .subtract(const Duration(minutes: 5))
                        .toIso8601String(),
                  },
                ]),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: _delegates,
            theme: AppTheme.light(BrandConfig.orient),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Job #9281 approved by customer'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('5m ago'), findsOneWidget);
      await tester.tap(find.text('Job #9281 approved by customer'));
      await tester.pumpAndSettle();
      expect(find.text('APPROVALS-DEST'), findsOneWidget);
    });
  });
}
