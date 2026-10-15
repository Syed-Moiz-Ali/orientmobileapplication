import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 06 — centralized theme architecture guard for the advisor hub.
///
/// Every Phase 06-owned production widget must resolve colour through the
/// active theme (`Theme.of(context).colorScheme` / `context.semanticColors`),
/// never by selecting a static light/dark palette (`AppColors.*` /
/// `AppDarkColors.*`), hardcoding a hex literal, or branching on `Brightness`.
///
/// Scope: only the surfaces this phase owns (advisor hub pages, sheets and
/// dialogs). Later-phase advisor sub-features (intake 07, inspection HUD 08,
/// estimates 09) keep their own palette migration and are intentionally NOT
/// listed here.
void main() {
  const owned = <String>[
    'lib/features/advisor/presentation/pages/advisor_home_view.dart',
    'lib/features/advisor/presentation/pages/advisor_jobs_view.dart',
    'lib/features/advisor/presentation/pages/advisor_reports_view.dart',
    'lib/features/advisor/presentation/pages/advisor_job_detail_view.dart',
    'lib/features/advisor/presentation/widgets/advisor_search_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_notification_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_profile_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_contact_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_approval_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_job_card_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_stat_dialog.dart',
    'lib/features/advisor/presentation/widgets/advisor_sheet.dart',
    'lib/features/advisor/presentation/widgets/advisor_handle.dart',
    'lib/features/advisor/presentation/widgets/advisor_detail_line.dart',
    'lib/features/advisor/presentation/widgets/advisor_outline_action.dart',
    'lib/features/advisor/presentation/widgets/advisor_solid_action.dart',
    'lib/features/advisor/presentation/widgets/advisor_contact_option.dart',
    'lib/features/advisor/presentation/widgets/advisor_menu_item.dart',
    'lib/features/advisor/presentation/widgets/advisor_divider.dart',
    'lib/features/advisor/presentation/widgets/advisor_notification_row.dart',
    'lib/features/advisor/presentation/widgets/advisor_job_card_row.dart',
    'lib/features/advisor/presentation/widgets/advisor_status.dart',
    'lib/features/advisor/presentation/widgets/advisor_approval_row.dart',
    // Phase 07.1: `advisor_meta_pill.dart` was deleted (migrated to shared
    // StatusPill) — it no longer belongs on this list.
  ];

  test('advisor Phase 06 widgets never select a static palette', () {
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
        reason: 'Phase 06-owned file is missing: $relative',
      );
      final source = file.readAsStringSync();
      final hasPalette =
          source.contains('AppColors.') ||
          source.contains('AppDarkColors') ||
          source.contains(RegExp(r'Color\(0x'));
      // `Brightness` may only be used for documented OS system-chrome styling;
      // the advisor hub has no such case, so any occurrence is a violation.
      final hasBrightness = source.contains('Brightness.');
      if (hasPalette || hasBrightness) {
        offenders.add(relative);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Advisor Phase 06 widgets must consume the active theme, not a static '
          'palette, hardcoded hex, or a Brightness branch:\n${offenders.join('\n')}',
    );
  });
}
