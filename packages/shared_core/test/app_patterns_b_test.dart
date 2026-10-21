// Phase-1P widget tests (Builder B): AppSearchPill, AppCarousel,
// AppMediaCard, AppListGroup, AppProfileHeader, AppSheetPicker.
//
// Covers presence/API, >= 48 dp targets, measured AA contrast pairs,
// chevron/divider RTL mirroring + ar rendering, 1.3x + 320px no-overflow,
// Semantics (headers, buttons, toggles, per-item nodes), sheet
// open/select/Show-N flow, carousel peek geometry (~2.2 visible), and
// no-border assertions where C16 forbids boxes.
//
// Harness: real MaterialIcons FontLoader in setUpAll,
// debugShowCheckedModeBanner: false, no network/file I/O in test bodies;
// sheet tests settle + dismiss cleanly.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

ThemeData _theme(bool dark) =>
    dark ? AppTheme.dark(BrandConfig.orient) : AppTheme.light(BrandConfig.orient);

Widget _wrap(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
  Locale? locale,
}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: MediaQuery(
        // fromView (like the capture harness): a bare MediaQueryData has
        // Size.zero, which would collapse AppBottomSheet's 90% max height.
        data: MediaQueryData.fromView(tester.view).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Center(child: child),
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
  Locale? locale,
}) async {
  await tester.pumpWidget(
    _wrap(tester, child, dark: dark, rtl: rtl, scale: scale, locale: locale),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
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
  });

  group('AA contrast pairs (phase-1P gate)', () {
    test('card title/meta ink on card surface, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final title = _ratio(scheme.onSurface, scheme.surface);
        final meta = _ratio(scheme.onSurfaceVariant, scheme.surface);
        debugPrint('1P title ${dark ? 'dark' : 'light'}=$title meta=$meta');
        expect(title, greaterThanOrEqualTo(4.5));
        expect(meta, greaterThanOrEqualTo(4.5));
      }
    });

    test('search pill query + hint ink on pill fill, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final query = _ratio(scheme.onSurface, scheme.surfaceContainerLow);
        final hint =
            _ratio(scheme.onSurfaceVariant, scheme.surfaceContainerLow);
        debugPrint('1P pill ${dark ? 'dark' : 'light'} query=$query hint=$hint');
        expect(query, greaterThanOrEqualTo(4.5));
        expect(hint, greaterThanOrEqualTo(4.5));
      }
    });

    test('section label ink on page canvas, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final canvas =
            dark ? AppDarkColors.canvas : AppColors.canvas;
        final ratio = _ratio(scheme.onSurfaceVariant, canvas);
        debugPrint('1P label ${dark ? 'dark' : 'light'}=$ratio');
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    });

    test('picker check cue on card surface (non-text, >= 3:1)', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final ratio = _ratio(scheme.primary, scheme.surface);
        debugPrint('1P check ${dark ? 'dark' : 'light'}=$ratio');
        expect(ratio, greaterThanOrEqualTo(3.0));
      }
    });

    test('hairline dividers are decorative-only (measured, both themes)', () {
      // Same standing rule as the phase-1c-i gate: the 1 px hairline does
      // not reach 3:1, so group boundaries are carried by spacing + the
      // leading icon rows, never by the divider alone.
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        expect(_ratio(scheme.outline, scheme.surface), lessThan(3.0));
      }
    });
  });

  group('AppSearchPill', () {
    testWidgets('renders hint + icon, tap fires, button semantics', (
      tester,
    ) async {
      var tapped = 0;
      await _pump(
        tester,
        AppSearchPill(hint: 'Search bookings', onTap: () => tapped++),
      );
      expect(find.text('Search bookings'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(tester.getSize(find.byType(AppSearchPill)).height,
          greaterThanOrEqualTo(48));
      final node = tester.getSemantics(find.byType(AppSearchPill));
      expect(node.flagsCollection.isButton, isTrue);
      // The node merges the pill label with the hint text below (same as
      // tappable AppSurfaceCard behavior); the label itself leads.
      expect(node.label.split('\n').first, 'Search bookings');
      await tester.tap(find.byType(AppSearchPill));
      expect(tapped, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('query display + clear action fires without pill tap', (
      tester,
    ) async {
      var tapped = 0;
      var cleared = 0;
      await _pump(
        tester,
        AppSearchPill(
          hint: 'Search bookings',
          query: 'oil change',
          onTap: () => tapped++,
          onClear: () => cleared++,
        ),
      );
      expect(find.text('\u2066oil change\u2069'), findsOneWidget);
      expect(find.text('Search bookings'), findsNothing);
      await tester.tap(find.byTooltip('Clear search'));
      expect(cleared, 1);
      expect(tapped, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no clear without onClear; inert without onTap', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppSearchPill(hint: 'Search', query: 'oil'),
      );
      expect(find.byIcon(Icons.clear_rounded), findsNothing);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);
      expect(
        tester.getSemantics(find.byType(AppSearchPill)).flagsCollection.isEnabled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('query text is LTR-locked with physical-left align', (
      tester,
    ) async {
      await _pump(
        tester,
        AppSearchPill(
          hint: 'Search',
          query: 'AED 240',
          onTap: () {},
        ),
        rtl: true,
      );
      final dir = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.text('\u2066AED 240\u2069'),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(dir.textDirection, TextDirection.ltr);
      final text = tester.widget<Text>(find.text('\u2066AED 240\u2069'));
      expect(text.textAlign, TextAlign.left);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320px + 1.3x + RTL + dark: no overflow', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppSearchPill(
            hint: 'A long hint that must ellipsize instead of overflowing',
            query: 'A long query that must ellipsize instead of overflowing',
            onTap: () {},
            onClear: () {},
          ),
        ),
        rtl: true,
        scale: 1.3,
        dark: true,
      );
      expect(find.byType(AppSearchPill), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppCarousel', () {
    List<Widget> cards(int n) => [
          for (var i = 0; i < n; i++)
            AppMediaCard(title: 'Card $i', meta: 'Meta $i'),
        ];

    testWidgets('header is a header; Show all fires', (tester) async {
      var seen = false;
      await _pump(
        tester,
        SizedBox(
          width: 390,
          child: AppCarousel(
            title: 'Recent bookings',
            subtitle: 'Last 7 days',
            seeAllLabel: 'Show all',
            onSeeAll: () => seen = true,
            children: cards(3),
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.text('Recent bookings'))
            .flagsCollection
            .isHeader,
        isTrue,
      );
      await tester.tap(find.text('Show all'));
      expect(seen, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('peeking next card (~2.2 visible) + cardExtent honored', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 390,
          child: AppCarousel(
            title: 'Recent bookings',
            cardExtent: 260,
            children: cards(3),
          ),
        ),
      );
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      final first = tester.getRect(find.text('Card 0'));
      final second = tester.getRect(find.text('Card 1'));
      // Card extent honored (text spans the 260-wide card minus padding).
      expect(first.width, lessThanOrEqualTo(260));
      // Second card peeks: starts inside the viewport, ends past its edge.
      expect(second.left, lessThan(viewport.right));
      expect(second.right, greaterThan(viewport.right));
      expect(tester.takeException(), isNull);
    });

    testWidgets('one Semantics node per item', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 390,
          child: AppCarousel(title: 'T', children: cards(3)),
        ),
      );
      for (var i = 0; i < 3; i++) {
        final node = tester.getSemantics(
          find.ancestor(
            of: find.text('Card $i'),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.label == 'Item ${i + 1} of 3',
            ),
          ),
        );
        // The node merges the item label with the card text below (same as
        // tappable AppSurfaceCard behavior); the label itself leads.
        expect(node.label.split('\n').first, 'Item ${i + 1} of 3');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls horizontally to reveal later cards', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 390,
          child: AppCarousel(title: 'T', children: cards(4)),
        ),
      );
      // Off-viewport cards are still in the tree (laid out past the edge).
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      expect(
        tester.getRect(find.text('Card 3')).left,
        greaterThan(viewport.right),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-700, 0),
      );
      await tester.pumpAndSettle();
      final revealed = tester.getRect(find.text('Card 3'));
      expect(revealed.left, lessThan(viewport.right));
      expect(revealed.right, greaterThan(viewport.left));
      expect(tester.takeException(), isNull);
    });

    testWidgets('320px + 1.3x + RTL + dark: no overflow', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppCarousel(
            title: 'A section title that wraps instead of clipping',
            subtitle: 'Supporting subtitle',
            seeAllLabel: 'Show all',
            onSeeAll: () {},
            cardExtent: 240,
            children: cards(3),
          ),
        ),
        rtl: true,
        scale: 1.3,
        dark: true,
      );
      expect(find.text('Card 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppMediaCard', () {
    testWidgets('renders title, meta and a single status pill', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: AppMediaCard(
            icon: Icons.build_outlined,
            title: 'Downtown service center',
            meta: '2.4 km away',
            status: AppStatusChip(
              label: 'Open now',
              kind: AppStatusKind.success,
            ),
          ),
        ),
      );
      expect(find.text('Downtown service center'), findsOneWidget);
      expect(find.text('2.4 km away'), findsOneWidget);
      expect(find.byType(AppStatusChip), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('light: soft shadow, NO border', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: AppMediaCard(title: 'T', meta: 'M'),
        ),
      );
      final decos = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration! as BoxDecoration)
          .toList();
      final card = decos.firstWhere(
        (d) =>
            d.borderRadius == BorderRadius.circular(20) &&
            (d.boxShadow != null || d.border != null),
      );
      expect(card.boxShadow, isNotNull);
      expect(card.border, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark: border, never shadow', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: AppMediaCard(title: 'T', meta: 'M'),
        ),
        dark: true,
      );
      final decos = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration! as BoxDecoration)
          .toList();
      final card = decos.firstWhere(
        (d) => d.boxShadow != null || d.border != null,
      );
      expect(card.border, isNotNull);
      expect(card.boxShadow, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tappable: button semantics, >= 48 dp, tap fires', (
      tester,
    ) async {
      var tapped = 0;
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppMediaCard(
            title: 'Tappable card',
            onTap: () => tapped++,
          ),
        ),
      );
      expect(tester.getSize(find.byType(AppMediaCard)).height,
          greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(find.byType(AppMediaCard)).flagsCollection.isButton,
        isTrue,
      );
      await tester.tap(find.text('Tappable card'));
      expect(tapped, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('static card has no button semantics', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: AppMediaCard(title: 'Static'),
        ),
      );
      expect(
        tester
            .getSemantics(find.byType(AppMediaCard))
            .flagsCollection
            .isButton,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + 320px + RTL + ar locale: wraps, no overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppMediaCard(
            icon: Icons.build_outlined,
            title: 'عنوان طويل يجب أن يلتف بدل أن يقص عند التكبير',
            meta: 'سطر وصفي طويل آخر يجب أن يلتف بشكل صحيح',
            status: const AppStatusChip(
              label: 'مفتوح الآن',
              kind: AppStatusKind.success,
            ),
            onTap: () {},
          ),
        ),
        rtl: true,
        scale: 1.3,
        locale: const Locale('ar'),
      );
      expect(find.byType(AppMediaCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppListGroup', () {
    AppListGroup group({ValueChanged<bool>? onChanged}) => AppListGroup(
          title: 'Preferences',
          items: [
            // Inert row: no onTap (null by default).
            const AppListGroupItem(
              leadingIcon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'App language',
              valueText: 'English',
            ),
            AppListGroupItem(
              leadingIcon: Icons.notifications_outlined,
              title: 'Push notifications',
              subtitle: 'Booking updates',
              switchValue: false,
              onChanged: onChanged,
            ),
          ],
        );

    testWidgets('section label is a header; inset dividers between rows', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(width: 360, child: group(onChanged: (_) {})),
      );
      expect(
        tester
            .getSemantics(find.text('Preferences'))
            .flagsCollection
            .isHeader,
        isTrue,
      );
      // Exactly one inset divider between the two rows.
      expect(find.byType(AppDivider), findsOneWidget);
      final divider =
          tester.widget<AppDivider>(find.byType(AppDivider));
      expect(divider.indent, 72);
      expect(find.text('English'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no card-in-card: no border/shadow boxes in the subtree', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(width: 360, child: group(onChanged: (_) {})),
      );
      final decos = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(AppListGroup),
              matching: find.byType(Container),
            ),
          )
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration! as BoxDecoration)
          .toList();
      expect(decos.where((d) => d.boxShadow != null), isEmpty);
      expect(decos.where((d) => d.border != null), isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('navigation row whole-tap + chevron mirrors in RTL', (
      tester,
    ) async {
      var tapped = 0;
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppListGroup(
            items: [
              AppListGroupItem(
                leadingIcon: Icons.language_rounded,
                title: 'Language',
                valueText: 'English',
                onTap: () => tapped++,
              ),
            ],
          ),
        ),
        rtl: true,
      );
      expect(tester.getSize(find.byType(AppListGroup)).height,
          greaterThanOrEqualTo(56));
      await tester.tap(find.text('Language'));
      expect(tapped, 1);
      expect(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right_rounded),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('switch row toggles with exactly one toggle node', (
      tester,
    ) async {
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: AppListGroup(
              items: [
                AppListGroupItem(
                  leadingIcon: Icons.notifications_outlined,
                  title: 'Push notifications',
                  switchValue: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Push notifications'));
      await tester.pump();
      expect(value, isTrue);
      expect(
        tester
            .getSemantics(find.byType(AppToggleRow))
            .flagsCollection
            .isToggled,
        isTrue,
      );
      // Exactly one toggle node: the decorative inner switch is excluded.
      expect(
        find.bySemanticsLabel('Push notifications'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled switch ignores taps and dims to 40%', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppListGroup(
            items: [
              // Disabled switch: null onChanged (the default) ignores taps.
              AppListGroupItem(
                leadingIcon: Icons.dark_mode_outlined,
                title: 'Dark mode',
                switchValue: false,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Dark mode'));
      await tester.pump();
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        0.4,
      );
      expect(find.byType(InkWell), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320px + 1.3x + RTL + dark: no overflow', (tester) async {
      await _pump(
        tester,
        SizedBox(width: 320, child: group(onChanged: (_) {})),
        rtl: true,
        scale: 1.3,
        dark: true,
      );
      expect(find.text('Push notifications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppProfileHeader', () {
    testWidgets('renders avatar initials, name header, subtitle, trailing', (
      tester,
    ) async {
      var edited = 0;
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppProfileHeader(
            name: 'Layla Haddad',
            subtitle: 'layla@example.com',
            trailing: AppTextButton(
              label: 'Edit',
              onPressed: () => edited++,
            ),
          ),
        ),
      );
      expect(find.text('LH'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('\u2066Layla Haddad\u2069'))
            .flagsCollection
            .isHeader,
        isTrue,
      );
      expect(find.text('\u2066layla@example.com\u2069'), findsOneWidget);
      await tester.tap(find.text('Edit'));
      expect(edited, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('semanticLabel overrides the header node label', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppProfileHeader(
            name: 'Layla Haddad',
            semanticLabel: 'Profile for Layla Haddad',
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(AppProfileHeader));
      // The node merges the override label with the header text below
      // (same as tappable AppSurfaceCard behavior); the label leads.
      expect(node.label.split('\n').first, 'Profile for Layla Haddad');
      expect(tester.takeException(), isNull);
    });

    testWidgets('320px + 1.3x + RTL + ar locale + dark: no overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 320,
          child: AppProfileHeader(
            name: 'ليلى حداد',
            subtitle: 'layla@example.com',
            trailing: AppTextButton(label: 'تعديل', onPressed: () {}),
          ),
        ),
        rtl: true,
        scale: 1.3,
        dark: true,
        locale: const Locale('ar'),
      );
      expect(find.text('\u2066ليلى حداد\u2069'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSheetPicker', () {
    List<AppSheetPickerOption> options() => const [
          AppSheetPickerOption(
            leadingIcon: Icons.schedule_rounded,
            title: 'Option one',
            subtitle: 'First choice',
          ),
          AppSheetPickerOption(
            leadingIcon: Icons.check_circle_outline_rounded,
            title: 'Option two',
            selected: true,
          ),
          AppSheetPickerOption(title: 'Option three'),
        ];

    testWidgets('renders handle, title, options and Show N button', (
      tester,
    ) async {
      var shown = 0;
      await _pump(
        tester,
        AppSheetPicker(
          title: 'Filter by status',
          options: options(),
          resultCount: 12,
          onShowResults: () => shown++,
        ),
      );
      expect(find.textContaining('Filter by status'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('AppBottomSheet.dragHandle')),
        findsOneWidget,
      );
      expect(find.text('Option one'), findsOneWidget);
      expect(find.text('Option two'), findsOneWidget);
      expect(find.text('Option three'), findsOneWidget);
      // No search field without a hint.
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Show 12 results'));
      expect(shown, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a row fires onSelected with its index', (
      tester,
    ) async {
      var picked = -1;
      await _pump(
        tester,
        AppSheetPicker(
          title: 'Pick one',
          options: options(),
          resultCount: 3,
          onSelected: (i) => picked = i,
          onShowResults: () {},
        ),
      );
      await tester.tap(find.text('Option three'));
      expect(picked, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected row shows check cue + selected semantics', (
      tester,
    ) async {
      await _pump(
        tester,
        AppSheetPicker(
          title: 'Pick one',
          options: options(),
          resultCount: 3,
          onSelected: (_) {},
          onShowResults: () {},
        ),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final node = tester.getSemantics(find.text('Option two'));
      expect(node.flagsCollection.isSelected, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search filters rows by title', (tester) async {
      await _pump(
        tester,
        AppSheetPicker(
          title: 'Pick one',
          searchHint: 'Search options',
          options: options(),
          resultCount: 3,
          onSelected: (_) {},
          onShowResults: () {},
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'two');
      await tester.pump();
      expect(find.text('Option one'), findsNothing);
      expect(find.text('Option two'), findsOneWidget);
      expect(find.text('Option three'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('route: open, select, Show N, settle + dismiss cleanly', (
      tester,
    ) async {
      var picked = -1;
      var shown = 0;
      await _pump(
        tester,
        Builder(
          builder: (ctx) => Center(
            child: TextButton(
              onPressed: () => showAppSheetPicker<void>(
                ctx,
                title: 'Filter by status',
                searchHint: 'Search statuses',
                options: options(),
                onSelected: (i) => picked = i,
                resultCount: 3,
                onShowResults: () {
                  shown++;
                  Navigator.of(ctx).pop();
                },
              ),
              child: const Text('Open picker'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsOneWidget);

      await tester.tap(find.text('Option one'));
      await tester.pump();
      expect(picked, 0);

      await tester.enterText(find.byType(TextField), 'three');
      await tester.pump();
      expect(find.text('Option one'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      await tester.tap(find.text('Show 3 results'));
      await tester.pumpAndSettle();
      expect(shown, 1);
      expect(find.byType(AppBottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('barrier tap dismisses the route', (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (ctx) => Center(
            child: TextButton(
              onPressed: () => showAppSheetPicker<void>(
                ctx,
                title: 'Pick one',
                options: options(),
                resultCount: 3,
              ),
              child: const Text('Open picker'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL + 1.3x + dark: no overflow', (tester) async {
      await _pump(
        tester,
        AppSheetPicker(
          title: 'A picker title that wraps onto two lines at scale',
          searchHint: 'Search options',
          options: options(),
          resultCount: 3,
          onSelected: (_) {},
          onShowResults: () {},
        ),
        rtl: true,
        scale: 1.3,
        dark: true,
      );
      expect(find.byType(AppSheetPicker), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
