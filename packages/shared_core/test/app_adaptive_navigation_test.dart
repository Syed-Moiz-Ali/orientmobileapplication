import 'package:flutter/material.dart';
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
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses a navigation rail on wider screens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
    expect(find.byType(NavigationRail), findsOneWidget);
  });
}
