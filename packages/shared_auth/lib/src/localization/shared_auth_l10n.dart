import 'package:flutter/widgets.dart';
import 'package:shared_auth/l10n/gen/shared_auth_localizations.dart';

/// Locale-aware accessor for `shared_auth`'s copy.
///
/// Mirrors `SharedCoreL10n`: reads the registered [SharedAuthLocalizations] and
/// falls back to the English bundle when no delegate is present (bare unit-test
/// harnesses), so auth widgets stay independently testable while apps always
/// get the active locale's copy.
abstract final class SharedAuthL10n {
  SharedAuthL10n._();

  static final SharedAuthLocalizations _english =
      lookupSharedAuthLocalizations(const Locale('en'));

  static SharedAuthLocalizations of(BuildContext context) {
    return Localizations.of<SharedAuthLocalizations>(
          context,
          SharedAuthLocalizations,
        ) ??
        _english;
  }

  /// Looks up copy for [locale] without a [BuildContext]. Used by Riverpod
  /// notifiers (for example login validation) that run outside the widget tree.
  static SharedAuthLocalizations forLocale(Locale? locale) {
    if (locale?.languageCode == 'ar') {
      return lookupSharedAuthLocalizations(const Locale('ar'));
    }
    return _english;
  }
}
