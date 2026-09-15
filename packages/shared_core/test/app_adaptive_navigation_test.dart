import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  const items = [
    AppNavItem(
      selectedIcon: Icons.home,
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    AppNavItem(
      selectedIcon: Icons.settings,
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  const sixItems = [
    AppNavItem(
      selectedIcon: Icons.home_rounded,
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    AppNavItem(
      selectedIcon: Icons.track_changes_rounded,
      icon: Icons.track_changes_outlined,
      label: 'Status',
    ),
    AppNavItem(
      selectedIcon: Icons.calendar_month_rounded,
      icon: Icons.calendar_month_outlined,
      label: 'Bookings',
    ),
    AppNavItem(
      selectedIcon: Icons.fact_check_rounded,
      icon: Icons.fact_check_outlined,
      label: 'Approvals',
    ),
    AppNavItem(
      selectedIcon: Icons.directions_car_rounded,
      icon: Icons.directions_car_outlined,
      label: 'Vehicles',
    ),
    AppNavItem(
      selectedIcon: Icons.person_rounded,
      icon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  group('AppAdaptiveNavigationFrame', () {
    testWidgets('uses only body content on compact screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 800)),
            child: AppAdaptiveNavigationFrame(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(AppNavigationRail), findsNothing);
    });

    testWidgets('uses the shared rail on wider screens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: AppAdaptiveNavigationFrame(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(AppNavigationRail), findsOneWidget);
      // Compact rail keeps horizontal space for content and labels icons via
      // tooltips instead of a stock label row.
      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(
        tester.getSize(find.byTooltip('Settings')).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('extends the rail with labels on the largest screens', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1600, 900)),
            child: AppAdaptiveNavigationFrame(
              items: items,
              selectedIndex: 0,
              onSelected: (_) {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(AppNavigationRail), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('AppBottomNavigation', () {
    testWidgets('exposes every destination and reports selection', (
      tester,
    ) async {
      var selected = 0;
      await _pumpBar(tester, items, onSelected: (value) => selected = value);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      expect(selected, 1);
    });

    testWidgets('fires one selection haptic for a genuinely new destination', (
      tester,
    ) async {
      final haptics = <Object?>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await _pumpBar(tester, items, selectedIndex: 1, onSelected: (_) {});

      // Re-tapping the active destination must not buzz again.
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(haptics, isEmpty);

      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(haptics, ['HapticFeedbackType.selectionClick']);
    });

    testWidgets('marks the active destination as selected for a11y', (
      tester,
    ) async {
      await _pumpBar(tester, items, selectedIndex: 1);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.selected == true &&
              widget.properties.label == 'Settings',
        ),
        findsOneWidget,
      );
    });

    testWidgets('presents a dot badge and announces it semantically', (
      tester,
    ) async {
      await _pumpBar(tester, items, badgeIndices: const {1});

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Settings, new activity',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
        findsOneWidget,
      );
    });

    testWidgets('presents a numeric badge when a real count exists', (
      tester,
    ) async {
      await _pumpBar(tester, items, badgeCounts: const {1: 4});

      expect(find.text('4'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Settings, 4 new',
        ),
        findsOneWidget,
      );
    });

    testWidgets('stays usable on the smallest supported phone', (tester) async {
      await _pumpBar(tester, sixItems, size: const Size(320, 640));

      expect(tester.takeException(), isNull);
      // 320px cannot carry six destinations, so the safe overflow appears.
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('survives an increased text scale', (tester) async {
      await _pumpBar(
        tester,
        sixItems,
        textScaler: const TextScaler.linear(1.6),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('renders in dark theme without hardcoded light colours', (
      tester,
    ) async {
      await _pumpBar(
        tester,
        sixItems,
        theme: AppTheme.dark(BrandConfig.orient),
        badgeIndices: const {0},
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('destination overflow', () {
    testWidgets('collapses a six-destination bar into a single More slot', (
      tester,
    ) async {
      await _pumpBar(tester, sixItems);

      // Four primary destinations plus More keep every slot readable.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Approvals'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
      expect(find.text('Vehicles'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('opens More and reaches an overflow destination', (
      tester,
    ) async {
      var selected = 0;
      await _pumpBar(tester, sixItems, onSelected: (value) => selected = value);

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();

      expect(selected, 4);
    });

    testWidgets(
      'marks the overflow slot selected when it holds the active tab',
      (tester) async {
        await _pumpBar(tester, sixItems, selectedIndex: 5);

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.selected == true &&
                widget.properties.label == 'More',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('surfaces activity hiding inside the overflow slot', (
      tester,
    ) async {
      await _pumpBar(tester, sixItems, badgeCounts: const {5: 3});

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'More, 3 new',
        ),
        findsOneWidget,
      );
    });
  });

  group('AppNavDrawer', () {
    testWidgets('lists every destination and reports selection', (
      tester,
    ) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            drawer: AppNavDrawer(
              title: 'Orient CRM',
              subtitle: 'Sales workspace',
              items: sixItems,
              selectedIndex: 0,
              badgeCounts: const {1: 12},
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      );

      final state = tester.state<ScaffoldState>(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Orient CRM'), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();
      expect(selected, 4);
    });
  });
}

Future<void> _pumpBar(
  WidgetTester tester,
  List<AppNavItem> items, {
  int selectedIndex = 0,
  ValueChanged<int>? onSelected,
  Set<int> badgeIndices = const {},
  Map<int, int> badgeCounts = const {},
  Size size = const Size(390, 844),
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ?? AppTheme.light(BrandConfig.orient),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: Scaffold(
        bottomNavigationBar: AppBottomNavigation(
          items: items,
          selectedIndex: selectedIndex,
          onSelected: onSelected ?? (_) {},
          badgeIndices: badgeIndices,
          badgeCounts: badgeCounts,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
