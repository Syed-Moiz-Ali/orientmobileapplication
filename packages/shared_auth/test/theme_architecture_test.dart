import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 05 — centralized theme architecture guard for `shared_auth`.
///
/// Mirrors the `shared_core` guard: authentication widgets must resolve colour
/// through the active theme (`Theme.of(context).colorScheme` /
/// `context.semanticColors`), never by selecting a static light/dark palette or
/// hardcoding hex. The only permitted `Brightness` use is genuine OS
/// system-chrome style (`auth_surface.dart` status-bar icon brightness).
void main() {
  test('auth presentation widgets never select a static palette', () {
    final dir = Directory('lib/src/presentation');
    expect(dir.existsSync(), isTrue, reason: 'run from shared_auth root');

    final paletteOffenders = <String>[];
    final brightnessOffenders = <String>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final name = entity.uri.pathSegments.last;
      final source = entity.readAsStringSync();
      if (source.contains('AppColors.') ||
          source.contains('AppDarkColors') ||
          source.contains('Color(0x')) {
        paletteOffenders.add(name);
      }
      // `Brightness` is only allowed for the documented system-chrome style.
      if (source.contains('Brightness.') && name != 'auth_surface.dart') {
        brightnessOffenders.add(name);
      }
    }

    expect(
      paletteOffenders,
      isEmpty,
      reason:
          'Auth widgets must consume the active theme, not a static palette '
          'or hardcoded hex:\n${paletteOffenders.join('\n')}',
    );
    expect(
      brightnessOffenders,
      isEmpty,
      reason:
          'Only auth_surface.dart may use Brightness (system status-bar chrome):'
          '\n${brightnessOffenders.join('\n')}',
    );
  });
}
