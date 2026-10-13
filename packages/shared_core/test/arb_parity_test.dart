import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Anti-drift guard for `shared_core`'s localization resources.
///
/// Fails when the EN and AR key sets differ, when a template key has no
/// `@description`, or when `flutter gen-l10n` reports untranslated messages.
void main() {
  test('shared_core ARB parity + no untranslated messages', () {
    final en = _read('lib/l10n/app_en.arb');
    final ar = _read('lib/l10n/app_ar.arb');

    final enKeys = _keys(en);
    final arKeys = _keys(ar);

    expect(
      arKeys.difference(enKeys),
      isEmpty,
      reason: 'Arabic has keys missing from the English template',
    );
    expect(
      enKeys.difference(arKeys),
      isEmpty,
      reason: 'English keys are missing an Arabic translation',
    );

    for (final key in enKeys) {
      expect(
        en['@$key'],
        isNotNull,
        reason: 'Missing @description for template key "$key"',
      );
    }

    final untranslated = File('l10n_untranslated.json');
    if (untranslated.existsSync()) {
      final decoded = jsonDecode(untranslated.readAsStringSync());
      expect(
        decoded,
        isEmpty,
        reason: 'flutter gen-l10n reported untranslated messages',
      );
    }
  });
}

Map<String, dynamic> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();
