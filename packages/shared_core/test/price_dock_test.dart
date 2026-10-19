import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({
  required Widget child,
  Locale locale = const Locale('en'),
  bool dark = false,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
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

Widget _dock({VoidCallback? onCta, bool busy = false, bool enabled = true}) =>
    PriceBreakdownDock(
      items: const [
        PriceBreakdownItem(label: 'Major Service', amount: 'AED 450'),
        PriceBreakdownItem(label: 'AC Refresh', amount: 'AED 120'),
      ],
      totalLabel: 'Total',
      totalAmount: 'AED 570',
      ctaLabel: 'Continue',
      busyLabel: 'Working…',
      onCta: onCta,
      busy: busy,
      ctaEnabled: enabled,
      trustLine: 'Free re-check within 7 days',
    );

void main() {
  group('PriceBreakdownDock', () {
    testWidgets('renders items, tabular total, CTA and trust line', (
      tester,
    ) async {
      await tester.pumpWidget(_host(child: _dock(onCta: () {})));
      expect(find.text('Major Service'), findsOneWidget);
      expect(find.text('AED 450'), findsOneWidget);
      expect(find.text('AED 570'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Free re-check within 7 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled CTA stays visible but inert', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(child: _dock(onCta: () => tapped = true, enabled: false)),
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('busy shows spinner and busy label', (tester) async {
      await tester.pumpWidget(_host(child: _dock(onCta: () {}, busy: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Working…'), findsOneWidget);
    });

    testWidgets('CTA meets the 52px touch floor', (tester) async {
      await tester.pumpWidget(_host(child: _dock(onCta: () {})));
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(52));
      expect(size.width, greaterThanOrEqualTo(48));
    });

    testWidgets('survives 320px at 1.3x', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: _host(child: _dock(onCta: () {})),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    setUpAll(() async {
      final latin = FontLoader(AppFontFamilies.app)
        ..addFont(
          rootBundle.load(
            'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
          ),
        );
      final arabic = FontLoader(AppFontFamilies.arabic)
        ..addFont(
          rootBundle.load(
            'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
          ),
        )
        ..addFont(
          rootBundle.load(
            'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Bold.ttf',
          ),
        );
      await latin.load();
      await arabic.load();
    });

    Future<void> capture(
      WidgetTester tester, {
      required Locale locale,
      required String fileName,
      bool dark = false,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 700);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(child: _dock(onCta: () {}), locale: locale, dark: dark));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
    }

    testWidgets('dock compact (English)', (tester) async {
      await capture(
        tester,
        locale: const Locale('en'),
        fileName: 'goldens/price_dock_compact_en.png',
      );
    });

    testWidgets('dock compact (Arabic)', (tester) async {
      await capture(
        tester,
        locale: const Locale('ar'),
        fileName: 'goldens/price_dock_compact_ar.png',
      );
    });

    testWidgets('dock compact dark (English)', (tester) async {
      await capture(
        tester,
        locale: const Locale('en'),
        dark: true,
        fileName: 'goldens/price_dock_compact_en_dark.png',
      );
    });
  });
}
