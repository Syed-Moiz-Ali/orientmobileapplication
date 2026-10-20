// Phase-1d-ii widget tests: AppShimmer, AppShimmerSkeleton, AppLoader,
// AppNetworkImage.
//
// Covers AA contrast pairs (loader accent >= 3.0 non-text, error-fallback
// icon >= 3.0; shimmer tints measured + judged subtle-by-design), state
// behavior (enabled/reduced-motion static, skeleton variants, loader label,
// network success/error/radius), Semantics (loading labels, live regions,
// image nodes), RTL and text scale 1.3x. Network images use deterministic
// stubs (kTransparentImage / undecodable bytes) — never real network.
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shimmer/shimmer.dart';

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
  bool noMotion = false,
}) {
  final brand = BrandConfig.orient;
  return MaterialApp(
    theme: AppTheme.light(brand),
    darkTheme: AppTheme.dark(brand),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: noMotion,
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
  bool noMotion = false,
}) async {
  await tester.pumpWidget(
    _wrap(child, dark: dark, rtl: rtl, scale: scale, noMotion: noMotion),
  );
  await tester.pump();
}

ThemeData _theme(bool dark) =>
    dark ? AppTheme.dark(BrandConfig.orient) : AppTheme.light(BrandConfig.orient);

/// 1x1 transparent PNG (the classic `kTransparentImage` bytes, inlined
/// because this Flutter revision does not export it from `flutter_test`).
final Uint8List _transparentPng = Uint8List.fromList(const <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  group('AA contrast pairs (phase-1d-ii gate)', () {
    test('loader accent vs page canvas >= 3.0, both themes', () {
      for (final dark in [false, true]) {
        final theme = _theme(dark);
        final ratio = _ratio(
          theme.colorScheme.primary,
          theme.scaffoldBackgroundColor,
        );
        debugPrint('1d-ii loader ${dark ? 'dark' : 'light'}=$ratio');
        expect(ratio, greaterThanOrEqualTo(3.0));
      }
    });

    test('error-fallback icon ink vs fill >= 3.0, both themes', () {
      for (final dark in [false, true]) {
        final scheme = _theme(dark).colorScheme;
        final ratio = _ratio(
          scheme.onSurfaceVariant,
          scheme.surfaceContainerHighest,
        );
        debugPrint('1d-ii img-error ${dark ? 'dark' : 'light'}=$ratio');
        expect(ratio, greaterThanOrEqualTo(3.0));
      }
    });

    test('shimmer tints measured: distinct but intentionally subtle', () {
      // No AA gate here by judgement (same treatment as 1c-ii's 1.01 fill
      // pair): the tints are decorative by design — the travelling motion +
      // the "Loading" semantics node carry the meaning, never the tint.
      for (final dark in [false, true]) {
        final sem = dark ? AppSemanticColors.dark : AppSemanticColors.light;
        final canvas =
            _theme(dark).scaffoldBackgroundColor;
        expect(sem.skeletonBase, isNot(equals(sem.skeletonHighlight)));
        debugPrint(
          '1d-ii shimmer ${dark ? 'dark' : 'light'} '
          'base-hl=${_ratio(sem.skeletonBase, sem.skeletonHighlight)} '
          'base-canvas=${_ratio(sem.skeletonBase, canvas)}',
        );
      }
    });
  });

  group('AppShimmer', () {
    testWidgets('wraps child in a live shimmer with defaults', (tester) async {
      await _pump(
        tester,
        const AppShimmer(child: SizedBox(width: 100, height: 14)),
      );
      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      final semantics = tester.getSemantics(find.byType(AppShimmer));
      expect(semantics.label, 'Loading');
      expect(tester.takeException(), isNull);
    });

    testWidgets('enabled=false renders the child with no ticker', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppShimmer(
          enabled: false,
          child: SizedBox(width: 100, height: 14),
        ),
      );
      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion renders static (no Shimmer widget)', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppShimmer(child: SizedBox(width: 100, height: 14)),
        noMotion: true,
      );
      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('live shimmer in RTL travels from the start edge', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppShimmer(child: SizedBox(width: 100, height: 14)),
        rtl: true,
      );
      expect(find.byType(Shimmer), findsOneWidget);
      final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
      expect(shimmer.direction, ShimmerDirection.rtl);
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom label + token period (1200 ms shimmer loop)', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppShimmer(
          semanticLabel: 'Loading bookings',
          child: SizedBox(width: 100, height: 14),
        ),
      );
      expect(
        tester.getSemantics(find.byType(AppShimmer)).label,
        'Loading bookings',
      );
      final shimmer = tester.widget<Shimmer>(find.byType(Shimmer));
      expect(shimmer.period, AppDurations.shimmerLoop);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppShimmerSkeleton', () {
    testWidgets('bar/card/circle/textBlock/listRows all render', (tester) async {
      await _pump(tester, const AppShimmerSkeleton());
      expect(find.byType(AppShimmer), findsOneWidget);

      await _pump(tester, const AppShimmerSkeleton.card(height: 96));
      expect(find.byType(AppShimmer), findsOneWidget);

      await _pump(tester, const AppShimmerSkeleton.circle());
      final circle = tester.getRect(find.byType(AppShimmerSkeleton));
      expect(circle.width, 40);
      expect(circle.height, 40);

      await _pump(tester, const AppShimmerSkeleton.textBlock());
      expect(
        find.byWidgetPredicate(
          (w) => w is FractionallySizedBox && w.widthFactor == 0.6,
        ),
        findsOneWidget,
      );

      await _pump(
        tester,
        const AppShimmerSkeleton.listRows(rows: 3, enabled: false),
      );
      // 3 rows x (40 px leading block each).
      expect(find.byType(AppShimmerSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('listRows leading gap is directional and removable', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppShimmerSkeleton.listRows(rows: 2, leading: false),
      );
      // The 12 px leading-to-text gap exists only with a leading block.
      Finder leadingGap() => find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == AppSpacing.md,
          );
      expect(leadingGap(), findsNothing);

      await _pump(
        tester,
        const AppShimmerSkeleton.listRows(rows: 2),
      );
      expect(leadingGap(), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL + dark + reduced motion safe', (tester) async {
      await _pump(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppShimmerSkeleton.card(height: 96),
            AppShimmerSkeleton.listRows(rows: 3),
          ],
        ),
        dark: true,
        rtl: true,
        scale: 1.3,
        noMotion: true,
      );
      // Static under reduced motion even at scale.
      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(AppShimmerSkeleton), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('AppLoader', () {
    testWidgets('28 px accent spinner + busy live-region label', (tester) async {
      await _pump(tester, const AppLoader(label: 'Saving changes'));
      final box = tester.getSize(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 28 && w.height == 28,
        ),
      );
      expect(box, const Size(28, 28));
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(
        (spinner.valueColor as AlwaysStoppedAnimation<Color>).value,
        _theme(false).colorScheme.primary,
      );
      final semantics = tester.getSemantics(find.byType(AppLoader));
      expect(semantics.label, 'Saving changes, loading');
      expect(semantics.flagsCollection.isLiveRegion, isTrue);
      expect(find.textContaining('Saving changes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('default label + 1.3x RTL dark safe', (tester) async {
      await _pump(
        tester,
        const AppLoader(),
        dark: true,
        rtl: true,
        scale: 1.3,
      );
      expect(
        tester.getSemantics(find.byType(AppLoader)).label,
        'Loading, loading',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion renders a static spinner (no ticker)', (
      tester,
    ) async {
      await _pump(
        tester,
        const AppLoader(label: 'Saving changes'),
        noMotion: true,
      );
      final staticSpinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      // Determinate value = no animation ticker; live region still announces.
      expect(staticSpinner.value, isNotNull);
      expect(
        tester.getSemantics(find.byType(AppLoader)).label,
        'Saving changes, loading',
      );

      await _pump(tester, const AppLoader(label: 'Saving changes'));
      final liveSpinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(liveSpinner.value, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('AppNetworkImage', () {
    // Engine codec work lands on the real event loop (proven by probe: the
    // frame arrives only after the FakeAsync body ends), so every image test
    // below drives pumpWidget + a real 300 ms delay inside runAsync — the
    // same pattern phase-0a uses for auth-restore pumps.
    Future<void> pumpImage(WidgetTester tester, Widget child) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_wrap(child));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pump();
      });
    }

    testWidgets('memory stub loads inside the radius clip', (tester) async {
      // Loading placeholder mirrors the clip radius (same [radius] on the
      // skeleton while the frame is pending); frozen here via reduced motion
      // so the check is deterministic.
      await _pump(
        tester,
        AppNetworkImage(
          imageUrl: 'https://example.com/cover.jpg',
          provider: MemoryImage(_transparentPng),
          width: 120,
          height: 120,
          semanticLabel: 'Cover photo',
        ),
        noMotion: true,
      );
      final skeleton = tester.widget<AppShimmerSkeleton>(
        find.byType(AppShimmerSkeleton),
      );
      expect(skeleton.radius, AppRadius.image);
      // While loading, the placeholder announces 'Loading image' instead —
      // frameBuilder replaces the whole subtree, wrapper included.
      await pumpImage(
        tester,
        AppNetworkImage(
          imageUrl: 'https://example.com/cover.jpg',
          provider: MemoryImage(_transparentPng),
          width: 120,
          height: 120,
          semanticLabel: 'Cover photo',
        ),
      );
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(
        clip.borderRadius,
        BorderRadius.circular(AppRadius.image),
      );
      // Decoded stub: real pixels, no fallback icon, image label announced.
      expect(find.byType(RawImage), findsOneWidget);
      expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
      expect(find.bySemanticsLabel('Cover photo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('undecodable bytes show the error fallback', (tester) async {
      await pumpImage(
        tester,
        AppNetworkImage(
          imageUrl: 'https://example.com/cover.jpg',
          provider: MemoryImage(Uint8List.fromList(const [0, 1, 2, 3])),
          width: 120,
          height: 120,
        ),
      );
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.bySemanticsLabel('Image failed to load'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.3x + RTL + dark error safe', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          _wrap(
            AppNetworkImage(
              imageUrl: 'https://example.com/avatar.jpg',
              provider: MemoryImage(Uint8List.fromList(const [9, 9, 9])),
              width: 64,
              height: 64,
              radius: AppRadius.pill,
            ),
            dark: true,
            rtl: true,
            scale: 1.3,
          ),
        );
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pump();
      });
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      // Avatar shape holds through the fallback: pill clip + pill fallback.
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, BorderRadius.circular(AppRadius.pill));
      final fallbackShape =
          (tester
                      .widget<Container>(
                        find.byWidgetPredicate(
                          (w) =>
                              w is Container &&
                              w.decoration is ShapeDecoration,
                        ),
                      )
                      .decoration as
                  ShapeDecoration)
              .shape as RoundedRectangleBorder;
      expect(
        fallbackShape.borderRadius,
        BorderRadius.circular(AppRadius.pill),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
