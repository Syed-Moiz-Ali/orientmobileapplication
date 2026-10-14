import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 07 — centralized theme architecture guard for the vehicle intake
/// studio (scan HUD, intake wizard, telemetry check-in, delivery handover,
/// brand/model pickers, signature pad).
///
/// Every Phase 07-owned production widget must resolve colour through the
/// active theme (`Theme.of(context).colorScheme` / `context.semanticColors`),
/// never by selecting a static light/dark palette (`AppColors.*` /
/// `AppDarkColors.*`), hardcoding a hex literal, or branching on `Brightness`.
///
/// Fixed-ink discipline: any `Colors.*` usage must carry a `FIXED-INK` or
/// `OPTICAL-HUD` justification marker on the same line or within the six
/// preceding lines (optical viewfinder ink over the black camera stage, or
/// non-rendered PNG export bytes). `Colors.transparent` is exempt — it is
/// the absence of colour, not a colour choice.
void main() {
  const owned = <String>[
    'lib/features/advisor/presentation/pages/scan_vehicle_view.dart',
    'lib/features/advisor/presentation/pages/vehicle_customer_view.dart',
    'lib/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart',
    'lib/features/advisor/presentation/pages/vehicle_delivery_view.dart',
    'lib/features/advisor/presentation/widgets/select_brand_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_signature_pad.dart',
  ];

  test('advisor Phase 07 widgets never select a static palette', () {
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
        reason: 'Phase 07-owned file is missing: $relative',
      );
      final source = file.readAsStringSync();
      final hasPalette =
          source.contains('AppColors.') ||
          source.contains('AppDarkColors') ||
          source.contains(RegExp(r'Color\(0x'));
      // `Brightness` may only be used for documented OS system-chrome styling;
      // the intake studio has no such case, so any occurrence is a violation.
      final hasBrightness = source.contains('Brightness.');
      if (hasPalette || hasBrightness) {
        offenders.add(relative);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Advisor Phase 07 widgets must consume the active theme, not a static '
          'palette, hardcoded hex, or a Brightness branch:\n${offenders.join('\n')}',
    );
  });

  test('advisor Phase 07 fixed ink is explicitly justified', () {
    final unjustified = <String>[];
    final fixedInk = RegExp(r'(?<!semantic)Colors\.(?!transparent)');
    for (final relative in owned) {
      final lines = File(relative).readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (!fixedInk.hasMatch(lines[i])) continue;
        final windowStart = (i - 6).clamp(0, lines.length);
        final window = lines.sublist(windowStart, i + 1).join('\n');
        if (!window.contains('FIXED-INK') &&
            !window.contains('OPTICAL-HUD')) {
          unjustified.add('$relative:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(
      unjustified,
      isEmpty,
      reason:
          'Fixed `Colors.*` ink must carry a FIXED-INK / OPTICAL-HUD '
          'justification marker within the six preceding lines:\n'
          '${unjustified.join('\n')}',
    );
  });
}
