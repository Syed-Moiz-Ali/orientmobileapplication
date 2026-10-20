// TOKEN SWATCH CAPTURE (phase-0b proof).
//
// Renders every new 0b token — accent family, info-teal family, semantic
// success/warning/error neighbors — with WCAG AA ratios computed at runtime
// and PRINTED IN THE IMAGE. Tagged baseline: excluded from default runs.
//
// Run (from packages/shared_core):
//   flutter test --tags baseline --update-goldens test/token_swatch_capture_test.dart   (generate)
//   flutter test --tags baseline test/token_swatch_capture_test.dart                    (compare)
//
// The key AA pairs are ALSO asserted: a failing ratio fails the test, so a
// future token change that breaks contrast cannot slip through.
@Tags(['baseline'])
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Exact WCAG 2.x relative luminance (sRGB 0..1 components).
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

String _r(Color a, Color b) => '${_ratio(a, b).toStringAsFixed(2)}:1';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.sublistView(bytes)),
      );
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

Widget _swatch({
  required String title,
  required ThemeData theme,
  required bool dark,
}) {
  final tokens = dark ? AppTokens.dark : AppTokens.light;
  final canvas = dark ? const Color(0xFF090B10) : const Color(0xFFFBFBFD);
  final ink = dark ? Colors.white : const Color(0xFF0F172A);
  final muted = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  // Real on-accent ink per theme (light: white text; dark: dark ink on the
  // bright primary — the Phase 01.1 amendment). Never invent combos.
  final onAccent = dark ? const Color(0xFF090B10) : Colors.white;

  Widget label(String text, {Color? color, bool bold = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: TextStyle(
            color: color ?? ink,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      );

  Widget chip(Color bg, Color border, Color fg, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );

  Widget dot(Color color, String text, {Color? fg}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: fg ?? ink,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  Widget button(Color bg, Color fg, String text, String ratio) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$text  •  $ratio',
          textAlign: TextAlign.center,
          style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      );

  final sem =
      dark ? AppSemanticColors.dark : AppSemanticColors.light;

  return Container(
    color: canvas,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label(title, bold: true),
        label('accent #215FE6 family (brand, unchanged hue)', color: muted),
        button(
          tokens.accent,
          onAccent,
          'Continue',
          'on-accent ${_r(onAccent, tokens.accent)}',
        ),
        const SizedBox(height: 8),
        button(
          tokens.accentPressed,
          tokens.accentPressedInk,
          'Pressed',
          'pressed ink ${_r(tokens.accentPressedInk, tokens.accentPressed)}',
        ),
        const SizedBox(height: 8),
        chip(
          tokens.accentSoft,
          tokens.accent,
          tokens.accentInk,
          'Accent soft chip  •  ink on soft ${_r(tokens.accentInk, tokens.accentSoft)}',
        ),
        const SizedBox(height: 20),
        label('info teal #0E7490 family (NEW semantic resolution)',
            color: muted),
        chip(
          tokens.infoSoft,
          tokens.infoBorder,
          tokens.infoInk,
          'In progress  •  ink on soft ${_r(tokens.infoInk, tokens.infoSoft)}',
        ),
        const SizedBox(height: 8),
        dot(
          tokens.infoBase,
          'dot on canvas ${_r(tokens.infoBase, canvas)}  •  white ref ${_r(Colors.white, tokens.infoBase)}',
        ),
        const SizedBox(height: 20),
        label('neighbors: success / warning / error vs info', color: muted),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            chip(sem.success.subtle, sem.success.border, sem.success.ink,
                'Success'),
            chip(sem.warning.subtle, sem.warning.border, sem.warning.ink,
                'Warning'),
            chip(sem.danger.subtle, sem.danger.border, sem.danger.ink,
                'Error'),
            chip(tokens.infoSoft, tokens.infoBorder, tokens.infoInk, 'Info'),
          ],
        ),
        const SizedBox(height: 20),
        label('text samples', color: muted),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: tokens.accent,
          child: Text(
            'Text on accent  •  ${_r(onAccent, tokens.accent)}',
            style: TextStyle(
              color: onAccent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.infoSoft,
            border: Border.all(color: tokens.infoBorder),
          ),
          child: Text(
            'Text on info soft  •  ${_r(tokens.infoInk, tokens.infoSoft)}',
            style: TextStyle(
              color: tokens.infoInk,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  setUpAll(() async {
    await _loadFonts();
    debugPrint('swatch: fonts ready');
  });

  testWidgets('token swatch light', (tester) async {
    final oldShadows = debugDisableShadows;
    debugDisableShadows = false;
    // Tall surface: swatch scrolls in production but goldens capture one
    // frame, so give it room (390 x 1300 @3x).
    tester.view.physicalSize = const Size(1170, 3900);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Asserted AA gates (fail the test on regression).
    expect(_ratio(Colors.white, AppColors.primary), greaterThanOrEqualTo(4.5));
    expect(_ratio(AppColors.primary, const Color(0xFFFBFBFD)),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(AppColors.accentPressedInk, AppColors.accentPressed),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(AppColors.accentInk, AppColors.accentSoft),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(Colors.white, AppColors.infoTeal),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(AppColors.infoTeal, const Color(0xFFFBFBFD)),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(AppColors.infoTealInk, AppColors.infoTealSoft),
        greaterThanOrEqualTo(4.5));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(BrandConfig.orient),
        home: Scaffold(
          body: SingleChildScrollView(
            child: _swatch(
              title: 'Token swatch — LIGHT (phase-0b)',
              theme: AppTheme.light(BrandConfig.orient),
              dark: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../../../docs/ui-redesign/baseline/token_swatch_light.png',
      ),
    );
    debugDisableShadows = oldShadows;
  });

  testWidgets('token swatch dark', (tester) async {
    final oldShadows = debugDisableShadows;
    debugDisableShadows = false;
    tester.view.physicalSize = const Size(1170, 3900);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    expect(_ratio(AppDarkColors.onPrimary, AppDarkColors.primary),
        greaterThanOrEqualTo(4.5));
    // Pressed flips to white ink: dark ink on the pressed fill is only
    // 3.81:1 (pre-existing shipped behavior until buttons adopt pressed ink).
    expect(_ratio(AppDarkColors.accentPressedInk, AppDarkColors.accentPressed),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(AppDarkColors.infoTealInk, AppDarkColors.infoTealSoft),
        greaterThanOrEqualTo(4.5));
    expect(_ratio(AppDarkColors.accentInk, AppDarkColors.accentSoft),
        greaterThanOrEqualTo(4.5));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(BrandConfig.orient),
        darkTheme: AppTheme.dark(BrandConfig.orient),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: _swatch(
              title: 'Token swatch — DARK (phase-0b)',
              theme: AppTheme.dark(BrandConfig.orient),
              dark: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../../../docs/ui-redesign/baseline/token_swatch_dark.png',
      ),
    );
    debugDisableShadows = oldShadows;
  });
}
