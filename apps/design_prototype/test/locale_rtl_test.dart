// English LTR + Arabic RTL verification:
//  - directionality comes from the locale
//  - Arabic copy renders (no raw string keys anywhere)
//  - money/number formatting follows the locale convention
//  - directional icons flip; the vehicle map does NOT (canonical exception)
//  - the prototype language switcher changes locale live
import 'package:design_prototype/design/prototype_theme.dart';
import 'package:design_prototype/shell/prototype_shell.dart';
import 'package:design_prototype/widgets/proto_primitives.dart';
import 'package:design_prototype/widgets/proto_vehicle_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prototype_test_utils.dart';

const _keyPattern = r'^[a-z]+(\.[a-zA-Z0-9]+)+$';

void main() {
  group('directionality', () {
    testWidgets('EN renders LTR', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated', size: const Size(390, 844));
      final dir = tester.widgetList<Directionality>(find.byType(Directionality)).first;
      expect(dir.textDirection, TextDirection.ltr);
      await disposeTree(tester);
    });

    testWidgets('AR renders RTL', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated',
          size: const Size(390, 844),
          locale: const Locale('ar'));
      final dir = tester.widgetList<Directionality>(find.byType(Directionality)).first;
      expect(dir.textDirection, TextDirection.rtl);
      await disposeTree(tester);
    });
  });

  group('Arabic copy', () {
    testWidgets('dashboard Arabic strings render', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated',
          size: const Size(768, 1024),
          locale: const Locale('ar'));
      expect(find.text('لوحة المالك'), findsWidgets);
      expect(find.text('ورشة القوز للسيارات'), findsOneWidget);
      await disposeTree(tester);
    });

    testWidgets('inspection Arabic strings render', (tester) async {
      await pumpScreen(tester, ProtoScreen.inspection,
          variant: 'partial',
          size: const Size(768, 1024),
          locale: const Locale('ar'));
      expect(find.text('ورقة الفحص'), findsOneWidget);
      expect(find.textContaining('نقطة فحص'), findsWidgets);
      await disposeTree(tester);
    });

    testWidgets('Arabic font family is applied to Arabic text', (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated',
          size: const Size(768, 1024),
          locale: const Locale('ar'));
      final paragraph = tester.renderObject<RenderParagraph>(find.text('ورشة القوز للسيارات'));
      expect(paragraph.text.style?.fontFamily, 'IBMPlexSansArabic');
      await disposeTree(tester);
    });

    testWidgets('no raw string keys are rendered on any screen (EN + AR)',
        (tester) async {
      for (final screen in ProtoScreen.values) {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          await pumpScreen(tester, screen,
              variant: screen.baseVariant,
              size: const Size(390, 844),
              locale: locale);
          final texts = tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
              .where((t) => t.isNotEmpty);
          for (final value in texts) {
            expect(RegExp(_keyPattern).hasMatch(value), isFalse,
                reason: 'untranslated key rendered on ${screen.goldenName}: "$value"');
          }
          await disposeTree(tester);
        }
      }
    });
  });

  group('locale formatting', () {
    testWidgets('money formats as AED 86,450 (EN) and 86,450 د.إ (AR)',
        (tester) async {
      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated', size: const Size(1280, 800));
      expect(find.textContaining('AED 86,450'), findsWidgets);
      await disposeTree(tester);

      await pumpScreen(tester, ProtoScreen.ownerDashboard,
          variant: 'populated',
          size: const Size(1280, 800),
          locale: const Locale('ar'));
      expect(find.textContaining('86,450 د.إ'), findsWidgets);
      await disposeTree(tester);
    });
  });

  group('directional icons and the vehicle map exception', () {
    testWidgets('chevrons mirror in AR and stay fixed in EN', (tester) async {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        await pumpScreen(tester, ProtoScreen.ownerDashboard,
            variant: 'populated', size: const Size(390, 844), locale: locale);
        final transform = tester.widgetList<Transform>(
          find.descendant(
            of: find.byType(ProtoDirIcon).first,
            matching: find.byType(Transform),
          ),
        ).first;
        final flipX = transform.transform.storage[0];
        expect(flipX, locale.languageCode == 'ar' ? -1.0 : 1.0);
        await disposeTree(tester);
      }
    });

    testWidgets('vehicle map body never mirrors in RTL (documented exception)',
        (tester) async {
      // pumpScreen warms the real-asset caches outside the fake-async zone.
      await pumpScreen(tester, ProtoScreen.inspection,
          variant: 'partial',
          size: const Size(1280, 800),
          locale: const Locale('ar'));
      final found = await pumpUntilFound(tester, find.byType(ProtoVehicleMap), maxFrames: 60);
      expect(found, isTrue, reason: 'vehicle map did not finish loading');
      final mapDirectionality = tester
          .widgetList<Directionality>(find.descendant(
            of: find.byType(ProtoVehicleMap),
            matching: find.byType(Directionality),
          ))
          .first;
      expect(mapDirectionality.textDirection, TextDirection.ltr);
      await disposeTree(tester);
    });
  });

  group('language switcher (prototype shell console)', () {
    testWidgets('tapping العربية switches the whole prototype to RTL live',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await loadPrototypeFonts();

      await tester.pumpWidget(const _ShellHarness());
      await tester.pump(const Duration(milliseconds: 100));

      // Console chip + dashboard top bar both carry the screen name.
      expect(find.text('Owner Dashboard'), findsWidgets);

      await tester.tap(find.text('ع'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('لوحة المالك'), findsWidgets);
      final dir = tester.widgetList<Directionality>(find.byType(Directionality)).first;
      expect(dir.textDirection, TextDirection.rtl);

      await disposeTree(tester);
    });
  });
}

/// Minimal stateful harness that mirrors main.dart's locale wiring so the real
/// console switcher can be exercised.
class _ShellHarness extends StatefulWidget {
  const _ShellHarness();

  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    final arabic = _locale.languageCode == 'ar';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: PrototypeTheme.light(arabic: arabic),
      home: PrototypeShell(
        locale: _locale,
        themeMode: _themeMode,
        onLocaleChanged: (locale) => setState(() => _locale = locale),
        onThemeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
