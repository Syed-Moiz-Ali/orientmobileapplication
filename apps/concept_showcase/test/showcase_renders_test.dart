import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:concept_showcase/concepts/concept_tokens.dart';
import 'package:concept_showcase/concepts/concept_a_screens.dart';
import 'package:concept_showcase/concepts/concept_b_screens.dart';
import 'package:concept_showcase/concepts/concept_c_screens.dart';
import 'showcase_font_loader.dart';

void main() {
  setUpAll(() async {
    await loadShowcaseFonts();
  });

  Widget buildTestHost(Widget child, Size size, {bool isArabic = false}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: isArabic ? const Locale('ar') : const Locale('en'),
      theme: ThemeData(
        fontFamily: isArabic ? 'IBMPlexSansArabic' : 'PlusJakartaSans',
      ),
      home: Scaffold(
        body: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );
  }

  group('Concept A — Premium Minimal Automotive Rendering Suite', () {
    for (final screen in ShowcaseScreen.values) {
      testWidgets('Concept A: ${screen.label} (Mobile 390 EN)', (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestHost(
            ConceptAScreens.buildScreen(screen, false, false),
            const Size(390, 844),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/concept_a_${screen.name}_390_en.png'),
        );
      });

      testWidgets('Concept A: ${screen.label} (Mobile 390 AR RTL)', (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestHost(
            ConceptAScreens.buildScreen(screen, false, true),
            const Size(390, 844),
            isArabic: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/concept_a_${screen.name}_390_ar.png'),
        );
      });
    }
  });

  group('Concept B — Modern Expressive Product Rendering Suite', () {
    for (final screen in ShowcaseScreen.values) {
      testWidgets('Concept B: ${screen.label} (Mobile 390 EN)', (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestHost(
            ConceptBScreens.buildScreen(screen, false, false),
            const Size(390, 844),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/concept_b_${screen.name}_390_en.png'),
        );
      });
    }
  });

  group('Concept C — Advanced Operational SaaS Rendering Suite', () {
    for (final screen in ShowcaseScreen.values) {
      testWidgets('Concept C: ${screen.label} (Mobile 390 EN)', (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestHost(
            ConceptCScreens.buildScreen(screen, false, false),
            const Size(390, 844),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(MaterialApp), findsOneWidget);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/concept_c_${screen.name}_390_en.png'),
        );
      });
    }
  });

  group('Responsive Breakpoint Visual Suite (Tablet 768 & Desktop 1280)', () {
    testWidgets('Concept A: Staff Inspection (Tablet 768 EN)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestHost(
          ConceptAScreens.buildScreen(ShowcaseScreen.staff, false, false),
          const Size(768, 1024),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/concept_a_staff_768_en.png'),
      );
    });

    testWidgets('Concept A: Owner Dashboard (Desktop 1280 EN)', (tester) async {
      tester.view.physicalSize = const Size(1280 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestHost(
          ConceptAScreens.buildScreen(ShowcaseScreen.owner, false, false),
          const Size(1280, 800),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/concept_a_owner_1280_en.png'),
      );
    });
  });
}
