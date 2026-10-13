import 'package:flutter/widgets.dart';
import 'package:shared_core/l10n/gen/shared_core_localizations.dart';

/// Locale-aware accessor for `shared_core`'s own copy.
///
/// Reads the [SharedCoreLocalizations] registered by the host application. When
/// no delegate is registered (for example in a bare unit-test harness that only
/// pumps the shared widget) it falls back to the English bundle so shared
/// widgets keep rendering their canonical English defaults instead of throwing.
///
/// Applications always register `SharedCoreLocalizations.delegate`, so the
/// fallback is never used in production; it exists purely so shared components
/// remain independently testable.
abstract final class SharedCoreL10n {
  SharedCoreL10n._();

  static final SharedCoreLocalizations _english =
      lookupSharedCoreLocalizations(const Locale('en'));

  static SharedCoreLocalizations of(BuildContext context) {
    return Localizations.of<SharedCoreLocalizations>(
          context,
          SharedCoreLocalizations,
        ) ??
        _english;
  }
}
