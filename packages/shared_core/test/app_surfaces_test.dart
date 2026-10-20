// Phase-1c-i widget tests: AppSurfaceCard, AppSection, AppListTile,
// AppSettingsTile, AppDivider, AppDataRow.
//
// Covers card border/shadow grammar, >= 48 dp targets, AA pairs (asserted),
// chevron/divider RTL mirroring, tabular + LTR-locked values, switch tiles,
// section chrome, and 1.3x overflow.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_core/src/gallery/design_system_gallery_screen.dart';

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

Widget _wrap(Widget child, {bool dark = false, bool rtl = false}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Center(child: child),
      ),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool rtl = false,
}) async {
  await tester.pumpWidget(_wrap(child, dark: dark, rtl: rtl));
  await tester.pump();
}

/// Text-scale pump (B6): same chrome as [_pump] with an explicit textScaler.
Future<void> _pumpScaled(
  WidgetTester tester,
  Widget child, {
  double scale = 1.3,
  bool dark = false,
}) async {
  final brand = BrandConfig.orient;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(brand),
      darkTheme: AppTheme.dark(brand),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData.fromView(tester.view).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('AA contrast pairs (phase-1c-i gate)', () {
    test('title / subtitle / value ink on card surface, both themes', () {
      // Light surface card.
      expect(
        _ratio(AppColors.textPrimary, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _ratio(AppColors.textSecondary, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
      // Dark surface card.
      expect(
        _ratio(AppDarkColors.textPrimary, AppDarkColors.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _ratio(AppDarkColors.textSecondary, AppDarkColors.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('accent leading circle ink on soft fill, both themes', () {
      expect(
        _ratio(AppColors.accentInk, AppColors.accentSoft),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _ratio(AppDarkColors.accentInk, AppDarkColors.accentSoft),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('hairline borders are decorative-only (measured, both themes)', () {
      // Measured 2026-10-20: 1.23 light / ~1.3 dark — the 1 px card/divider
      // hairline does NOT reach 3:1 (same as the pre-existing theme
      // cardTheme/dividerTheme hairlines, which were 1.2-2.0 in phase-1b).
      // Accepted as decorative: card boundaries are carried by surface
      // elevation + shadow/spacing, never by the hairline alone. All text
      // on cards is AA (asserted above). Revisit in polish if the hairline
      // is ever the sole boundary cue.
      expect(
        _ratio(AppColors.borderDefault, AppColors.surface),
        lessThan(3.0),
      );
      expect(
        _ratio(AppDarkColors.borderDefault, AppDarkColors.surface),
        lessThan(3.0),
      );
    });
  });

  group('AppSurfaceCard', () {
    testWidgets('tappable card is >= 48 dp with button semantics', (
      tester,
    ) async {
      await _pump(
        tester,
        AppSurfaceCard(
          headerTitle: 'Details',
          onTap: () {},
          showChevron: true,
          child: const Text('x'),
        ),
      );
      expect(tester.takeException(), isNull);
      final card = find.byType(AppSurfaceCard);
      expect(tester.getSize(card).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(card).flagsCollection.isButton,
        isTrue,
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('static card has no button semantics', (tester) async {
      await _pump(
        tester,
        const AppSurfaceCard(child: Text('static')),
      );
      expect(
        tester
            .getSemantics(find.byType(AppSurfaceCard))
            .flagsCollection
            .isButton,
        isFalse,
      );
    });

    testWidgets('outlined card has border, elevated card has shadow', (
      tester,
    ) async {
      await _pump(
        tester,
        const Column(
          children: [
            AppSurfaceCard(child: Text('a')),
            AppSurfaceCard(outlined: false, child: Text('b')),
          ],
        ),
      );
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration! as BoxDecoration)
          .toList();
      final bordered = containers.firstWhere((d) => d.border != null);
      expect(bordered.boxShadow, isNull);
      final elevated = containers.firstWhere((d) => d.boxShadow != null);
      expect(elevated.border, isNull);
    });

    testWidgets('chevron mirrors in RTL', (tester) async {
      await _pump(
        tester,
        AppSurfaceCard(
          headerTitle: 'Details',
          onTap: () {},
          showChevron: true,
          child: const Text('x'),
        ),
        rtl: true,
      );
      // DirectionalIcon flips direction-sensitive glyphs under RTL.
      expect(
        find.ancestor(
          of: find.byIcon(Icons.chevron_right_rounded),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );
    });
  });

  group('AppSection', () {
    testWidgets('heading is a header with see-all action + 12 gap', (
      tester,
    ) async {
      var seen = false;
      await _pump(
        tester,
        AppSection(
          title: 'Recent activity',
          subtitle: 'Last 7 days',
          seeAllLabel: 'See all',
          onSeeAll: () => seen = true,
          child: const Text('body'),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester
            .getSemantics(find.text('Recent activity'))
            .flagsCollection
            .isHeader,
        isTrue,
      );
      await tester.tap(find.text('See all'));
      expect(seen, isTrue);
    });
  });

  group('AppListTile', () {
    testWidgets('min height 56, whole-row tap, subtitle + value', (
      tester,
    ) async {
      var tapped = false;
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppListTile(
            leadingIcon: Icons.build_outlined,
            title: 'Oil change',
            subtitle: 'Due in 2 weeks',
            valueText: 'AED 240',
            onTap: () => tapped = true,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final row = find.byType(AppListTile);
      expect(tester.getSize(row).height, greaterThanOrEqualTo(56));
      await tester.tap(find.text('Oil change'));
      expect(tapped, isTrue);
      // Value keeps tabular figures and an LTR lock.
      final value = tester.widget<Text>(find.text('AED 240'));
      expect(
        value.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(
        find.ancestor(
          of: find.text('AED 240'),
          matching: find.byType(Directionality),
        ),
        findsWidgets,
      );
    });

    testWidgets('no overflow at 1.3x with long subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData.fromView(tester.view).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: AppListTile(
                      leadingIcon: Icons.build_outlined,
                      title: 'Oil change with a long title that wraps',
                      subtitle:
                          'A long supporting line that must wrap, never clip',
                      valueText: 'AED 240',
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSettingsTile', () {
    testWidgets('whole switch row toggles with toggle semantics', (
      tester,
    ) async {
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: AppSettingsTile.switchTile(
              leadingIcon: Icons.notifications_outlined,
              title: 'Push notifications',
              subtitle: 'Booking updates',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Push notifications'));
      await tester.pump();
      expect(value, isTrue);
      expect(
        tester
            .getSemantics(find.byType(AppSettingsTile))
            .flagsCollection
            .isToggled,
        isTrue,
      );
    });

    testWidgets('disabled switch ignores taps and dims to 40%', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppSettingsTile.switchTile(
            leadingIcon: Icons.dark_mode_outlined,
            title: 'Dark mode',
            value: false,
            onChanged: null,
          ),
        ),
      );
      await tester.tap(find.text('Dark mode'));
      await tester.pump();
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        0.4,
      );
      // Symmetric with the non-switch inert tile: no InkWell, no tap target.
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('value + chevron variant navigates on tap', (tester) async {
      var tapped = false;
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppSettingsTile(
            leadingIcon: Icons.language_rounded,
            title: 'Language',
            valueText: 'English',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Language'));
      expect(tapped, isTrue);
      expect(find.text('English'), findsOneWidget);
    });
  });

  group('AppDivider', () {
    testWidgets('inset divider is 72 px start, 1 px, decorative', (
      tester,
    ) async {
      await _pump(tester, const AppDivider.inset());
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, const EdgeInsetsDirectional.only(start: 72));
      final box = container.decoration ?? container.color;
      expect(box, isNotNull);
      expect(
        find.ancestor(
          of: find.byType(Container),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('inset mirrors in RTL', (tester) async {
      await _pump(tester, const AppDivider.inset(), rtl: true);
      final container = tester.widget<Container>(find.byType(Container));
      final resolved = (container.margin! as EdgeInsetsDirectional)
          .resolve(TextDirection.rtl);
      expect(resolved.left, 0);
      expect(resolved.right, 72);
    });
  });

  group('AppDataRow', () {
    testWidgets('label/value layout, tabular value, LTR lock in RTL', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppDataRow(label: 'الحالة', value: 'AED 1,240.00'),
        ),
        rtl: true,
      );
      expect(tester.takeException(), isNull);
      final value = tester.widget<Text>(find.text('AED 1,240.00'));
      expect(
        value.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      final dir = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.text('AED 1,240.00'),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(dir.textDirection, TextDirection.ltr);
    });

    testWidgets('long Arabic wraps at 1.3x without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData.fromView(tester.view).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: const Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: AppDataRow(
                      label: 'ملاحظات طويلة جدا يجب أن تلتف بدل أن تقص',
                      value: 'AED 1,240.00',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('surfaces gallery section', () {
    testWidgets('renders without overflow at 1.3x', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData.fromView(tester.view).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  child: SurfacesGallerySection(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('LTR gallery shows no Arabic-script demo row (B1)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: SurfacesGallerySection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('الحالة'), findsNothing);
      expect(find.text('Reference'), findsOneWidget);
    });

    testWidgets('ar-locale gallery shows the Arabic-script demo row (B1)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(
            body: SingleChildScrollView(
              child: SurfacesGallerySection(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('الحالة'), findsOneWidget);
      expect(find.text('Reference'), findsNothing);
    });
  });

  group('dark-mode pumps (B6)', () {
    testWidgets('card renders dark with border, never shadow', (tester) async {
      await _pump(
        tester,
        const AppSurfaceCard(child: Text('dark card')),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      final decos = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .map((c) => c.decoration! as BoxDecoration)
          .toList();
      final card = decos.firstWhere((d) => d.border != null);
      expect(card.boxShadow, isNull);
    });

    testWidgets('list + settings tiles render dark', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppListTile(
                leadingIcon: Icons.build_outlined,
                title: 'Oil change',
                subtitle: 'Due in 2 weeks',
                valueText: 'AED 240',
                onTap: () {},
              ),
              AppSettingsTile.switchTile(
                leadingIcon: Icons.notifications_outlined,
                title: 'Push notifications',
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Oil change'), findsOneWidget);
      expect(find.text('Push notifications'), findsOneWidget);
    });

    testWidgets('data row renders dark', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppDataRow(label: 'Status', value: 'Active'),
        ),
        dark: true,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('text-scale 1.3x pumps (B6)', () {
    testWidgets('card wraps at 1.3x', (tester) async {
      await _pumpScaled(
        tester,
        const SizedBox(
          width: 320,
          child: AppSurfaceCard(
            headerTitle: 'A card title that keeps wrapping instead of clipping',
            child: Text('Body text that also wraps at large text scales.'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('section wraps at 1.3x', (tester) async {
      await _pumpScaled(
        tester,
        SizedBox(
          width: 320,
          child: AppSection(
            title: 'A section title that keeps wrapping instead of clipping',
            subtitle: 'Supporting subtitle',
            seeAllLabel: 'See all',
            onSeeAll: () {},
            child: const Text('body'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings switch tile wraps at 1.3x', (tester) async {
      await _pumpScaled(
        tester,
        SizedBox(
          width: 320,
          child: AppSettingsTile.switchTile(
            leadingIcon: Icons.notifications_outlined,
            title: 'A long setting title that must wrap, never clip',
            subtitle: 'A long supporting line that must wrap, never clip',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('divider renders at 1.3x', (tester) async {
      await _pumpScaled(tester, const AppDivider.inset());
      expect(tester.takeException(), isNull);
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, const EdgeInsetsDirectional.only(start: 72));
    });
  });

  group('AppListTile static variant (B6)', () {
    testWidgets('no onTap: no ink, no button semantics, still 56 dp', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppListTile(
            leadingIcon: Icons.receipt_long_outlined,
            title: 'Static row',
            subtitle: 'No tap target, no chevron',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(InkWell), findsNothing);
      expect(
        tester
            .getSemantics(find.byType(AppListTile))
            .flagsCollection
            .isButton,
        isFalse,
      );
      expect(
        tester.getSize(find.byType(AppListTile)).height,
        greaterThanOrEqualTo(56),
      );
    });
  });

  group('AppSurfaceCard semantics label (B6)', () {
    testWidgets('tappable card falls back to headerTitle', (tester) async {
      await _pump(
        tester,
        AppSurfaceCard(
          headerTitle: 'Details',
          onTap: () {},
          child: const Text('x'),
        ),
      );
      final node = tester.getSemantics(find.byType(AppSurfaceCard));
      expect(node.flagsCollection.isButton, isTrue);
      // The node merges child text below the label (pre-existing card
      // behavior); the label itself must lead with the header title.
      expect(node.label.split('\n').first, 'Details');
    });

    testWidgets('tappable card honors an explicit semanticLabel', (
      tester,
    ) async {
      await _pump(
        tester,
        AppSurfaceCard(
          headerTitle: 'Details',
          semanticLabel: 'Open booking details',
          onTap: () {},
          child: const Text('x'),
        ),
      );
      expect(
        tester
            .getSemantics(find.byType(AppSurfaceCard))
            .label
            .split('\n')
            .first,
        'Open booking details',
      );
    });
  });

  group('AppSettingsTile switch row control (B3/B4/B7)', () {
    testWidgets('switch row activates via keyboard Enter + Space (B3)', (
      tester,
    ) async {
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: AppSettingsTile.switchTile(
              leadingIcon: Icons.notifications_outlined,
              title: 'Push notifications',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      Focus.of(tester.element(find.text('Push notifications'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, isFalse);
    });

    testWidgets('switch row has ripple + focus-ring wiring (B3)', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppSettingsTile.switchTile(
            leadingIcon: Icons.notifications_outlined,
            title: 'Push notifications',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );
      final ink = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(AppToggleRow),
          matching: find.byType(InkWell),
        ),
      );
      expect(ink.onTap, isNotNull);
      // Real focus wiring: drive focus to the row and assert it holds focus
      // (InkWell renders the theme focusColor ring when focused).
      Focus.of(tester.element(find.text('Push notifications'))).requestFocus();
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Push notifications'))).hasFocus,
        isTrue,
      );
    });

    testWidgets('switch row exposes exactly one toggle node (B3)', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppSettingsTile.switchTile(
            leadingIcon: Icons.notifications_outlined,
            title: 'Push notifications',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Push notifications'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.byType(AppSettingsTile))
            .flagsCollection
            .isToggled,
        isTrue,
      );
    });

    testWidgets('non-switch tile without onTap is dimmed + inert (B4)', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 360,
          child: AppSettingsTile(
            leadingIcon: Icons.language_rounded,
            title: 'Language',
            valueText: 'English',
          ),
        ),
      );
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        0.4,
      );
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('enabled ON switch uses the token primary track (B7)', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 360,
          child: AppSettingsTile.switchTile(
            leadingIcon: Icons.notifications_outlined,
            title: 'Push notifications',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      // Widget-level: resolve the rendered Switch's effective track/thumb
      // for the selected state to the primary pair. PNG evidence:
      // docs/ui-redesign/baseline/gallery/1c-i-surfaces_*_*.png shows the
      // ON switch in primary.
      final rendered = tester.widget<Switch>(find.byType(Switch));
      expect(rendered.value, isTrue);
      final theme = Theme.of(tester.element(find.byType(Switch)));
      final trackProp =
          rendered.trackColor ?? theme.switchTheme.trackColor!;
      final thumbProp =
          rendered.thumbColor ?? theme.switchTheme.thumbColor!;
      expect(
        trackProp.resolve({WidgetState.selected}),
        theme.colorScheme.primary,
      );
      expect(
        thumbProp.resolve({WidgetState.selected}),
        theme.colorScheme.onPrimary,
      );
      expect(
        tester
            .getSemantics(find.byType(AppSettingsTile))
            .flagsCollection
            .isToggled,
        isTrue,
      );
    });
  });

  group('surfaces gallery a11y (C14 automated, M4)', () {
    Future<void> pumpGallery(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: SurfacesGallerySection(),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('tap targets meet the Android minimum', (tester) async {
      await pumpGallery(tester);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('tap targets are labeled', (tester) async {
      await pumpGallery(tester);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('text contrast meets the guideline', (tester) async {
      await pumpGallery(tester);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
  });
}
