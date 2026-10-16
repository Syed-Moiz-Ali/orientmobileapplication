import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 10 — responsive class-system guard for the technician console.
///
/// Breakpoints live in exactly one file
/// (`packages/shared_core/lib/src/layout/app_responsive.dart`). Phase
/// 10-owned files must branch through the window class — never through raw
/// `MediaQuery.sizeOf(context).width` comparisons or hardcoded width
/// literals.
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

  test('technician console never reads raw viewport widths', () {
    expect(
      Directory('lib/features/technician').existsSync(),
      isTrue,
      reason: 'run from the staff_app root',
    );

    final rawWidth = RegExp(r'MediaQuery\s*\.\s*(sizeOf|of)\s*\(context\)');
    final offenders = <String>[];
    for (final relative in owned) {
      final source = File(relative).readAsStringSync();
      // Allowed MediaQuery uses (non-width): viewInsets, disableAnimations,
      // padding, devicePixelRatio. Width reads are the violation.
      final widthRead = RegExp(
        r'MediaQuery\s*\.\s*(sizeOf|of)\s*\(context\)[^;]*?\.width',
      );
      if (rawWidth.hasMatch(source) && widthRead.hasMatch(source)) {
        offenders.add('$relative (raw MediaQuery width read)');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Breakpoints live in app_responsive.dart — use context.isCompact / '
          'isExpanded / isLarge, adaptive.pick() or AppAdaptiveBuilder:\n'
          '${offenders.join('\n')}',
    );
  });

  test('technician console has no hardcoded breakpoint literals', () {
    // Bare width comparisons against class boundaries. Geometry math
    // (Size(maxWidth, h), flexes, paddings) and non-breakpoint numbers
    // (48dp targets, counts, durations) are not violations.
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
      reason:
          'Hardcoded breakpoint literal — route through the window class:\n'
          '${offenders.join('\n')}',
    );
  });
}
