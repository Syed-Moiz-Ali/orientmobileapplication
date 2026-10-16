import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 11 — centralized theme guard for the supervisor workspace.
///
/// Every owned production widget must resolve colour through the active theme
/// (`Theme.of(context).colorScheme` / `context.semanticColors`), never a static
/// palette (`AppColors.*` / `AppDarkColors.*`) or a `Brightness` branch. The
/// frozen providers/entities are intentionally NOT listed (they keep their own
/// domain palette as byte-identical contracts).
///
/// `Colors.*` survives only as `Colors.transparent` or with a `FIXED-INK`
/// justification within 8 lines above.
void main() {
  const owned = <String>[
    'lib/features/supervisor/presentation/supervisor_dashboard_view.dart',
    'lib/features/supervisor/presentation/supervisor_login_view.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_scaffold.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_dashboard_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_jobs_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_queue_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_review_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_reports_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_staff_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_schedule_tab.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_assign_sheet.dart',
    'lib/features/supervisor/presentation/widgets/qc_checklist_sheet.dart',
    'lib/features/supervisor/presentation/widgets/staff_notification_bell.dart',
    'lib/features/supervisor/presentation/widgets/supervisor_components.dart',
  ];

  test('supervisor widgets never select a static palette', () {
    expect(
      Directory('lib/features/supervisor').existsSync(),
      isTrue,
      reason: 'run from the staff_app root',
    );
    final offenders = <String>[];
    for (final relative in owned) {
      final file = File(relative);
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Phase 11-owned file is missing: $relative',
      );
      final source = file.readAsStringSync();
      if (source.contains('AppColors.') ||
          source.contains('AppDarkColors') ||
          source.contains('Brightness.')) {
        offenders.add(relative);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Supervisor widgets must consume the active theme, not a static '
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
