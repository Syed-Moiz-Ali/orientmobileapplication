// Search-affordance guard (U1 + C16 one path per task).
//
// Pins the ui/integration-1 search-affordance audit contract at the shared
// composition layer: every home shell shows EXACTLY ONE visible search icon,
// and the customer vehicles list keeps its sanctioned U1 exception (search
// icon ONLY when > 5 items; <= 5 cards-only).
//
// Ruling (a) locus (ui/fix-rulings): the single visible affordance sits in
// the FIRST header row at the top-right/end-side — either the shell AppBar
// action cluster (post-ruling owner: AppAppBar WITH the trigger, page shows
// none) or the page-header trailing Row (supervisor/tech/advisor/customer
// header row, vehicles find-aids row). Never stacked below a subtitle and
// never mid-page. The COUNT guards below are unchanged; the LOCUS group
// added for ruling (a) pins the position per shell.
//
// Why shared_core: the five home shells live in owner_app / staff_app /
// customer_app, which all depend on shared_core — the dependency arrow points
// the wrong way to pump those shells from here (a dev-dependency would be a
// pub cycle). So this guard pins the shared chrome compositions each home
// mirrors post-audit (DashboardShell + AppAppBar / WorkspaceAppBar + header
// search row), using the same widgets, same U1 icon
// (Icons.search_rounded) and the same visibility rule the audit applied
// (shell trigger hidden on the home tab, header U1 kept — except post-ruling
// owner, which flips to shell-kept/header-removed with the same palette).
// Per-app regression is additionally covered by the scoped search finders in
// the apps' own tests (owner before-capture + characterization,
// supervisor/technician after-captures, advisor single-entry pins).
//
// Harness: bundled fonts (loaded once in setUpAll),
// debugShowCheckedModeBanner false, shadows restored via addTearDown, BOTH
// connectivity mocks (check/checkConnectivity -> List + status stream),
// en + ar locales with delegates + AppTheme. Not a capture file: no
// baseline tag, no goldens.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('packages/shared_core/Plus Jakarta Sans', [
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
  ]);

  var dir = Directory(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 10; i++) {
    final candidate = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (candidate.existsSync()) {
      final loader = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(ByteData.sublistView(candidate.readAsBytesSync())),
        );
      await loader.load();
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

/// Visible search affordances on a pumped shell: the U1 contract icon.
/// skipOffstage defaults to true, so hidden (audit-removed) triggers are
/// never counted — only what the user can see and tap.
Finder _visibleSearchIcons() => find.byIcon(Icons.search_rounded);

/// LOCUS assertion (ruling a, ui/fix-rulings): the single visible search
/// affordance sits in the FIRST header row at the top-right/end-side —
/// either the shell AppBar action cluster or the page-header trailing Row —
/// never stacked below a subtitle and never mid-page.
///
/// Checks (position-only, no logic/palette changes):
/// 1) first header band: center-y in the top ~35% of the viewport;
/// 2) end-side: right half in LTR, left half in RTL (bell/avatar cluster);
/// 3) same row as [rowTitle]: |dy| < 48 (stacked-below-subtitle would sit a
///    full text row lower, mid-page far lower);
/// 4) ancestor is the AppBar action cluster OR a header trailing Row.
void _expectTopEndLocus(WidgetTester tester, {required String rowTitle}) {
  final search = _visibleSearchIcons();
  expect(
    search,
    findsOneWidget,
    reason: 'locus needs exactly one visible search icon',
  );
  final searchCenter = tester.getCenter(search);
  final size = MediaQuery.sizeOf(tester.element(search));
  final isRtl =
      Directionality.of(tester.element(search)) == TextDirection.rtl;
  expect(
    searchCenter.dy,
    lessThan(size.height * 0.35),
    reason:
        'search must sit in the first header band '
        '(dy ${searchCenter.dy.toStringAsFixed(1)} on ${size.height.toStringAsFixed(0)}h), never mid-page',
  );
  if (isRtl) {
    expect(
      searchCenter.dx,
      lessThan(size.width * 0.5),
      reason:
          'search must sit end-side in RTL '
          '(dx ${searchCenter.dx.toStringAsFixed(1)} on ${size.width.toStringAsFixed(0)}w)',
    );
  } else {
    expect(
      searchCenter.dx,
      greaterThan(size.width * 0.5),
      reason:
          'search must sit top-right in LTR '
          '(dx ${searchCenter.dx.toStringAsFixed(1)} on ${size.width.toStringAsFixed(0)}w)',
    );
  }
  expect(
    find.text(rowTitle),
    findsWidgets,
    reason: 'locus row-mate title "$rowTitle" must be visible',
  );
  final titleCenter = tester.getCenter(find.text(rowTitle).first);
  expect(
    (searchCenter.dy - titleCenter.dy).abs(),
    lessThan(48),
    reason:
        'search must share the first header row with "$rowTitle" '
        '(Δdy ${(searchCenter.dy - titleCenter.dy).abs().toStringAsFixed(1)}), never stacked below a subtitle',
  );
  final inAppBar =
      find.ancestor(of: search, matching: find.byType(AppBar)).evaluate().isNotEmpty;
  final inRow =
      find.ancestor(of: search, matching: find.byType(Row)).evaluate().isNotEmpty;
  expect(
    inAppBar || inRow,
    isTrue,
    reason: 'search must live in the AppBar action cluster or a header trailing Row',
  );
}

/// Post-audit staff/owner home chrome: spec-C8 [AppAppBar] WITHOUT the shell
/// search trigger (hidden on the home tab) + a header row carrying the ONE
/// kept U1 search action. Mirrors owner `_OwnerChrome` (tab 0),
/// supervisor `_SupervisorChrome` (floor tab) and technician `_TechChrome`
/// (Today tab) after the audit fix.
Widget _specBarHomeShell({required String title}) {
  return DashboardShell(
    showOfflineBanner: false,
    appBar: AppAppBar(title: title, showDivider: true),
    body: ListView(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Home header')),
            AppIconButton(
              icon: Icons.search_rounded,
              onPressed: () {},
              tooltip: 'Search',
            ),
          ],
        ),
      ],
    ),
  );
}

