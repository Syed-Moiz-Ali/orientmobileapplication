import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:customer_app/l10n/gen/customer_localizations_en.dart';
import 'package:flutter/widgets.dart';

/// Null-safe localization access for customer surfaces.
///
/// Production always provides the delegate (see `main.dart`), so the live
/// app resolves the device locale. Widget tests that pump screens without
/// delegates fall back to the English template — the same `t?.x ?? '…'
/// precedent the routers already use — instead of crashing. Every string
/// still lives in the ARB files with exact EN/AR parity; the fallback only
/// mirrors the template.
extension CustomerL10nContext on BuildContext {
  CustomerLocalizations get cx =>
      CustomerLocalizations.of(this) ?? CustomerLocalizationsEn();
}
