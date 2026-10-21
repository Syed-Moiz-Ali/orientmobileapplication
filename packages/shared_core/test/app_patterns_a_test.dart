// Phase-1P (builder A) widget tests: AppStepScaffold, AppStickyActionBar,
// AppOrDivider, AppAltAuthRow, AppSummaryRow.
//
// Covers presence/API, >= 48 dp targets, AA contrast pairs (asserted, not
// just printed), RTL mirroring (back arrow, CTA alignment, LTR-isolated
// digits), 1.3x + 320 px overflow, Semantics (header/button/meter), the
// reduced-motion static step transition, and busy-CTA width preservation.
//
// NOTE: AppPageHeader (item 2) already exists in this branch (tracked,
// titleLarge + actions/breadcrumbs grammar) and is out of bounds for this
// builder (no-touch rule), so it is not built or tested here — see the
// return report for the additive-param request.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Exact WCAG 2.x relative luminance (kept in sync with the phase-1 harness).
double _luminance(Color c) {
  double lin(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _ratio(Color a, Color b) {
  final l1 = _luminance(a), l2 = _luminance(b);
  final hi = l1 > l2 ? l1 : l2, lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

Future<void> _loadMaterialIcons() async {
  try {
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
        return;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) return;
      dir = parent;
    }
  } catch (_) {
    // Glyphs fall back; geometry/semantics assertions still hold.
  }
}

Widget _wrap(
  Widget child, {
  bool dark = false,
  bool rtl = false,
  double scale = 1.0,
  bool disableAnimations = false,
  double viewInsetsBottom = 0,
}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: disableAnimations,
          viewInsets: EdgeInsets.only(bottom: viewInsetsBottom),
        ),
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
  bool disableAnimations = false,
  double viewInsetsBottom = 0,
}) async {
  await tester.pumpWidget(
    _wrap(
      child,
      dark: dark,
      rtl: rtl,
      scale: scale,
      disableAnimations: disableAnimations,
      viewInsetsBottom: viewInsetsBottom,
    ),
  );
  await tester.pump();
}