/// Post-audit advisor home chrome: no shell bar at all (product exception) +
/// the greeting header owning the ONE search icon. Mirrors
/// `_AdvisorHomeHeader` (shell appBar null, Ctrl+K invisible).
Widget _advisorHomeShell() {
  return DashboardShell(
    showOfflineBanner: false,
    body: ListView(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Good morning')),
            AppIconButton(
              icon: Icons.search_rounded,
              onPressed: () {},
              tooltip: 'Search',
            ),
          ],
        ),
      ],
    ),
  );
}

/// Post-audit customer home chrome: [WorkspaceAppBar] with NO onSearch (the
/// customer shell never had a bar trigger) + the greeting header owning the
/// ONE search icon. Mirrors `CustomerScaffold` + `CustomerHomeHeader`.
Widget _customerHomeShell() {
  return DashboardShell(
    showOfflineBanner: false,
    appBar: WorkspaceAppBar(
      title: 'Garage',
      subtitle: 'Sub',
      actions: [
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
          tooltip: 'Notifications',
        ),
      ],
    ),
    body: ListView(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Hello')),
            AppIconButton(
              icon: Icons.search_rounded,
              onPressed: () {},
              tooltip: 'Search',
            ),
          ],
        ),
      ],
    ),
  );
}

/// Post-ruling owner home chrome (ruling a, ui/fix-rulings): spec-C8
/// [AppAppBar] WITH the shell search trigger (top-right action cluster) +
/// a page header showing NO search action. Mirrors flipped `_OwnerChrome`
/// (tab 0, same `openOwnerSearch` palette) + `_HomeHeader` without the
/// page icon. Same one-icon count, new locus (shell-kept).
Widget _shellSearchHomeShell({required String title}) {
  return DashboardShell(
    showOfflineBanner: false,
    appBar: AppAppBar(
      title: title,
      showDivider: true,
      actions: [
        AppIconButton(
          icon: Icons.search_rounded,
          onPressed: () {},
          tooltip: 'Search',
        ),
      ],
    ),
    body: ListView(
      children: const [
        Row(
          children: [
            Expanded(child: Text('Home header')),
          ],
        ),
      ],
    ),
  );
}

