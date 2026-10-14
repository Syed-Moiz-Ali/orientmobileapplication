import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 01.2 — bespoke-bar deprecation guard.
///
/// `AppTopBar`, `CustomerTopBar` and `GradientBanner` are deprecated in favour
/// of `WorkspaceAppBar` / `AppPageHeader`. Existing callers owned by Phases
/// 06–20 stay on the allowlist below; any *new* file referencing the legacy
/// bars fails the build.
void main() {
  // Files that already consume the legacy bars (owned by their V2 phases).
  // Additions here require the owning phase's sign-off.
  const allowed = {
    // The deprecated widgets themselves + their compatibility exports.
    'app_top_bar.dart',
    'gradient_banner.dart',
    'shared_core.dart',
    // Intentional localization coverage of the deprecated bar.
    'localized_shared_widgets_test.dart',
    // This guard itself names the legacy bars in its pattern/allowlist.
    'deprecation_guard_test.dart',
    // Phase 01.2 golden gallery (documents the deprecated surface once).
    'phase01_2_gallery.dart',
    // Existing feature callers (migrate in Phases 06–20, never extend).
    'customer_invoice_detail_view.dart',
    'customer_feedback_view.dart',
    'customer_breakdown_result_view.dart',
    'customer_breakdown_help_view.dart',
    'customer_book_service_view.dart',
    'customer_booking_detail_view.dart',
    'customer_approvals_page.dart',
    'add_vehicle_view.dart',
    'customer_service_status_page.dart',
    'customer_notifications_view.dart',
    'vehicle_customer_view.dart',
    'advisor_vehicle_checkin_view.dart',
    'crm_header_banner.dart',
    // Frozen design-prototype doc reference (comment only, not a widget use).
    'proto_primitives.dart',
  };

  test('no new bespoke-bar usages beyond the allowlist', () {
    final roots = [
      Directory('../../apps'),
      Directory('../../packages'),
    ];
    final offenders = <String>[];
    final pattern = RegExp(
      r'\b(AppTopBar|CustomerTopBar|GradientBanner)\b',
    );
    for (final root in roots) {
      if (!root.existsSync()) continue;
      for (final entity in root.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final name = entity.uri.pathSegments.last;
        if (allowed.contains(name)) continue;
        // Concept showcase is a frozen visual reference — never production.
        if (entity.path.contains('concept_showcase')) continue;
        // Design docs / phase reports are not code.
        if (entity.path.contains('phases/')) continue;
        final source = entity.readAsStringSync();
        if (pattern.hasMatch(source)) offenders.add(entity.path);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'New bespoke-bar usage detected — use WorkspaceAppBar or '
          'AppPageHeader instead:\n${offenders.join('\n')}',
    );
  });

  test('deprecated bars carry @Deprecated annotations', () {
    final topBar =
        File('lib/src/widgets/app_top_bar.dart').readAsStringSync();
    final banner =
        File('lib/src/widgets/gradient_banner.dart').readAsStringSync();
    expect(topBar.contains("@Deprecated('Use WorkspaceAppBar"), isTrue);
    expect(banner.contains('@Deprecated('), isTrue);
  });
}
