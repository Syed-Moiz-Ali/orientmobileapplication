import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  const testNavItems = [
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: 'Today',
    ),
    AppNavItem(
      selectedIcon: Icons.assignment_rounded,
      icon: Icons.assignment_outlined,
      label: 'Jobs',
    ),
    AppNavItem(
      selectedIcon: Icons.bar_chart_rounded,
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
    ),
    AppNavItem(
      selectedIcon: Icons.person_rounded,
      icon: Icons.person_outlined,
      label: 'Profile',
    ),
  ];

  group('Phase 4: Unified ORIENT Shell Components', () {
    testWidgets('OrientBrandMark renders compact and expanded modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(
            body: Column(
              children: [
                OrientBrandMark(workspace: 'Advisor', compact: true),
                OrientBrandMark(workspace: 'Advisor'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('O'), findsNWidgets(2));
      expect(find.text('ORIENT'), findsOneWidget);
      expect(find.text('ADVISOR'), findsOneWidget);
    });

    testWidgets('AppBottomNavigation renders clean base, top border and active pill', (
      tester,
    ) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return AppBottomNavigation(
                  items: testNavItems,
                  selectedIndex: selected,
                  badgeCounts: const {1: 3},
                  onSelected: (i) => setState(() => selected = i),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('AppNavigationRail renders header and footer in compact mode', (
      tester,
    ) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: AppNavigationRail(
              items: testNavItems,
              selectedIndex: selected,
              onSelected: (i) => selected = i,
              header: const OrientBrandMark(workspace: 'Advisor', compact: true),
              footer: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          ),
        ),
      );

      expect(find.text('O'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    });

    testWidgets('AppNavigationRail renders header and footer in extended mode', (
      tester,
    ) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: AppNavigationRail(
              items: testNavItems,
              selectedIndex: selected,
              extended: true,
              onSelected: (i) => selected = i,
              header: const OrientBrandMark(workspace: 'Operations'),
              footer: const ListTile(
                dense: true,
                leading: CircleAvatar(child: Text('SA')),
                title: Text('Supervisor Ali'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('ORIENT'), findsOneWidget);
      expect(find.text('OPERATIONS'), findsOneWidget);
      expect(find.text('Supervisor Ali'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
    });

    testWidgets('AppAdaptiveNavigationFrame adapts across mobile, tablet, and desktop', (
      tester,
    ) async {
      final widths = [320.0, 390.0, 768.0, 1024.0, 1440.0];

      for (final width in widths) {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(BrandConfig.orient),
            home: Scaffold(
              body: AppAdaptiveNavigationFrame(
                items: testNavItems,
                selectedIndex: 0,
                onSelected: (_) {},
                headerBuilder: (ctx, ext) => OrientBrandMark(
                  workspace: 'Staff',
                  compact: !ext,
                ),
                footerBuilder: (ctx, ext) => Icon(
                  Icons.account_circle_outlined,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                child: Center(child: Text('Content Width $width')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Content Width $width'), findsOneWidget);

        if (width >= 600) {
          expect(find.byType(AppNavigationRail), findsOneWidget);
          expect(find.text('O'), findsOneWidget);
        } else {
          expect(find.byType(AppNavigationRail), findsNothing);
        }
      }
    });

    testWidgets('AppBottomNavigation remains accessible under 1.6x text scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.6),
            ),
            child: Scaffold(
              bottomNavigationBar: AppBottomNavigation(
                items: testNavItems,
                selectedIndex: 0,
                onSelected: (_) {},
              ),
              body: const Center(child: Text('Accessible Shell')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
    });
  });
}
