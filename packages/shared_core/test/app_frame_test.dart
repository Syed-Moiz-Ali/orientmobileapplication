// Phase-1e-i widget tests: AppScaffold, AppAppBar, AppBottomNav,
// AppNavRail, AppSegmentedControl, AppPillTabs.
//
// Covers AA contrast pairs (active/inactive nav labels, active icon,
// unselected/selected segment labels vs the sunken track/chip,
// pill-tab ink >= 4.5/3.0; the chip-vs-track boundary is measured and
// documented as non-color-cued), state behavior (sticky action,
// refresh wrapper, nav selection, option changes, >5 assert), RTL (back
// button mirrors, tabs row mirrors) and text scale 1.3x.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Exact WCAG 2.x relative luminance (kept in sync with the swatch harness).
double _luminance(Color c) {
  double lin(double v) => v <= 0.04045
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _ratio(Color a, Color b) {
  final l1 = _luminance(a), l2 = _luminance(b);
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

Widget _wrap(
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: child,
        ),
      ),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
}) async {
  await tester.pumpWidget(
    _wrap(child, dark: dark, rtl: rtl, scale: scale),
  );
  await tester.pump();
}

const _navItems = [
  AppBottomNavItem(label: 'Home', icon: Icons.home_outlined),
  AppBottomNavItem(
      label: 'Bookings', icon: Icons.calendar_month_outlined, badgeCount: 3),
  AppBottomNavItem(label: 'Activity', icon: Icons.timeline_outlined),
  AppBottomNavItem(label: 'Wallet', icon: Icons.wallet_outlined),
  AppBottomNavItem(label: 'More', icon: Icons.more_horiz_rounded),
];

