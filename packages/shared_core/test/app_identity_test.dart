// Phase-1c-ii widget tests: AppAvatar, AppBadge, AppChip, AppStatusChip,
// AppInfoTooltip.
//
// Covers AA contrast pairs (asserted >= 4.5 for text, >= 3.0 for the tooltip
// glyph), state behavior (toggle/disabled/open/dismiss), the mandated
// success-soft vs info-soft comparison, RTL, and text scale 1.3x.
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
}) async {
  await tester.pumpWidget(
    _wrap(child, dark: dark, rtl: rtl, scale: scale),
  );
  await tester.pump();
}

ThemeData _theme(bool dark) =>
    dark ? AppTheme.dark(BrandConfig.orient) : AppTheme.light(BrandConfig.orient);

void main() {
  group('AA contrast pairs (phase-1c-ii gate)', () {
    test('avatar ink on fill, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final ratio =
            _ratio(scheme.onPrimaryContainer, scheme.primaryContainer);
        debugPrint('1c-ii avatar ${dark ? 'dark' : 'light'} ink-on-fill=$ratio');
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    });

    test('badge fills, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        expect(_ratio(scheme.onPrimary, scheme.primary),
            greaterThanOrEqualTo(4.5));
        expect(_ratio(scheme.onError, scheme.error),
            greaterThanOrEqualTo(4.5));
      }
    });

    test('filter chip selected + unselected, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        expect(
          _ratio(scheme.onInverseSurface, scheme.inverseSurface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _ratio(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
      }
    });

    test('status chip ink on soft, all six kinds, both themes', () {
      for (final dark in [false, true]) {
        final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
        final scheme = _theme(dark).colorScheme;
        final families = {
          'success': sem.success,
          'warning': sem.warning,
          'error': sem.danger,
          'info': sem.info,
          'neutral': sem.neutral,
          'accent': AppStatusColors(
            base: sem.primary,
            subtle: sem.primarySubtle,
            border: sem.primaryBorder,
            ink: scheme.onPrimaryContainer,
          ),
        };
        families.forEach((name, family) {
          expect(
            _ratio(family.ink, family.subtle),
            greaterThanOrEqualTo(4.5),
            reason: '$name ${dark ? 'dark' : 'light'}',
          );
        });
      }
    });

    test('tooltip glyph on page canvas (non-text, >= 3:1)', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final canvas =
            dark ? AppDarkColors.canvas : AppColors.canvas;
        expect(
          _ratio(scheme.onSurfaceVariant, canvas),
          greaterThanOrEqualTo(3.0),
        );
      }
    });

    test('success-soft vs info-soft comparison (dot + label carry it)', () {
      final fills =
          _ratio(AppSemanticColors.light.success.subtle, AppSemanticColors.light.info.subtle);
      final dots =
          _ratio(AppSemanticColors.light.success.base, AppSemanticColors.light.info.base);
      final inks =
          _ratio(AppSemanticColors.light.success.ink, AppSemanticColors.light.info.ink);
      debugPrint('1c-ii success-vs-info light: fills=$fills dots=$dots inks=$inks');
      // The pale fills are near-identical by design (measured ~1.01): the
      // status MUST be carried by the dot hue + human label, never the fill.
      expect(fills, lessThan(1.5));
      expect(dots, greaterThan(1.5));
    });
  });

  group('AppAvatar', () {
    testWidgets('shows derived initials at every size', (tester) async {
      for (final size in AppAvatarSize.values) {
        await _pump(tester, AppAvatar(name: 'Layla Haddad', size: size));
        expect(find.text('LH'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('single-word name and tappable 48 dp target', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        AppAvatar(name: 'Omar', onTap: () => tapped++),
      );
      expect(find.text('O'), findsOneWidget);
      await tester.tap(find.byType(AppAvatar));
      expect(tapped, 1);
      final target = tester.getSize(find.byType(InkWell));
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL safe', (tester) async {
      await _pump(
        tester,
        const AppAvatar(name: 'Layla Haddad', size: AppAvatarSize.extraSmall),
        rtl: true,
        scale: 1.3,
      );
      expect(find.text('LH'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x long custom initials ellipsize, no overflow',
        (tester) async {
      await _pump(
        tester,
        const AppAvatar(
          name: 'Layla Haddad',
          initials: 'WXYZ',
          size: AppAvatarSize.extraSmall,
        ),
        scale: 1.3,
      );
      expect(find.text('WXYZ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppBadge', () {
    testWidgets('caps at 99+ and keeps a 20 px minimum', (tester) async {
      await _pump(tester, const AppBadge(count: 120));
      expect(find.text('\u206699+\u2069'), findsOneWidget);
      final size = tester.getSize(find.byType(AppBadge));
      expect(size.height, greaterThanOrEqualTo(20));
      expect(size.width, greaterThanOrEqualTo(20));
      expect(tester.takeException(), isNull);
    });

    testWidgets('error kind + 1.3x RTL safe', (tester) async {
      await _pump(
        tester,
        const AppBadge(count: 7, kind: AppBadgeKind.error),
        rtl: true,
        scale: 1.3,
      );
      expect(find.text('\u20667\u2069'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x capped 99+ ellipsizes, no overflow', (tester) async {
      await _pump(
        tester,
        const AppBadge(count: 120),
        scale: 1.3,
      );
      expect(find.text('\u206699+\u2069'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('capped count is bidi-isolated in RTL 1.3x', (tester) async {
      await _pump(
        tester,
        const AppBadge(count: 120),
        rtl: true,
        scale: 1.3,
      );
      // Isolated payload preserves "99+" reading order in RTL
      // (unisolated it would flip to "+99").
      expect(find.text('\u206699+\u2069'), findsOneWidget);
      expect(find.text('99+'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppChip', () {
    testWidgets('tap toggles, selected shows a check cue', (tester) async {
      var selected = false;
      await tester.pumpWidget(
        _wrap(AppChip(
          label: 'Open',
          selected: selected,
          onSelected: (v) => selected = v,
        )),
      );
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      await tester.tap(find.byType(AppChip));
      expect(selected, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected chip exposes check + selected semantics',
        (tester) async {
      await _pump(
        tester,
        AppChip(label: 'Open', selected: true, onSelected: (_) {}),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final semantics = tester.getSemantics(find.byType(AppChip));
      expect(semantics.flagsCollection.isSelected, isTrue);
      final target = tester.getSize(find.byType(InkWell));
      expect(target.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled chip ignores taps at 40% opacity', (tester) async {
      await _pump(tester, const AppChip(label: 'Off'));
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(Opacity), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL safe', (tester) async {
      await _pump(
        tester,
        AppChip(label: 'Delayed', onSelected: (_) {}),
        rtl: true,
        scale: 1.3,
      );
      expect(find.text('Delayed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppStatusChip', () {
    testWidgets('renders dot + label for every kind', (tester) async {
      for (final kind in AppStatusKind.values) {
        await _pump(tester, AppStatusChip(label: 'Label', kind: kind));
        expect(find.text('Label'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('1.3x + RTL + dark safe', (tester) async {
      await _pump(
        tester,
        const AppStatusChip(label: 'Syncing', kind: AppStatusKind.info),
        dark: true,
        rtl: true,
        scale: 1.3,
      );
      expect(find.text('Syncing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('semanticLabel overrides semantics, not visible text',
        (tester) async {
      await _pump(
        tester,
        const AppStatusChip(
          label: 'Active',
          kind: AppStatusKind.success,
          semanticLabel: 'Active status',
        ),
      );
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Active status'), findsNothing);
      final semantics = tester.getSemantics(find.byType(AppStatusChip));
      expect(semantics.label, 'Active status');
      expect(tester.takeException(), isNull);
    });
  });

  group('AppInfoTooltip', () {
    testWidgets('tap opens, barrier tap dismisses', (tester) async {
      await _pump(
        tester,
        const AppInfoTooltip(message: 'Plain language reason.'),
      );
      expect(find.text('\u2066Plain language reason.\u2069'), findsNothing);
      await tester.tap(find.byType(AppInfoTooltip));
      await tester.pump();
      expect(find.text('\u2066Plain language reason.\u2069'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      expect(find.text('\u2066Plain language reason.\u2069'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('second tap toggles closed + focusable + labelled',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        AppInfoTooltip(
          message: 'Why text.',
          semanticLabel: 'Why this status',
          focusNode: node,
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
      final semantics = tester.getSemantics(find.byType(AppInfoTooltip));
      expect(semantics.label, 'Why this status');
      await tester.tap(find.byType(AppInfoTooltip));
      await tester.pump();
      expect(find.text('\u2066Why text.\u2069'), findsOneWidget);
      // While open, the transparent modal barrier sits above the icon (same
      // as a dialog scrim), so the re-tap lands on the barrier and dismisses
      // through onDismiss — the net effect is still a toggle.
      await tester.tap(find.byType(AppInfoTooltip), warnIfMissed: false);
      await tester.pump();
      expect(find.text('\u2066Why text.\u2069'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hit area >= 48 dp, 1.3x + RTL safe', (tester) async {
      await _pump(
        tester,
        const AppInfoTooltip(message: 'Long reason that wraps at scale.'),
        rtl: true,
        scale: 1.3,
      );
      final target = tester.getSize(find.byType(InkWell));
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
      await tester.tap(find.byType(AppInfoTooltip));
      await tester.pump();
      expect(
          find.text('\u2066Long reason that wraps at scale.\u2069'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('popover message is bidi-isolated, RTL 1.3x no overflow',
        (tester) async {
      await _pump(
        tester,
        const AppInfoTooltip(message: 'Plain language reason.'),
        rtl: true,
        scale: 1.3,
      );
      await tester.tap(find.byType(AppInfoTooltip));
      await tester.pump();
      // Exact isolated text renders; the trailing period stays attached
      // in RTL instead of migrating.
      expect(find.text('\u2066Plain language reason.\u2069'),
          findsOneWidget);
      expect(find.text('Plain language reason.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
