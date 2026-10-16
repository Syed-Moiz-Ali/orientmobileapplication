import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 11 — responsive class-system guard for the supervisor workspace.
///
/// Breakpoints live in exactly one file
/// (`packages/shared_core/lib/src/layout/app_responsive.dart`). Supervisor
/// presentation code must branch through the window class — never through raw
/// `MediaQuery` width reads or hardcoded breakpoint literals.
void main() {
  const owned = <String>[
    'lib/features/supervisor/presentation/supervisor_dashboard_view.dart',
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

  test('supervisor presentation never reads raw viewport widths', () {
    expect(
      Directory('lib/features/supervisor').existsSync(),
      isTrue,
      reason: 'run from the staff_app root',
    );
    final offenders = <String>[];
    for (final relative in owned) {
      final source = File(relative).readAsStringSync();
      final widthRead = RegExp(
        r'MediaQuery\s*\.\s*(sizeOf|of)\s*\(context\)[^;]*?\.width',
      );
      if (widthRead.hasMatch(source)) {
        offenders.add('$relative (raw MediaQuery width read)');
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Breakpoints live in app_responsive.dart — use context.isCompact / '
          'adaptive.pick() / AppAdaptiveBuilder:\n${offenders.join('\n')}',
    );
  });

  test('supervisor presentation has no hardcoded breakpoint literals', () {
    final breakpoint = RegExp(
      r'(maxWidth|width)\s*(>=|>|<=|<)\s*(600|768|834|900|1000|1024|1280|1440)\b',
    );
    final offenders = <String>[];
    for (final relative in owned) {
      final lines = File(relative).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (breakpoint.hasMatch(lines[i])) {
          offenders.add('$relative:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Hardcoded breakpoint literal:\n${offenders.join('\n')}',
    );
  });
}
