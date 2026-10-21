// C16 hard-reject automated guards (additive).
//
// Fails the build if a shared card regresses to a bordered light-theme
// decoration, if the page-header/hero path renders an uppercase transform,
// if a primary control's tap target drops below 48dp, or if a badge
// overlaps the icon it decorates. Hermetic: no network, bundled fonts only
// (loaded once in setUpAll), light theme via [AppTheme.light].
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('packages/shared_core/Plus Jakarta Sans', [
    'assets/fonts/plus_jakarta_sans/PlusJakartaSans-Variable.ttf',
  ]);
  await load('packages/shared_core/IBM Plex Sans Arabic', [
    'assets/fonts/ibm_plex_sans_arabic/IBMPlexSansArabic-Regular.ttf',
  ]);

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
      break;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(BrandConfig.orient),
    home: Scaffold(body: Center(child: child)),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_wrap(child));
  await tester.pump();
  expect(tester.takeException(), isNull);
}

/// Card-surface [BoxDecoration]s in the subtree must be borderless in light
/// theme (C5: border XOR shadow; C16 hard-reject: light cards take the
/// shadow path, never a 1px border). Scoped to card geometry (circular
/// radius 16–20): status chips (pill 999) carry their own ring by design
/// and are not card surfaces.
List<BoxDecoration> _borderedCardDecorations(WidgetTester tester) {
  final found = <BoxDecoration>[];
  for (final element in find
      .byWidgetPredicate(
        (w) =>
            w is Container && w.decoration is BoxDecoration ||
            w is DecoratedBox && w.decoration is BoxDecoration,
      )
      .evaluate()) {
    final widget = element.widget;
    final BoxDecoration decoration;
    if (widget is Container) {
      decoration = widget.decoration! as BoxDecoration;
    } else {
      decoration = (widget as DecoratedBox).decoration as BoxDecoration;
    }
    if (decoration.border == null) continue;
    final radius = decoration.borderRadius;
    if (radius is BorderRadius) {
      final r = radius.topLeft.x;
      if (r >= 15.0 && r <= 21.0) found.add(decoration);
    }
  }
  return found;
}

/// True when [s] contains cased Latin running text in ALL CAPS (codes like
/// "JC-1042" and numerals are exempt — caller text, not a transform).
bool _isAllCapsLatin(String s) {
  final letters = s.replaceAll(RegExp('[^A-Za-z]'), '');
  if (letters.length < 2) return false;
  return letters == letters.toUpperCase() && letters != letters.toLowerCase();
}

List<String> _allCapsTexts(WidgetTester tester) {
  final hits = <String>[];
  for (final element in find.byType(Text).evaluate()) {
    final widget = element.widget as Text;
    final data = widget.data ?? widget.textSpan?.toPlainText() ?? '';
    if (_isAllCapsLatin(data)) hits.add(data);
  }
  return hits;
}

