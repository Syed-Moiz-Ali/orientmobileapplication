import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  bool dark = false,
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
        ? AppTheme.dark(BrandConfig.orient, locale: locale)
        : AppTheme.light(BrandConfig.orient, locale: locale),
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppChartTheme palette', () {
    test('light/dark palettes are the frozen 6-value series', () {
      expect(AppChartTheme.paletteFor(Brightness.light), AppColors.chartSeries);
      expect(
        AppChartTheme.paletteFor(Brightness.dark),
        AppColors.chartSeriesDark,
      );
      expect(AppChartTheme.paletteFor(Brightness.light).length, 6);
      expect(AppChartTheme.maxSeries, 4);
    });

    testWidgets('of() resolves brightness, locale and direction', (
      tester,
    ) async {
      late AppChartTheme light;
      late AppChartTheme ar;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              light = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(light.isDark, isFalse);
      expect(light.isRtl, isFalse);
      expect(light.isArabic, isFalse);
      expect(light.palette, AppColors.chartSeries);

      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: Builder(
            builder: (context) {
              ar = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(ar.isRtl, isTrue);
      expect(ar.isArabic, isTrue);
    });

    testWidgets('series colours cap at maxSeries and wrap', (tester) async {
      late AppChartTheme theme;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              theme = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.seriesColors(1), [AppColors.chartSeries[0]]);
      expect(theme.seriesColors(2), [
        AppColors.chartSeries[0],
        AppColors.chartSeries[1],
      ]);
      expect(theme.seriesColors(4), [
        AppColors.chartSeries[0],
        AppColors.chartSeries[1],
        AppColors.chartSeries[2],
        AppColors.chartSeries[3],
      ]);
      // More than max is capped to 4.
      expect(theme.seriesColors(6).length, 4);
      // Index wraps the palette.
      expect(theme.seriesColor(6), AppColors.chartSeries[0]);
    });

    testWidgets('orderSeries mirrors in RTL only', (tester) async {
      late AppChartTheme ltr;
      late AppChartTheme rtl;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              ltr = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: Builder(
            builder: (context) {
              rtl = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(ltr.orderSeries([1, 2, 3]), [1, 2, 3]);
      expect(rtl.orderSeries([1, 2, 3]), [3, 2, 1]);
    });

    testWidgets('gridline + tooltip inks come from the theme', (tester) async {
      late AppChartTheme theme;
      late ColorScheme scheme;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              theme = AppChartTheme.of(context);
              scheme = Theme.of(context).colorScheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(theme.gridlineColor, scheme.outline);
      final box = theme.tooltipDecoration;
      expect(box.color, scheme.inverseSurface);
    });
  });

  group('AppChartPlaceholder', () {
    testWidgets('renders localized empty-data copy (EN/AR)', (tester) async {
      await tester.pumpWidget(_host(child: const AppChartPlaceholder()));
      expect(find.text('No data yet'), findsOneWidget);
      expect(
        find.text('No chart data available for this period'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        _host(locale: const Locale('ar'), child: const AppChartPlaceholder()),
      );
      expect(find.text('لا توجد بيانات بعد'), findsOneWidget);
    });
  });

  group('Currency formatting via AppFormatters', () {
    testWidgets('formatCurrency keeps locale placement (EN/AR)', (
      tester,
    ) async {
      late AppChartTheme theme;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              theme = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final en = AppFormatters(const Locale('en'));
      final ar = AppFormatters(const Locale('ar'));
      expect(theme.formatCurrency(12450, en), 'AED 12,450');
      expect(theme.formatCurrency(12450, ar), '12,450 د.إ');
      // Latin digits in both locales.
      expect(
        AppFormatters.containsNonLatinDigits(theme.formatCurrency(12450, ar)),
        isFalse,
      );
    });

    testWidgets('formatValue groups quantities, currencies money', (
      tester,
    ) async {
      late AppChartTheme theme;
      await tester.pumpWidget(
        _host(
          child: Builder(
            builder: (context) {
              theme = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      final en = AppFormatters(const Locale('en'));
      expect(theme.formatValue(12450, en), '12,450');
      expect(theme.formatValue(12450, en, currency: true), 'AED 12,450');
    });

    testWidgets('fourth series resolves and RTL order mirrors four', (
      tester,
    ) async {
      late AppChartTheme rtl;
      await tester.pumpWidget(
        _host(
          locale: const Locale('ar'),
          child: Builder(
            builder: (context) {
              rtl = AppChartTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(rtl.seriesColors(4).length, 4);
      expect(rtl.orderSeries([1, 2, 3, 4]), [4, 3, 2, 1]);
      expect(rtl.orderedPalette(4).length, 4);
    });
  });
}
