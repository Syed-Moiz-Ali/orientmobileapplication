import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 09 — centralized theme architecture guard for the repair estimates
/// studio.
///
/// Every Phase 09-owned production file must resolve colour through the
/// active theme (`Theme.of(context).colorScheme` / `context.semanticColors`),
/// never by selecting a static light/dark palette (`AppColors.*` /
/// `AppDarkColors.*`) or branching on `Brightness`.
///
/// `Color(0x…)` / `Colors.*` survive only for the signature document
/// artifact (black ink on white paper PNG export) carrying a `FIXED-INK`
/// justification within 8 lines above, or for `Colors.transparent`.
void main() {
  const owned = <String>[
    'lib/features/advisor/presentation/pages/repair_order_view.dart',
    'lib/features/advisor/presentation/pages/advisor_assign_tasks_view.dart',
    'lib/features/advisor/presentation/widgets/repair_estimate_math.dart',
    'lib/features/advisor/presentation/widgets/repair_price_breakdown_dock.dart',
    'lib/features/advisor/presentation/widgets/repair_estimate_share_sheet.dart',
  ];

  test('repair estimates never select a static palette', () {
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
        reason: 'Phase 09-owned file is missing: $relative',
      );
      final source = file.readAsStringSync();
      final hasPalette =
          source.contains('AppColors.') ||
          source.contains('AppDarkColors');
      final hasBrightness = source.contains('Brightness.');
      if (hasPalette || hasBrightness) {
        offenders.add(relative);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Repair estimates must consume the active theme, not a static '
          'palette or a Brightness branch:\n${offenders.join('\n')}',
    );
  });

  test('hex literals and Colors.* appear only with a FIXED-INK justification',
      () {
    final offenders = <String>[];
    final hexRef = RegExp(r'Color\(0x');
    final colorsRef = RegExp(r'(?<![A-Za-z])Colors\.');
    for (final relative in owned) {
      final lines = File(relative).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final isHex = hexRef.hasMatch(line);
        final isColors = colorsRef.hasMatch(line);
        if (!isHex && !isColors) continue;
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
          'Every Color(0x…) / Colors.* usage must carry a FIXED-INK '
          'justification within 8 lines above:\n${offenders.join('\n')}',
    );
  });
}