void main() {
  setUpAll(() async {
    await _loadFonts();
  });

  group('hard-reject (a): borderless light cards', () {
    testWidgets('AppMediaCard renders no Border in light theme', (
      tester,
    ) async {
      await _pump(
        tester,
        AppMediaCard(
          icon: Icons.directions_car_rounded,
          title: 'Ahmed · Camry',
          meta: 'Waiting parts · Due today',
          status: const AppStatusChip(
            label: 'Waiting parts',
            kind: AppStatusKind.error,
          ),
        ),
      );
      expect(_borderedCardDecorations(tester), isEmpty);
    });

    testWidgets('AppSurfaceCard outlined:false renders no Border', (
      tester,
    ) async {
      await _pump(
        tester,
        AppSurfaceCard(
          outlined: false,
          child: const Text('6 inspections due today'),
        ),
      );
      expect(_borderedCardDecorations(tester), isEmpty);
    });

    testWidgets('AppListGroup renders no Border in light theme', (
      tester,
    ) async {
      await _pump(
        tester,
        AppListGroup(
          title: 'Assigned to you',
          items: [
            AppListGroupItem(
              leadingIcon: Icons.directions_car_rounded,
              title: 'Ahmed · Camry',
              subtitle: 'Waiting parts · Due today',
              valueText: 'JC-1042',
              onTap: () {},
            ),
            AppListGroupItem(
              leadingIcon: Icons.directions_car_rounded,
              title: 'Layla · Yaris',
              subtitle: 'In progress · 09:15 AM',
              valueText: 'JC-1041',
              onTap: () {},
            ),
          ],
        ),
      );
      expect(_borderedCardDecorations(tester), isEmpty);
    });
  });

  group('hard-reject (b): no uppercase transform in header/hero path', () {
    testWidgets('AppPageHeader keeps cased input as-is', (tester) async {
      await _pump(
        tester,
        const AppPageHeader(
          title: 'Good to see you, Omar',
          subtitle: 'Branch A · Morning shift',
        ),
      );
      // Cased input must never render as ALL CAPS Latin (the eyebrow
      // slot upper-cases, so headers pass no eyebrow — enforced here).
      expect(_allCapsTexts(tester), isEmpty);
      expect(find.text('Good to see you, Omar'), findsOneWidget);
      expect(find.text('Branch A · Morning shift'), findsOneWidget);
    });

    testWidgets('hero-style card copy stays sentence case', (tester) async {
      await _pump(
        tester,
        const AppSurfaceCard(
          outlined: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('6 inspections due today'),
              Text("Review what's urgent first."),
            ],
          ),
        ),
      );
      expect(_allCapsTexts(tester), isEmpty);
      expect(find.text('6 inspections due today'), findsOneWidget);
    });
  });

  group('hard-reject (c): tap targets >= 48dp', () {
    testWidgets('AppPillButton hit areas (all sizes)', (tester) async {
      for (final size in AppPillButtonSize.values) {
        await _pump(
          tester,
          SizedBox(
            width: 300,
            child: AppPillButton.primary(
              label: 'View jobs',
              onPressed: () {},
              size: size,
            ),
          ),
        );
        final box = tester.getRect(find.byType(AppPillButton));
        expect(box.height, greaterThanOrEqualTo(48.0));
        expect(box.width, greaterThanOrEqualTo(48.0));
      }
    });

    testWidgets('AppIconButton hit area is 48x48', (tester) async {
      await _pump(
        tester,
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
          tooltip: 'Notifications',
        ),
      );
      final box = tester.getRect(find.byType(AppIconButton));
      expect(box.height, greaterThanOrEqualTo(48.0));
      expect(box.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('tiles: AppTileRow whole row >= 48dp', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: AppTileRow(
            title: 'Ahmed · Camry',
            subtitle: 'Waiting parts · Due today',
          ),
        ),
      );
      final box = tester.getRect(find.byType(AppTileRow));
      expect(box.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('hard-reject (d): badge offset outside its icon', () {
    testWidgets('AppBadge rect is disjoint from the icon glyph', (
      tester,
    ) async {
      await _pump(
        tester,
        // Same offset-outside pattern used by the screens: the badge
        // floats above the hit-area corner, disjoint from the centered
        // 20px glyph (the 48dp hit area itself is allowed to underlap —
        // the glyph is what must stay uncovered).
        Stack(
          clipBehavior: Clip.none,
          children: [
            AppIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: () {},
              tooltip: 'Notifications',
            ),
            const PositionedDirectional(
              top: -8,
              end: -6,
              child: AppBadge(count: 3, kind: AppBadgeKind.error),
            ),
          ],
        ),
      );
      final glyphBox = tester.getRect(
        find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byType(Icon),
        ),
      );
      expect(glyphBox.width, 20.0);
      final badgeBox = tester.getRect(find.byType(AppBadge));
      expect(
        glyphBox.overlaps(badgeBox),
        isFalse,
        reason: 'badge $badgeBox overlaps glyph $glyphBox',
      );
    });
  });
}
