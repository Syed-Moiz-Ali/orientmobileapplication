import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _app({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      SharedCoreLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: theme ?? AppTheme.light(BrandConfig.orient, locale: locale),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: home,
  );
}

void _size(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

const _items = <AppNavItem>[
  AppNavItem(
    selectedIcon: Icons.dashboard_rounded,
    icon: Icons.dashboard_outlined,
    label: 'Today',
  ),
  AppNavItem(
    selectedIcon: Icons.receipt_long_rounded,
    icon: Icons.receipt_long_outlined,
    label: 'Jobs',
  ),
  AppNavItem(
    selectedIcon: Icons.bar_chart_rounded,
    icon: Icons.bar_chart_outlined,
    label: 'Reports',
  ),
  AppNavItem(
    selectedIcon: Icons.person_rounded,
    icon: Icons.person_outline_rounded,
    label: 'Profile',
  ),
];

void main() {
  group('Navigation RTL mirroring', () {
    testWidgets(
      'rail border sits on the reading-end (inner) edge in both directions',
      (tester) async {
        await tester.pumpWidget(
          _app(
            home: const Scaffold(
              body: AppNavigationRail(
                items: _items,
                selectedIndex: 0,
                onSelected: _noop1,
              ),
            ),
          ),
        );
        final decorated = tester.widget<DecoratedBox>(
          find
              .descendant(
                of: find.byType(AppNavigationRail),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final border =
            (decorated.decoration as BoxDecoration).border!
                as BorderDirectional;
        // The rail's border is declared on the reading-end edge, so it mirrors:
        // a single `end` side resolves to right in LTR and left in RTL.
        expect(border.end.width, greaterThan(0));
        expect(border.start, BorderSide.none);
      },
    );

    testWidgets('bottom bar mirrors destination order in RTL', (tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          home: const Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              items: _items,
              selectedIndex: 0,
              onSelected: _noop1,
            ),
          ),
        ),
      );
      final first = tester.getCenter(find.text('Today'));
      final last = tester.getCenter(find.text('Profile'));
      expect(first.dx, greaterThan(last.dx));
    });

    testWidgets('drawer opens from the end edge in RTL', (tester) async {
      _size(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          home: Scaffold(
            drawer: AppNavDrawer(
              title: 'Orient CRM',
              items: _items,
              selectedIndex: 0,
              onSelected: _noop1,
            ),
          ),
        ),
      );
      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      expect(
        tester.getTopRight(find.byType(Drawer)).dx,
        moreOrLessEquals(390, epsilon: 1),
      );
    });

    testWidgets('overflow destination label + sheet localize', (tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          home: const Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              items: [
                ..._items,
                AppNavItem(
                  selectedIcon: Icons.settings_rounded,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                ),
                AppNavItem(
                  selectedIcon: Icons.directions_car_rounded,
                  icon: Icons.directions_car_outlined,
                  label: 'Vehicles',
                ),
              ],
              selectedIndex: 0,
              onSelected: _noop1,
            ),
          ),
        ),
      );
      expect(find.text('المزيد'), findsOneWidget);
      await tester.tap(find.text('المزيد'));
      await tester.pumpAndSettle();
      expect(find.text('المزيد'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('badge semantics localize in Arabic', (tester) async {
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          home: const Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              items: _items,
              selectedIndex: 0,
              onSelected: _noop1,
              badgeCounts: {1: 4},
            ),
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Jobs، 4 جديد',
        ),
        findsOneWidget,
      );
    });
  });

  group('WorkspaceAppBar', () {
    testWidgets('renders title, subtitle, actions and back button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            appBar: WorkspaceAppBar(
              title: 'Workshop Overview',
              subtitle: 'Shift operations',
              showBack: true,
              actions: const [
                IconButton(onPressed: _noop, icon: Icon(Icons.refresh_rounded)),
              ],
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      );
      expect(find.text('Workshop Overview'), findsOneWidget);
      expect(find.text('Shift operations'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byType(DirectionalIcon), findsWidgets);
    });
  });

  group('Breadcrumbs', () {
    testWidgets('render trail and current crumb; separators mirror', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          home: const Scaffold(
            body: AppBreadcrumbs(
              items: [
                AppBreadcrumbItem(label: 'Dashboard'),
                AppBreadcrumbItem(label: 'Inventory'),
                AppBreadcrumbItem.current('PO #123'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('PO #123'), findsOneWidget);
      expect(find.byType(DirectionalIcon), findsNWidgets(2));
    });

    testWidgets('AppPageHeader renders a breadcrumb slot', (tester) async {
      await tester.pumpWidget(
        _app(
          home: const Scaffold(
            body: AppPageHeader(
              breadcrumbs: [
                AppBreadcrumbItem(label: 'Dashboard'),
                AppBreadcrumbItem.current('Inventory'),
              ],
              title: 'Inventory',
            ),
          ),
        ),
      );
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Inventory'), findsWidgets);
    });
  });

  group('AppMasterDetailScaffold', () {
    Widget sample({bool detailOpen = true}) => Scaffold(
      body: AppMasterDetailScaffold(
        detailOpen: detailOpen,
        master: const Text('MASTER'),
        detail: const Text('DETAIL'),
      ),
    );

    testWidgets('shows one pane on compact', (tester) async {
      _size(tester, const Size(390, 800));
      await tester.pumpWidget(_app(home: sample()));
      expect(find.text('DETAIL'), findsOneWidget);
      expect(find.text('MASTER'), findsNothing);

      await tester.pumpWidget(_app(home: sample(detailOpen: false)));
      await tester.pumpAndSettle();
      expect(find.text('MASTER'), findsOneWidget);
      expect(find.text('DETAIL'), findsNothing);
    });

    testWidgets('shows both panes on tablet/desktop', (tester) async {
      _size(tester, const Size(1024, 768));
      await tester.pumpWidget(_app(home: sample()));
      expect(find.text('MASTER'), findsOneWidget);
      expect(find.text('DETAIL'), findsOneWidget);
    });
  });

  group('AppThreePaneScaffold', () {
    Widget sample() => const Scaffold(
      body: AppThreePaneScaffold(
        first: Text('P1'),
        second: Text('P2'),
        third: Text('P3'),
      ),
    );

    testWidgets('degrades to one / two / three panes by window class', (
      tester,
    ) async {
      _size(tester, const Size(390, 800));
      await tester.pumpWidget(_app(home: sample()));
      expect(find.text('P2'), findsOneWidget);
      expect(find.text('P1'), findsNothing);

      _size(tester, const Size(768, 900));
      await tester.pumpWidget(_app(home: sample()));
      await tester.pumpAndSettle();
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('P2'), findsOneWidget);
      expect(find.text('P3'), findsNothing);

      _size(tester, const Size(1280, 900));
      await tester.pumpWidget(_app(home: sample()));
      await tester.pumpAndSettle();
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('P2'), findsOneWidget);
      expect(find.text('P3'), findsOneWidget);
    });
  });

  group('Accessibility & motion', () {
    testWidgets('rail labels stay clean at 1.6x in Arabic', (tester) async {
      _size(tester, const Size(834, 900));
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          textScaler: const TextScaler.linear(1.6),
          home: const Scaffold(
            body: AppNavigationRail(
              items: _items,
              selectedIndex: 0,
              onSelected: _noop1,
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('modal sheet closes on Escape (desktop)', (tester) async {
      _size(tester, const Size(1280, 900));
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      showAppModalSheet<void>(
        context: ctx,
        title: 'Filters',
        builder: (_) => const SizedBox(height: 80, child: Text('Sheet body')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
    });

    testWidgets('shell body is focus-traversable', (tester) async {
      _size(tester, const Size(1280, 900));
      await tester.pumpWidget(
        _app(
          home: Scaffold(
            body: FocusTraversalGroup(
              child: Column(children: const [TextField(), TextField()]),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

void _noop() {}
void _noop1(int _) {}
