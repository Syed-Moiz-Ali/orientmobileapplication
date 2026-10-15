import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Bespoke-bar deprecation guard (Phase 01.2, extended Phase 07.1).
///
/// `AppTopBar`, `CustomerTopBar` and `GradientBanner` are deprecated in favour
/// of `WorkspaceAppBar` / `AppPageHeader`. Phase 07.1 migrated every
/// allowlisted caller, so the allowlist now holds only the definitions
/// themselves, intentional coverage, and frozen references — any other file
/// *using* the legacy bars fails the build.
///
/// The scan strips `//` line comments and `/* */` blocks first so prose
/// migration notes never trip it; only real code references count. A second
/// test fails on any bespoke `*AppBar` / `*HeaderBanner` *definition* in
/// `apps/` (the four product bars were deleted in Phase 07.1).
void main() {
  // Files that may still name the legacy bars (definitions, intentional
  // coverage, frozen references). Everything else must be clean.
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
    // Frozen design-prototype doc reference (comment only, not a widget use).
    'proto_primitives.dart',
    // Phase 07.1 migration verification files: they name the legacy bars
    // inside source-scan patterns (like this guard does), never render them.
    'phase07_1_migration_test.dart',
  };

  test('no bespoke-bar usages beyond the allowlist', () {
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
        final source = _stripComments(entity.readAsStringSync());
        if (pattern.hasMatch(source)) offenders.add(entity.path);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Bespoke-bar usage detected — use WorkspaceAppBar or '
          'AppPageHeader instead:\n${offenders.join('\n')}',
    );
  });

  test('no bespoke app-bar / header-banner definitions in apps/', () {
    final offenders = <String>[];
    final definition = RegExp(
      r'class\s+\w*(AppBar|HeaderBanner)\w*\s+extends',
    );
    for (final entity in Directory('../../apps').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Frozen references are never production code.
      if (entity.path.contains('concept_showcase')) continue;
      if (entity.path.contains('design_prototype')) continue;
      final source = _stripComments(entity.readAsStringSync());
      if (definition.hasMatch(source)) offenders.add(entity.path);
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Bespoke app-bar definition detected — compose WorkspaceAppBar '
          'instead:\n${offenders.join('\n')}',
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

/// Strips `//` line comments and `/* */` blocks so doc/prose mentions of
/// legacy names never count as usages.
String _stripComments(String source) {
  final withoutBlocks = source.replaceAll(
    RegExp(r'/\*.*?\*/', dotAll: true),
    '',
  );
  return withoutBlocks
      .split('\n')
      .map((line) {
        final index = line.indexOf('//');
        return index < 0 ? line : line.substring(0, index);
      })
      .join('\n');
}