/// Customer vehicles list header (sanctioned U1 exception): the search
/// find-aid appears ONLY when the loaded list has MORE THAN 5 items.
///
/// Mirrors the real `customer_vehicles_tab` header (ruling-a compliant):
/// title + find-aids share the SAME first Row (top-right/end-side), the
/// subtitle spans full width below — never AppPageHeader, whose compact
/// layout would stack the action below the subtitle.
Widget _vehiclesListShell({required int itemCount}) {
  final showFindAids = itemCount > 5;
  return DashboardShell(
    showOfflineBanner: false,
    appBar: WorkspaceAppBar(title: 'Vehicles', subtitle: 'Sub'),
    body: ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: Text('My vehicles')),
                if (showFindAids)
                  AppIconButton(
                    icon: Icons.search_rounded,
                    onPressed: () {},
                    tooltip: 'Search vehicles',
                  ),
              ],
            ),
            Text('$itemCount'),
          ],
        ),
      ],
    ),
  );
}

/// Pre-audit duplication (negative control): shell trigger AND header action
/// both visible. The audit removed exactly this shape; the guard pins that
/// it counts as two so a reintroduction fails loudly.
Widget _duplicatedShell() {
  return DashboardShell(
    showOfflineBanner: false,
    appBar: AppAppBar(
      title: 'Home',
      actions: [
        AppIconButton(
          icon: Icons.search_rounded,
          onPressed: () {},
          tooltip: 'Search',
        ),
      ],
    ),
    body: ListView(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Home header')),
            AppIconButton(
              icon: Icons.search_rounded,
              onPressed: () {},
              tooltip: 'Search',
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _pumpShell(
  WidgetTester tester,
  Widget shell, {
  Locale locale = const Locale('en'),
  Size surface = const Size(360, 800),
  double textScale = 1.0,
}) async {
  final oldShadows = debugDisableShadows;
  debugDisableShadows = false;
  // Restored even when the pump body throws, otherwise the framework
  // painting-vars invariant fails every later test in the file.
  addTearDown(() => debugDisableShadows = oldShadows);
  tester.view.physicalSize = Size(surface.width * 3.0, surface.height * 3.0);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
    MethodCall call,
  ) async {
    if (call.method == 'checkConnectivity' || call.method == 'check') {
      return <String>['wifi'];
    }
    return null;
  });
  binding.defaultBinaryMessenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(
      onListen: (Object? args, MockStreamHandlerEventSink events) {},
    ),
  );
  addTearDown(
    () => binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          SharedCoreLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: shell,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
  debugDisableShadows = oldShadows;
}

void main() {
  setUpAll(() async {
    await _loadFonts();
  });

  group('search affordance: exactly one visible icon per home (en)', () {
    testWidgets('owner home chrome shows one search icon', (tester) async {
      await _pumpShell(tester, _specBarHomeShell(title: 'Dashboard'));
      expect(_visibleSearchIcons(), findsOneWidget);
    });

    testWidgets('supervisor floor home chrome shows one search icon', (
      tester,
    ) async {
      await _pumpShell(tester, _specBarHomeShell(title: 'Floor'));
      expect(_visibleSearchIcons(), findsOneWidget);
    });

    testWidgets('technician today home chrome shows one search icon', (
      tester,
    ) async {
      await _pumpShell(tester, _specBarHomeShell(title: 'Today'));
      expect(_visibleSearchIcons(), findsOneWidget);
    });

    testWidgets('advisor home chrome shows one search icon', (tester) async {
      await _pumpShell(tester, _advisorHomeShell());
      expect(_visibleSearchIcons(), findsOneWidget);
    });

    testWidgets('customer home chrome shows one search icon', (tester) async {
      await _pumpShell(tester, _customerHomeShell());
      expect(_visibleSearchIcons(), findsOneWidget);
    });
  });

  group('search affordance: same single path in ar', () {
    testWidgets('owner home chrome shows one search icon (ar)', (
      tester,
    ) async {
      await _pumpShell(
        tester,
        _specBarHomeShell(title: 'Dashboard'),
        locale: const Locale('ar'),
      );
      expect(_visibleSearchIcons(), findsOneWidget);
    });

    testWidgets('advisor home chrome shows one search icon (ar)', (
      tester,
    ) async {
      await _pumpShell(
        tester,
        _advisorHomeShell(),
        locale: const Locale('ar'),
      );
      expect(_visibleSearchIcons(), findsOneWidget);
    });

    testWidgets('customer home chrome shows one search icon (ar)', (
      tester,
    ) async {
      await _pumpShell(
        tester,
        _customerHomeShell(),
        locale: const Locale('ar'),
      );
      expect(_visibleSearchIcons(), findsOneWidget);
    });
  });

  group('search affordance: vehicles list sanctioned exception', () {
    testWidgets('five or fewer vehicles show no search icon', (tester) async {
      await _pumpShell(tester, _vehiclesListShell(itemCount: 5));
      expect(_visibleSearchIcons(), findsNothing);
    });

    testWidgets('one vehicle shows no search icon', (tester) async {
      await _pumpShell(tester, _vehiclesListShell(itemCount: 1));
      expect(_visibleSearchIcons(), findsNothing);
    });

    testWidgets('more than five vehicles show exactly one search icon', (
      tester,
    ) async {
      await _pumpShell(tester, _vehiclesListShell(itemCount: 6));
      expect(_visibleSearchIcons(), findsOneWidget);
    });
  });

  group('search affordance: matrix extremes keep one path', () {
    testWidgets('320px at 1.3x still shows exactly one icon per home', (
      tester,
    ) async {
      const small = Size(320, 568);
      await _pumpShell(
        tester,
        _specBarHomeShell(title: 'Dashboard'),
        surface: small,
        textScale: 1.3,
      );
      expect(_visibleSearchIcons(), findsOneWidget);

      await _pumpShell(
        tester,
        _advisorHomeShell(),
        surface: small,
        textScale: 1.3,
      );
      expect(_visibleSearchIcons(), findsOneWidget);

      await _pumpShell(
        tester,
        _customerHomeShell(),
        surface: small,
        textScale: 1.3,
        locale: const Locale('ar'),
      );
      expect(_visibleSearchIcons(), findsOneWidget);
    });
  });

  group('search affordance: locus first header row end-side (ruling a)', () {
    testWidgets('post-ruling owner shell trigger sits top-right in AppBar', (
      tester,
    ) async {
      await _pumpShell(tester, _shellSearchHomeShell(title: 'Dashboard'));
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Dashboard');
    });

    testWidgets('header-row home shell keeps locus in trailing Row', (
      tester,
    ) async {
      await _pumpShell(tester, _specBarHomeShell(title: 'Dashboard'));
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Home header');
    });

    testWidgets('advisor header-row locus stays end-side', (tester) async {
      await _pumpShell(tester, _advisorHomeShell());
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Good morning');
    });

    testWidgets('customer header-row locus stays end-side', (tester) async {
      await _pumpShell(tester, _customerHomeShell());
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Hello');
    });

    testWidgets('vehicles find-aid locus sits in trailing Row', (
      tester,
    ) async {
      await _pumpShell(tester, _vehiclesListShell(itemCount: 6));
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'My vehicles');
    });

    testWidgets('shell locus mirrors end-side in ar', (tester) async {
      await _pumpShell(
        tester,
        _shellSearchHomeShell(title: 'Dashboard'),
        locale: const Locale('ar'),
      );
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Dashboard');
    });

    testWidgets('customer locus mirrors end-side in ar', (tester) async {
      await _pumpShell(
        tester,
        _customerHomeShell(),
        locale: const Locale('ar'),
      );
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Hello');
    });

    testWidgets('320px at 1.3x keeps shell locus top-right', (tester) async {
      await _pumpShell(
        tester,
        _shellSearchHomeShell(title: 'Dashboard'),
        surface: const Size(320, 568),
        textScale: 1.3,
      );
      expect(_visibleSearchIcons(), findsOneWidget);
      _expectTopEndLocus(tester, rowTitle: 'Dashboard');
    });
  });

  group('search affordance: negative control', () {
    testWidgets('shell trigger plus header action counts as two', (
      tester,
    ) async {
      // The pre-audit duplication the audit collapsed (header kept, shell
      // hidden). If this shape ever returns, the one-icon guards above fail.
      await _pumpShell(tester, _duplicatedShell());
      expect(_visibleSearchIcons(), findsNWidgets(2));
    });
  });
}
