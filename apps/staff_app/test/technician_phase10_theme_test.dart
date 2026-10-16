import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 10 — centralized theme architecture guard for the technician
/// execution console.
///
/// Every Phase 10-owned production file must resolve colour through the
/// active theme (`Theme.of(context).colorScheme` / `context.semanticColors`),
/// never by selecting a static light/dark palette (`AppColors.*` /
/// `AppDarkColors.*`) or branching on `Brightness`. (The frozen domain
/// entities keep their own palette getters as byte-identical contracts and
/// are intentionally NOT listed here.)
///
/// `Colors.*` survives only with a `FIXED-INK` justification within 8 lines
/// above (white glyphs on saturated grease fills) or for
/// `Colors.transparent`.
void main() {
  const owned = <String>[
    'lib/features/technician/presentation/technician_dashboard_view.dart',
    'lib/features/technician/presentation/widgets/technician_today_view.dart',
    'lib/features/technician/presentation/widgets/technician_jobs_view.dart',
    'lib/features/technician/presentation/widgets/technician_productivity_view.dart',
    'lib/features/technician/presentation/widgets/technician_components.dart',
    'lib/features/technician/presentation/widgets/job_detail_sheet.dart',
    'lib/features/technician/presentation/widgets/parts_request_sheet.dart',
    'lib/features/technician/presentation/widgets/escalation_sheet.dart',
  ];

  test('technician console never selects a static palette', () {
    expect(
      Directory('lib/features/technician').existsSync(),
      isTrue,
      reason: 'run from the staff_app root',
    );

    final offenders = <String>[];
    for (final relative in owned) {
      final file = File(relative);
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Phase 10-owned file is missing: $relative',
      );
      final source = file.readAsStringSync();
      final hasPalette =
          source.contains('AppColors.') || source.contains('AppDarkColors');
      final hasBrightness = source.contains('Brightness.');
      if (hasPalette || hasBrightness) {
        offenders.add(relative);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Technician console must consume the active theme, not a static '
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
