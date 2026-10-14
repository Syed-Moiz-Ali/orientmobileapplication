import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  bool dark = false,
  AppDensityMode density = AppDensityMode.comfortable,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      SharedCoreLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: dark
        ? AppTheme.dark(BrandConfig.orient, locale: locale, density: density)
        : AppTheme.light(BrandConfig.orient, locale: locale, density: density),
    home: Scaffold(body: child),
  );
}

/// Phase 01.2 — AppDensity ThemeExtension + provider + widget wiring.
void main() {
  group('AppDensity tokens', () {
    test('comfortable and compact carry the frozen row geometry', () {
      expect(AppDensity.comfortable.rowHeight, 44);
      expect(AppDensity.comfortable.headerHeight, 40);
      expect(AppDensity.compact.rowHeight, 36);
      expect(AppDensity.compact.headerHeight, 36);
      expect(AppDensity.comfortable.isCompact, isFalse);
      expect(AppDensity.compact.isCompact, isTrue);
      expect(AppDensity.comfortable.isComfortable, isTrue);
    });

    test('forMode resolves each mode', () {
      expect(
        AppDensity.forMode(AppDensityMode.comfortable),
        AppDensity.comfortable,
      );
      expect(
        AppDensity.forMode(AppDensityMode.compact),
        AppDensity.compact,
      );
    });

    test('copyWith overrides only the supplied role', () {
      final edited = AppDensity.comfortable.copyWith(rowHeight: 40);
      expect(edited.rowHeight, 40);
      expect(edited.headerHeight, AppDensity.comfortable.headerHeight);
      expect(edited.mode, AppDensityMode.comfortable);
    });

    test('lerp interpolates geometry and flips mode past midpoint', () {
      final quarter = AppDensity.comfortable.lerp(AppDensity.compact, 0.25);
      expect(quarter.rowHeight, closeTo(42, 0.001));
      expect(quarter.mode, AppDensityMode.comfortable);
      final past = AppDensity.comfortable.lerp(AppDensity.compact, 0.75);
      expect(past.mode, AppDensityMode.compact);
      expect(
        AppDensity.comfortable.lerp(AppDensity.compact, 1).rowHeight,
        36,
      );
    });

    test('null other lerps to self', () {
      expect(
        AppDensity.comfortable.lerp(null, 0.5),
        AppDensity.comfortable,
      );
    });
  });

  group('Theme registration (light + dark)', () {
    test('light and dark themes register the density extension', () {
      final light = AppTheme.light(BrandConfig.orient);
      final dark = AppTheme.dark(BrandConfig.orient);
      expect(light.extension<AppDensity>(), AppDensity.comfortable);
      expect(dark.extension<AppDensity>(), AppDensity.comfortable);
    });

    test('density parameter selects the compact extension', () {
      final light = AppTheme.light(
        BrandConfig.orient,
        density: AppDensityMode.compact,
      );
      final dark = AppTheme.dark(
        BrandConfig.orient,
        density: AppDensityMode.compact,
      );
      expect(light.extension<AppDensity>(), AppDensity.compact);
      expect(dark.extension<AppDensity>(), AppDensity.compact);
    });

    testWidgets('context.density follows the active theme (light)', (
      tester,
    ) async {
      late AppDensity seen;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              seen = context.density;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, AppDensity.comfortable);
    });

    testWidgets('context.density follows the active theme (dark compact)', (
      tester,
    ) async {
      late AppDensity seen;
      await tester.pumpWidget(
        _host(
          dark: true,
          density: AppDensityMode.compact,
          child: Builder(
            builder: (context) {
              seen = context.density;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, AppDensity.compact);
      expect(seen.rowHeight, 36);
    });

    testWidgets('a bare ThemeData still resolves comfortable', (tester) async {
      late AppDensity seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              seen = context.density;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen, AppDensity.comfortable);
    });
  });

  group('densityModeProvider + AppDensityScope', () {
    test('provider defaults to comfortable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(densityModeProvider), AppDensityMode.comfortable);
    });

    test('provider can toggle to compact', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(densityModeProvider.notifier).state =
          AppDensityMode.compact;
      expect(container.read(densityModeProvider), AppDensityMode.compact);
    });

    testWidgets('AppDensityScope overrides the subtree only', (tester) async {
      late AppDensity outer;
      late AppDensity inner;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              outer = context.density;
              return AppDensityScope(
                mode: AppDensityMode.compact,
                child: Builder(
                  builder: (context) {
                    inner = context.density;
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );
      expect(outer, AppDensity.comfortable);
      expect(inner, AppDensity.compact);
    });
  });

  group('Widget wiring', () {
    const columns = [
      AppTableColumn(label: 'Plate', flex: 2),
      AppTableColumn(label: 'Amount', numeric: true),
    ];

    Widget tableHarness() => AppTable<String>(
          columns: columns,
          items: const ['A 12345'],
          cells: (context, item) => [
            AppTableCell.text(context, item),
            AppTableCell.numeric(context, 'AED 1,250'),
          ],
          compactBuilder: (context, item) =>
              AppRecordRow(title: item, onTap: () {}),
        );

    testWidgets('compact density forces dense table rows (light)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(density: AppDensityMode.compact, child: tableHarness()),
      );
      await tester.pump();
      final header =
          tester.widget<AppTableHeader>(find.byType(AppTableHeader));
      expect(header.dense, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact density forces dense table rows (dark)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          dark: true,
          density: AppDensityMode.compact,
          child: tableHarness(),
        ),
      );
      await tester.pump();
      final header =
          tester.widget<AppTableHeader>(find.byType(AppTableHeader));
      expect(header.dense, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('comfortable density keeps regular rows on wide screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(child: tableHarness()));
      await tester.pump();
      final header =
          tester.widget<AppTableHeader>(find.byType(AppTableHeader));
      expect(header.dense, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('record-row padding follows density', (tester) async {
      Future<EdgeInsetsGeometry> paddingFor(AppDensityMode mode) async {
        await tester.pumpWidget(
          _host(
            density: mode,
            child: const AppRecordRow(title: 'Probe'),
          ),
        );
        // AnimatedTheme tweens between brightness/density swaps; settle so
        // the new extension is fully resolved before measuring.
        await tester.pumpAndSettle();
        final padding = tester.widget<Padding>(
          find.descendant(
            of: find.byType(AppRecordRow),
            matching: find.byType(Padding),
          ).first,
        );
        return padding.padding;
      }

      final comfortable = await paddingFor(AppDensityMode.comfortable);
      final compact = await paddingFor(AppDensityMode.compact);
      final cComfortable = comfortable.resolve(TextDirection.ltr);
      final cCompact = compact.resolve(TextDirection.ltr);
      expect(
        cCompact.vertical,
        lessThan(cComfortable.vertical),
        reason: 'compact rows must be tighter than comfortable rows',
      );
    });

    testWidgets('record-row explicit padding override is honoured', (
      tester,
    ) async {
      const custom = EdgeInsets.all(2);
      await tester.pumpWidget(
        _host(
          density: AppDensityMode.compact,
          child: const AppRecordRow(title: 'Probe', padding: custom),
        ),
      );
      await tester.pump();
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(AppRecordRow),
          matching: find.byType(Padding),
        ).first,
      );
      expect(padding.padding, custom);
    });

    testWidgets('list-surface skeleton renders in both densities', (
      tester,
    ) async {
      for (final mode in AppDensityMode.values) {
        await tester.pumpWidget(
          _host(
            density: mode,
            child: const AppListSurface(
              isLoading: true,
              skeletonRows: 2,
              child: SizedBox.shrink(),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(AppSkeleton), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('table renders in Arabic compact density without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          density: AppDensityMode.compact,
          child: tableHarness(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
