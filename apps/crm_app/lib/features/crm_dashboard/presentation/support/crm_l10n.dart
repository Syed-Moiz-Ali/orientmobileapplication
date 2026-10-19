import 'package:crm_app/l10n/gen/crm_localizations.dart';
import 'package:crm_app/l10n/gen/crm_localizations_en.dart';
import 'package:flutter/widgets.dart';

/// Null-safe localization access for CRM surfaces.
///
/// Production always provides the delegate (see `main.dart`), so the live
/// app resolves the device locale. Widget tests that pump screens without
/// delegates fall back to the English template instead of crashing. Every
/// string still lives in the ARB files with exact EN/AR parity; the fallback
/// only mirrors the template.
extension CrmL10nContext on BuildContext {
  CrmLocalizations get cx =>
      CrmLocalizations.of(this) ?? CrmLocalizationsEn();
}