void main() {
  group('AppScaffold', () {
    testWidgets('renders body + sticky action fires', (tester) async {
      var tapped = 0;
      var secondary = 0;
      await _pump(
        tester,
        AppScaffold(
          stickyActionLabel: 'Save changes',
          onStickyAction: () => tapped++,
          stickySecondaryLabel: 'Discard',
          onStickySecondary: () => secondary++,
          body: const Text('Body content'),
        ),
      );
      expect(find.text('Body content'), findsOneWidget);
      await tester.tap(find.text('Save changes'));
      expect(tapped, 1);
      await tester.tap(find.text('Discard'));
      expect(secondary, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no sticky bar without labels; refresh iff onRefresh',
        (tester) async {
      await _pump(
        tester,
        const AppScaffold(body: Text('Plain')),
      );
      expect(find.text('Plain'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsNothing);

      await _pump(
        tester,
        AppScaffold(onRefresh: () async {}, body: const Text('Pull')),
      );
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacks sticky action above bottom nav', (tester) async {
      await _pump(
        tester,
        AppScaffold(
          stickyActionLabel: 'Save changes',
          onStickyAction: () {},
          bottomNavigationBar: AppBottomNav(
            items: _navItems,
            currentIndex: 0,
            onTap: (_) {},
          ),
          body: const Text('Stacked'),
        ),
      );
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      // Action stacks ABOVE the nav: its center sits higher on screen.
      final actionDy = tester.getCenter(find.text('Save changes')).dy;
      final navDy = tester.getCenter(find.text('Home')).dy;
      expect(actionDy, lessThan(navDy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x safe', (tester) async {
      await _pump(
        tester,
        AppScaffold(
          stickyActionLabel: 'Save changes',
          onStickyAction: () {},
          body: const Text('A long body line that must keep wrapping '
              'instead of overflowing at large text scales'),
        ),
        scale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppAppBar', () {
    testWidgets('56 high, back button mirrors in RTL', (tester) async {
      await _pump(
        tester,
        const AppScaffold(
          appBar: AppAppBar(title: 'Bookings', showBack: true),
          body: Text('x'),
        ),
      );
      final bar = tester.getSize(find.byType(AppBar));
      expect(bar.height, 56);
      final ltrDx = tester.getCenter(find.byType(DirectionalIcon)).dx;

      await _pump(
        tester,
        const AppScaffold(
          appBar: AppAppBar(title: 'Bookings', showBack: true),
          body: Text('x'),
        ),
        rtl: true,
      );
      final rtlDx = tester.getCenter(find.byType(DirectionalIcon)).dx;
      expect(ltrDx, lessThan(200));
      expect(rtlDx, greaterThan(600));
      expect(tester.takeException(), isNull);
    });

    testWidgets('back falls back to maybePop; divider opt-in',
        (tester) async {
      await _pump(
        tester,
        const AppScaffold(
          appBar: AppAppBar(title: 'T', showBack: true, showDivider: true),
          body: Text('x'),
        ),
      );
      // Hairline below the bar: 1 px container in theme outline.
      final scheme = AppTheme.light(BrandConfig.orient).colorScheme;
      final hairline = find.byWidgetPredicate(
        (w) => w is Container && w.color == scheme.outline,
      );
      expect(hairline, findsOneWidget);
      await tester.tap(find.byType(DirectionalIcon));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('large builds a pinned SliverAppBar', (tester) async {
      await _pump(
        tester,
        const CustomScrollView(
          slivers: [AppAppBar.large(title: 'Activity')],
        ),
      );
      // AppAppBar.large is a sliver builder, NOT for Scaffold.appBar: it
      // returns a SliverAppBar type (see the "do NOT use" doc on the class).
      expect(find.byType(AppAppBar), findsOneWidget);
      expect(find.byType(SliverAppBar), findsOneWidget);
      final sliver = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.pinned, isTrue);
      expect(sliver.expandedHeight, 144);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x safe', (tester) async {
      await _pump(
        tester,
        const AppScaffold(
          appBar: AppAppBar(title: 'A very long screen title', showBack: true),
          body: Text('x'),
        ),
        scale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppBottomNav + AppNavRail', () {
    testWidgets('selects + fires index; badge shows', (tester) async {
      var index = -1;
      await _pump(
        tester,
        AppBottomNav(
          items: _navItems,
          currentIndex: 0,
          onTap: (i) => index = i,
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('Wallet'));
      expect(index, 3);
      // Selected state is exposed to screen readers.
      final home = tester.getSemantics(find.text('Home'));
      expect(home.flagsCollection.isSelected, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects more than 5 items', (tester) async {
      await _pump(
        tester,
        AppBottomNav(
          items: const [..._navItems, ..._navItems],
          currentIndex: 0,
          onTap: (_) {},
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('rail renders + selects; 1.3x safe', (tester) async {
      var index = -1;
      await _pump(
        tester,
        SizedBox(
          height: 400,
          child: Row(
            children: [
              AppNavRail(
                items: _navItems,
                currentIndex: 1,
                onTap: (i) => index = i,
              ),
              const Expanded(child: Text('Content')),
            ],
          ),
        ),
        scale: 1.3,
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      // Rail tap fires the destination index (mirrors the bottom-nav test).
      await tester.tap(find.text('Wallet'));
      expect(index, 3);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSegmentedControl + AppPillTabs', () {
    const options = [
      AppSegmentedOption(value: 'day', label: 'Day'),
      AppSegmentedOption(value: 'week', label: 'Week'),
      AppSegmentedOption(value: 'month', label: 'Month'),
    ];

    testWidgets('changes value + exposes selected Semantics',
        (tester) async {
      var value = 'day';
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => AppSegmentedControl<String>(
              options: options,
              selected: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Week'));
      await tester.pump();
      expect(value, 'week');
      expect(
        tester.getSemantics(find.text('Week')).flagsCollection.isSelected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrollable variant scrolls; tabs row mirrors in RTL',
        (tester) async {
      await _pump(
        tester,
        AppSegmentedControl<String>.scrollable(
          options: const [
            ...options,
            AppSegmentedOption(value: 'year', label: 'Year'),
            AppSegmentedOption(value: 'all', label: 'All time'),
          ],
          selected: 'day',
          onChanged: (_) {},
        ),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await _pump(
        tester,
        AppPillTabs<String>(
          options: options,
          selected: 'day',
          onChanged: (_) {},
        ),
        rtl: true,
      );
      // Mirrored row: the first option sits at the inline-start (right).
      final firstDx = tester.getCenter(find.text('Day')).dx;
      final lastDx = tester.getCenter(find.text('Month')).dx;
      expect(firstDx, greaterThan(lastDx));
      expect(tester.takeException(), isNull);
    });

    testWidgets('pill tabs change value; 1.3x safe', (tester) async {
      var value = 'day';
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(1.3),
              ),
              child: AppPillTabs<String>(
                options: options,
                selected: value,
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Month'));
      await tester.pump();
      expect(value, 'month');
      expect(tester.takeException(), isNull);
    });
  });

  group('AA contrast (measured, light + dark)', () {
    for (final dark in [false, true]) {
      final scheme = (dark
              ? AppTheme.dark(BrandConfig.orient)
              : AppTheme.light(BrandConfig.orient))
          .colorScheme;
      final tokens = dark ? AppTokens.dark : AppTokens.light;
      // The segmented track is the semantic surfaceSunken token (NOT a
      // surfaceContainer* role, even though AppTheme maps those roles to the
      // same hex — the assertion below pins the spec token directly).
      final sunken = (dark
              ? AppSemanticColors.dark
              : AppSemanticColors.light)
          .surfaceSunken;
      test('active label ${dark ? 'dark' : 'light'} >= 4.5', () {
        expect(_ratio(scheme.onSurface, scheme.surface), greaterThan(4.5));
      });
      test('inactive label ${dark ? 'dark' : 'light'} >= 4.5', () {
        expect(
          _ratio(scheme.onSurfaceVariant, scheme.surface),
          greaterThan(4.5),
        );
      });
      test('active icon ${dark ? 'dark' : 'light'} >= 3.0', () {
        expect(_ratio(scheme.primary, scheme.surface), greaterThan(3.0));
      });
      test('pill-tab ink ${dark ? 'dark' : 'light'} >= 4.5', () {
        expect(
          _ratio(tokens.accentInk, tokens.accentSoft),
          greaterThan(4.5),
        );
      });
      test('unselected segment label vs track ${dark ? 'dark' : 'light'} '
          '>= 4.5', () {
        // Text sits directly on the track, so the text bar (4.5) applies.
        // NOTE: onSurfaceVariant is only 4.40:1 on the sunken track in
        // light (measured 2026-10-20) — the widget therefore inks
        // unselected labels with onSurface (16.49 light / 18.19 dark).
        expect(_ratio(scheme.onSurface, sunken), greaterThan(4.5));
      });
      test('selected segment label on chip ${dark ? 'dark' : 'light'} '
          '>= 4.5', () {
        // Selected text sits on the surface chip, not the track.
        expect(_ratio(scheme.onSurface, scheme.surface), greaterThan(4.5));
      });
      test('selected chip vs track ${dark ? 'dark' : 'light'} documented', () {
        // The surface chip on the sunken track is ~1.08:1 light / ~1.03:1
        // dark by design (a sunken track reads via recess, not via a chip
        // ring), so the 3.0 non-text bar intentionally does NOT apply to
        // this boundary. Selection is never color-alone: e1 shadow in
        // light, outline border in dark, semibold weight + `selected`
        // Semantics in both (asserted in the widget test below).
        expect(_ratio(scheme.surface, sunken), lessThan(3.0));
      });
    }

    testWidgets('selected segment keeps non-color cues', (tester) async {
      const segOptions = [
        AppSegmentedOption(value: 'day', label: 'Day'),
        AppSegmentedOption(value: 'week', label: 'Week'),
      ];
      for (final dark in [false, true]) {
        // pumpAndSettle (not _pump): switching themeMode runs the
        // AnimatedTheme interpolation, so a single pump would still read
        // the previous brightness's colors.
        await tester.pumpWidget(
          _wrap(
            AppSegmentedControl<String>(
              options: segOptions,
              selected: 'day',
              onChanged: (_) {},
            ),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        final scheme = (dark
                ? AppTheme.dark(BrandConfig.orient)
                : AppTheme.light(BrandConfig.orient))
            .colorScheme;
        final chip = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color == scheme.surface,
        );
        expect(chip, findsOneWidget);
        final deco =
            tester.widget<Container>(chip).decoration! as BoxDecoration;
        if (dark) {
          expect(deco.border, isNotNull);
        } else {
          expect(deco.boxShadow, isNotNull);
        }
      }
      expect(tester.takeException(), isNull);
    });
  });
}
