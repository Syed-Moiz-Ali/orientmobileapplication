import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 08 — centralized theme architecture guard for the staff inspection
/// HUD & evidence workspace.
///
/// Every Phase 08-owned production file must resolve colour through the
/// active theme (`Theme.of(context).colorScheme` / `context.semanticColors`),
/// never by selecting a static light/dark palette (`AppColors.*` /
/// `AppDarkColors.*`), hardcoding a hex literal, or branching on
/// `Brightness`.
///
/// `Colors.*` is allowed only with a `FIXED-INK` justification comment within
/// 8 lines above (white glyphs on saturated status fills, scrims over user
/// media) or for `Colors.transparent`. Later phases (estimates 09 and the
/// shared `inspection_widgets.dart` helpers owned by repair_order_view) keep
/// their own migration and are intentionally NOT listed here.
void main() {
  const owned = <String>[
    'lib/features/advisor/presentation/pages/choose_inspection_view.dart',
    'lib/features/advisor/presentation/pages/inspection_sheet_view.dart',
    'lib/features/advisor/presentation/pages/inspection_preview_view.dart',
    'lib/features/advisor/presentation/pages/real_damage_canvas.dart',
    'lib/features/advisor/presentation/pages/damage_detail_sheet.dart',
    'lib/features/advisor/inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart',
  ];

  test('inspection HUD widgets never select a static palette', () {
    expect(
      Directory('lib/features/advisor').existsSync(),
      isTrue,
      reason: 'run from the staff_app root',
    );

    final offenders = <String>[];
    for (final relative in owned) {
      final file = File(relative);
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Phase 08-owned file is missing: $relative',
      );
      final source = file.readAsStringSync();
      final hasPalette =
          source.contains('AppColors.') ||
          source.contains('AppDarkColors') ||
          source.contains(RegExp(r'Color\(0x'));
      final hasBrightness = source.contains('Brightness.');
      if (hasPalette || hasBrightness) {
        offenders.add(relative);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Inspection HUD widgets must consume the active theme, not a static '
          'palette, hardcoded hex, or a Brightness branch:\n${offenders.join('\n')}',
    );
  });

  test('Colors.* appears only with a FIXED-INK justification', () {
    final offenders = <String>[];
    for (final relative in owned) {
      final lines = File(relative).readAsLinesSync();
      final colorsRef = RegExp(r'(?<![A-Za-z])Colors\.');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!colorsRef.hasMatch(line)) continue;
        if (line.contains('Colors.transparent')) continue;
        var justified = false;
        for (var j = i - 1; j >= 0 && j >= i - 8; j--) {
          if (lines[j].contains('FIXED-INK')) {
            justified = true;
            break;
          }
        }
        if (!justified) {
          offenders.add('$relative:${i + 1}: $line');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Every Colors.* usage must carry a FIXED-INK justification within '
          '8 lines above:\n${offenders.join('\n')}',
    );
  });
}
