// Phase-1a widget tests: AppPillButton, AppIconButton, AppTextButton.
//
// Covers sizes, >= 48 dp hit areas, AA contrast pairs (asserted, not just
// printed), loading width preservation + busy semantics + ignored taps,
// disabled treatment, RTL icon placement, and 1.3x text scale.
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

Widget _wrap(Widget child, {bool dark = false}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(body: Center(child: child)),
  );
}

Future<void> _pump(WidgetTester tester, Widget child, {bool dark = false}) async {
  await tester.pumpWidget(_wrap(child, dark: dark));
  await tester.pump();
}

void main() {
  group('AA contrast pairs (phase-1a gate)', () {
    test('primary / pressed / soft', () {
      expect(_ratio(Colors.white, AppColors.primary), greaterThanOrEqualTo(4.5));
      expect(_ratio(AppColors.primary, const Color(0xFFFBFBFD)),
          greaterThanOrEqualTo(4.5));
      expect(_ratio(AppColors.accentPressedInk, AppColors.accentPressed),
          greaterThanOrEqualTo(4.5));
      expect(_ratio(AppColors.accentInk, AppColors.accentSoft),
          greaterThanOrEqualTo(4.5));
    });

    test('destructive + success filled', () {
      expect(_ratio(Colors.white, const Color(0xFFDC2626)),
          greaterThanOrEqualTo(4.5));
      expect(_ratio(const Color(0xFF090B10), const Color(0xFFF87171)),
          greaterThanOrEqualTo(4.5));
      expect(_ratio(Colors.white, AppColors.successStrong),
          greaterThanOrEqualTo(4.5));
      expect(_ratio(AppDarkColors.onPrimary, AppDarkColors.successStrong),
          greaterThanOrEqualTo(4.5));
    });
  });

  group('AppPillButton sizes + hit areas', () {
    testWidgets('visual heights are 52 / 44 / 36', (tester) async {
      for (final entry in {
        AppPillButtonSize.large: 52.0,
        AppPillButtonSize.medium: 44.0,
        AppPillButtonSize.small: 36.0,
      }.entries) {
        await _pump(
          tester,
          SizedBox(
            width: 300,
            child: AppPillButton.primary(
              label: 'Go',
              onPressed: () {},
              size: entry.key,
              isExpanded: false,
            ),
          ),
        );
        final pill = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        expect(pill.constraints?.maxHeight ?? -1, entry.value);
      }
    });

    testWidgets('every size keeps a >= 48 dp hit area', (tester) async {
      for (final size in AppPillButtonSize.values) {
        await _pump(
          tester,
          AppPillButton.primary(
            label: 'Go',
            onPressed: () {},
            size: size,
            isExpanded: false,
          ),
        );
        final outer = tester.getSize(find.byType(AppPillButton));
        expect(outer.height, greaterThanOrEqualTo(48),
            reason: 'size $size hit height');
        expect(outer.width, greaterThanOrEqualTo(88),
            reason: 'size $size min width');
      }
    });
  });

  group('states', () {
    testWidgets('tap fires, disabled ignores + dims to 40%', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        AppPillButton.primary(label: 'Go', onPressed: () => tapped++),
      );
      await tester.tap(find.byType(AppPillButton));
      expect(tapped, 1);

      await _pump(
        tester,
        const AppPillButton.primary(label: 'Go', onPressed: null),
      );
      await tester.tap(find.byType(AppPillButton));
      expect(tapped, 1);
      final opacity =
          tester.widget<Opacity>(find.byType(Opacity).first).opacity;
      expect(opacity, 0.4);
      expect(
        tester.getSemantics(find.byType(AppPillButton)).flagsCollection.isEnabled,
        isFalse,
      );
    });

    testWidgets('loading preserves width, uses label color, ignores taps',
        (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        SizedBox(
          width: 300,
          child: AppPillButton.primary(
              label: 'Save changes', onPressed: () => tapped++),
        ),
      );
      final normalWidth = tester.getSize(find.byType(AppPillButton)).width;

      await _pump(
        tester,
        SizedBox(
          width: 300,
          child: AppPillButton.primary(
            label: 'Save changes',
            onPressed: () => tapped++,
            isLoading: true,
          ),
        ),
      );
      expect(tester.getSize(find.byType(AppPillButton)).width, normalWidth);
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(
        (spinner.valueColor as AlwaysStoppedAnimation<Color>).value,
        Colors.white,
      );
      await tester.tap(find.byType(AppPillButton));
      expect(tapped, 0);
      expect(
        tester
            .getSemantics(find.byType(AppPillButton))
            .label
            .contains('loading'),
        isTrue,
      );
    });

    testWidgets('variants render and respond', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPillButton.secondary(
                label: 'S', onPressed: () => tapped++),
            AppPillButton.ghost(
                label: 'G', onPressed: () => tapped++),
            AppPillButton.destructive(
                label: 'D', onPressed: () => tapped++, isExpanded: false),
            AppPillButton.success(
                label: 'Ok', onPressed: () => tapped++, isExpanded: false),
            AppIconButton(
                icon: Icons.add, onPressed: () => tapped++, tooltip: 'Add'),
            AppTextButton(label: 'See all', onPressed: () => tapped++),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('S'));
      await tester.tap(find.text('G'));
      await tester.tap(find.text('D'));
      await tester.tap(find.text('Ok'));
      expect(tapped, 4);
    });
  });

  group('RTL + text scale', () {
    testWidgets('leading icon renders at the start side in RTL',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: AppPillButton.primary(
                  label: 'Next',
                  onPressed: null,
                  icon: Icons.arrow_forward_rounded,
                  isExpanded: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final iconDx =
          tester.getCenter(find.byType(DirectionalIcon)).dx;
      final labelDx = tester.getCenter(find.text('Next')).dx;
      // RTL: start side is right, so the leading icon sits right of label.
      expect(iconDx, greaterThan(labelDx));
    });

    testWidgets('directional icon flips in RTL, not in LTR', (tester) async {
      Future<int> flipCount(bool rtl) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(BrandConfig.orient),
            home: Scaffold(
              body: Directionality(
                textDirection:
                    rtl ? TextDirection.rtl : TextDirection.ltr,
                child: const Center(
                  child: AppPillButton.primary(
                    label: 'Next',
                    onPressed: null,
                    icon: Icons.arrow_forward_rounded,
                    isExpanded: false,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        // Exactly one flip wraps the arrow Icon itself (framework internals
        // may add their own mirrored text runs — those are not ours).
        return find
            .descendant(
              of: find.byType(AppPillButton),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Transform &&
                    w.transform.storage[0] < 0 &&
                    w.child is Icon,
              ),
            )
            .evaluate()
            .length;
      }

      expect(await flipCount(false), 0);
      expect(await flipCount(true), 1);
    });

    testWidgets('no overflow at 1.3x text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData.fromView(
                tester.view,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppPillButton.primary(
                        label: 'Save changes now', onPressed: () {}),
                    AppTextButton(label: 'See all items', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Save changes now'), findsOneWidget);
    });
  });

  group('AppIconButton geometry + semantics', () {
    testWidgets('48x48 hit area with tooltip label', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        AppIconButton(
            icon: Icons.add, onPressed: () => tapped++, tooltip: 'Add item'),
      );
      expect(tester.getSize(find.byType(AppIconButton)), const Size(48, 48));
      expect(
        tester.getSemantics(find.byType(AppIconButton)).label,
        contains('Add item'),
      );
      await tester.tap(find.byType(AppIconButton));
      expect(tapped, 1);
    });
  });
}
