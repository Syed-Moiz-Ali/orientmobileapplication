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
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

Widget _card({VoidCallback? onFavorite}) => AirbnbImageCard(
      image: const VehicleSilhouetteArt(),
      badge: const TrustPill.topRated('Top rated'),
      title: 'Toyota Land Cruiser',
      meta: '2021 · White · 48,200 km',
      onFavorite: onFavorite,
      favoriteLabel: 'Save to favorites',
      footer: const Text('A 12345'),
    );

void main() {
  group('AirbnbImageCard', () {
    testWidgets('renders art, badge, title and footer', (tester) async {
      await tester.pumpWidget(_host(child: _card()));
      expect(find.text('Toyota Land Cruiser'), findsOneWidget);
      expect(find.text('Top rated'), findsOneWidget);
      expect(find.text('A 12345'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('heart renders only with a handler', (tester) async {
      await tester.pumpWidget(_host(child: _card()));
      expect(find.byIcon(Icons.favorite_outline_rounded), findsNothing);

      var tapped = false;
      await tester.pumpWidget(
        _host(child: _card(onFavorite: () => tapped = true)),
      );
      await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
      expect(tapped, isTrue);
    });

    testWidgets('favorited heart uses the error tone', (tester) async {
      await tester.pumpWidget(
        _host(
          child: AirbnbImageCard(
            image: const VehicleSilhouetteArt(),
            title: 'Car',
            favorited: true,
            onFavorite: () {},
            favoriteLabel: 'Save',
          ),
        ),
      );
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives 320px at 1.3x', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.3),
          ),
          child: _host(child: _card(onFavorite: () {})),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('TrustPill', () {
    testWidgets('verified and top-rated resolve theme tones', (tester) async {
      await tester.pumpWidget(
        _host(
          child: const Column(
            children: [
              TrustPill.verified('Verified workshop'),
              SizedBox(height: 8),
              TrustPill.topRated('Top rated'),
            ],
          ),
        ),
      );
      expect(find.text('Verified workshop'), findsOneWidget);
      expect(find.text('Top rated'), findsOneWidget);
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
      required Size size,
      required Locale locale,
      required String fileName,
      bool dark = false,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
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
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _card(onFavorite: () {}),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        TrustPill.verified('Verified workshop'),
                        SizedBox(width: 8),
                        TrustPill.topRated('Top rated'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      await expectLater(find.byType(Scaffold), matchesGoldenFile(fileName));
    }

    testWidgets('airbnb compact (English)', (tester) async {
      await capture(
        tester,
        size: const Size(390, 1200),
        locale: const Locale('en'),
        fileName: 'goldens/airbnb_compact_en.png',
      );
    });

    testWidgets('airbnb compact (Arabic)', (tester) async {
      await capture(
        tester,
        size: const Size(390, 1200),
        locale: const Locale('ar'),
        fileName: 'goldens/airbnb_compact_ar.png',
      );
    });

    testWidgets('airbnb compact dark (English)', (tester) async {
      await capture(
        tester,
        size: const Size(390, 1200),
        locale: const Locale('en'),
        dark: true,
        fileName: 'goldens/airbnb_compact_en_dark.png',
      );
    });
  });
}