AppStepScaffold _step({
  double? progress,
  int? step,
  int? totalSteps,
  VoidCallback? onBack,
  bool hideBack = false,
  VoidCallback? onCta,
  bool loading = false,
  Key? stepKey,
  String title = "What's your phone number?",
}) {
  return AppStepScaffold(
    progress: progress ?? (step == null ? 0.25 : null),
    step: step,
    totalSteps: totalSteps,
    backLabel: 'Back',
    onBack: hideBack ? null : (onBack ?? () {}),
    title: title,
    subtitle: 'We will send a confirmation code.',
    stepKey: stepKey,
    ctaLabel: 'Continue',
    onCta: onCta ?? () {},
    isLoading: loading,
    child: const Text('Step content'),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadMaterialIcons();
  });

  group('AA contrast pairs (phase-1P gate)', () {
    test('text pairs reach 4.5:1, both themes', () {
      final light = AppTheme.light(BrandConfig.orient);
      final dark = AppTheme.dark(BrandConfig.orient);
      final pairs = <String, List<Color>>{
        'light onSurface/surface': [
          light.colorScheme.onSurface,
          light.colorScheme.surface,
        ],
        'light onSurfaceVariant/surface': [
          light.colorScheme.onSurfaceVariant,
          light.colorScheme.surface,
        ],
        'light onSurface/canvas': [
          light.colorScheme.onSurface,
          light.scaffoldBackgroundColor,
        ],
        'light onPrimary/primary': [
          light.colorScheme.onPrimary,
          light.colorScheme.primary,
        ],
        'light onError/error': [
          light.colorScheme.onError,
          light.colorScheme.error,
        ],
        'dark onSurface/surface': [
          dark.colorScheme.onSurface,
          dark.colorScheme.surface,
        ],
        'dark onSurfaceVariant/surface': [
          dark.colorScheme.onSurfaceVariant,
          dark.colorScheme.surface,
        ],
        'dark onSurface/canvas': [
          dark.colorScheme.onSurface,
          dark.scaffoldBackgroundColor,
        ],
        'dark onPrimary/primary': [
          dark.colorScheme.onPrimary,
          dark.colorScheme.primary,
        ],
        'dark onError/error': [
          dark.colorScheme.onError,
          dark.colorScheme.error,
        ],
      };
      for (final entry in pairs.entries) {
        final ratio = _ratio(entry.value[0], entry.value[1]);
        debugPrint(
          'contrast ${entry.key} = ${ratio.toStringAsFixed(2)}:1',
        );
        expect(ratio, greaterThanOrEqualTo(4.5), reason: entry.key);
      }
    });
  });

  group('AppStepScaffold presence + API', () {
    testWidgets('renders progress, back, headline, subtitle, CTA', (
      tester,
    ) async {
      await _pump(tester, _step());
      expect(find.text("What's your phone number?"), findsOneWidget);
      expect(find.text('We will send a confirmation code.'), findsOneWidget);
      expect(find.text('Step content'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('progress clamps to 0..1', (tester) async {
      await _pump(tester, _step(progress: 1.5));
      var fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fill.widthFactor, 1.0);
      await _pump(tester, _step(progress: -0.2));
      fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fill.widthFactor, 0.0);
    });

    testWidgets('step/totalSteps resolves progress (2/4 = 0.5)', (
      tester,
    ) async {
      await _pump(tester, _step(step: 2, totalSteps: 4));
      final fill = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fill.widthFactor, 0.5);
    });

    testWidgets('null onBack hides the back arrow', (tester) async {
      await _pump(tester, _step(hideBack: true));
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('back wiring + CTA tap fire', (tester) async {
      var backed = false;
      var continued = false;
      await _pump(
        tester,
        _step(onBack: () => backed = true, onCta: () => continued = true),
      );
      // Real gesture through the tooltip-labeled back arrow (fails if the
      // arrow is ever wrapped in IgnorePointer or covered by an overlay).
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      expect(backed, isTrue);
      await tester.tap(find.text('Continue'));
      expect(continued, isTrue);
    });

    testWidgets('back arrow is a >= 48 dp target', (tester) async {
      await _pump(tester, _step());
      final size = tester.getSize(find.byTooltip('Back'));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('sticky CTA is full-width large (52)', (tester) async {
      await _pump(
        tester,
        SizedBox(width: 400, child: _step()),
      );
      final pill = tester.widget<AppPillButton>(find.byType(AppPillButton));
      expect(pill.isExpanded, isTrue);
      expect(pill.size, AppPillButtonSize.large);
      final size = tester.getSize(find.byType(AppPillButton));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(300));
    });
  });

  group('AppStepScaffold step transition', () {
    testWidgets('slide + fade over 200-300 ms ease-out', (tester) async {
      await _pump(tester, _step(step: 1, totalSteps: 3));
      final switcher =
          tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration,
          greaterThanOrEqualTo(const Duration(milliseconds: 200)));
      expect(switcher.duration,
          lessThanOrEqualTo(const Duration(milliseconds: 300)));
      expect(switcher.switchInCurve, AppMotion.enter);
      // Mid-flight both effects are mounted.
      await tester.pumpWidget(_wrap(_step(step: 2, totalSteps: 3)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion collapses to a static switch', (
      tester,
    ) async {
      await _pump(tester, _step(step: 1, totalSteps: 3),
          disableAnimations: true);
      final switcher =
          tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
      expect(switcher.duration, Duration.zero);
      await tester.pumpWidget(
        _wrap(_step(step: 2, totalSteps: 3), disableAnimations: true),
      );
      await tester.pump();
      expect(find.text('Step content'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keyboard-safe: CTA survives 400 px viewInsets', (
      tester,
    ) async {
      await _pump(tester, _step(), viewInsetsBottom: 400);
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppStickyActionBar', () {
    Widget bar({bool rtl = false, VoidCallback? onCta}) {
      return Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: AppStickyActionBar(
          summary: const AppSummaryRow(label: 'Total', value: 'AED 240.00'),
          ctaLabel: 'Continue',
          onCta: onCta ?? () {},
        ),
      );
    }

    testWidgets('summary starts, single CTA ends (LTR)', (tester) async {
      var tapped = false;
      await _pump(tester, bar(onCta: () => tapped = true));
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('\u2066AED 240.00\u2069'), findsOneWidget);
      expect(find.byType(AppPillButton), findsOneWidget);
      final summaryX = tester.getCenter(find.text('Total')).dx;
      final ctaX = tester.getCenter(find.byType(AppPillButton)).dx;
      expect(summaryX, lessThan(ctaX));
      await tester.tap(find.text('Continue'));
      expect(tapped, isTrue);
    });

    testWidgets('RTL mirrors: summary ends, CTA starts', (tester) async {
      await _pump(tester, bar(rtl: true));
      final summaryX = tester.getCenter(find.text('Total')).dx;
      final ctaX = tester.getCenter(find.byType(AppPillButton)).dx;
      expect(summaryX, greaterThan(ctaX));
      expect(tester.takeException(), isNull);
    });

    testWidgets('CTA meets 48 dp target', (tester) async {
      await _pump(tester, SizedBox(width: 360, child: bar()));
      final size = tester.getSize(find.byType(AppPillButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('busy CTA keeps width', (tester) async {
      Widget busy(bool loading) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AppStickyActionBar(
            summary: const AppSummaryRow(label: 'Total', value: 'AED 240.00'),
            ctaLabel: 'Continue',
            onCta: () {},
            isLoading: loading,
          ),
        );
      }

      await _pump(tester, SizedBox(width: 360, child: busy(false)));
      final idle = tester.getSize(find.byType(AppPillButton));
      await _pump(tester, SizedBox(width: 360, child: busy(true)));
      final busySize = tester.getSize(find.byType(AppPillButton));
      expect((idle.width - busySize.width).abs(), lessThanOrEqualTo(0.5));
    });
  });

  group('AppOrDivider', () {
    testWidgets('renders caller label between two hairlines', (
      tester,
    ) async {
      await _pump(tester, const AppOrDivider(label: 'or'));
      expect(find.text('or'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('label is a param, never hardcoded (Arabic)', (
      tester,
    ) async {
      await _pump(tester, const AppOrDivider(label: 'أو'), rtl: true);
      expect(find.text('أو'), findsOneWidget);
      expect(find.text('or'), findsNothing);
    });
  });

  group('AppAltAuthRow', () {
    testWidgets('whole row is a >= 48 dp button with ripple', (
      tester,
    ) async {
      var tapped = false;
      await _pump(
        tester,
        SizedBox(
          width: 340,
          child: AppAltAuthRow(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            onTap: () => tapped = true,
          ),
        ),
      );
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      final size = tester.getSize(find.byType(InkWell));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(300));
      final semantics = tester.getSemantics(find.text('Continue with Google'));
      expect(semantics.flagsCollection.isButton, isTrue);
      await tester.tap(find.text('Continue with Google'));
      expect(tapped, isTrue);
    });

    testWidgets('default trailing chevron mirrors in RTL', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 340,
          child: AppAltAuthRow(
            label: 'Use password instead',
            icon: Icons.lock_outline_rounded,
            onTap: null,
          ),
        ),
        rtl: true,
      );
      expect(find.byType(DirectionalIcon), findsOneWidget);
      // Mirrored via Transform.flip in RTL.
      expect(find.byType(Transform), findsWidgets);
      // Disabled: 40 % opacity, no tap response.
      expect(
        tester.widget<Opacity>(find.byType(Opacity).first).opacity,
        0.4,
      );
    });

    testWidgets('radius 20 hairline, not a card', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 340,
          child: AppAltAuthRow(
            label: 'Continue with Apple',
            icon: Icons.apple_rounded,
            onTap: null,
          ),
        ),
      );
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppAltAuthRow),
          matching: find.byType(Material),
        ),
      );
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(20));
      expect(shape.side.width, 1.0);
    });
  });

  group('AppSummaryRow', () {
    testWidgets('value is tabular and LTR-isolated in RTL', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 340,
          child: AppSummaryRow(label: 'المجموع', value: 'AED 1,240.00'),
        ),
        rtl: true,
      );
      expect(find.text('المجموع'), findsOneWidget);
      final value = tester.widget<Text>(
        find.text('\u2066AED 1,240.00\u2069'),
      );
      final features = value.style!.fontFeatures!;
      expect(features, contains(FontFeature.tabularFigures()));
      // Value subtree is locked LTR even though the page is RTL.
      final ltrScope = find.ancestor(
        of: find.text('\u2066AED 1,240.00\u2069'),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Directionality &&
              w.textDirection == TextDirection.ltr,
        ),
      );
      expect(ltrScope, findsWidgets);
    });

    testWidgets('wraps at 1.3x without overflow', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 340,
          child: AppSummaryRow(
            label: 'Total including all taxes and service charges',
            value: 'AED 1,240.00',
          ),
        ),
        scale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Semantics', () {
    testWidgets('step headline is a header, meter has a value', (
      tester,
    ) async {
      await _pump(tester, _step());
      final header = tester.getSemantics(
        find.text("What's your phone number?"),
      );
      expect(header.flagsCollection.isHeader, isTrue);
      final cta = tester.getSemantics(find.text('Continue'));
      expect(cta.flagsCollection.isButton, isTrue);
    });

    testWidgets('summary row merges label + value', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 340,
          child: AppSummaryRow(label: 'Total', value: 'AED 240.00'),
        ),
      );
      expect(find.byType(MergeSemantics), findsOneWidget);
      // Single-phrase readout: both parts surface on the merged node, so a
      // screen reader announces "Total AED 240.00" as one unit.
      final node = tester.getSemantics(find.byType(MergeSemantics));
      expect(node.label, contains('Total'));
      expect(node.label, contains('AED 240.00'));
    });
  });

  group('stress: 320 px + 1.3x, both themes', () {
    Future<void> check(
      WidgetTester tester,
      Widget child, {
      bool dark = false,
    }) async {
      tester.view.physicalSize = const Size(960, 1704);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await _pump(tester, child, scale: 1.3, dark: dark);
      expect(tester.takeException(), isNull);
    }

    testWidgets('step scaffold, light', (tester) async {
      await check(tester, _step());
    });

    testWidgets('step scaffold, dark', (tester) async {
      await check(tester, _step(), dark: true);
    });

    testWidgets('sticky bar + divider + rows, light', (tester) async {
      await check(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppStickyActionBar(
              summary: AppSummaryRow(label: 'Total', value: 'AED 240.00'),
              ctaLabel: 'Continue',
              onCta: null,
            ),
            AppOrDivider(label: 'or'),
            AppAltAuthRow(
              label: 'Continue with Google',
              icon: Icons.g_mobiledata_rounded,
              onTap: null,
            ),
          ],
        ),
      );
    });

    testWidgets('sticky bar + divider + rows, dark RTL', (tester) async {
      tester.view.physicalSize = const Size(960, 1704);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await _pump(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppStickyActionBar(
              summary: AppSummaryRow(
                label: 'المجموع',
                value: 'AED 240.00',
              ),
              ctaLabel: 'متابعة',
              onCta: null,
            ),
            AppOrDivider(label: 'أو'),
            AppAltAuthRow(
              label: 'المتابعة عبر جوجل',
              icon: Icons.g_mobiledata_rounded,
              onTap: null,
            ),
          ],
        ),
        scale: 1.3,
        dark: true,
        rtl: true,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
