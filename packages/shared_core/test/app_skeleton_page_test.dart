import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Widget _host({required Widget child, Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocales.supported,
    localizationsDelegates: const [
      SharedCoreLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: AppTheme.light(BrandConfig.orient, locale: locale),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

/// Phase 07.1 — `AppSkeleton.page()` dashboard placeholder: renders in both
/// themes and locales, survives 320 px, and stays static under
/// reduced-motion.
void main() {
  testWidgets('page renders without overflow (EN)', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(child: const AppSkeleton.page()));
    await tester.pump();
    expect(find.byType(AppSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page renders at 320 px (AR)', (tester) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(locale: const Locale('ar'), child: const AppSkeleton.page()),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('page resolves dark skeleton tokens', (tester) async {
    late Color base;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(BrandConfig.orient),
        home: Builder(
          builder: (context) {
            base = context.semanticColors.skeletonBase;
            return const Scaffold(
              body: SingleChildScrollView(child: AppSkeleton.page()),
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(base, AppDarkColors.skeletonBase);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page stays static under reduced motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _host(child: const AppSkeleton.page()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
